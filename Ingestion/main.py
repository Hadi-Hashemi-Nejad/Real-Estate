import requests
import json

url = "https://bayut.p.rapidapi.com/properties/list"

querystring = {"locationExternalIDs":"5002,6020","purpose":"for-sale","hitsPerPage":"2","lang":"en","sort":"city-level-score","categoryExternalID":"4","priceMax":"5000000","areaMin":"1300","roomsMin":"2","roomsMax":"2"}

headers = {
	"X-RapidAPI-Key": "f70d515e3fmshc7081c7447a5c31p1733e0jsnb81c8ac77ac8",
	"X-RapidAPI-Host": "bayut.p.rapidapi.com"
}

response = requests.get(url, headers=headers, params=querystring)

# print(json.dumps(response.json(),indent=4))
print(response.json().items())