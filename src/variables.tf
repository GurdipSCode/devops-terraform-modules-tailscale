variable "contact_email" {
  description = "Point of contact e-mail address" 
}
variable "tailscale_auth_key" {
  description = "Tailscale authentication key (auth key or OAuth client secret)"
  type        = string
  sensitive   = true
}

variable "hostname" {
  description = "Hostname to register in Tailscale"
  type        = string
}

variable "advertise_routes" {
  description = "List of subnet routes to advertise (CIDR notation)"
  type        = list(string)
  default     = []
}

variable "accept_routes" {
  description = "Accept subnet routes advertised by other nodes"
  type        = bool
  default     = false
}

variable "advertise_exit_node" {
  description = "Advertise this node as an exit node"
  type        = bool
  default     = false
}

variable "exit_node" {
  description = "Use a specific exit node (IP or hostname)"
  type        = string
  default     = ""
}

variable "advertise_tags" {
  description = "List of ACL tags to apply to this node"
  type        = list(string)
  default     = []
}

variable "enable_ssh" {
  description = "Enable Tailscale SSH server"
  type        = bool
  default     = false
}

variable "shields_up" {
  description = "Block incoming connections"
  type        = bool
  default     = false
}

variable "ephemeral" {
  description = "Register as an ephemeral node (removed when offline)"
  type        = bool
  default     = false
}

variable "preauth_key" {
  description = "Use a pre-authentication key instead of interactive login"
  type        = bool
  default     = true
}

variable "tailscale_version" {
  description = "Version of Tailscale to install"
  type        = string
  default     = "latest"
}

variable "login_server" {
  description = "Custom control server URL (for Headscale or self-hosted)"
  type        = string
  default     = ""
}

variable "state_dir" {
  description = "Directory to store Tailscale state"
  type        = string
  default     = "/var/lib/tailscale"
}

variable "extra_args" {
  description = "Additional arguments to pass to tailscale up"
  type        = list(string)
  default     = []
}
