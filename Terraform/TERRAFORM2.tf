===================================================================================================================================================
Terraform import
1. Create main.tf with resource type and local name.
provider "aws" {
  region = "us-east-1"
} 
# Define the resource you want to manage
resource "aws_instance" "web" {
  # No attributes yet, because Terraform will import the current state
}
2. Initialize Terraform (terraform init).
3. Import the resource (terraform import aws_instance.web <ID>).
   terraform import aws_instance.web i-0abcd1234efgh5678
4. Update Terraform configuration to match reality.
5. Plan & apply as usual.

terraform state list
terraform state show aws_instance.web
===================================================================================================================================================
terraform refresh
---
terraform plan 
terraform refresh
change main.tf config
terraform apply
===================================================================================================================================================
3. Implicit Dependency in Terraform
Implicit dependency is when Terraform automatically understands the order of resource creation based on references inside resource blocks.
It happens when one resource uses attributes of another resource.

Features:
    -No need to specify depends_on.
    -Terraform builds a dependency graph automatically.
    -Safer and cleaner code.
    -Works only if attributes are referenced.

Example (Implicit Dependency):
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id   # Reference creates implicit dependency
  cidr_block = "10.0.1.0/24"
}
===================================================================================================================================================
4. Explicit Dependency in Terraform
Explicit dependency is when you manually tell Terraform about the dependency between resources using the depends_on meta-argument.

Features:
  -Required when resources don’t have direct attribute references.
  -Ensures correct creation or destruction order.
  -Useful in complex scenarios like null resources, provisioners, or external services.


Example (Explicit Dependency):
resource "aws_iam_role" "my_role" {
  name = "myRole"
  assume_role_policy = <<EOT
  {
    "Version": "2012-10-17",
    "Statement": []
  }
  EOT
}

resource "aws_instance" "my_instance" {
  ami           = "ami-123456"
  instance_type = "t2.micro"
  depends_on = [aws_iam_role.my_role]  # Explicit dependency
}

---
When to Use
Implicit: Most of the time (cleaner & automatic).
Explicit: When resources don’t have a direct reference but must follow a specific order.
---
Interview-Style Summary
In Terraform, dependencies can be implicit or explicit.
Implicit dependencies are created automatically when one resource references another resource’s attributes.
Explicit dependencies are declared manually using the depends_on argument, ensuring Terraform respects resource creation/destruction order 
even without attribute references.
===================================================================================================================================================
terraform destroy -target=resource_type.name --------> to destroy only that resource.

If you don’t want to delete it but just remove it from Terraform management
  -terraform state rm resource_type.name.
  -delete that resoucre block in main.tf

If you remove it from .tf files and run terraform apply, Terraform will also destroy it (because it no longer exists in config).
===================================================================================================================================================
terraform validate
terraform fmt -check
===================================================================================================================================================
Terraform Lifecycle Policies
In Terraform, a lifecycle policy is a meta-argument that you can attach to resources to control how Terraform creates, updates, or 
destroys them.
It helps prevent accidental deletions, control replacement behavior, and manage dependencies beyond the default Terraform flow.
---
Features of Lifecycle Policies
Terraform provides 3 main lifecycle arguments:
1. create_before_destroy
  -Ensures a new resource is created before the old one is destroyed.
  -Useful when downtime must be avoided.

2. prevent_destroy
  -Protects critical resources (like DBs, S3 buckets) from being destroyed.
  -Terraform throws an error if terraform destroy or apply tries to remove it.

3. ignore_changes
  -Ignores specific attributes during updates.
  -Useful when external systems update resource properties (e.g., an autoscaling group updates desired_capacity).
---
Use Cases with Terraform Code
1. Preventing Destruction

resource "aws_s3_bucket" "prod" {
  bucket = "my-prod-bucket"

  lifecycle {
    prevent_destroy = true
  }
}
✅ Prevents accidental deletion of critical prod bucket.
---
2. Create Before Destroy (Zero Downtime Upgrade)
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}
✅ Ensures Terraform launches a new EC2 instance before terminating the old one.
---
3. Ignore Changes
resource "aws_autoscaling_group" "example" {
  name                      = "asg-example"
  desired_capacity          = 2
  max_size                  = 5
  min_size                  = 1

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}
✅ Even if an operator manually changes desired_capacity, Terraform will not override it.
---
Importance
  -Protects critical resources (DB, S3) from deletion.
  -Ensures zero downtime deployments with create_before_destroy.
  -Avoids unnecessary changes with ignore_changes.
  -Provides fine-grained control over resource lifecycle.
