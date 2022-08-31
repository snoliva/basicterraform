# Terraform for Beginner
In this project let's build a simple EC2 instance with your VPC in AWS. Contain basic concepts like choose provider, variables, outputs and tags. Also, use docker-compose to test your terraform recipe.

## Basic concepts to terraform

`variable:` Let you customize aspects of Terraform modules without altering the module's own source code. it's like function arguments. See more information [here](https://www.terraform.io/language/values/variables)

`output:` Make information about your infrastructure available on the command line. It's like function return values. See more information [here](https://www.terraform.io/language/values/outputs)

`tags:` Define specific keys of resource, for example `Environment`, `Project`, etc.

## Commands

`terraform init:` Initialize a working directory that contain configurations files.

`terraform validate:` Validate the configuration files in directory.

`terraform fmt:` Rewrite Terraform configurations files.

`terraform apply:` Execute the actions proposed in a Terraform plan.

## How to use terraform in docker-compose?

For run terraform in docker:

```
docker-compose -f deploy/docker-compose.yml run --rm terraform <name_of_command>
```