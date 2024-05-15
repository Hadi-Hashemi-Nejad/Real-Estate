import requests
from io import BytesIO
import pyarrow as pa
import pyarrow.csv as pv
import pyarrow.parquet as pq
from datetime import date
import boto3
import os

class Downloader:
    def __init__(self):
        self.url = 'https://www.dubaipulse.gov.ae/dataset/3b25a6f5-9077-49d7-8a1e-bc6d5dea88fd/resource/a37511b0-ea36-485d-bccd-2d6cb24507e7/download/transactions.csv'
        self.filename = str(date.today())+"_"+"DLD_transactions.parquet.gzip"
        self.download_and_save()

    def download_and_save(self):
        '''
        This def downloads Dubai's historical files from dubai pulse website and then saves it in s3 bucket.
        Beware that this file is large and will take some time.
        '''
        print("starting DLD transactions download")
        response = requests.get(self.url)
        print("finished DLD transactions download")

        files = [f for f in os.listdir('.') if os.path.isfile(f)]
        if 'terraform.tfvars' in files:
            with open("terraform.tfvars", "r") as creds:
                creds_list = creds.read().split('[', 1)[1].split(']')[0]
                creds_list = list(eval(creds_list))
        else:
            with open("../../../terraform.tfvars", "r") as creds:
                creds_list = creds.read().split('[', 1)[1].split(']')[0]
                creds_list = list(eval(creds_list))

        transactions_table = pv.read_csv(BytesIO(response.content))
        writer = pa.BufferOutputStream()
        pq.write_table(transactions_table, writer)
        body = bytes(writer.getvalue())
        print("starting upload to s3 bucket")
        session = boto3.Session(region_name="us-east-1", aws_access_key_id=creds_list[0], aws_secret_access_key=creds_list[1])
        s3 = session.client("s3")
        s3.put_object(Body=body, Bucket="hadis-s3-project-bucket", Key="Real-Estate/input/"+self.filename)
        print("finshed upload to s3 bucket")


def handler(event, context):
    '''
    This def runs when docker image is started
    '''
    Downloader()

if __name__ == "__main__":
    '''
    This def runs when you are manually running python file
    '''
    Downloader()