---
Interviewer-Style Summary
“Terraform lifecycle policies allow me to control how resources are created, updated, or destroyed. For example, I use prevent_destroy to
safeguard production databases, create_before_destroy for zero downtime replacements, and ignore_changes when certain attributes are 
managed outside Terraform (like autoscaling). They’re essential in production because they prevent accidental outages and keep deployments 
reliable.”
===================================================================================================================================================
Terraform Meta-Arguments
In Terraform, meta-arguments are special arguments that can be used with any resource or module.
They are not specific to a provider but instead control how Terraform manages the resource (its lifecycle, replication, dependencies, etc.).

---
Main Meta-Arguments in Terraform
1. depends_on
  -Forces explicit dependency between resources.
  -Useful when Terraform cannot automatically infer dependencies.

2. count
  -Creates multiple instances of the same resource.
  -Indexed with count.index.

3. for_each
  -Similar to count, but creates resources based on a map or set of strings.
  -Each resource gets a unique key.

4. provider
  -Explicitly specifies which provider configuration a resource should use.
  -Useful when you have multiple provider blocks (e.g., two AWS accounts).

5. lifecycle
  -Controls resource behavior during creation, destruction, or updates.
  -Includes prevent_destroy, ignore_changes, create_before_destroy.

---
Use Cases with Terraform Code
1. depends_on
resource "aws_instance" "app" {
  ami           = "ami-123456"
  instance_type = "t2.micro"
  depends_on    = [aws_security_group.sg]
}

resource "aws_security_group" "sg" {
  name = "app-sg"
}
✅ Ensures EC2 launches after the security group is created.
---
2. count
resource "aws_instance" "servers" {
  count         = 3
  ami           = "ami-123456"
  instance_type = "t2.micro"
  tags = {
    Name = "server-${count.index}"
  }
}
✅ Creates 3 EC2 instances with names server-0, server-1, server-2.
---

3. for_each
variable "buckets" {
  default = {
    logs   = "log-bucket"
    backup = "backup-bucket"
  }
}

resource "aws_s3_bucket" "buckets" {
  for_each = var.buckets
  bucket   = each.value
  tags = {
    Name = each.key
  }
}
===================================================================================================================================================
Terraform Data Block
A data block in Terraform is used to fetch and reference existing resources that are not created by your Terraform configuration.
It allows Terraform to read data from providers (like AWS, Azure, GCP) and use that information in resource definitions.
---
Features of Data Blocks
1. Read-Only → Data sources only read existing infra, they don’t create or modify it.
2. Dynamic Lookup → You can fetch details like AMI IDs, VPC IDs, Subnets, Secrets, etc.
3. Reusability → Avoids hardcoding IDs by dynamically fetching them.
4. Integration → Helps when you mix Terraform-managed and manually created resources.
---
Syntax

data "<PROVIDER>_<TYPE>" "<NAME>" {
  # arguments (filters, ids, etc.)
}
---
Use Cases with Terraform Code
1. Fetching Latest AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
}
✅ Always launches EC2 with the latest Ubuntu AMI.
---

2. Using an Existing VPC
data "aws_vpc" "default" {
  default = true
}

resource "aws_subnet" "public" {
  vpc_id     = data.aws_vpc.default.id
  cidr_block = "10.0.1.0/24"
}

✅ Fetches the default VPC ID instead of hardcoding it.
---
3. Getting a Secret from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "my-db-password"
}
resource "aws_db_instance" "appdb" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = data.aws_secretsmanager_secret_version.db_password.secret_string
}

✅ Pulls the DB password securely from Secrets Manager.
---
4. Fetching IAM User Info
data "aws_iam_user" "devuser" {
  user_name = "developer"
}

output "user_arn" {
  value = data.aws_iam_user.devuser.arn
}

✅ Retrieves IAM user info without creating a new user.
---
Importance
  -Avoids hardcoding values like IDs, ARNs, AMIs.
  -Enables dynamic, reusable Terraform code.
  -Helps when combining Terraform with pre-existing resources.
  -Enhances security (by fetching secrets dynamically).
---
Interviewer-Style Summary

