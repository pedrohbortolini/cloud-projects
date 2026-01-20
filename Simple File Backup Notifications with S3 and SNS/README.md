# Simple File Backup Notifications with Amazon S3 and SNS

## Overview

This project demonstrates how to build an automated notification system that sends email alerts whenever files are uploaded to an Amazon S3 bucket.
The solution was implemented in **two ways**:

* **Using AWS Management Console (GUI)**
* **Using Infrastructure as Code with Terraform**

Both approaches create the same architecture:
**S3 → SNS → Email notification**

---

## Architecture

* **Amazon S3**: Stores backup files
* **Amazon SNS**: Distributes notifications
* **Email Subscription**: Receives alerts when new files are uploaded

Whenever an object is created in the S3 bucket, an event notification is triggered and sent to an SNS topic, which then delivers an email notification to subscribed recipients.

---

## ❗ Problem

Backup operations and file transfers are critical for data protection and compliance.
However, without real-time visibility, teams often discover missing or failed backups too late, increasing the risk of data loss.

Manually checking S3 buckets is inefficient, error-prone, and does not scale well. Organizations need an automated and reliable way to be notified immediately when backup files are successfully uploaded.

---

## Solution

This project implements a **serverless and event-driven notification system** using Amazon S3 and Amazon SNS.

Whenever a file is uploaded to a backup bucket:

1. Amazon S3 detects the event
2. The event is sent to an SNS topic
3. SNS delivers an email notification instantly

This ensures real-time visibility into backup operations without the need for manual checks or custom monitoring scripts.

---

## Implementation Using AWS GUI (Management Console)

### 1. Create an SNS Topic

* Access **Amazon SNS → Topics**
* Create a **Standard** topic named:

  ```
  backup-alerts-gui
  ```
* Example ARN:

  ```
  arn:aws:sns:us-east-1:99999999:backup-alerts-gui
  ```

### 2. Create an Email Subscription

* Inside the topic, go to **Subscriptions**
* Create a subscription of type **Email**
* Enter the email address that will receive notifications
* Confirm the subscription via the email sent by SNS

### 3. Create an S3 Bucket

* Create a new S3 bucket to store backup files
* Enable:

  * **Versioning**
  * **Default Encryption (SSE-S3)**

### 4. Configure SNS Topic Policy

* Update the **Access Policy** of the SNS topic
* Allow the **S3 service (`s3.amazonaws.com`)** to publish messages to the topic
* This step is mandatory for S3 event notifications to work

### 5. Configure S3 Event Notifications

* Go to the S3 bucket → **Properties**
* Open **Event notifications**
* Create a notification for:

  * Event type: `ObjectCreated`
  * Destination: SNS topic `backup-alerts-gui`

### 6. Result

From this point on, every file uploaded to the S3 bucket triggers:

```
S3 → SNS → Email notification
```

## ⚠️ Important Observations (GUI)

* When modifying the **SNS Topic Policy**, the email subscription **may become unsubscribed automatically**
* This happened during this project
* **Solution**:

  * Delete the subscription
  * Recreate it
  * Confirm the email again


---

## 🧱 Implementation Using Terraform (Infrastructure as Code)

This project was also implemented using **Terraform**, fully automating the creation of all AWS resources.

### Resources Created

* SNS Topic
* SNS Topic Policy (allowing S3 to publish messages)
* Email Subscription
* S3 Bucket
* S3 Bucket Versioning
* S3 Bucket Encryption
* S3 Event Notifications

### Key Benefits of Terraform Approach

* Reproducible and consistent infrastructure
* Easy to deploy in multiple environments
* Version-controlled infrastructure
* No manual configuration via console

### Workflow

```bash
tofu init
tofu plan
tofu apply
```

After applying the Terraform configuration, the behavior is identical to the GUI implementation:

* Uploading a file to S3 triggers an SNS notification
* An email alert is sent automatically

---

## 📝 Variables Configuration

All customizable values (region, bucket name, environment, tags, email address, etc.) are defined using variables and can be set via:

```
terraform.tfvars
```

This allows easy customization without changing the core code.

---

## 🏁 Final Result

* Fully serverless
* Event-driven
* Real-time notifications
* Implemented both manually (GUI) and programmatically (Terraform)

This project demonstrates a common and practical AWS integration pattern that is frequently used in production environments.
