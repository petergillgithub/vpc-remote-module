variable "aws_vpc" {
    type = string
    default = null
}


variable "enable_dns_hostnames" {
    type = bool
    
}
variable "enable_dns_support" {
    type = bool
    
}
variable "comman_tags" {
    type = map(string)
    default = {
      "ManegedBy" = "Terraform"
      "Env" = "Dev"
    }
}

variable "publicsubnets" {
    type = list(string)
    default = null

  
}

variable "privatesubnets" {
    type = list(string)
    default = null

  
}
variable "availability_zone" {
    type = list(string)

    default = null
  
}