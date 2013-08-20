import re, json
import time, urllib.request, os, glob

from bs4 import BeautifulSoup

import tart
class HackerNewsCommentAPI:
    """ The class used for searching the HTML for
        all our comments and their data
    """

    def parse_comments(self, page, isAsk):
        """ Parse comments from an HN comments page
            Returns a dict of metadata about the story and a list of comments. E.g.
            {
                text: 'example'
                time: '100 days ago '
                indent: '80'
                author: 'pg'
            }

        """
        soup = BeautifulSoup(page)
        resp = self._parse_comments(soup)
        if (isAsk == "true"):
            text = self.parse_text(soup)
        else:
            text = ''
        return resp, text

    def parse_text(self, soup):
        """ Returns the text of an 'Ask HN' post
        """

        text_content = soup.findAll("tr")
        text = text_content[7].text
        return text

    def _parse_comments(self, soup):
        """ Extract all the comments from a comments page.
            Returns None if this page has no comments.
        """

        comment_tables = soup.find_all('table', 0)
        comment_tables = list(map(str, comment_tables))

        del comment_tables[0:4]
        del comment_tables[-1]

        comments = []
        for table in comment_tables:
            comment = {}
            comment['indent'] = None
            comment['author'] = None
            comment['time'] = None
            comment['text'] = None
            soup = BeautifulSoup(table)
            head = soup.find_all('span', 'comhead')
            body = soup.find_all('span', 'comment')
            body = list(map(str, body))

            for img in soup.find_all('img', {"src" : "s.gif"}):
                indent = (img.get('width'))
            if int(indent) % 10 == 0:
                comment['indent'] = indent
            else:
                comment['indent'] = indent
                comment['author'] = ''
                comment['time'] = ''
                comment['text'] = '[deleted]'
                # comment['link'] = ''

            authorStart = str(head).find('user?id=') + 8
            authorEnd = str(head).find('">', authorStart)
            if (comment['author'] == None):
                comment['author'] = str(head)[authorStart:authorEnd]


            timeStart = str(head).find('</a>') + 5
            timeEnd = str(head).find(' |')
            if (comment['time'] == None):
                comment['time'] = str(head)[timeStart:timeEnd]

            #comment['link'] = head.find_all('a')[1]['href'].split('item?id=')[1]
            textStart = 44
            textEnd = body[0].find('</font>')
            if (comment['text'] == None):
                comment['text'] = body[0][textStart:textEnd]
            comments.append(comment)
        return comments

    def cacheComments(self, source, comments, text):
        """ Given the comment page source, this writes the two
            cache files.
        """
        ## USEFUL CODE FOR LATER???
        workingDir = os.getcwd() + '/data/cache/'

        if not os.path.exists(workingDir):
            os.makedirs(workingDir)
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

        print("Opening file to write...")
        cache = open(workingDir + '%s.json' % source, 'w')
        comments = json.dumps(comments)
        cache.write(comments)
        print("Comments cached!")
        cache.close()
        textCache = open(workingDir + '%s.txt' % source, 'w')
        textCache.write(text)
        print("Text cached!")
        textCache.close()


    def checkCache(self):
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

    def getPage(self, source, isAsk, deleteComments):
        workingDir = os.getcwd() + '/data/cache/'
        url = 'https://news.ycombinator.com/item?id=%s' % source
        cacheList = []

        cacheList = self.checkCache()
        fileToCheck = workingDir + source
        cached = fileToCheck in cacheList
        if (deleteComments != "True" and cached == True): # Checks if comments are cached
            print("Comments in cache!")
            cache = open(workingDir + '%s.json' % source, 'r')
            comments = json.load(cache)
            cache.close()

            textCache = open(workingDir + '%s.txt' % source, 'r')
            text = textCache.read()
            tart.send('addText', text=text)
            textCache.close()

            for comment in comments:
                print(comment)
                tart.send('addComments', comment=comment)
            return

        else:
            print("Comments not cached...")
        print("curling page: " + url)
        with urllib.request.urlopen(url) as url:
            urlSource = url.read()
        print("page curled")
        comments, text = self.parse_comments(urlSource, isAsk)
        jsonComments = json.dumps(comments)
        comments = json.loads(jsonComments)
        if (comments == None):
            tart.send('commentError', text="No comments! Check back later!")
            return

        tart.send('addText', text=text)
        for comment in comments:
            print(comment)
            tart.send('addComments', comment=comment)
        self.cacheComments(source, comments, text)