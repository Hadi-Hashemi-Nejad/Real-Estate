import requests
from datetime import date
import pandas as pd
import pyarrow as pa
import pyarrow.csv as pv
import pyarrow.parquet as pq
import boto3
import json
import os

class importer:
    def __init__(self, areaID=6901):
        self.areaID = str(areaID)
        self.headers = {"X-RapidAPI-Key": "f70d515e3fmshc7081c7447a5c31p1733e0jsnb81c8ac77ac8",
                                  "X-RapidAPI-Host": "bayut.p.rapidapi.com"}
        self.url = "https://bayut.p.rapidapi.com/properties/list"
        self.querystring = {"locationExternalIDs":"6901", #6901 refers to Downtown Dubai
                            "purpose":"for-sale",
                            "hitsPerPage":"25","page":"0",
                            "lang":"en",
                            "sort":"date-desc",
                            "categoryExternalID":"4",
                            "priceMax":"4000000",
                            "areaMin":"120",
                            "roomsMin":"2","roomsMax":"2"}
        self.querystring["locationExternalIDs"] = self.areaID
        self.result = pd.DataFrame()
		#Running functions now
        print("starting API requests")
        self.bayut_pages_in_requests()   
        print("saving results")     
        self.save_result()
    
    def bayut_pages_in_requests(self):
        '''
        Bayut API is paginated (max 25 properties per page). This loops through pages of API for chosen Query 
        and creates a joined dataframe.
        '''
        nbPages = int(requests.get(self.url, headers=self.headers, params=self.querystring).json().get("nbPages"))
        for page in range(nbPages):
            print("Reading page %d of %d in paginated API calls"%(page+1, nbPages))
            self.querystring["page"] = str(page)
            response = requests.get(self.url, headers=self.headers, params=self.querystring).json()
            df = pd.DataFrame(response.get("hits"))
            self.result = pd.concat([self.result, df], ignore_index=True)
        print("All API calls are completed")
        
    def save_result(self):
        '''
        The joined API calls are saved as a parquet file in your s3 bucket
        '''
        self.result["ownerID"] = self.result["ownerID"].astype(str) #Some ownerID are not digits. Will need to research
        self.result = self.result.drop('extraFields', axis=1) #This column is empty and schema cannot guess type
        table = pa.Table.from_pandas(self.result)
        file_name = str(date.today())+"_bayut_listings_for_"+self.areaID+".parquet.gzip"
        files = [f for f in os.listdir('.') if os.path.isfile(f)]
        if 'terraform.tfvars' in files:
            with open("terraform.tfvars", "r") as creds:
                creds_list = creds.read().split('[', 1)[1].split(']')[0]
                creds_list = list(eval(creds_list))
        else:
            with open("../../../terraform.tfvars", "r") as creds:
                creds_list = creds.read().split('[', 1)[1].split(']')[0]
                creds_list = list(eval(creds_list))

        writer = pa.BufferOutputStream()
        pq.write_table(table, writer)
        body = bytes(writer.getvalue())
        session = boto3.Session(region_name="us-east-1", aws_access_key_id=creds_list[0], aws_secret_access_key=creds_list[1])
        s3 = session.client("s3")
        s3.put_object(Body=body, Bucket="hadis-s3-project-bucket", Key="Real-Estate/input/"+file_name)

        print("saved result in s3 bucket")

        
def handler(event, context):
    '''
    This def runs when docker image is started
    '''
    areaIDs = [6901]
    for areaID in areaIDs:
        importer(areaID)

if __name__ == "__main__":
    '''
    This def runs when you are manually running python file
    '''
    areaIDs = [6901]
    for areaID in areaIDs:
        importer(areaID)