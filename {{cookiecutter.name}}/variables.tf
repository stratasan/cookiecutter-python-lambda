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

variable "vault_root" {
  default     = "secret/star/services/${terraform.workspace}"
  description = "Secrets under this path may be read by the function"
}

variable "zipfile" {
  default     = "lambda.zip"
  description = "filename of package produced by Make"
}
