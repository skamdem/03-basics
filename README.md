# Terraform basics 

> This project, a basic web app behind a load balancer, originates from [here](https://github.com/sidpalas/devops-directive-terraform-course "devops directive terraform course").
> It involves the following elements:
> - Remote backend & provider config
> - Route 53 hosted zone
> - Load balancer
> - EC2 instances
> - RDS DB instances
 

## List of commands:

```
$ terraform init
$ terraform validate
$ terraform fmt
$ terraform plan
$ terraform apply
$ terraform init -upgrade // after updating "required_providers"
$ terraform destroy // cleanup on project completion
```
***
## Files configuration : 

| Fine name | Contents |
| ------------ | ------------- |
| aws_resources.tf | resources |
| main.tf | terraform setup |
| outputs.tf | outputs |
| providers.tf | list of providers |
| terraform.tfvars | actual values of variable |
| variables.tf | variables definition |
