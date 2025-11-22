| Feature     | `count`                                    | `for_each`                                          |
| ----------- | ------------------------------------------ | --------------------------------------------------- |
| Purpose     | Create multiple **identical** resources    | Create multiple **distinct** resources              |
| Indexing    | Accessed via numeric index — `count.index` | Accessed via key — `each.key`, value — `each.value` |
| Input type  | Number (integer)                           | Map or Set                                          |
| When to use | When resources are similar                 | When resources need unique values/naming            |
| Identifiers | Hard to track if list order changes        | Safe from reorder issues                            |

1. COUNT
resource "aws_instance" "web" {
  count         = 3
  ami           = "ami_id"
  instance_type = "t2.micro"

  tags = {
    Name = "web-server-${count.index}"
  }
}
Terraform creates:
web-server-0
web-server-1
web-server-2

Why count?
Because all servers are identical and only differ numerically.

2. How to make Terraform start numbering from 1
 resource "aws_instance" "web" {
  count         = 3
  ami           = "ami_id"
  instance_type = "t2.micro"

  tags = {
    Name = "web-server-${count.index + 1}"
  }
}
web-server-1
web-server-2
web-server-3
 
-------------------------------------------------------------------------------------------------------------------------------------------------------
FOR EACH
Use Case:
Create EC2 instances where each server needs a different name and different instance type, like:
app server
db server
cache server
----------------------------------------------------------------
 resource "aws_instance" "multi" {
  for_each      = {
    web  = "t3.micro"
    app  = "t3.small"
    db   = "t3.medium"
  }

  ami           = "ami-0c1a7f89451184c8b"
  instance_type = each.value

  tags = {
    Name = each.key
  }
}
| Instance Name | Instance Type |
| ------------- | ------------- |
| web           | t3.micro      |
| app           | t3.small      |
| db            | t3.medium     |
 
variable "servers" {
  type = map(string)
  default = {
    app   = "t3.medium"
    db    = "t3.large"
    cache = "t3.small"
  }
}
resource "aws_instance" "multi" {
  for_each      = var.servers
  ami           = var.ami_id
  instance_type = each.value

  tags = {
    Name = each.key
  }
}
| Name  | Type      |
| ----- | --------- |
| app   | t3.medium |
| db    | t3.large  |
| cache | t3.small  |

TO SET
resource "aws_instance" "multi_instances" {
  for_each      = toset(["web", "app", "db"])
  ami           = "ami-0c1a7f89451184c8b"
  instance_type = "t3.micro"  # Same type for all

  tags = {
    Name = each.value
  }
}
| Instance Name | Instance Type |
| ------------- | ------------- |
| web           | t3.micro      |
| app           | t3.micro      |
| db            | t3.micro      |

