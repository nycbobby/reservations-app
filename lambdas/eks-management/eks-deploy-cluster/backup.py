import boto3
import json
import time
import os
from terrasnek.api import TFC

# get tfc token from ASM
client = session.client('secretsmanager', region_name='us-east-1')
secret_value = client.get_secret_value(
    SecretId='tfc_token'
)

# test data
# TFC_URL = 'https://app.terraform.io'
# TFC_ORG = 'tba_bb'
# WORKSPACE_ID = 'ws-3c8reuKc6dqa5FjC'

# set constants
TFC_TOKEN = json.loads(secret_value['SecretString'])['tfc_token']
TFC_URL = os.environ['TFC_URL']
TFC_ORG = os.environ['TFC_ORG']
WORKSPACE_ID = os.environ['WORKSPACE_ID']

API = TFC(TFC_TOKEN, url=TFC_URL)
API.set_org(TFC_ORG)

CREATE_RUN_PAYLOAD = {
    "data": {
        "attributes": {
        "message": "Starting run through API"
        },
        "type":"runs",
        "relationships": {
            "workspace": {
                "data": {
                "type": "workspaces",
                "id": WORKSPACE_ID
                }
            }
        }
    }
}

APPLY_RUN_PAYLOAD = {"comment":"Applying from API"}

def error(msg):
    print(msg)
    raise ValueError(msg)

def apply_run(run_id):
    try:
        API.runs.apply(run_id,payload=APPLY_RUN_PAYLOAD)
        print('Run applied successfully.')
    except:
        error('Error applying run.')


def plan_waiter(run_status, run_id):
    # waits for Terraform plan to complete
    while run_status not in ['planned','planned_and_finished']:
        run_status = API.runs.show(run_id,include=None)['data']['attributes']['status']
        print(f'current run status: {run_status}')
        time.sleep(2)

def create_run():
    # create Terraform run
    try:
        run = API.runs.create(CREATE_RUN_PAYLOAD)
        print('Run created successfully.')
    except:
        error('Error creating run.')
    run_status = run['data']['attributes']['status']
    run_id = run['data']['id']
    plan_waiter(run_status, run_id)
    return run_id

def lambda_handler(event, context):
    # lambda entrypoint
    run_id = create_run()
    apply_run(run_id)

    return {
        'statusCode': 200,
        'body': "OK"
    }

lambda_handler('','')