“In Terraform, I use data blocks to query and reference existing resources instead of hardcoding IDs. For example, I fetch the latest AMI
ID for EC2, look up an existing VPC, or retrieve DB credentials from Secrets Manager. Data sources are read-only, which makes them safe 
and essential for dynamic infrastructure.”
===================================================================================================================================================
Terraform count Meta-Argument
count is a meta-argument in Terraform that allows you to create multiple instances of the same resource (or none at all) using a single block.
It is index-based (count.index) and generates resources in sequence.
---
Features of count
1. Looping Mechanism → Creates multiple resources from one block.
2. Conditional Resource Creation → Can be used with boolean logic (count = var.enabled ? 1 : 0).
3. Indexed Access → Resources can be uniquely identified with count.index.
4. Scales Easily → Avoids repetitive resource definitions.
---
Real-Time Use Cases with Examples
1. Creating Multiple EC2 Instances

variable "instance_count" {
  default = 3
}

resource "aws_instance" "servers" {
  count         = var.instance_count
  ami           = "ami-123456"
  instance_type = "t2.micro"

  tags = {
    Name = "server-${count.index}"
  }
}
✅ Creates 3 EC2 instances: server-0, server-1, server-2.
---
2. Conditional Resource Creation
variable "create_bucket" {
  default = true
}

resource "aws_s3_bucket" "mybucket" {
  count  = var.create_bucket ? 1 : 0
  bucket = "conditional-bucket-example"
}
✅ Creates an S3 bucket only if create_bucket = true.
---
3. Creating Multiple IAM Users

variable "users" {
  default = ["dev1", "dev2", "dev3"]
}

resource "aws_iam_user" "users" {
  count = length(var.users)
  name  = var.users[count.index]
}
✅ Creates IAM users: dev1, dev2, dev3.
---
4. Creating Multiple Security Group Rules

variable "ports" {
  default = [22, 80, 443]
}

resource "aws_security_group_rule" "allow_ports" {
  count             = length(var.ports)
  type              = "ingress"
  from_port         = var.ports[count.index]
  to_port           = var.ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_sg.id
}

✅ Opens ports 22, 80, 443 in the security group.
---
5. Creating Multiple EBS Volumes

resource "aws_ebs_volume" "volumes" {
  count             = 2
  availability_zone = "us-east-1a"
  size              = 10
  tags = {
    Name = "data-volume-${count.index}"
  }
}
✅ Creates 2 EBS volumes named data-volume-0 and data-volume-1.
---
Importance
  -Reduces code duplication.
  -Enables dynamic scaling of resources.
  -Provides conditional flexibility (create or skip).
  -Useful in real-world infra (multi-EC2, multiple users, multiple ports).
---
Interviewer-Style Summary

“I use the count meta-argument when I need multiple instances of a resource. For example, creating 3 EC2 instances, multiple IAM users, 
or multiple SG rules without writing repetitive code. It also helps in conditional creation, like skipping an S3 bucket in non-prod 
environments. This keeps Terraform code scalable, DRY, and flexible.”
===================================================================================================================================================
Difference Between count and for_each (Layman Language)
🔹 count
Think of it like numbering seats in a cinema hall.
If you say count = 3, Terraform will create 3 resources and name them like:
resource[0], resource[1], resource[2].
Access is always by number (index).
---
🔹 for_each
Think of it like naming seats with labels instead of numbers.
If you have a list of names or a map, Terraform will create resources using those names as identifiers.
Access is always by name (key) instead of index.
---
👉 In short:
count = use when you just need “X number of things.”
for_each = use when you need resources identified by names/keys (better clarity and tracking).
---
Real-Time AWS Examples
✅ Example 1: Using count to create EC2 instances
variable "instance_count" {
  default = 3
}
resource "aws_instance" "servers" {
  count         = var.instance_count
  ami           = "ami-123456"
  instance_type = "t2.micro"

  tags = {
    Name = "server-${count.index}"
  }
}

➡️ Creates 3 EC2 instances named:
server-0
server-1
server-2
---
✅ Example 2: Using for_each to create EC2 instances with specific names
variable "instances" {
  default = ["app", "db", "cache"]
}
resource "aws_instance" "servers" {
  for_each      = toset(var.instances)
  ami           = "ami-123456"
  instance_type = "t2.micro"

  tags = {
    Name = each.key
  }
}

➡️ Creates 3 EC2 instances named:
app
db
cache
---
When to Use What?
✅ Use count if:
You just need a fixed number of resources.
Index-based naming (server-0, server-1) is enough.

