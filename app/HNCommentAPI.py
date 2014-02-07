import urllib.request
from bs4 import BeautifulSoup
import re, json, os, glob, html.parser

import tart




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
    return text


def flatten(comments, level = 0):
    #comments is a list
    h = html.parser.HTMLParser() # To decode the HTML entities

    if not comments:
        return []#exit case

    res = []
    #add the level key so you can keep track of the original level
    for c in comments:
        c['indent'] = level * 40
        c['text'] = h.unescape(c['text'])
        c['time'] = c['created_at']

        #removes the childs from the item (important)
        childs = c.pop('children', [])
        #adds the item to the result
        res.append(c)
        #and the flattened childs later
        res += flatten(childs, level+1)
        #in the next loop the next sibling will be added

    return res




def getCommentPage(source, isAsk):
    """Gets the comments and text of the post
    """

    workingDir = os.getcwd() + '/data/cache/'
    textURL = 'https://news.ycombinator.com/item?id=%s' % source
    commentsURL = 'http://hn.algolia.com/api/v1/items/{0}'.format(source)

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
    if (comments == []):
        tart.send('commentError', text="No comments! Check back later!")
    for comment in comments:
        tart.send('addComments', comment=comment, hnid=source)