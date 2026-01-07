variable "zone" {
  type = string
}

variable "subnet_id" {
  description = "Subnet where VM will be placed"
  type        = string
}

variable "vm_count" {
  description = "Number of virtual machines"
  type        = number
}

variable "cores" {
  type = number
}

variable "memory" {
  type = number
}
