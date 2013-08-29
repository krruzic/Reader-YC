import re, json
import time, urllib.request, os, glob

from bs4 import BeautifulSoup

import tart
class HackerNewsCommentAPI:
    """ The class used for searching the HTML for
        all our comments and their data
    """

    def parse_comments(self, page, isAsk):
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
        soupStart = time.time()
        soup = BeautifulSoup(page)
        soupEnd = time.time()
        print("Souping: ", soupEnd - soupStart)
        if (isAsk == "true"):
            print("Getting text...")
            text = self.parse_text(soup)
        else:
            text = ''

        comment_tables = soup.find_all('table', 0)
        comment_tables = list(map(str, comment_tables))

        del comment_tables[0:4]
        if (len(comment_tables) == 0):
            return None, text
        del comment_tables[-1]


        comments = []
        totalTime = 0
        for table in comment_tables:
            startTime = time.time()
            comment = {}
            comment['indent'] = None
            comment['author'] = None
            comment['time'] = None
            comment['text'] = None
            comment['link'] = None

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
                comment['link'] = ''

            authorStart = str(head).find('user?id=') + 8
            authorEnd = str(head).find('">', authorStart)
            if (comment['author'] == None):
                comment['author'] = str(head)[authorStart:authorEnd]


            timeStart = str(head).find('</a>') + 5
            timeEnd = str(head).find(' |')
            if (comment['time'] == None):
                comment['time'] = str(head)[timeStart:timeEnd]

            if (comment['link'] == None):
                comment['link'] = head[0].find_all('a')[1]['href'].split('item?id=')[1]

            textStart = 44
            textEnd = body[0].find('</font>')
            if (comment['text'] == None):
                comment['text'] = body[0][textStart:textEnd]
            comments.append(comment)
            endTime = time.time()
            print("Time to parse 1 comment: ", endTime - startTime)
            totalTime = totalTime + (endTime - startTime)
        print("Time to parse ", len(comment_tables), " comments: ", totalTime)
        return comments, text

    def parse_text(self, soup):
        """ Returns the text of an 'Ask HN' post
        """

        text_content = str(soup.findAll("tr")[7])
        textStart = text_content.find('d><td>') + 6
        textEnd = text_content.find('</td', textStart)
        text = text_content[textStart:textEnd]
        text = text.replace('<p>', '\n') # Replace unclosed <p>'s with new lines
        text = text.replace('</p>', '') # Remove the crap BS4 adds
        print(text)
        return text

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
            print("Deleting oldest file... " + oldestFile)
            os.remove(oldestFile + '.json')
            os.remove(oldestFile + '.txt')

        print("Opening file to write...")
        cache = open(workingDir + '%s.json' % source, 'w', encoding='utf-8')
        comments = json.dumps(comments)
        cache.write(comments)
        print("Comments cached!")
        cache.close()
        textCache = open(workingDir + '%s.txt' % source, 'w', encoding='utf-8')
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
        if (source == '-1'):
            tart.send('addText', text='')
            tart.send('commentError', text="Jobs posting, no comments.")
            return

        workingDir = os.getcwd() + '/data/cache/'
        url = 'https://news.ycombinator.com/item?id=%s' % source
        cacheList = []

        cacheList = self.checkCache()
        fileToCheck = workingDir + source
        cached = fileToCheck in cacheList
        if (deleteComments != "True" and cached == True): # Checks if comments are cached, and whether we should keep them.
            print("Comments in cache!")
            cache = open(workingDir + '%s.json' % source, 'r', encoding='utf-8')
            comments = json.load(cache)
            cache.close()

            textCache = open(workingDir + '%s.txt' % source, 'r', encoding='utf-8')
            text = textCache.read()
            tart.send('addText', text=text)
            textCache.close()

            for comment in comments:
                tart.send('addComments', comment=comment, hnid=source)
            return

        else:
            print("Comments not cached...")
        print("curling page: " + url)
        with urllib.request.urlopen(url) as url:
            urlSource = url.read()
        print("page curled")
        comments, text = self.parse_comments(urlSource, isAsk)
        if (comments == None):
            tart.send('addText', text=text)
            tart.send('commentError', text="No comments! Check back later!", hnid=source)
            return
        jsonComments = json.dumps(comments)
        comments = json.loads(jsonComments)


        tart.send('addText', text=text)
        for comment in comments:
            tart.send('addComments', comment=comment, hnid=source)
        self.cacheComments(source, comments, text)