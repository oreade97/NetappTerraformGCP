import base64
import sys
import json
import functions_framework
import math
from google.cloud import netapp_v1

# Percentage of the volume capacity to increase
capacity_to_increase = 20
# Threshold for used capacity percentage
used_capacity_threshold = 8
# Maximum allowable capacity for the storage pool (in GiB)
max_storage_pool_capacity = 10240  # Example: 10 TiB limit

def calculate_capacity(volume_capacity, total_storage_pool_capacity, used_storage_pool_capacity, percentage):
    available_storage_pool_capacity = total_storage_pool_capacity - used_storage_pool_capacity
    increase_capacity = math.ceil(volume_capacity * (percentage / 100))

    # If increase_capacity is greater than available_storage_pool_capacity,
    # increase the storage pool by exactly the increase_capacity amount
    if increase_capacity > available_storage_pool_capacity:
        total_storage_pool_capacity += increase_capacity

    volume_capacity += increase_capacity

    return volume_capacity, total_storage_pool_capacity


# Triggered from a message on a Cloud Pub/Sub topic.
@functions_framework.cloud_event
def netapp_volumes_autogrow(cloud_event):

    print("A NetApp Volumes capacity event has triggered the autogrow function.")
    message = base64.b64decode(cloud_event.data["message"]["data"]).decode()
    json_message = json.loads(message)

    # Print response
    print(json_message)


    # Check if state is "closed", if so, skip resizing
    state = json_message["incident"]["state"]
    if state == "closed":
        print("Incident state is 'closed'. Skipping the resize operation.")
        return  # Exit the function if state is "closed"
        
    myregion = json_message["incident"]["resource"]["labels"]["location"]
    myvolume = json_message["incident"]["resource"]["labels"]["name"]
    myproject = json_message["incident"]["resource"]["labels"]["resource_container"]

    # Create a client to get the volume information
    client = netapp_v1.NetAppClient()
    volume_name = f"projects/{myproject}/locations/{myregion}/volumes/{myvolume}"

    # Initialize request argument(s)
    request = netapp_v1.GetVolumeRequest(
        name=volume_name,
    )

    # Make the request
    response = client.get_volume(request=request)

    # Get the required information from the response
    myservicelevel = response.service_level
    myvolumecapacity = response.capacity_gib
    usedcapacity = response.used_gib

    mystoragepool = response.storage_pool

    # Create a client to get the storage pool information
    client = netapp_v1.NetAppClient()
    storagepool_name = f"projects/{myproject}/locations/{myregion}/storagePools/{mystoragepool}"

    # Initialize request argument(s)
    request = netapp_v1.GetStoragePoolRequest(
        name=storagepool_name,
    )

    # Make the request
    response = client.get_storage_pool(request=request)

    # Get the required information from the response
    mystoragepoolname = response.name
    mystoragepooltotalcapacity = response.capacity_gib
    mystoragepoolusedcapacity = response.volume_capacity_gib

    # Calculate the percentage of used volume capacity to total volume capacity
    used_capacity_percentage = (usedcapacity / myvolumecapacity) * 100 if myvolumecapacity > 0 else 0

    # Check if the used capacity percentage is less than the threshold
    if used_capacity_percentage < used_capacity_threshold:
        print(f"Used capacity percentage {used_capacity_percentage:.2f}% is less than the threshold {used_capacity_threshold}%. Skipping the resize operation.")
        return  # Skip resizing if used capacity percentage is less than 8%

    # Calculate the new volume and storage pool capacity
    new_volume_capacity, new_storage_pool_capacity = calculate_capacity(
        myvolumecapacity, 
        mystoragepooltotalcapacity, 
        mystoragepoolusedcapacity, 
        capacity_to_increase
    )

    # Check if the new storage pool capacity exceeds the maximum allowed capacity
    if new_storage_pool_capacity > max_storage_pool_capacity:
        print(f"New storage pool capacity {new_storage_pool_capacity} GiB exceeds the maximum limit of {max_storage_pool_capacity} GiB. Operation stopped.")
        return  # Stop the function if new capacity exceeds the maximum allowed

    # Continue with resizing logic
    print(f"The capacity of the storage pool {mystoragepoolname} is {mystoragepooltotalcapacity} GiB.")

    if new_storage_pool_capacity != mystoragepooltotalcapacity:
        print(f"The storage pool will be resized to {new_storage_pool_capacity} GiB.")

        # Initialize request argument(s) for updating the storage pool
        storage_pool = netapp_v1.StoragePool()
        storage_pool.name = mystoragepoolname
        storage_pool.capacity_gib = new_storage_pool_capacity

        request = netapp_v1.UpdateStoragePoolRequest(
            update_mask="capacityGib",
            storage_pool=storage_pool,
        )

        # Make the request to update the storage pool
        operation = client.update_storage_pool(request=request)

        # Wait for operation to complete
        response = operation.result()

    print(f"The capacity of the volume {volume_name} is {myvolumecapacity} GiB.")
    print(f"The volume will be resized to {new_volume_capacity} GiB.")

    # Initialize request argument(s) for updating the volume
    volume = netapp_v1.Volume()
    volume.name = volume_name
    volume.capacity_gib = new_volume_capacity

    request = netapp_v1.UpdateVolumeRequest(
        update_mask="capacityGib",
        volume=volume,
    )

    # Make the request to update the volume
    operation = client.update_volume(request=request)

    # Wait for operation to complete
    response = operation.result()

    # Handle the response
    print(f"Volume resize completed. New capacity: {new_volume_capacity} GiB.")
