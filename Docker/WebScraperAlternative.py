from cgitb import html
from json import JSONDecoder
from bs4 import BeautifulSoup 
import requests 

class Webscraper:  
#Beware, change "https" to "http" because we only enabled port 80 on the ALB and Security Groups
        page = requests.get("http://myanimelist.net/anime/season") 
        soup = BeautifulSoup(page.content, 'lxml')

        def __init__(self, done):
            self.page = done
         
   
        def __call__(self):
#SUCCESSFULLY SCRAPES THE TITLES
                for seasonal_anime in self.soup.find_all('div', class_="seasonal-anime js-seasonal-anime"):
                        anime = seasonal_anime.find('a', class_="link-title").text
                        anime_synopsis = seasonal_anime.find('p', class_='preline').text
                        print("Anime Name: \n" + anime)
                        print("Anime Synopsis: \n" + anime_synopsis) 
                        print("--------")

#Beware, change "https" to "http" because we only enabled port 80 on the ALB and Security Groups
scrape = Webscraper(done="http://myanimelist.net/anime/season") 
scrape()   




