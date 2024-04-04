"""
Vincent Papelard, 2024

This script configures and runs a REST API that enables access to the database
used in the project "Your News Anchor". It is implemented using FastAPI. The
database itself is implemented using PostgreSQL.

In order to run this script, execute uvicorn app:app --reload in the directory 
where this script is located.
"""
import os
from typing import List
from datetime import datetime

import yaml
import psycopg2
from fastapi import FastAPI, Response
from fastapi.responses import JSONResponse
from pydantic import BaseModel

app = FastAPI()
config = yaml.safe_load(open("./config.yml"))

# Getting API key and DB password fron environment values
config["security_token"] = os.environ["API_TOKEN"]
config["database_password"] = os.environ["DB_PWD"]


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
    is_from_user: bool

class ArticlesUpdateRequest(BaseModel):
    """
    Data sent to the /update_articles endpoint to request an update of the 
    daily articles stored in the database.
    """
    security_token: str
    articles: List[Article]

class FeedsRetrievalRequest(BaseModel):
    """
    Request sent to the /feeds in order to retrieve the list of feeds for
    a user.
    """
    username: str # The name of the user
    security_token: str # The API security token


@app.get("/")
async def root():
    """
    Returns a help message.
    """
    return {"msg": "Please send requests to the /feeds and /update_articles endpoints"}

@app.post("/feeds", status_code=200)
async def get_rss_feeds(retrieval_request: FeedsRetrievalRequest, response: Response):
    """
    Returns a list of all the RSS feeds to extract data from available to a specific user.

    This includes all standard RSS feeds (available to everyone) as well as
    the RSS feeds the user registered himself.
    """
    if retrieval_request.security_token != config["security_token"]:
        return JSONResponse(status_code=401, content={"msg": "Your security code is not valid"})
    
    username = retrieval_request.username
    user_exists_request = f"""SELECT * FROM users WHERE username='{username}'"""
    cursor = conn.cursor()
    cursor.execute(user_exists_request)
    results = cursor.fetchall()
    if not results:
        return JSONResponse(status_code=401, content={"msg": f"User {username} does not exist in the database"})

    get_id_query = f"""SELECT id from users where username='{username}'"""
    cursor.execute(get_id_query)
    results = cursor.fetchall()
    if not results:
        JSONResponse(status_code=401, content={"msg": f"Error: could not retrieve id for use {username}"})
    user_id = results[0][0]
    print(user_id)
    fetch_rss_feeds_request = f"""SELECT url, language, topic, name FROM (select url, language, topic, name from user_sources where user_id={user_id}) union  (select url, language, topic, name from standard_sources where not exists (select * from user_sources where user_sources.url=standard_sources.url));"""
    
    cursor.execute(fetch_rss_feeds_request)
    results = cursor.fetchall()

    # Turning the resulting data into a dictionary for ease of use
    dict_results = []
    for rss in results:
        dict_rss = {
            "name": rss[3],
            "url": rss[0],
            "topic": rss[2],
            "language": rss[1]
        }
        dict_results.append(dict_rss)
    return dict_results

@app.post("/all_feeds", status_code=200)
async def get_all_rss_feeds(secret_token: str, response: Response):
    """
    Returns a list of all the RSS feeds saved in the database.
    """
    if secret_token != config["security_token"]:
        return JSONResponse(status_code=401, content={"msg": "Your security code is not valid"})
    
    # Retrieving user-added sources
    fetch_user_rss_feeds_request = f"""SELECT id, url, language, topic, name FROM user_sources;"""
    cursor = conn.cursor()
    cursor.execute(fetch_user_rss_feeds_request)
    results = cursor.fetchall()

    # Turning the resulting data into a dictionary for ease of use
    dict_results = []
    for rss in results:
        dict_rss = {
            "source_id": rss[0],
            "name": rss[4],
            "url": rss[1],
            "topic": rss[3],
            "language": rss[2],
            "is_from_user": True
        }
        dict_results.append(dict_rss)
    
    # Retrieving standard sources
    fetch_standard_rss_feeds_request = f"""SELECT id, url, language, topic, name from standard_sources;"""
    cursor.execute(fetch_standard_rss_feeds_request)
    results = cursor.fetchall()
    for rss in results:
        dict_rss = {
            "source_id": rss[0],
            "name": rss[4],
            "url": rss[1],
            "topic": rss[3],
            "language": rss[2],
            "is_from_user": False
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
    cursor.execute("SELECT id, is_from_user FROM daily_articles")
    old_article_id_tuples = cursor.fetchall()
    old_article_ids = []

    for id_tuple in old_article_id_tuples:
        old_article_ids.append(str(id_tuple))
    for article in articles:

        # Formatting the date (if any) before inserting it in the table
        date = article.date
        if date: # i.e. if the date string is not empty
            date = datetime.strptime(date, '%a %d %b %Y, %I:%M%p')
            if article.is_from_user:
                request = f"""INSERT INTO daily_articles(title, url, content, rss_source_id, authors, date, image, is_from_user, user_source_id) VALUES('{article.title.replace("'", '"')}', '{article.url.replace("'", '"')}', '{article.content.replace("'", '"')}', {article.source_id}, '{article.authors.replace("'", '"')}', '{date}', '{article.image}', TRUE, {article.source_id})"""
            else:
                request = f"""INSERT INTO daily_articles(title, url, content, rss_source_id, authors, date, image, is_from_user, standard_source_id) VALUES('{article.title.replace("'", '"')}', '{article.url.replace("'", '"')}', '{article.content.replace("'", '"')}', {article.source_id}, '{article.authors.replace("'", '"')}', '{date}', '{article.image}', FALSE, {article.source_id})"""
        else:
            if article.is_from_user:
                request = f"""INSERT INTO daily_articles(title, url, content, rss_source_id, authors, image, is_from_user, user_source_id) VALUES('{article.title.replace("'", '"')}', '{article.url.replace("'", '"')}', '{article.content.replace("'", '"')}', {article.source_id}, '{article.authors.replace("'", '"')}', '{article.image}', TRUE, {article.source_id})"""
            else:
                request = f"""INSERT INTO daily_articles(title, url, content, rss_source_id, authors, image, is_from_user, standard_source_id) VALUES('{article.title.replace("'", '"')}', '{article.url.replace("'", '"')}', '{article.content.replace("'", '"')}', {article.source_id}, '{article.authors.replace("'", '"')}', '{article.image}', FALSE, {article.source_id})"""
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


    





