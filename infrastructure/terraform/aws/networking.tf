# # Main VPC 
# resource "aws_vpc" "main" {
#     cidr_block = "10.0.0.0/18"

#     tags = {
#         Name = "Main VPC"
#     }
# }

# # Public subnet with default route to internet gateway
# resource "aws_subnet" "public" {
#     vpc_id = aws_vpc.main.id
#     cidr_block = "10.0.0.0/24"

#     tags = {
#         Name = "Public Subnet"
#     }
# }

# resource "aws_subnet" "private" {
#     vpc_id = aws_vpc.main.id
#     cidr_block = "10.0.1.0/24"

#     tags = {
#         Name = "Private Subnet"
#     }
# }

# # Main internet gateway for VPC
# resource "aws_internet_gateway" "igw" {
#     vpc_id = aws_vpc.main.id

#     tags = {
#         Name = "Main IGW"
#     }
# }

# # Elastic IP for NAT Gateway
# resource "aws_eip" "nat_ip" {
#     vpc = true
#     depends_on = [
#         aws_internet_gateway.igw
#     ]

#     tags = {
#         Name = "NAT Gateway EIP"
#     }
# }

# # Main NAT Gateway for VPC
# # Must be placed in the public subnet with internet gateway as the default route (see route table)
# resource "aws_nat_gateway" "nat" {
#     allocation_id = aws_eip.nat_ip.id 
#     subnet_id = aws_subnet.public.id

#     tags = {
#         Name = "Main NAT Gateway"
#     }
# }

# # Route Table for Public Subnet
# resource "aws_route_table" "public" {
#     vpc_id = aws_vpc.main.id 

#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = aws_internet_gateway.igw.id
#     }

#     tags = {
#         Name = "Public Route Table"
#     }
# }

# # Association between public subnet and public route table
# resource "aws_route_table_association" "public" {
#     subnet_id = aws_subnet.public.id
#     route_table_id = aws_route_table.public.id
# }

# # Route Table for private subnet
# resource "aws_route_table" "private" {
#     vpc_id = aws_vpc.main.id
 
#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = aws_nat_gateway.nat.id
#     }

#     tags = {
#         Name = "Private Route Table"
#     }
# }

# # Association between private subnet and private route table
# resource "aws_route_table_association" "private" {
#     subnet_id = aws_subnet.private.id
#     route_table_id = aws_route_table.private.id
# }
