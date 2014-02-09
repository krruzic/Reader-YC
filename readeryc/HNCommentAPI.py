from bs4 import BeautifulSoup
import re, json, os, glob, requests
from datetime import *


def pretty_date(time):
    """
Get a datetime object or a int() Epoch timestamp and return a
pretty string like 'an hour ago', 'Yesterday', '3 months ago',
'just now', etc
"""

    now = datetime.utcnow()
    if type(time) is int:
        diff = now - datetime.fromtimestamp(time)
    elif isinstance(time, datetime):
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
            return "1 minute ago "
        if second_diff < 3600:
            return str( second_diff // 60 ) + " minutes ago "
        if second_diff < 7200:
            return "1 hour ago "
        if second_diff < 86400:
            return str( second_diff // 3600 ) + " hours ago "
    if day_diff == 1:
        return "Yesterday "
    if day_diff <= 7:
        return str(day_diff) + " days ago "
    if day_diff < 31:
        return str(day_diff // 7) + " weeks ago "
    if str(day_diff // 365) == '1':
        return str(day_diff // 365) + " year ago "
    return str(day_diff // 365) + " years ago "

def getText(url):
    """Finds the text portion of text posts,
       and returns it to tart.
    """
    HEADERS = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.29 Safari/537.22',
    }


    source = requests.get(url, headers=HEADERS)

    soup = BeautifulSoup(source.content)

    text_content = soup.findAll("tr")
    text_content =str(text_content[7])

    textStart = text_content.find('d><td>') + 6
    textEnd = text_content.find('</td', textStart)
    text = text_content[textStart:textEnd]
    if (text == 'td><img height="1" src="s.gif" width="0"/>'): # Checks for dead
        self.dead = True
        text = "[dead]"
    if '<form action="/r"' in text: # Sometimes my method of checking for text posts fails...
        text = ""
    #tart.send('addText', text=text)
    text = text.replace('rel="nofollow"', '')
    text = text.replace('<p>', '\n') # Replace unclosed <p>'s with new lines
    text = text.replace('</p>', '') # Remove the crap BS4 adds

    return text


def flatten(comments, level = 0):
    #comments is a list

    if not comments:
        return []#exit case

    res = []
    #add the level key so you can keep track of the original level
    for comment in comments:
        #comment['text'] = comment['text'].replace('rel="nofollow"', '')
        #comment['text'] = comment['text'].replace('\n', '')
        # comment['text'] = comment['text'].replace('</p>', '') # Remove the crap BS4 adds
        comment['indent'] = level * 40
        parts = comment['created_at'].split('.')
        dt = datetime.strptime(parts[0], "%Y-%m-%dT%H:%M:%S")
        comment['time'] = pretty_date(dt) # returns a relative date

        #removes the childs from the item (important)
        childs = comment.pop('children', [])
        #adds the item to the result
        res.append(comment)
        #and the flattened childs later
        res += flatten(childs, level+1)
        #in the next loop the next sibling will be added

    return res



def getCommentPage(source, isAsk):
    """Gets the comments and text of the post
    """

    HEADERS = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.29 Safari/537.22',
    }


    textURL = 'https://news.ycombinator.com/item?id=%s' % source
    commentsURL = 'http://hn.algolia.com/api/v1/items/{0}'.format(source)
    text = ""
    if (isAsk == "true"):
        text = getText(textURL)

    r = requests.get(commentsURL, headers=HEADERS)

    toFlatten = r.json()
    #toFlatten = json.loads(decoded)
    print("Flattening comments")
    if ('message' in toFlatten):
        if (toFlatten['message'] == 'ObjectID does not exist'):
            return text, []
    comments = flatten(toFlatten['children'])


    return text, comments # possibly zero comments