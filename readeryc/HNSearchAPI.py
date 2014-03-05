import re, json

from bs4 import BeautifulSoup
from datetime import datetime
from time import mktime
import requests
from urllib.parse import quote
from .readerutils import readerutils

class NoResultsFoundException(Exception):
    pass


def getSearchResults(startIndex, source):
    """
    Queries the HNSearch API and returns
    tuples of the results
    """
    print("STARTING: " + str(startIndex))
    url = 'http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][title]={0}&start={1}&limit=30&sortby=create_ts+desc'.format(quote(source), startIndex)  # requests the search from the api
    print(url)
    r = requests.get(url, headers=readerutils.HEADERS) # reads the returned data
    print("Page curled")
    items = r.json()
    if items['hits'] == 0:
        raise NoResultsFoundException('No stories were found')

    incomplete_iso_8601_format = '%Y-%m-%dT%H:%M:%SZ' # The time is returned in this format
    res = []
    results = items['results']
    for e in items['results']:
        if e['item']['text'] != None: # Javascript uses lowercase for bools...
            isAsk = 'true'
        else:
            isAsk = 'false'
        _id = e['item']['id']
        title = e['item']['title']
        points = e['item']['points']
        if (points == 1):
            points = str(points)
        else:
            points = str(points)
        num_comments = e['item']['num_comments']
        domain = e['item']['domain']
        poster = e['item']['username']
        articleURL = e['item']['url']
        commentURL = 'https://news.ycombinator.com/item?id=' + str(_id)
        if (isAsk == 'true'): # Ask posts don't have a domain or articleURL
            domain = "http://news.ycombinator.com/"
            articleURL = commentURL
        timestamp = readerutils.prettyDate(datetime.strptime(e['item']['create_ts'], incomplete_iso_8601_format))
        result = {
            'title': title, 
            'poster': poster, 
            'points': points, 
            'num_comments': str(num_comments), 
            'timestamp': timestamp, 
            'id': str(_id), 
            'domain': domain, 
            'articleURL': articleURL, 
            'commentURL': commentURL, 
            'isAsk': isAsk
            }
        res.append(result)

    return res


