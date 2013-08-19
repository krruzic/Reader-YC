import urllib.request
from bs4 import BeautifulSoup
import re

class HackerNewsSearchAPI:
    def pretty_date(time):
        """
        Get a datetime object or a int() Epoch timestamp and return a
        pretty string like 'an hour ago', 'Yesterday', '3 months ago',
        'just now', etc
        """

        from datetime import datetime
        now = datetime.now()
        if type(time) is int:
            diff = now - datetime.fromtimestamp(time)
        elif isinstance(time,datetime):
            diff = now - time
        elif not time:
            diff = now - now
        second_diff = diff.seconds
        day_diff = diff.days

        if day_diff < 0:
            return ''

        if day_diff == 0:
            if second_diff < 10:
                return "Just now"
            if second_diff < 60:
                return str(second_diff) + " seconds ago"
            if second_diff < 120:
                return  "1 minute ago"
            if second_diff < 3600:
                return str( second_diff / 60 ) + " minutes ago"
            if second_diff < 7200:
                return "1 hour ago"
            if second_diff < 86400:
                return str( second_diff / 3600 ) + " hours ago"
        if day_diff == 1:
            return "Yesterday"
        if day_diff < 7:
            return str(day_diff) + " days ago"
        if day_diff < 31:
            return str(day_diff//7) + " weeks ago"
        if day_diff < 365:
            return str(day_diff//30) + " months ago"
        if str(day_diff//365) == '1':
            return str(day_diff//365) + " year ago"
        return str(day_diff//365) + " years ago"

    def getResults(self, startIndex, source):
        """
        Queries the HNSearch API and returns
        tuples of the results
        """

        url = 'http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][title]=%s&start=%d&limit=30' % startIndex % quote(search) # requests the search from the api
        response = urllib.request.urlopen(url).read() # reads the returned data
        items = json.loads(response.decode('ascii'))
        incomplete_iso_8601_format = '%Y-%m-%dT%H:%M:%SZ' # The time is returned in this format
        res = []
        results = items['results']
        for e in items['results']: # Go through each result, creating a tuple, which represents an result
            _id = e['item']['id']
            title = e['item']['title']
            points = e['item']['points']
            num_comments = e['item']['num_comments']
            poster = e['item']['username']
            timestamp = pretty_date(datetime.strptime(e['item']['create_ts'], incomplete_iso_8601_format))
            result = (str(_id), title, poster, str(points), str(num_comments), timestamp)
