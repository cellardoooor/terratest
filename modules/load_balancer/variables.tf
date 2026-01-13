variable "name" {
  description = "Load balancer name"
  type        = string
  default     = "load-balancer"
}

variable "subnet_id" {
  description = "Subnet ID for load balancer"
  type        = string
}

variable "targets" {
  description = "List of target IP addresses"
  type        = list(string)
  default     = []
}

variable "enable_https" {
  description = "Enable HTTPS listener (port 443)"
  type        = bool
  default     = false
}

variable "healthcheck_name" {
  description = "Health check name"
  type        = string
  default     = "http"
}

variable "healthcheck_port" {
  description = "Health check port"
  type        = number
  default     = 80
}

variable "healthcheck_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}