import urllib.request, threading, sqlite3, os, glob
from .HNStoryAPI import getStoryPage
from .HNCommentAPI import getCommentPage
from .HNUserAPI import getUserPage
from .HNSearchAPI import getSearchResults
from bs4 import BeautifulSoup
from datetime import datetime, timedelta
import requests, requests.utils, pickle, re, html.parser, cgi
import tart
# import lxml.html as l

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
    readerToken = '5613db57aaedcafdff67fb12844f5b39a0d47a93' # this is supposed to be a secret, DO NOT USE IT, get your own from http://www.readability.com/developers/api/parser
    BASE_PATH = os.getcwd() + '/data/'
    COOKIE = os.path.join(BASE_PATH, 'hackernews.cookie')
    HEADERS = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.29 Safari/537.22',
    }
    cache = [] #{'ident': None} # Keep track of current request

    def __init__(self):
        super().__init__(debug=False)   # set True for some extra debug output
        self.settings = {
            'openInBrowser': 'false',
            'readerMode': 'false',
            'loggedIn': 'false',
            'username': ''
        }
        self.restore_data(self.settings, self.SETTINGS_FILE)
        print("restored: ", self.settings)

    def onUiReady(self):
        print("UI READY!!")
        tart.send('restoreSettings', **self.settings)
        self.onRequestPage("topPage", "topPage")

    def onSaveSettings(self, settings):
        self.settings.update(settings)
        self.save_data(self.settings, self.SETTINGS_FILE)

    def onRequestPage(self, source, sentBy, askPost="false", deleteComments="false", startIndex=0):
        """ This is really ugly, but it handles all url requests with threading, it also prevents the same request from being made twice
        """
        entryExists = False
        position = 0
        currReq = {'ident': (datetime.now(), source)}
        src = ""
        for i in self.cache:
            position = position + 1
            src = i['ident'][1]
            if src == source:
                print("Request in progress!!")
                entryExists = True
                ts = i['ident'][0]
                if datetime.now() - ts > timedelta(minutes=5): # If the request is old, make the new one anyway
                    break
                return # Otherwise quit

        print("Requests pending: ", len(self.cache))
        if len(self.cache) == 0:
            self.cache.append(currReq)
            entryExists = True

        if entryExists != True:
            print("Request doesn't exist")
            if len(self.cache) > 5: # If we have 5 reqs going, remove the first one before adding
                self.cache.pop(0)
            self.cache.append(currReq)
            t = threading.Thread(target=self.parseRequest, args=(source, sentBy, startIndex, askPost))

        else: # If the request does exist
            if len(self.cache) == 1: # If it is the only one we make the request (first request added)
                print("Only request?")
                #self.cache.append(currReq) # Append it to cache
                t = threading.Thread(target=self.parseRequest, args=(source, sentBy, startIndex, askPost))
            else: # If there are multiple requests
                print("Checking request")
                #ts, src = self.cache[position]['ident'] # Check the time the request was made
                if src == source: # If the cache source is the same as current request
                    print("Request is the same!")
                    if datetime.now() - ts > timedelta(minutes=5): # Check if cache was made 5 mins ago
                        print("Old enough, request OK")
                        t = threading.Thread(target=self.parseRequest, args=(source, sentBy, startIndex, askPost))
                    else:
                        return
        t.daemon = True
        t.start()


    def parseRequest(self, source, sentBy, startIndex, askPost):
        print("Parsing request for: " + sentBy)
        if (sentBy == 'topPage'or sentBy == 'askPage'or sentBy == 'newestPage'):
            self.story_routine(source, sentBy)
        elif (sentBy == 'commentPage'):
            self.comments_routine(source, askPost)
        elif (sentBy == 'userPage'):
            self.user_routine(source)
        elif (sentBy == 'searchPage'):
            self.search_routine(startIndex, source)
        else:
            print("Error getting page...")
            return
        print("request complete! Removing...")
        self.cache.pop(-1)


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


    def comments_routine(self, source, askPost):
        print("source sent:" + source)
        try:
            getCommentPage(source, askPost)
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
        r = requests.get('https://news.ycombinator.com/newslogin')
        print("SOUPING")
        soup = BeautifulSoup(r.content)
        try:
            fnid = soup.find('input', attrs=dict(name='fnid'))['value']
            print(fnid, username, password)
        except:
            print()
        payload = {
            'fnid': fnid,
            'u': username,
            'p': password
        }
        result = "false"
        sess = requests.session()
        res = sess.get('https://news.ycombinator.com/newslogin', headers=self.HEADERS)
        fnid = soup.find('input')['value']
        soup = BeautifulSoup(res.content)
        params = {'u': username, 'p': password, 'fnid': fnid}
        r = sess.post('https://news.ycombinator.com/y', headers=self.HEADERS, params=params)
        # assert r.status_code == 200, "Unexpected status code: %s" % r.status_code
        print(r.text)
        if ("Bad login" not in r.text):
            print("no bad login")
            cookies = sess.cookies
            f = open(self.COOKIE, 'wb')
            pickle.dump(requests.utils.dict_from_cookiejar(cookies), f)
            f.close()
            result = "true"
        tart.send('loginResult', result=result)

    def onGetProfile(self, username):
        f = open(self.COOKIE, 'rb')
        cookies = requests.utils.cookiejar_from_dict(pickle.load(f))
        f.close()

        h = html.parser.HTMLParser() # To decode the HTML entities
        r = requests.get('https://news.ycombinator.com/user?id={0}'.format(username), headers=self.HEADERS, cookies=cookies)
        soup = BeautifulSoup(r.content)
        #print(r.content)
        about = soup.find('textarea', {'name': 'about'}).text 
        about = h.unescape(about)
        about = about.replace('<i>', '*')
        about = about.replace('<\i>', '*')
        about = re.sub("<.*?>", "", about)
        email = soup.find('input', {'name': 'email'})['value']
        email = h.unescape(email)

        tart.send('profileRetrieved', email=email, about=about)

    def onSaveProfile(self, email, about):
        f = open(self.COOKIE, 'rb')
        cookies = requests.utils.cookiejar_from_dict(pickle.load(f))
        #h = html.parser.HTMLParser() # To decode the HTML entities
        about = cgi.escape(about)
        email = cgi.escape(email)
        sess = requests.session()

        r = sess.get('https://news.ycombinator.com/user?id={0}'.format(username), headers=HEADERS, cookies=cookies)
        soup = BeautifulSoup(r.content)
        showdead = str(soup.find('select', {'name': 'showdead'}))
        showdead = showdead[showdead.find('selected=')+12:showdead.find("</option")]
    
        noprocrast = str(soup.find('select', {'name': 'noprocrast'}))
        noprocrast = noprocrast[noprocrast.find('selected=')+12:noprocrast.find("</option")]

        params =  {
            'fnid': soup.find('input', attrs=dict(name='fnid'))['value'],
            'about': about,
            'email': email,
            'showdead': showdead,#soup.find('select', {'name': 'showdead'})['selected'].text,
            'noprocrast': noprocrast,#soup.find('select', {'name': 'noprocrast'})['selected'].text,
            'maxvisit': soup.find('input', {'name': 'maxvisit'})['value'],
            'minaway': soup.find('input', {'name': 'minaway'})['value'],
            'delay': soup.find('input', {'name': 'delay'})['value']
        }
        print(params)
        r = sess.post('https://news.ycombinator.com/x', headers=self.HEADERS, params=params, cookies=cookies)



    def onLogout(self):
        os.remove(self.COOKIE)
        tart.send('logoutResult')

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

    def onDeleteCache(self):
        print("PYTHON DELETING CACHE")
        workingDir = os.getcwd() + '/data/cache/'
        cursor = self.conn.cursor()
        os.chdir(workingDir)
        files=glob.glob('*.json')
        print("deleting comments")
        for filename in files:
            os.unlink(filename)
        files=glob.glob('*.txt')
        print("deleting text stories")
        for filename in files:
            os.unlink(filename)
        os.chdir('../../')
        print(os.getcwd())
        print("Dropping favourites table")
        cursor.execute("""DROP TABLE IF EXISTS articles""")
        cursor.execute("""CREATE TABLE IF NOT EXISTS articles
                (title text, articleURL text, saveTime text,
                poster text, numComments text, isAsk text,
                domain text, points text, hnid text PRIMARY KEY)
            """)
        tart.send('cacheDeleted', text="Cache cleared!")

    def onCopyLink(self, articleLink):
        from tart import clipboard
        c = clipboard.Clipboard()
        mimeType = 'text/plain'
        c.insert(mimeType, articleLink)
        tart.send('copyResult', text=articleLink + " copied to clipboard!")
