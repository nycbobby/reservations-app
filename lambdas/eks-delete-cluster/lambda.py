import boto3
import time
import os

CLIENT = boto3.client('eks')
CLUSTER_NAME = os.environ['cluster_name']
NODEGROUP_NAME = os.environ['nodegroup_name']

def error(msg):
    # print error message to Cloudwatch logs an exit
    print(msg)
    raise ValueError(msg)

def delete_cluster():
    # delete eks cluster
    try:
        CLIENT.delete_cluster(
            name=CLUSTER_NAME
        )
    except:
        error('Error deleting cluster.')

def delete_waiter(delete_obj):
    # wait for delete nodegroup to complete
    status = delete_obj['nodegroup']['status']
    while status == 'DELETING':
        try:
            response = describe_nodegroup()
            status = response['nodegroup']['status']
            time.sleep(2)
        except:
            status = 'n/a'

def delete_nodegroup():
    # delete nodegroup
    try:
        response = CLIENT.delete_nodegroup(
            clusterName=CLUSTER_NAME,
            nodegroupName=NODEGROUP_NAME
        )
    except:
        error('Error deleting nodegroup.')
    delete_waiter(response)

def describe_nodegroup():
    # describe nodegroup
    nodegroup_obj = CLIENT.describe_nodegroup(
        clusterName=CLUSTER_NAME,
        nodegroupName=NODEGROUP_NAME
    )
    return nodegroup_obj

def lambda_handler(event, context):
    # lambda entrypoint
    delete_nodegroup()
    delete_cluster()

    return {
        'statusCode': 200,
        'body': "OK"
    }
  