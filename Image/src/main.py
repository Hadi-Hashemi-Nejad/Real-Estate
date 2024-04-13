import requests
from datetime import date
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
import boto3
import json

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
        self.loop_pages_in_requests()
        self.save_result()
    
    def loop_pages_in_requests(self):
        '''
        Bayut API is paginated (max 25 properties per page). This loops through pages of API for chosen Query 
        and creates a joined dataframe.
        '''
        nbPages = int(requests.get(self.url, headers=self.headers, params=self.querystring).json().get("nbPages"))
        for page in range(nbPages):
            print("Reading page %d of %d in paginated API calls"%(page, nbPages))
            self.querystring["page"] = str(page)
            response = requests.get(self.url, headers=self.headers, params=self.querystring).json()
            df = pd.DataFrame(response.get("hits"))
            self.result = pd.concat([self.result, df], ignore_index=True)
        print("All API calls are completed")
        
    def save_result(self):
        '''
        The joined API calls are saved as a parquet file
        '''
        self.result["ownerID"] = self.result["ownerID"].astype(str) #Some ownerID are not digits. Will need to research
        self.result = self.result.drop('extraFields', axis=1) #This column is empty and schema cannot guess type
        self.file_name = str(date.today())+"_"+self.areaID+".parquet.gzip"
        table = pa.Table.from_pandas(self.result)
        pq.write_table(table, self.file_name)

        with open("AWS_credentials.txt", "r") as creds:
            creds_list = json.loads(creds.read())
        s3_client = boto3.client('s3', aws_access_key_id=creds_list[0], aws_secret_access_key=creds_list[1])
        s3_client.upload_file(self.file_name, "hadis-s3-project-bucket","Real-Estate/input/"+self.file_name)
        print("saved result in s3 bucket")

        
def handler(event, context):
    areaIDs = [6901]
    for areaID in areaIDs:
        importer(areaID)