class cleaner:
    def __init__(self):
        self.temp = ""
    def download_files(self):
        with open("AWS_credentials.txt", "r") as creds:
            creds_list = json.loads(creds.read())
        s3 = boto3.resource('s3', aws_access_key_id=creds_list[0], aws_secret_access_key=creds_list[1])
        my_bucket = s3.Bucket('hadis-s3-project-bucket')
        for object_summary in my_bucket.objects.filter(Prefix="Real-Estate/input/"):
            print(object_summary.key)
            if "Real-Estate/input/"+str(datetime.date.today()) in object_summary.key:
                my_bucket.download_file(object_summary.key, object_summary.key.split("/")[-1])
                print("downloaded")

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