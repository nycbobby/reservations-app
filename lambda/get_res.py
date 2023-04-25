import boto3
from prettytable import PrettyTable

session = boto3.Session(
    aws_access_key_id="AKIATZUPZTKPT33VCENR",
    aws_secret_access_key="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",
    region_name="us-east-1"
)

dynamodb = session.resource('dynamodb')

TABLE = dynamodb.Table('Reservations')
COLUMNS = ['ReservationId','RoomNumber','CustomerName','Nights']

def list_all_res():
    response = TABLE.scan()
    t = PrettyTable()
    t.field_names = COLUMNS
    t.align['CustomerName'] = 'l'

    for row in response['Items']:
        row_list = []
        for c in COLUMNS:
            row_list.append(row[c])
        t.add_row(row_list)

    return t.get_string(sortby='ReservationId')

def lambda_handler(event,context):
    response = list_all_res()
    print(response)
    return {
        'statusCode': 200,
        'body': response
    }