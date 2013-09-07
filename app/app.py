import urllib.request, threading, sqlite3
from .HNStoryAPI import getStoryPage
from .HNCommentAPI import getCommentPage
from .HNUserAPI import getUserPage
from .HNSearchAPI import getSearchResults
#from requests import session
from bs4 import BeautifulSoup

#import requests
import tart


#HS = HackerNewsStoryAPI()
#HC = HackerNewsCommentAPI()
#HU = HackerNewsUserAPI()
#HQ = HackerNewsSearchAPI()

class App(tart.Application):
    """ The class that directly communicates with Tart and Cascades
    """
    bbm = False
    conn = sqlite3.connect("data/favourites.db")
    SETTINGS_FILE = 'data/settings.state'


    def __init__(self):
        super().__init__(debug=False)   # set True for some extra debug output
        self.settings = {
            'openInBrowser': 'false'
        }
        self.restore_data(self.settings, self.SETTINGS_FILE)
        print("restored: ", self.settings)

    def onUiReady(self):
        print("UI READY!!")
        tart.send('restoreSettings', **self.settings)
        self.onRequestPage("topPage", "topPage")
        #readCursor = sqlite3.connect("data/read.db")
        #readCursor.execute("CREATE TABLE IF NOT EXISTS readTable (link text PRIMARY KEY)")
        # self.onRequestPage("Ask HN", "askPage")
        # self.onRequestPage("Newest Posts", "newestPage")

    def onSaveSettings(self, settings):
        self.settings.update(settings)
        self.save_data(self.settings, self.SETTINGS_FILE)

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

        if source[0] == '/':
            source = source[1:]
        try:
            stories, moreLink = getStoryPage("https://news.ycombinator.com/" + source)
        except IOError:
            tart.send('{0}ListError'.format(sentByShort), text="<b><span style='color:#fe8515'>Error getting stories</span></b>\nCheck your connection and try again!")
            return
        except IndexError:
            print("Expired link?")
            tart.send('{0}ListError'.format(sentByShort), text="<b><span style='color:#fe8515'>Link expired</span></b>\nPlease refresh the page")
            return

        for story in stories:
            tart.send('add{0}Stories'.format(sentByShort), story=story, moreLink=moreLink, sentTo=sentBy)
        if (source == 'news'):
            tart.send('addCoverStories', stories=stories)


    def comments_routine(self, source, askPost, deleteComments):
        print("source sent:" + source)
        try:
            getCommentPage(source, askPost, deleteComments)
        except IOError:
            print("ERROR GETTING COMMENTS")
            tart.send('addText', text='', hnid=source)
            tart.send('commentError', text="<b><span style='color:#fe8515'>Error getting comments</span></b>\nCheck your connection and try again!", hnid=source)


    def user_routine(self, source):
        print("source sent: " + source)

        source = source.strip() # strips leading and trailing whitespaces
        source = source.split(' ', 1)[0] # Takes just the first word passed
        try:
            detailList = getUserPage(source)
            print(detailList)
            if (detailList != []):
                tart.send('userInfoReceived', details=detailList)
        except IOError:
            tart.send('userError', text="<b><span style='color:#fe8515'>Error getting User page</span></b>\nCheck your connection and try again!")

    def search_routine(self, startIndex, source):
        print("Searching for: " + source)
        try:
            getSearchResults(startIndex, source)
        except IOError:
            tart.send('searchError', text="<b><span style='color:#fe8515'>Error getting stories</span></b>\nCheck your connection and try again!")

    def onRequestLogin(self, username, password):

        HN = "https://news.ycombinator.com/"
        HN_LOGIN = HN + "newslogin?whence=news"
        HN_LOGIN_POST = HN + 'y'

        r = requests.get(HN_LOGIN)
        print("SOUPING")
        soup = BeautifulSoup(r.content)
        try:
            fnid = soup.find('input', attrs=dict(name='fnid'))['value']
        except:
            print()
        print(fnid)
        payload = {
            'fnid': fnid,
            'u': username,
            'p': password
        }

        with session() as c:
            c.post(HN_LOGIN_POST, data=payload)
            print(c.cookies)
            request = c.get('https://news.ycombinator.com/saved?id=deft')
            tart.send('loginResult', text=request.text)

    def onSaveArticle(self, article):
        article = tuple(article)
        cursor = self.conn.cursor()
        cursor.execute("""CREATE TABLE IF NOT EXISTS articles
                          (title text, articleURL text, saveTime text,
                           poster text, numComments text, isAsk text,
                           domain text, points text, hnid text PRIMARY KEY)
                       """)


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
        tart.send('deleteResult', text="Article removed from favourites", itemToRemove=selected)

    def onLoadFavourites(self):
        cursor = self.conn.cursor()
        cursor.execute("""CREATE TABLE IF NOT EXISTS articles
                  (title text, articleURL text, saveTime text,
                   poster text, numComments text, isAsk text,
                   domain text, points text, hnid text PRIMARY KEY)
               """)

        cursor.execute('SELECT * FROM articles')
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

    #     sel = cursor.execute("SELECT * FROM readTable WHERE link = ?", (link,))
    #     data = sel.fetchall()
    #if (len(data) == 0):
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
