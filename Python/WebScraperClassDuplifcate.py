from cgitb import html
from json import JSONDecoder
import json
from bs4 import BeautifulSoup 
import requests 
import boto3 as boto3
import sys

class Webscraper:  
#Beware, change "https" to "http" because we only enabled port 80 on the ALB and Security Groups
        page = requests.get("http://myanimelist.net/anime/season") 
        soup = BeautifulSoup(page.content, 'lxml').encode("utf-8")

        def __init__(self, done):
#Queries the page
            self.page = done
         
   
        def __call__(self):
#SUCCESSFULLY SCRAPES THE TITLES
                with open('items.json', 'w') as table_item:
                        sys.stdout = table_item    
                        for seasonal_anime in self.soup.find_all('div', class_="seasonal-anime js-seasonal-anime"):
                                anime = seasonal_anime.find('a', class_="link-title").text
                                anime_synopsis = seasonal_anime.find('p', class_='preline').text
                                print ("Anime Name: " + anime)
                                print ("Anime Synopsis: " + anime_synopsis)  
                        table_item.close()

                                
#Beware, change "https" to "http" because we only enabled port 80 on the ALB and Security Groups
scrape = Webscraper(done="http://myanimelist.net/anime/season") 
scrape()  


dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('exampletable') 

# Read the JSON file
with open('items.json') as json_data:
    items = json.load(json_data)

    with table.batch_writer() as batch:

        # Loop through the JSON objects
        for item in items:
            batch.put_item(Item=item)