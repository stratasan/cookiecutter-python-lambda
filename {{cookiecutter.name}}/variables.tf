variable "sentry_dsn" {
  default     = "https://sentry.io"
  description = "sentry dsn for Lambda service, override with TF_VAR_sentry_dsn"
}

variable "timeout_sec" {
  default     = 60
  description = "Timeout for lambda function in seconds"
}

variable "memory_mb" {
  default     = 128
  description = "Memory allocated to the function in MB"
}
variable "runtime" {
  default     = "python3.7"
  description = "Lambda Runtime to use"
}

variable "vault_address" {
  default     = "https://not.really.vault.com"
  description = "URL for our Vault, override with TF_VAR_vault_address"
}

variable "upload_bucket" {
  description = "S3 bucket of lambda code package"
}

variable "upload_key" {
  description = "S3 key of lambda code package"
}
