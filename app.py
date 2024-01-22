"""
Vincent Papelard, 2024

This script configures and runs a REST API that enables access to the database
used in the project "Your News Anchor". It is implemented using FastAPI. The
database itself is implemented using PostgreSQL.

In order to run this script, execute uvicorn app:app --reload in the directory 
where this script is located.
"""
from typing import List
from datetime import datetime

import yaml
import psycopg2
from fastapi import FastAPI, Response, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel

app = FastAPI()
config = yaml.safe_load(open("./config.yml"))

# Inits the database
conn = psycopg2.connect(database=config["database_name"],
                    host=config["database_url"],
                    user=config["database_user"],
                    password=config["database_password"],
                    port=config["database_port"])


class Article(BaseModel):
    """
    Data structure that stores information about an article.
    """
    source_id: int
    source: str
    url: str
    title: str
    content: str
    authors: str
    # Images as passed as URLs
    image: str
    # Publish dates are passed as strings (datetime.datetime objects are not
    # serializable).
    # These strings are formatted as '%a %d %b %Y, %I:%M%p'
    # (or as en empty string if no publish date was found)
    date: str

class ArticlesUpdateRequest(BaseModel):
    """
    Data sent to the /update_articles endpoint to request an update of the 
    daily articles stored in the database.
    """
    security_token: str
    articles: List[Article]


@app.get("/")
async def root():
    """
    Returns a help message.
    """
    raise NotImplemented

@app.get("/feeds")
async def get_rss_feeds():
    """
    Returns a list of all the RSS feeds to extract data from.
    """
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM rss_feeds")
    results = cursor.fetchall()

    # Turning the resulting data into a dictionary for ease of use
    dict_results = []
    for rss in results:
        dict_rss = {
            "source_id": rss[0],
            "name": rss[1],
            "url": rss[2],
            "topic": rss[3],
            "language": rss[4]
        }
        dict_results.append(dict_rss)
    return dict_results


@app.post("/update_articles", status_code=200)
async def update_articles(new_articles: ArticlesUpdateRequest, response: Response):
    """
    Removes all daily articles currently stored in the database and
    replaces them with the ones sent through this request.
    """


    # Checking the security token to make sure the user is allowed to update
    # the daily articles, as this is a destructive action.
    # Any unauthorized request will yield a 401 error.
    if new_articles.security_token != config["security_token"]:
        return JSONResponse(status_code=401, content={"msg": "Your security code is not valid"})
    
    articles = new_articles.articles
    # Adding the new articles to the daily_articles table
    cursor = conn.cursor()
    cursor.execute("SELECT id FROM daily_articles")
    old_article_id_tuples = cursor.fetchall()
    old_article_ids = []

    for id_tuple in old_article_id_tuples:
        old_article_ids.append(str(id_tuple[0]))
    for article in articles:

        # Formatting the date (if any) before inserting it in the table
        date = article.date
        if date: # i.e. if the date string is not empty
            date = datetime.strptime(date, '%a %d %b %Y, %I:%M%p')
            request = f"""INSERT INTO daily_articles(title, url, content, rss_source_id, authors, date, image) VALUES('{article.title.replace("'", '"')}', '{article.url.replace("'", '"')}', '{article.content.replace("'", '"')}', {article.source_id}, '{article.authors.replace("'", '"')}', '{date}', '{article.image}')"""
        else:
            request = f"""INSERT INTO daily_articles(title, url, content, rss_source_id, authors, image) VALUES('{article.title.replace("'", '"')}', '{article.url.replace("'", '"')}', '{article.content.replace("'", '"')}', {article.source_id}, '{article.authors.replace("'", '"')}', '{article.image}')"""

        cursor.execute(request)
    conn.commit()

    # Erasing all old articles.
    # Old articles are deleted only after the new ones have been added in order
    # to avoid a situation where a bug would arise after deleting everything in
    # the table, thus leading to an empty table.
    if old_article_ids:
        request = f"""DELETE FROM daily_articles WHERE id IN ({", ". join(old_article_ids)});"""
    else:
        request = f"""DELETE * FROM daily_articles;"""
    cursor.execute(request)
    conn.commit()


    





