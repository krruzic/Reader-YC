import urllib.request
from bs4 import BeautifulSoup
import re, json, os, glob, html.parser
from datetime import *

import tart

from datetime import *

def pretty_date(time):
    """
Get a datetime object or a int() Epoch timestamp and return a
pretty string like 'an hour ago', 'Yesterday', '3 months ago',
'just now', etc
"""
    print(type(time))
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

    print("curling page: " + url)
    with urllib.request.urlopen(url) as url:
        source = url.read()
    print("page curled")

    soup = BeautifulSoup(source)

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
    h = html.parser.HTMLParser() # To decode the HTML entities

    if not comments:
        return []#exit case

    res = []
    #add the level key so you can keep track of the original level
    for comment in comments:
        comment['text'] = comment['text'].replace('rel="nofollow"', '')
        comment['text'] = comment['text'].replace('\n', '')
        comment['text'] = comment['text'].replace('<p>', '\n') # Replace unclosed <p>'s with new lines
        comment['text'] = comment['text'].replace('</p>', '') # Remove the crap BS4 adds
        comment['indent'] = level * 40
        comment['text'] = h.unescape(comment['text'])
        parts = comment['created_at'].split('.')
        dt = datetime.strptime(parts[0], "%Y-%m-%dT%H:%M:%S")
        print(dt)
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

    textURL = 'https://news.ycombinator.com/item?id=%s' % source
    commentsURL = 'http://hn.algolia.com/api/v1/items/{0}'.format(source)
    text = ""
    if (isAsk == "true"):
        text = getText(textURL)

    print("curling page: " + commentsURL)
    with urllib.request.urlopen(commentsURL) as url:
        urlSource = url.read()
    print("page curled")

    decoded = urlSource.decode("utf-8")
    toFlatten = json.loads(decoded)
    print("Flattening comments")
    comments = flatten(toFlatten['children'])


    print("Sending comments")
    tart.send('addText', text=text, hnid=source)
    if (comments == []):
        tart.send('commentError', text="No comments! Check back later!")
    for comment in comments:
        tart.send('addComments', comment=comment, hnid=source)