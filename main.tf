resource "aws_vpc" "main" {
    
    cidr_block = var.aws_vpc
    enable_dns_hostnames = var.enable_dns_hostnames
    enable_dns_support = var.enable_dns_support
    tags = merge(var.comman_tags,{
        "Name" = "Demo-VPC"
    })

  
}

resource "aws_subnet" "publicsubnets" {
    count = length(var.publicsubnets)
    vpc_id = aws_vpc.main.id
    cidr_block = element(var.publicsubnets,count.index)
    map_public_ip_on_launch = true
    availability_zone = element(var.availability_zone,count.index)
    tags = merge(var.comman_tags,{
        "Name" = "public-subnet ${count.index + 1}"
    })
  
}

resource "aws_subnet" "privatesubnets" {
    count = length(var.privatesubnets)
    vpc_id = aws_vpc.main.id
    cidr_block = element(var.privatesubnets,count.index)
    availability_zone = element(var.availability_zone,count.index)
    tags = merge(var.comman_tags,{
        "Name" = "private-subnet ${count.index + 1}"
    })
  
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = merge(var.comman_tags,{
        "Name" = "Internet-Gate-Way"
    })
  
}

resource "aws_route_table" "publicrt" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"

        gateway_id = aws_internet_gateway.igw.id
    }
    tags = merge(var.comman_tags,{
        "Name" = "public-Rt"
    })
  
}

resource "aws_route_table_association" "publicrtassociate" {
    count = length(var.publicsubnets)
    subnet_id = element(aws_subnet.publicsubnets[*].id,count.index)
    route_table_id = aws_route_table.publicrt.id
  
}


resource "aws_eip" "elasticip" {
    count = length(var.publicsubnets)
    domain = "vpc"
    tags = merge(var.comman_tags,{
        "Name" = "elastic-ip ${count.index + 1}"
    })
  
}

resource "aws_nat_gateway" "natgateway" {
    count = length(var.publicsubnets)
    allocation_id = element(aws_eip.elasticip[*].id,count.index)
    subnet_id = element(aws_subnet.privatesubnets[*].id,count.index)
    tags = merge(var.comman_tags,{
        "Name" = "Nat-Gate-Way ${count.index + 1}"
    })

    depends_on = [ aws_internet_gateway.igw ]
  
}

resource "aws_route_table" "privatert" {
    count = length(var.privatesubnets)
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"

        nat_gateway_id = element(aws_nat_gateway.natgateway[*].id,count.index)
    }
    tags = merge(var.comman_tags,{
        "Name" = "private-Rt"
    })
  
}

resource "aws_route_table_association" "privatertassociate" {
    count = length(var.privatesubnets)
    subnet_id = element(aws_subnet.privatesubnets[*].id,count.index)
    route_table_id = element(aws_route_table.privatert[*].id,count.index)
  
}

