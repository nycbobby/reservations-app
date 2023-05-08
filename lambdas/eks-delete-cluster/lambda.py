import boto3
import json
import time
from terrasnek.api import TFC

client = boto3.client('secretsmanager', region_name='us-east-1')

secret_value = client.get_secret_value(
    SecretId='tfc_token'
)

TFC_TOKEN = json.loads(secret_value['SecretString'])['tfc_token']
TFC_URL = 'https://app.terraform.io'

api = TFC(TFC_TOKEN, url=TFC_URL)
api.set_org("tpa_bb")

create_run_payload = {
    "data": {
        "attributes": {
        "message": "Starting run through API"
        },
        "type":"runs",
        "relationships": {
            "workspace": {
                "data": {
                "type": "workspaces",
                "id": "ws-3c8reuKc6dqa5FjC"
                }
            }
        }
    }
}

run = api.runs.create(create_run_payload)
run_status = run['data']['attributes']['status']
run_id = run['data']['id']

while run_status != 'planned':
    #print(f"status is: {run_status}")
    run_status = api.runs.show(run_id,include=None)['data']['attributes']['status']
    time.sleep(2)

apply_run_payload = {
  "comment":"Applying from API"
}

try:
    applied_run = api.runs.apply(run["data"]["id"],payload=apply_run_payload)
    print('Run applied successfully.')
except:
    print('Error applying run.')