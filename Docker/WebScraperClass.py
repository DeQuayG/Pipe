from cgitb import html
from json import JSONDecoder
from bs4 import BeautifulSoup 
import requests 
import boto3
import botocore

#Queries the page 
# "season" will always be the current season within their URL nomenclature
page = requests.get("https://myanimelist.net/anime/season") 
soup = BeautifulSoup(page.content, 'lxml')  
resource = boto3.resource('s3')
s3 = boto3.resource('s3') 


anime_list =  []
def anime_pull():
    with open('data.txt', 'w') as f:
            for seasonal_anime in soup.find_all('div', class_="seasonal-anime js-seasonal-anime"):
                anime = seasonal_anime.find('a', class_="link-title").text
                anime_synopsis = seasonal_anime.find('p', class_='preline').text
                anime_list.append("Anime Name: \n" + anime)
                anime_list.append("Anime Synopsis: \n" + anime_synopsis) 
                anime_list.append("--------")
                
                f.close()
                
                
                
if __name__ == '__main__':  
    anime_pull()
    s3.Bucket("kyoanibuck3t").put_object(Key= "data.txt", Body= str(anime_list), ACL='public-read')
