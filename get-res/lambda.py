import boto3
from prettytable import PrettyTable

dynamodb = boto3.resource('dynamodb')

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