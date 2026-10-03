variable "prefix" {
    type = string
}

variable "resource_group_name" {
    type = string
}

variable "location" {
    type = string
}

variable "db_login" {
    type = string
    sensitive = true
}

variable "db_password" {
    type = string
    sensitive = true
}

variable "vnet_id" {
    type = string
}

variable "subnet_db_id" {
    type = string
}