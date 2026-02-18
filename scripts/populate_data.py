import boto3
import json
import os

# Configuration
REGION = "us-east-1"
TABLE_NAME = "Claims"
ACCOUNT_ID = boto3.client("sts").get_caller_identity()["Account"]
BUCKET_NAME = f"referral-claim-notes-{ACCOUNT_ID}"

dynamodb = boto3.resource("dynamodb", region_name=REGION)
s3 = boto3.client("s3", region_name=REGION)
table = dynamodb.Table(TABLE_NAME)

def populate_claims():
    print(f"Populating DynamoDB table '{TABLE_NAME}'...")
    with open("mocks/claims.json", "r") as f:
        claims = json.load(f)
        for claim in claims:
            table.put_item(Item=claim)
            print(f"Inserted claim: {claim['claimId']}")

def populate_notes():
    print(f"Populating S3 bucket '{BUCKET_NAME}'...")
    with open("mocks/notes.json", "r") as f:
        notes_list = json.load(f)
        for item in notes_list:
            claim_id = item["claimId"]
            note_content = item["notes"]
            key = f"{claim_id}.txt"
            
            s3.put_object(
                Bucket=BUCKET_NAME,
                Key=key,
                Body=note_content
            )
            print(f"Uploaded note for claim: {claim_id}")

if __name__ == "__main__":
    try:
        populate_claims()
        populate_notes()
        print("Data population complete.")
    except Exception as e:
        print(f"Error: {e}")
