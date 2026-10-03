variable "ssh_public_key" {
  type        = string
  description = "Permanent root SSH public-key text shared with the NixOS configuration; never a private key."
}

variable "create_instance" {
  type        = bool
  default     = false
  description = "Create and associate the Tarkin EC2 instance after the empty host Age secret has been populated."
}