✅ Use for_each if:
You want resources with unique names/keys.
You want to easily reference a specific resource by its name (servers["app"]).
---
Interviewer-Style Summary
“In simple terms, count is like numbering resources 0,1,2… while for_each is like giving them meaningful names (app, db, cache). 
I use count when I need a fixed number of identical resources, and for_each when I need resources mapped to keys like environment names 
or user lists. This makes my code cleaner and easier to manage.”
===================================================================================================================================================

Difference Between map and toset
🔹 map (Key → Value Pairs)
Think of a dictionary in real life 📖.
You look up a word (key) and get its meaning (value).
In Terraform, map = key → value.

👉 Example in real life:
{"apple" = "red", "banana" = "yellow"}
"apple" is the key, "red" is the value.
---
🔹 toset (Unique Items, No Values)
Think of a bucket of unique balls ⚽🏀🎾.
Each ball is just an item, there is no value attached.
In Terraform, toset = a collection of unique strings only (no duplicates).

👉 Example in real life:
{"apple", "banana", "orange"}
Just items, no extra meaning attached.

---
Terraform Examples
✅ Example with map
variable "buckets" {
  default = {
    logs   = "log-bucket"
    backup = "backup-bucket"
  }
}

resource "aws_s3_bucket" "buckets" {
  for_each = var.buckets
  bucket   = each.value   # gets the bucket name
  tags = {
    Name = each.key       # gets the key (logs/backup)
  }
}

➡️ Creates:
Bucket with name log-bucket and tag logs.
Bucket with name backup-bucket and tag backup.
---
✅ Example with toset
variable "instances" {
  default = ["app", "db", "cache"]
}
resource "aws_instance" "servers" {
  for_each      = toset(var.instances)
  ami           = "ami-123456"
  instance_type = "t2.micro"

  tags = {
    Name = each.key   # here key = same as value
  }
}

➡️ Creates:
Instance with tag app
Instance with tag db
Instance with tag cache
---
Quick Analogy in Layman’s Terms

Map = A dictionary (Key → Value) 📕
👉 You look up "apple" → it says "red".

toset = A bucket of unique items 🎒
👉 Just "apple, banana, orange", no extra meaning.
---
Interviewer-Style Summary
“In Terraform, I use a map when I need key-value pairs, for example, environment = bucket name. I use toset when I just need a unique 
list of items, like instance names. Maps are dictionaries, while toset is just a bag of unique strings.”
---
🔹 1. string
A sequence of characters (text).
Example:
variable "env" {
  type    = string
  default = "production"
}
---
🔹 2. number
Any numeric value (integer or float).
Example:
variable "instance_count" {
  type    = number
  default = 3
}
---
🔹 3. bool (boolean)
Represents true or false.
Example:
variable "enable_monitoring" {
  type    = bool
  default = true
}
---
🔹 4. list (array)
An ordered collection of values (like a shopping list).
Example:
variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
---
🔹 5. set
Like a list, but no duplicates and order doesn’t matter.
Example:
variable "security_groups" {
  type    = set(string)
  default = ["sg-12345", "sg-12345", "sg-67890"]
}
# Will automatically remove duplicates → ["sg-12345", "sg-67890"]
---
🔹 6. map (dictionary / key-value pairs)
A collection of key-value pairs (like a phonebook).
Example:
variable "instance_types" {
  type = map(string)
  default = {
    dev  = "t2.micro"
    prod = "m5.large"
  }
}
---
🔹 7. object
A structured collection (like a JSON object)
Example:

variable "server" {
  type = object({
    name = string
    cpu  = number
    tags = list(string)
  })
  default = {
    name = "app-server"
    cpu  = 4
    tags = ["frontend", "production"]
  }
}
---
🔹 8. tuple
An ordered collection of elements of different data types (like a basket with mixed fruits).
Example:
variable "my_tuple" {
  type    = tuple([string, number, bool])
  default = ["server1", 2, true]
}

---
✅ Summary in Layman’s Language:
string → Text
number → Numbers
bool → Yes/No (true/false)
list → Ordered collection (can have duplicates)
set → Unordered collection (no duplicates)
map → Key-value pairs
object → Structured group (like JSON)
tuple → Fixed collection with mixed types

===================================================================================================================================================
🔹 What is for_each in Terraform?
for_each lets you create multiple resources, one for each item in a map or set of strings.
Unlike count (which works with numbers and index),
for_each works with named keys, so you can manage resources more predictabl

