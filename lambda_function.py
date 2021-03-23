import json
import boto3
import os

#Network Manager API only works with request to us-west-2  See: https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/networkmanager.html#NetworkManager.Client.register_transit_gateway
region='us-west-2'

def lambda_handler(event, context):
    
    nm_client = boto3.client('networkmanager',region_name=region)
    
    #Get Global Network Id from enviroment variable
    globalnetwork_id = os.environ.get('GlobalNetworkId')

    #Get TransitGatewayARN from lambda execution
    tgw_arn=event['tgw_arn']
    print(event['tgw_arn'])
    print(globalnetwork_id)

    try:
        response = nm_client.register_transit_gateway(
           GlobalNetworkId=globalnetwork_id,
           TransitGatewayArn=tgw_arn
           )
        print("Log: Registation success")   
    except: 
        #This will happen when running terraform destroy since the lambda is trigger again for the already registered TGW.
        response = {"errorMessage": tgw_arn+"  has already been registered or is in the process of being registered/deregistered."}
        print("Log: Registation failed")
    return response
