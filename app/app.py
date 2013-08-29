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
        print("UI READY!!")
        self.onRequestPage("topPage", "topPage")
        readCursor = sqlite3.connect("data/read.db")
        readCursor.execute("CREATE TABLE IF NOT EXISTS readTable (link text PRIMARY KEY)")
        # favCursor = self.conn.cursor()
        # favCursor.execute("""CREATE TABLE IF NOT EXISTS articles
        #                   (title text, articleURL text, saveTime text,
        #                    poster text, numComments text, isAsk text,
        #                    domain text, points text, hnid text PRIMARY KEY)
        #                """)
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
        except urllib.error.URLError:
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
            tart.send('addCoverStories', stories=stories)


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
            tart.send('searchError', text="Error getting search results, Check your connection \nand try again")

    def onSaveArticle(self, article):
        article = tuple(article)
        cursor = self.conn.cursor()


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

    # def onReadArticle(self, link):
    #     cursor = sqlite3.connect("data/read.db")
    #     sel = cursor.execute( "SELECT COUNT(*) FROM readTable" )
    #     Result = sel.fetchall()
    #     records = Result[0][0]
    #     if (records >= 300):
    #         print("Read Table emptied!")
    #         cursor.execute("DELETE from * readTable")
    #         cursor.commit()

    #     try:
    #         cursor.execute("INSERT INTO readTable VALUES (?)", (link,))
    #         print("article marked as read")
    #         tart.send('readState', state="read")
    #     except sqlite3.IntegrityError:
    #         cursor.close()
    #         print("Error inserting...")
    #         return

    #     # save data to database
    #     cursor.commit()
    #     cursor.close()


    # def onCheckReadState(self, link):
    #     cursor = sqlite3.connect("data/read.db")
    #     sel = cursor.execute("SELECT * FROM readTable WHERE link = ?", (link,))
    #     data = sel.fetchall()
    #     if (len(data) == 0):
    #         tart.send('readState', state="unread")
    #     else:
    #         tart.send('readState', state="read")
    #     cursor.close()


    def onCopyLink(self, articleLink):
        from tart import clipboard
        c = clipboard.Clipboard()
        mimeType = 'text/plain'
        c.insert(mimeType, articleLink)
        tart.send('copyResult', text=articleLink + " copied to clipboard!")