👉 Think of it like:
count = numbered list (0,1,2,3…)
for_each = dictionary (key → value)
---
🔹 Use Cases of for_each with Real-time Examples
---
✅ 1. Creating IAM Users from a List of Names

variable "users" {
  type    = set(string)
  default = ["alice", "bob", "charlie"]
}

resource "aws_iam_user" "users" {
  for_each = var.users
  name     = each.value
}
📌 Real-world use: If your company hires new employees, just add names to the variable — Terraform creates new IAM users automatically.
---
✅ 2. Creating EC2 Instances with Custom Tags (Map Example)
variable "instances" {
  type = map(string)
  default = {
    "frontend" = "t2.micro"
    "backend"  = "t2.small"
    "db"       = "t2.medium"
  }
}

resource "aws_instance" "servers" {
  for_each      = var.instances
  instance_type = each.value
  ami           = "ami-123456"
  tags = {
    Name = each.key
  }
}

📌 Real-world use:
Frontend team → t2.micro
Backend team → t2.small
DB team → t2.medium
Each instance gets a different type + name, but all in one Terraform block.
---
✅ 3. Creating Multiple S3 Buckets with Unique Configs
variable "buckets" {
  type = map(string)
  default = {
    "logs"    = "private"
    "website" = "public-read"
  }
}

resource "aws_s3_bucket" "buckets" {
  for_each = var.buckets
  bucket   = "mycompany-${each.key}"
  acl      = each.value
}

📌 Real-world use:
mycompany-logs → private bucket for audit logs
mycompany-website → public bucket for static website hosting

---
✅ 4. Security Groups for Different Applications
variable "sg_rules" {
  type = map(number)
  default = {
    "app"  = 8080
    "db"   = 3306
    "ssh"  = 22
  }
}

resource "aws_security_group_rule" "rules" {
  for_each          = var.sg_rules
  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  security_group_id = aws_security_group.main.id
}
📌 Real-world use:
Port 8080 → App traffic
Port 3306 → Database traffic
Port 22 → SSH access
---
🔑 Why for_each is Better than count (sometimes)
With count, deleting item 0 shifts all indexes → Terraform may try to recreate resources unnecessarily.
With for_each, resources are tied to keys → more stable and predictable.
👉 Example:
If you remove "bob" from users, only Bob’s IAM user is deleted. Alice & Charlie remain untouched.
But with count, deleting 1 in the middle could cause all indexes to shift, and Terraform may destroy/recreate unintended resources.
---
✅ Summary in Layman’s Words:
Use for_each when you want to create resources that can be uniquely identified by name/key.
It’s perfect for IAM users, EC2 instances with roles, S3 buckets, SG rules where each resource is different.
It avoids the index shifting problem that happens with count.
===================================================================================================================================================
🔹 Difference Between count and for_each in Terraform
1. count
Think of count like saying:
👉 “I want 5 copies of this thing.”
It is number-based (you tell Terraform how many you want).
The resources created will be indexed using numbers (0, 1, 2…).

✅ Example: Create 3 EC2 instances
resource "aws_instance" "web" {
  count         = 3
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  tags = {
    Name = "web-${count.index}"
  }
}
🔹 Creates 3 instances named: web-0, web-1, web-2.
---
2. for_each
Think of for_each like saying:
👉 “I have this shopping list, create one resource for each item on it.”
It is map or set-based (you give Terraform a list/map of values).
Resources are created with keys (not just numbers).

✅ Example: Create EC2 instances with specific names
resource "aws_instance" "web" {
  for_each      = toset(["frontend", "backend", "database"])
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  tags = {
    Name = each.key
  }
}
🔹 Creates 3 instances named: frontend, backend, database.
---
🔑 Key Differences (Layman Style)
Feature count (Number-based) for_each (Key-based)
When to use When you just need X copies When each resource is unique
Indexing Uses numbers (0,1,2) Uses keys (name, id, etc.)
Flexibility Less flexible (harder to rename or remove one item) More flexible (you can add/remove specific items easily)
Best Example 3 identical EC2 servers Servers with different roles (frontend, backend)
---
🚀 Real-World Analogy
count = “I want 5 chairs of the same model.”
for_each = “I want one chair for Alice, one for Bob, one for Charlie (different labels).”
---
👉 In interviews, you can say:
Use count when the number of resources matters.
Use for_each when the identity (name, key) of each resource matters.


