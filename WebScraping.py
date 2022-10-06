import requests, openpyxl
from bs4 import BeautifulSoup

excel = openpyxl.Workbook()
sheet = excel.active
sheet.title = 'Top IMDB movies'
sheet.append(['Rank','Title','Year','Rating'])

url = requests.get('https://www.imdb.com/india/top-rated-indian-movies/')
url.raise_for_status()

soup = BeautifulSoup(url.content,'html.parser')

movies = soup.find('tbody', class_= "lister-list").find_all('tr')

for movie_1 in movies:
    movie_rank = movie_1.find('td', class_= 'titleColumn').get_text(strip=True).split('.')[0]
    movie_title = movie_1.find('td', class_= 'titleColumn').find('a').text
    movie_year = movie_1.find('td', class_= 'titleColumn').find('span').text.strip('()')
    movie_rate = movie_1.find('td', class_= 'ratingColumn imdbRating').find('strong').text
    movie_list = [movie_rank, movie_title, movie_year, movie_rate ]
    sheet.append([movie_rank, movie_title, movie_year, movie_rate ])
    
excel.save('IMDB Movies.xlsx')



