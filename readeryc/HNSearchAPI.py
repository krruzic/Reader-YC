import re, json

from bs4 import BeautifulSoup
from datetime import datetime
from time import mktime
import requests
from urllib.parse import quote


class NoResultsFoundException(Exception):
    pass


def pretty_date(time):
    """
    Get a datetime object or a int() Epoch timestamp and return a
    pretty string like 'an hour ago', 'Yesterday', '3 months ago',
    'just now', etc
    """

    from datetime import datetime
    now = datetime.now()
    print(time)
    if type(time) is int:
        diff = now - datetime.fromtimestamp(time)
    elif isinstance(time,datetime):
        diff = now - time
    elif not time:
        diff = now - now
    second_diff = diff.seconds
    day_diff = diff.days

    if day_diff < 0:
        return "Just now "

    if day_diff == 0:
        if second_diff < 10:
            return "Just now "
        if second_diff < 60:
            return str(second_diff) + " seconds ago "
        if second_diff < 120:
            return  "1 minute ago "
        if second_diff < 3600:
            return str( second_diff // 60 ) + " minutes ago "
        if second_diff < 7200:
            return "1 hour ago "
        if second_diff < 86400:
            return str( second_diff // 3600 ) + " hours ago "
    if day_diff == 1:
        return "Yesterday "
    if day_diff < 7:
        return str(day_diff) + " days ago "
    if day_diff < 31:
        return str(day_diff // 7) + " weeks ago "
    if day_diff < 365:
        return str(day_diff // 30) + " months ago "
    if str(day_diff // 365) == '1':
        return str(day_diff // 365) + " year ago "
    return str(day_diff // 365) + " years ago "

def getSearchResults(startIndex, source):
    """
    Queries the HNSearch API and returns
    tuples of the results
    """
    HEADERS = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.29 Safari/537.22',
    }
    print("STARTING: " + str(startIndex))
    url = 'http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][title]={0}&start={1}&limit=30&sortby=create_ts+desc'.format(quote(source), startIndex)  # requests the search from the api
    print(url)
    r = requests.get(url, headers=HEADERS) # reads the returned data
    print("Page curled")
    items = json.loads(r.json())
    if items['hits'] == 0:
        raise NoResultsFoundException('No stories were found')

    incomplete_iso_8601_format = '%Y-%m-%dT%H:%M:%SZ' # The time is returned in this format
    res = []
    results = items['results']
    for e in items['results']:
        if (e['item']['text'] != None): # Javascript uses lowercase for bools...
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
        timestamp = pretty_date(datetime.strptime(e['item']['create_ts'], incomplete_iso_8601_format))
        print(isAsk)
        result = (title, poster, points, str(num_comments), timestamp, str(_id), domain, articleURL, commentURL, isAsk)
        print('sending story!')
        return result