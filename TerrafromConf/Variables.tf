variable "vpc_cidr" {
    type = string
} 

variable "public_cidrs" {
  type = list
  public_cidrs  = ["10.10.10.0/28", "10.10.11.0/28", "10.10.12.0/28"]
} 

variable "az" {
  type = list
  azs = ["us-east-1a", "us-east-1b", "eu-east-1c"]
} 

variable "private_cidrs" {
    type = list
    private_subnets = ["172.18.1.0/26", "172.18.2.0/26", "172.18.3.0/26"]
}