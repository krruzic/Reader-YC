import urllib.request
from bs4 import BeautifulSoup
import re, json

import tart


class HackerNewsCommentAPI:
    """The class used for searching the HTML for
       all our comments and their data
    """

    def getText(self, url):
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
        tart.send('addText', text=text)

    def flatten(self, comments, level = 0):
            #comments is a list

            if not comments:
                    return []#exit case

            res = []
            #add the level key so you can keep track of the original level
            for c in comments:
                    c['level'] = level
                    #removes the childs from the item (important)
                    childs = c.pop('children', [])
                    #adds the item to the result
                    res.append(c)
                    #and the flattened childs later
                    res += self.flatten(childs, level+1)
                    #in the next loop the next sibling will be added

            return res

    def getPage(self, source):
        """Gets the comments and text of the post
        """

        #textURL = 'http://news.ycombinator.com/item?id=%s' % source
        commentsURL = 'https://hndroidapi.appspot.com/nestedcomments/format/json/id/%s' % source

        #text = self.getText(textURL)

        print("curling page: " + commentsURL)
        with urllib.request.urlopen(commentsURL) as url:
            source = url.read()
        print("page curled")
        decoded = source.decode("utf-8")
        toFlatten = json.loads(decoded)
        comments = self.flatten(toFlatten['items'])

        for comment in comments:
            tart.send('addComments', comment=comment)