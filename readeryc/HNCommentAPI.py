from bs4 import BeautifulSoup
import re, json, os, glob, requests, time, html.parser
from datetime import *
from .readerutils import readerutils



def flatten(comments, level = 0):
    #comments is a list
    h = html.parser.HTMLParser() # To decode the HTML entities

    if not comments:
        return []#exit case

    res = []
    #add the level key so you can keep track of the original level
    for comment in comments:
        comment['indent'] = level * 40
        parts = comment['created_at'].split('.')
        dt = datetime.strptime(parts[0], "%Y-%m-%dT%H:%M:%S")
        comment['time'] = pretty_date(dt) # returns a relative date
        #comment['text'] = h.unescape(comment['text'])

        #removes the childs from the item (important)
        comment.pop('created_at', None)
        comment.pop('points', None)
        comment.pop('type', None)

        childs = comment.pop('children', [])
        #adds the item to the result
        res.append(comment)
        #and the flattened childs later
        res += flatten(childs, level+1)
        #in the next loop the next sibling will be added

    return res

def apiFetch(source, isAsk):
    #h = html.parser.HTMLParser() # To decode the HTML entities

    toFlatten = source.json()
    text = ""
    if (isAsk == "true"):
        text = toFlatten['text']

    #toFlatten = json.loads(decoded)
    print("Flattening comments")
    if ('message' in toFlatten):
        if (toFlatten['message'] == 'ObjectID does not exist'):
            return text, []
    comments = flatten(toFlatten['children'])
    return text, comments # possibly zero comments

def legacyText(soup):
    """ Returns the text of an 'Ask HN' post
    """
    text = ""
    text_content = str(soup.findAll("tr")[7])
    textStart = text_content.find('d><td>') + 6
    textEnd = text_content.find('</td', textStart)
    text = text_content[textStart:textEnd]
    if ('<form action="/r"' in text):
        return ""
    text = text.replace('<p>', '\n') # Replace unclosed <p>'s with new lines
    text = text.replace('</p>', '') # Remove the crap BS4 adds

    return text



def legacyFetch(page, isAsk):
    """ Extract all the comments from a comments page.
        Returns None if this page has no comments.
        Otherwise returns dicts of comments EG)
        {
        text: 'example'
        time: '100 days ago '
        indent: '80'
        author: 'pg'
        }
    """
    
    #soupStart = time.time()
    soup = BeautifulSoup(page.content)
    #soupEnd = time.time()
    #print("Souping: ", soupEnd - soupStart)
    if (isAsk == "true"):
        print("Getting text...")
        text = legacyText(soup)
    else:
        text = ''

    comment_tables = soup.find_all('table', 0)
    comment_tables = list(map(str, comment_tables))

    del comment_tables[0:4]
    if (len(comment_tables) == 0):
        return text, []
    del comment_tables[-1]


    comments = []
    totalTime = 0
    itercomments = iter(comment_tables)
    for table in itercomments:
        #startTime = time.time()
        comment = {}
        comment['indent'] = None
        comment['author'] = None
        comment['time'] = None
        comment['text'] = None
        comment['id'] = None

        soup = BeautifulSoup(table)
        head = soup.find_all('span', 'comhead')
        body = soup.find_all('span', 'comment')
        body = list(map(str, body))

        for img in soup.find_all('img', {"src" : "s.gif"}):
            indent = (img.get('width'))
        if int(indent) % 10 == 0:
            comment['indent'] = int(indent)
        else:
            next(itercomments)
            # comment['indent'] = indent
            # comment['author'] = ''
            # comment['time'] = ''
            # comment['text'] = '[deleted]'
            # comment['id'] = ''

        authorStart = str(head).find('user?id=') + 8
        authorEnd = str(head).find('">', authorStart)
        if (comment['author'] == None):
            comment['author'] = str(head)[authorStart:authorEnd]


        timeStart = str(head).find('</a>') + 5
        timeEnd = str(head).find(' |')
        if (comment['time'] == None):
            comment['time'] = str(head)[timeStart:timeEnd]

        if (comment['id'] == None):
            comment['id'] = head[0].find_all('a')[1]['href'].split('item?id=')[1]

        textStart = 44
        textEnd = body[0].find('</font>')
        if (comment['text'] == None):
            comment['text'] = body[0][textStart:textEnd]

        comments.append(comment)
        #endTime = time.time()
        #print("Time to parse 1 comment: ", endTime - startTime)
        #totalTime = totalTime + (endTime - startTime)
    #print("Time to parse ", len(comment_tables), " comments: ", totalTime)
    return text, comments



def getCommentPage(source, isAsk, legacy=False):
    """Gets the comments and text of the post
    """

    scrapeURL = 'https://news.ycombinator.com/item?id=%s' % source
    commentsURL = 'http://hn.algolia.com/api/v1/items/{0}'.format(source)
    text = ""

    if (legacy == True):
        print("scraping to fetch comments")
        r = requests.get(scrapeURL, headers=readerutils.HEADERS)
        text, comments = legacyFetch(r, isAsk)
    elif (legacy == False):
        print("using api to fetch comments")
        r = requests.get(commentsURL, headers=readerutils.HEADERS)
        text, comments = apiFetch(r, isAsk)
    print("text is a ", type(text))
    return text, comments


