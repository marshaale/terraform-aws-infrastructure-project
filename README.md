# Preview

<img src="./docs/Screenshot%20from%202026-10-28%2015-08-07.png" height="40%"/>

# AWS Infrastructure with Terraform

Provision AWS infrastructure using **Terraform (Infrastructure as
Code)**. This project demonstrates how to create a VPC, deploy EC2
instances across two public subnets, distribute incoming traffic through
a load balancer, and use Amazon S3 for object storage.

> **Learning project:** Build the infrastructure in small steps, verify
> each resource, and destroy resources when you finish to avoid
> unnecessary AWS charges.

## Architecture

The target architecture includes:

- **AWS VPC** --- an isolated virtual network for the project.
- **Two public subnets** --- separate subnets in different
  Availability Zones for improved availability.
- **Application Load Balancer (ALB)** --- receives HTTP/HTTPS traffic
  and distributes requests across the EC2 instances.
- **EC2 Auto Scaling Group** --- maintains the desired number of
  application instances and can replace unhealthy instances.
- **Amazon S3** --- stores objects such as uploaded files or
  application assets. The application instances access the bucket
  through an appropriately scoped IAM role.
- **Terraform** --- defines, provisions, updates, and destroys the
  infrastructure.

### Architecture flow

```text
                         Internet
                            |
                     Internet Gateway
                            |
                       Public ALB
                      /           \
             Public Subnet A   Public Subnet B
                EC2 instance     EC2 instance
                      \           /
                    Auto Scaling Group
                            |
                   Application accesses S3
                  (using an IAM instance role)
```

The load balancer is deployed across both public subnets. EC2 instances
may be placed in public subnets for this learning diagram, but **a
production design should generally place application instances in
private subnets** and allow inbound application traffic only from the
load balancer. In that design, private instances need a suitable
outbound path if they must download updates or reach public services.

## Project objectives

By completing this project, you will learn to:

1.  Define AWS resources using Terraform configuration files.
2.  Create a VPC and public subnet resources.
3.  Configure an Internet Gateway and public route table.
4.  Deploy an Application Load Balancer and target group.
5.  Launch EC2 instances through a Launch Template and Auto Scaling
    Group.
6.  Configure security groups using least-privilege rules.
7.  Create an S3 bucket with secure defaults.
8.  Grant application instances limited S3 access through IAM.
9.  Validate changes with `terraform plan` and apply them safely.
10. Manage Terraform state and clean up resources.

## Prerequisites

Install and configure:

- An AWS account with permission to create the resources in this
  project.
- AWS CLI, configured with a suitable profile or environment
  credentials.
- Terraform CLI.
- Git.

Check your installations:

```bash
terraform version
aws --version
aws sts get-caller-identity
```

Choose the AWS Region you intend to use and verify that the required EC2
instance types are available there. Do not commit AWS access keys,
secret keys, state files, or `.tfvars` files containing secrets to Git.

## Suggested project structure

```text
terraform-aws-infrastructure/
├── README.md
├── .gitignore
├── versions.tf
├── providers.tf
├── variables.tf
├── main.tf
├── networking.tf
├── security.tf
├── load_balancer.tf
├── compute.tf
├── s3.tf
├── iam.tf
├── outputs.tf
├── terraform.tfvars.example
└── modules/                 # Optional, for later refactoring
```
