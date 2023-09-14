import boto3, json
from prettytable import PrettyTable

DYNAMODB = boto3.resource('dynamodb')
COLUMNS = ['ReservationId','RoomNumber','CustomerName','Nights']

def list_all_res(table):
    response = table.scan()
    t = PrettyTable()
    t.field_names = COLUMNS
    t.align['CustomerName'] = 'l'

    for row in response['Items']:
        row_list = []
        for c in COLUMNS:
            row_list.append(row[c])
        t.add_row(row_list)

    return_dict = {
        'raw_scan': response,
        'pretty_table': t.get_string(sortby='ReservationId') 
    }
    return return_dict

def lambda_handler(event,context):
    table_name = f"{event['headers']['customer'].lower()}-reservations"
    table = DYNAMODB.Table(table_name)
    response = list_all_res(table)
    print(response)
    return {
        'statusCode': 200,
        'body': json.dumps(response, default=str)
    }