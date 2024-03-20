import requests

url = "https://bayut.p.rapidapi.com/auto-complete"

querystring = {"query":"abu dhabi","hitsPerPage":"25","page":"0","lang":"en"}

headers = {
	"X-RapidAPI-Key": "f70d515e3fmshc7081c7447a5c31p1733e0jsnb81c8ac77ac8",
	"X-RapidAPI-Host": "bayut.p.rapidapi.com"
}

response = requests.get(url, headers=headers, params=querystring)

print(response.json())