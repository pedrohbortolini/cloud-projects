# AWS CLI Setup and First Commands with CLI and S3

This repository contains a small hands-on project that demonstrates the first steps using **AWS CLI** and creating an **S3 bucket** using **AWS CloudFormation**.

The goal is to show basic AWS CLI usage, credential configuration, and the **Infrastructure as Code (IaC)** approach using CloudFormation stacks.

---

## Project Structure

```
aws-cli-setup-first-commands/
├── README.md
└── cloudformation/
    └── bucket.yaml
```

---

## 1. AWS CLI Verification

The first step is to confirm if AWS CLI is installed.

```bash
aws --version
```

In this project, AWS CLI was already installed in the WSL environment, so no additional installation was required.

---

## 2. Credential Configuration

AWS CLI requires credentials to interact with AWS services.

To configure credentials, run:

```bash
aws configure
```

During this process, the following information is stored:

* AWS Access Key ID
* AWS Secret Access Key
* Default AWS Region
* Default Output Format

⚠️ **Security Note:**
For production environments, it is recommended to use **IAM Roles** or **AWS SSO** instead of storing static credentials.

---

## 3. Creating an S3 Bucket using CloudFormation

CloudFormation is an AWS service that allows you to define infrastructure as code (IaC).
You create a template file that describes the resources, and AWS creates them automatically.

### What is a CloudFormation Stack?

A stack is a collection of AWS resources that are created, updated, and deleted as a single unit.

In this project, a stack is used to create an S3 bucket.

### CloudFormation Template

The template used in this project is located at:

```
cloudformation/bucket.yaml
```

### Why not set a fixed bucket name?

The bucket name is not fixed in the template to avoid errors due to name conflicts.
S3 bucket names must be globally unique.

---

## 4. Deploying the CloudFormation Stack

To create the stack and deploy the S3 bucket, run:

```bash
aws cloudformation create-stack \
  --stack-name my-first-bucket-stack \
  --template-body file://cloudformation/bucket.yaml
```

This command starts the creation of the stack and resources defined in the template.

---

## 5. Stack Lifecycle and Cleanup

When a CloudFormation stack is deleted, all resources created by it are also deleted automatically.

To delete the stack:

```bash
aws cloudformation delete-stack \
  --stack-name my-first-bucket-stack
```

### Best Practices

* Resources created by CloudFormation should not be modified manually.
* All changes should be made by updating the template and running `update-stack`.

This avoids configuration drift and keeps infrastructure consistent.

---

## 6. CloudFormation vs Terraform (Stack vs State)

| CloudFormation                           | Terraform                                    |
| ---------------------------------------- | -------------------------------------------- |
| Uses stacks                              | Uses state                                   |
| AWS native                               | Multi-cloud                                  |
| Changes should be made through templates | Changes through code and `terraform apply`   |
| Deleting a stack removes resources       | `destroy` removes resources managed in state |

---

## 7. Key Takeaways

* AWS CLI is a basic and essential tool to interact with AWS services.
* CloudFormation allows Infrastructure as Code (IaC) using templates.
* A stack is a collection of resources managed together.
* Deleting a stack removes all resources created by it.
* Infrastructure should be managed through IaC to avoid manual drift.

---

## Tools Used

* AWS CLI
* AWS CloudFormation
* Amazon S3
* WSL (Linux environment)

---
