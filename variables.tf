variable "subscription_id" {
    type = string
    sensitive = true
}

variable "prefix" {
    type = string
}

variable "location" {
    type = string
}

variable "my_ip" {
    type = string
    sensitive = true
}

variable "db_login" {
    type = string
    sensitive = true
}

variable "db_password" {
    type = string
    sensitive = true
}

variable "beacon_image" {
    type = string
}

variable "admin_ssh_key" {
    type = string
}

variable "vm_size" {
    type = string
    default = "Standard_B2ats_v2"
}

variable "admin_username" {
    type = string
    sensitive = true
}

variable "db_name" {
    type = string
}