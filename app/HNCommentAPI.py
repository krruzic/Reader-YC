import urllib.request
from bs4 import BeautifulSoup
import re, json, os, glob

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
        return text


    def flatten(self, comments, level = 0):
            #comments is a list

            if not comments:
                    return []#exit case

            res = []
            #add the level key so you can keep track of the original level
            for c in comments:
                    c['level'] = level
                    c['comment'] = c['comment'].replace('__BR__',' \n')
                    #removes the childs from the item (important)
                    childs = c.pop('children', [])
                    #adds the item to the result
                    res.append(c)
                    #and the flattened childs later
                    res += self.flatten(childs, level+1)
                    #in the next loop the next sibling will be added

            return res


    def checkCache(self, source):
        """ Checks to see if a comment page has been cached
        """
        ## USEFUL CODE FOR LATER???
        files = []
        workingDir = os.getcwd() + '/data/cache/'
        pagesCached = glob.glob(workingDir + '*.json')
        for page in pagesCached:
            filename = os.path.splitext(page)[0]
            files.append(filename)
        return files


    def cacheComments(self, source, comments, text):
        """ Given the comment page source, this writes the two
            cache files.
        """
        ## USEFUL CODE FOR LATER???
        workingDir = os.getcwd() + '/data/cache/'
        pagesCached = glob.glob(workingDir + '*.json')
        oldestFile = ""
        modded = 10000000000000000 # A large starting number...
        for item in pagesCached:
            modTime = os.stat(item).st_mtime
            if modTime <= modded: # a high modTime means a newer file. Or something.
                modded = modTime
                oldestFile = item

        oldestFile = os.path.splitext(oldestFile)[0] # Gets just the file name
        if (len(pagesCached) > 5): # In case there are too many files
            print("TOO MANY FILES")
            for the_file in os.listdir(workingDir):
                file_path = os.path.join(workingDir, the_file)
            if os.path.isfile(file_path):
                os.unlink(file_path)

        if (len(pagesCached) > 4): # Checks to see if we need to delete a file before caching
            print(pagesCached)
            print("Deleting oldest file... " + oldestFile)
            os.remove(oldestFile + '.json')
            os.remove(oldestFile + '.txt')

        cache = open(workingDir + '%s.json' % source, 'w')
        json.dump(comments, cache)
        print("Comments cached!")
        cache.close()
        textCache = open(workingDir + '%s.txt' % source, 'w')
        textCache.write(text)
        print("Text cached!")
        textCache.close()


    def getPage(self, source, isAsk):
        """Gets the comments and text of the post
        """
        workingDir = os.getcwd() + '/data/cache/'
        textURL = 'http://news.ycombinator.com/item?id=%s' % source
        commentsURL = 'http://hndroidapi.appspot.com/nestedcomments/format/json/id/%s' % source

        cacheList = self.checkCache(source)
        text = ""

        print(cacheList)
        if (workingDir + source in cacheList):
            print("Comments in cache!")
            cache = open(workingDir + '%s.json' % source, 'r')
            comments = json.load(cache)

            if (isAsk == "true"):
                textCache = open(workingDir + '%s.txt' % source, 'r')
                text = textCache.read()
                tart.send('addText', text=text)

            for comment in comments:
                tart.send('addComments', comment=comment)
            return
        else:
            print("Comments not cached...")

        if (isAsk == "true"):
            text = self.getText(textURL)

        print("curling page: " + commentsURL)
        with urllib.request.urlopen(commentsURL) as url:
            urlSource = url.read()
        print("page curled")

        decoded = urlSource.decode("utf-8")
        toFlatten = json.loads(decoded)
        print("Flattening comments")
        comments = self.flatten(toFlatten['items'])


        print("Sending comments")
        for comment in comments:
            tart.send('addComments', comment=comment)
        self.cacheComments(source, comments, text)