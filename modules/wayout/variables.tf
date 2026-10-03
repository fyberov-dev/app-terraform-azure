variable "prefix" {
    type = string
}

variable "resource_group_name" {
    type = string
}

variable "location" {
    type = string
}

variable "locked" {
    type    = bool
    default = false
}

variable "subnet_app_id" {
    type = string
}

variable "subnet_service_id" {
    type = string
}