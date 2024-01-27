terraform {
  backend "gcs" {
    bucket = "ore-github-action-bucket"
    prefix = "githubAction"
  }
}