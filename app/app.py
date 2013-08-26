import urllib.request, threading, sqlite3
from .HNStoryAPI import HackerNewsStoryAPI
from .HNCommentAPI import HackerNewsCommentAPI
from .HNUserAPI import HackerNewsUserAPI
from .HNSearchAPI import HackerNewsSearchAPI
import tart

HS = HackerNewsStoryAPI()
HC = HackerNewsCommentAPI()
HU = HackerNewsUserAPI()
HQ = HackerNewsSearchAPI()

class App(tart.Application):
    """ The class that directly communicates with Tart and Cascades
    """
    bbm = False
    conn = sqlite3.connect("data/favourites.db")


    def onUiReady(self):
        self.onRequestPage("topPage", "topPage")
        # self.onRequestPage("Ask HN", "askPage")
        # self.onRequestPage("Newest Posts", "newestPage")

    def onRequestPage(self, source, sentBy, askPost="false", deleteComments="false", startIndex=0):
        t = threading.Thread(target=self.parseRequest, args=(source, sentBy, startIndex, askPost, deleteComments))
        t.daemon = True
        t.start()

    def parseRequest(self, source, sentBy, startIndex, askPost, deleteComments):
        print("Parsing request for: " + sentBy)
        if (sentBy == 'topPage'or sentBy == 'askPage'or sentBy == 'newestPage'):
            self.story_routine(source, sentBy)
        elif (sentBy == 'commentPage'):
            self.comments_routine(source, askPost, deleteComments)
        elif (sentBy == 'userPage'):
            self.user_routine(source)
        elif (sentBy == 'searchPage'):
            self.search_routine(startIndex, source)
        else:
            print("Error getting page...")
            return

    def story_routine(self, source, sentBy):
        print("source sent:" + source)
        print("sent by: " + sentBy)
        if source == 'topPage':
            source = 'news'
        if source == 'askPage':
            source = 'ask'
        if source == 'newestPage':
            source = 'newest'

        sentByShort = sentBy[0:3]

        try:
            postList, moreLink = HS.getPage("https://news.ycombinator.com/" + source)
        except (urllib.error.URLError, socket.error):
            print("error from python: " + "URLError")
            tart.send('{0}ListError'.format(sentByShort), text="Error getting news feed, check your connection and try again")
            return
        except IndexError:
            print("error from python: " + "IndexError")
            tart.send('{0}ListError'.format(sentByShort), text="Expired Link! Unable to load more content...")
            return

        stories = []
        for item in postList:
            stories.append(item.getDetails())

        tart.send('add{0}Stories'.format(sentByShort), stories=stories, moreLink=moreLink, sentTo=sentBy)
        if (source == 'news'):
            return
            #tart.send('addCoverStories', stories=stories)


    def comments_routine(self, source, askPost, deleteComments):
        print("source sent:" + source)
        try:
            HC.getPage(source, askPost, deleteComments)
        except (urllib.error.URLError):
            tart.send('commentError', text="Error getting comments. Check your connection \nand try again")
            tart.send('addText', text='')

    def user_routine(self, source):
        print("source sent: " + source)

        source = source.strip() # strips leading and trailing whitespaces
        source = source.split(' ', 1)[0] # Takes just the first word passed
        try:
            detailList = HU.getUserPage("http://news.ycombinator.com/user?id=" + source)
            if (detailList != []):
                tart.send('userInfoReceived', details=detailList)
        except urllib.error.URLError:
            tart.send('userError', text="Error getting user page, Check your connection \nand try again")

    def search_routine(self, startIndex, source):
        print("Searching for: " + source)
        try:
            HQ.getResults(startIndex, source)
        except urllib.error.URLError:
            tart.send('seachError', text="Error getting search results, Check your connection \nand try again")

    def onSaveArticle(self, article):
        article = tuple(article)
        cursor = self.conn.cursor()

        try:
            cursor.execute("""CREATE TABLE articles
                              (title text, articleURL text, saveTime text,
                               poster text, numComments text, isAsk text,
                               domain text, points text, hnid text PRIMARY KEY)
                           """)
        except:
            print('table already exists')

        # insert to table
        try:
            cursor.execute("INSERT INTO articles VALUES (?,?,?,?,?,?,?,?,?)", article)
            print("Article saved!")
        except sqlite3.IntegrityError:
            print("Article already saved!")
            tart.send('saveResult', text="Article already favourited")
            return

        # save data to database
        self.conn.commit()

        tart.send('saveResult', text="Article successfully favourited")

    def onDeleteArticle(self, hnid, selected):
        hnid = str(hnid)
        cursor = self.conn.cursor()
        cursor.execute("DELETE FROM articles WHERE hnid=?", (hnid,) )


        self.conn.commit()
        # Return information to display a 'deleted' toast
        tart.send('deleteResult', text="Article unfavourited", itemToRemove=selected)

    def onLoadFavourites(self):
        cursor = self.conn.execute('SELECT * FROM articles')
        tart.send('fillList', list=self.get_rowdicts(cursor))


    def get_rowdicts(self, cursor):
        return list(cursor)


    # #         d = {}
    # # for idx, col in enumerate(cursor.description):
    # #     d[col[0]] = row[idx]
    # # return d
    #     print(cursor)
    #     fields = [col[0] for col in cursor.description]
    #     for row in cursor:
    #         d = {}
    #         for key in fields:
    #             d[key] = row[key]
    #         yield d

    def onCopyLink(self, articleLink):
        from tart import clipboard
        c = clipboard.Clipboard()
        mimeType = 'text/plain'
        c.insert(mimeType, articleLink)
        tart.send('copyResult', text=articleLink + " copied to clipboard!")

# class utility(object):
#     """A class used by App to simplify things :)
#     """

#     def cacheWriter(self, comments, url):
#         pageIDStart = url.find('=') + 1
#         pageID = url[pageIDStart:-1] + '.xml'

#         fileToWrite = os.getcwd() + '/cache/' + pageID
#         cacheFile = open(fileToRead, 'w+')

#         cacheFile.write('<articles>\n')
#         for comment in comments:
#             cacheFile.write('\t<item>\n')
#             for detail in comment:
#                 cacheFile.write('\t\t<commentNum>' detail[0] + '</commentNum>')
#                 cacheFile.write('\t\t<poster>' + detail[1] + '</poster>')
#                 cacheFile.write('\t\t<timePosted>' + detail[2] + '</timePosted>')
#                 cacheFile.write('\t\t<indent>' + detail[3] + '</indent>')
#                 cacheFile.write('\t\t<text>' + detail[4] + '</text>')
#         cacheFile.write('</articles>')
#         cacheFile.close()

#     def addFavourite(self, itemDetails):
#         fileToWrite = os.getcwd() + '/history' + '.xml'
#         try:
#             with open(fileToWrite): pass
#         except IOError:
#             print("History file doesn't exist, creating now.")
