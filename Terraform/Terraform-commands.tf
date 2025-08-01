=============================================================================================================================================
✅ Part 1: Terraform Commands — Categorized Section-wise
=============================================================================================================================================
Below is a complete categorized list of commonly used Terraform commands grouped by purpose.

📦 Core Lifecycle Commands
-----------------------------------------------------------------------------------
| Command             | Purpose                                                    |
| ------------------- | ---------------------------------------------------------- |
| `terraform init`    | Initializes the working directory and downloads providers. |
| `terraform plan`    | Shows execution plan before applying.                      |
| `terraform apply`   | Applies the changes to reach desired state.                |
| `terraform destroy` | Destroys all resources managed by Terraform.               |
| `terraform refresh` | Updates the state file with real infrastructure.           |
-----------------------------------------------------------------------------------

🧹 Code Formatting & Validation
--------------------------------------------------------------------------------------
| Command              | Purpose                                                      |
| -------------------- | ------------------------------------------------------------ |
| `terraform fmt`      | Formats Terraform configuration files.                       |
| `terraform validate` | Validates the configuration syntax and internal consistency. |
| `terraform graph`    | Generates a graph of the dependency graph.                   |
---------------------------------------------------------------------------------------

📄 State File Management
---------------------------------------------------------------------------------------------------
| Command                                     | Purpose                                            |
| ------------------------------------------- | -------------------------------------------------- |
| `terraform state list`                      | Lists all resources in the current state file.     |
| `terraform state show <address>`            | Shows details of a specific resource from state.   |
| `terraform state rm <address>`              | Removes resource from state without destroying it. |
| `terraform state mv <source> <destination>` | Moves or renames a resource within state.          |
| `terraform state pull`                      | Downloads raw state from remote backend.           |
| `terraform state push`                      | Uploads local state to remote backend.             |
| `terraform taint <resource>`                | Marks a resource for recreation.                   |
| `terraform untaint <resource>`              | Removes taint from a resource.                     |
---------------------------------------------------------------------------------------------------

📥 Output & Inspection
-----------------------------------------------------------------------------
| Command               | Purpose                                           |
| --------------------- | ------------------------------------------------- |
| `terraform output`    | Shows output values from the last apply.          |
| `terraform show`      | Displays current state or saved plan file.        |
| `terraform providers` | Lists provider plugins used in the configuration. |
-----------------------------------------------------------------------------

🛠️ Import, Debugging & Advanced
-----------------------------------------------------------------------------------
| Command             | Purpose                                                    |
| ------------------- | ---------------------------------------------------------- |
| `terraform import`  | Brings existing infrastructure into Terraform state.       |
| `terraform console` | Interactive REPL for evaluating Terraform expressions.     |
| `terraform debug`   | Enables debugging and verbose logging (via env variables). |
| `terraform version` | Prints Terraform CLI version.                              |
------------------------------------------------------------------------------------

