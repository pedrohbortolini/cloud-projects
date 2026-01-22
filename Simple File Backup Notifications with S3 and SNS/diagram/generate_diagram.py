import json
import os
from diagrams import Diagram, Cluster, Edge
from diagrams.aws.storage import S3
from diagrams.aws.integration import SNS
from diagrams.aws.general import User, Client
from diagrams.aws.security import IAM
from diagrams.aws.management import Config

# =========================
# 1. Load plan.json
# =========================
plan_path = "../plan.json"
# Fallback to prevent crash if file doesn't exist
if not os.path.exists(plan_path):
    resources = []
else:
    with open(plan_path) as f:
        plan = json.load(f)
    resources = plan.get("planned_values", {}).get("root_module", {}).get("resources", [])

# =========================
# 2. Detect features
# =========================
features = {
    "s3": False, "sns": False, "subscription": False,
    "versioning": False, "encryption": False, 
    "lifecycle": False, "pab": False,
    "topic_policy": False
}

# 1. Try to detect via planned resources (The standard method)
for r in resources:
    t = r["type"]
    if t == "aws_s3_bucket": features["s3"] = True
    elif t == "aws_sns_topic": features["sns"] = True
    elif t == "aws_sns_topic_subscription": features["subscription"] = True
    elif t == "aws_s3_bucket_versioning": features["versioning"] = True
    elif t == "aws_s3_bucket_server_side_encryption_configuration": features["encryption"] = True
    elif t == "aws_s3_bucket_lifecycle_configuration": features["lifecycle"] = True
    elif t == "aws_s3_bucket_public_access_block": features["pab"] = True
    elif t == "aws_sns_topic_policy": features["topic_policy"] = True

# 2. LOGIC FIX: Fallback for Subscription
# If explicit resource not found, check if input variable has emails.
# Terraform uses 'count', so if list > 0, the resource will exist.
if not features["subscription"]:
    # Fetch variables from JSON
    vars_config = plan.get("variables", {})
    email_list = vars_config.get("email_addresses", {}).get("value", [])
    
    # If list exists and is not empty, activate feature
    if email_list and len(email_list) > 0:
        features["subscription"] = True
        print(f"Debug: Subscription detected via variable (Emails: {len(email_list)})")

# =========================
# 3. Draw diagram
# =========================
graph_attr = {
    "fontsize": "20",
    "bgcolor": "white",
    "pad": "0.5"
}

with Diagram(
    "Secure File Backup Notification Architecture",
    filename="secure_backup_architecture",
    show=False,
    direction="LR",
    graph_attr=graph_attr
):
    
    user = User("Uploader")

    with Cluster("AWS Environment"):

        # -------- S3 Area --------
        if features["s3"]:
            with Cluster("Data Storage Layer"):
                bucket = S3("Backup Bucket")
                user >> Edge(label="PutObject", color="darkorange") >> bucket

                # Using Config or S3 with different colors to represent settings
                with Cluster("Security & Compliance"):
                    if features["encryption"]:
                        bucket - Edge(style="dotted") - S3("SSE-S3\nEncryption")
                    if features["pab"]:
                        bucket - Edge(style="dotted") - S3("Block Public\nAccess")
                
                with Cluster("Data Management"):
                    if features["versioning"]:
                        bucket - Edge(style="dotted") - S3("Versioning\nEnabled")
                    if features["lifecycle"]:
                        bucket - Edge(style="dotted") - S3("Lifecycle\nExpiration")

        # -------- SNS Area --------
        if features["sns"]:
            with Cluster("Event Driven Layer"):
                topic = SNS("SNS Topic")
                
                if features["topic_policy"]:
                    # The Policy "guards" the topic
                    policy = IAM("Topic Policy\n(Allow S3 Only)")
                    
                    # Logical connection: S3 -> Policy Check -> SNS
                    if features["s3"]:
                        bucket >> Edge(label="s3:ObjectCreated", color="firebrick", style="dashed") >> policy >> topic
                else:
                    # If no policy, connect directly
                    if features["s3"]:
                        bucket >> topic

                # Subscribers
                if features["subscription"]:
                    subscriber = Client("Email Subscriber")
                    topic >> Edge(label="SMTP Notification", color="blue") >> subscriber

print("Diagram generated: secure_backup_architecture.png")