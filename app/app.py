import threading
import os
import glob
import sqlite3
import requests
import requests.utils
import pickle
import re
import html.parser
import cgi

from bs4 import BeautifulSoup
from datetime import datetime, timedelta
from socket import error as SocketError
import errno
import tart

from readeryc import HNapi, readerutils


class App(tart.Application):

    """ The class that directly communicates with Tart and Cascades
    """

    cache = []  # {'ident': None} # Keep track of current request
    SETTINGS_FILE = readerutils.SETTINGS_FILE
    COOKIE = readerutils.COOKIE
    HEADERS = readerutils.HEADERS

    def __init__(self):
        super().__init__(debug=False)   # set True for some extra debug output
        self.settings = {
            'openInBrowser': False,
            'readerMode': False,
            'loggedIn': False,
            'username': '',
            'legacyFetch': False
        }
        self.restore_data(self.settings, self.SETTINGS_FILE)
        self.sess = HNapi(self.settings['username'])
        print("restored: ", self.settings)

    def onUiReady(self):
        print("UI READY!!")
        tart.send('restoreSettings', **self.settings)
        self.onRequestPage("news", "news")
        # self.onRequestPage("ask", "ask")
        # self.onRequestPage("newest", "newest")

    def onSaveSettings(self, settings):
        self.settings.update(settings)
        self.save_data(self.settings, self.SETTINGS_FILE)

# Handling requests
    def onRequestPage(self, source, sentBy, askPost="false", deleteComments="false", startIndex=0, author=""):
        """ This is really ugly, but it handles all url requests with threading,
            it also prevents the same request from being made twice
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
                # If the request is old, make the new one anyway
                if datetime.now() - ts > timedelta(minutes=5):
                    break
                return  # Otherwise quit

        print("Requests pending: ", len(self.cache))
        if len(self.cache) == 0:
            self.cache.append(currReq)
            entryExists = True

        if entryExists != True:
            print("Request doesn't exist")
            # If we have 5 reqs going, remove the first one before adding
            if len(self.cache) > 5:
                self.cache.pop(0)
            self.cache.append(currReq)  # Append it to cache
            t = threading.Thread(target=self.parseRequest, args=(
                source, sentBy, startIndex, askPost, author))

        else:  # If the request does exist
            if len(self.cache) == 1:  # If it is the only one we make the request (first request added)
                print("Only request?")
                t = threading.Thread(target=self.parseRequest, args=(
                    source, sentBy, startIndex, askPost, author))
            else:  # If there are multiple requests
                print("Checking request")
                # ts, src = self.cache[position]['ident'] # Check the time the
                # request was made
                # If the cache source is the same as current request
                if src == source:
                    print("Request is the same!")
                    # Check if cache was made 5 mins ago
                    if datetime.now() - ts > timedelta(minutes=5):
                        print("Old enough, request OK")
                        t = threading.Thread(target=self.parseRequest, args=(
                            source, sentBy, startIndex, askPost, author))
                    else:
                        return
        t.daemon = True
        t.start()

    def parseRequest(self, source, sentBy, startIndex, askPost, author):
        print("Parsing request for: " + sentBy)
        if (sentBy in ['news', 'ask', 'newest']):
            self.storyRoutine(source, sentBy)
        elif (sentBy == 'commentPage'):
            self.commentsRoutine(source, askPost)
        elif (sentBy == 'searchPage'):
            self.searchRoutine(startIndex, [source, author])
        else:
            print("Error getting page...")
            return
        print("request complete! Removing...")
        self.cache.pop(-1)

# GET functions
    def storyRoutine(self, source, sentBy):
        try:
            stories, moreLink = self.sess.getStories(source)
        except requests.exceptions.ConnectionError:
            tart.send('{0}ListError'.format(sentBy),
                      text="<b><span style='color:#ff8e00'>Error getting stories</span></b>\nCheck your connection and try again!")
            return
        except readeryc.models.ExpiredLinkException:
            print("Expired link?")
            tart.send('{0}ListError'.format(sentBy),
                      text="<b><span style='color:#ff8e00'>Link expired</span></b>\nPlease refresh the page")
            return

        for story in stories:
            tart.send('add{0}Stories'.format(sentBy),
                      story=story, moreLink=moreLink, sentTo=sentBy)
        if (source == 'news'):
            tart.send('addCoverStories', stories=stories)

    def commentsRoutine(self, source, askPost):
        print("source sent:" + source)

        try:
            text, comments = self.sess.getComments(
                source, askPost, self.settings['legacyFetch'])
            if (text != ""):
                text = readerutils.textReplace(text)

            tart.send('addText', text=text, hnid=source)
            if (comments == []):
                tart.send(
                    'commentError', text="No comments, check back later!", hnid=source)
            for comment in comments:
                comment['text'] = readerutils.textReplace(comment['text'])
                comment['barColour'] = "#" + \
                    readerutils.getColour(comment["indent"] // 40)
                tart.send('addComments', comment=comment, hnid=source)

        except requests.exceptions.ConnectionError:
            print("ERROR GETTING COMMENTS")
            tart.send('addText', text='', hnid=source)
            tart.send(
                'commentError', text="<b><span style='color:#ff8e00'>Error getting comments</span></b>\nCheck your connection and try again!", hnid=source)
        except SocketError:
            print("ERROR GETTING COMMENTS")
            tart.send('addText', text='', hnid=source)
            tart.send(
                'commentError', text="<b><span style='color:#ff8e00'>Error getting comments</span></b>\nCheck your connection and try again!", hnid=source)

    def searchRoutine(self, startIndex, source):
        print("Searching for: " + str(source))
        try:
            result = self.sess.getSearchStories(startIndex, source)
            if result == []:
                tart.send(
                    'searchError', text="<b><span style='color:#ff8e00'>No results found!</span></b>")
                return
            for res in result:
                tart.send('addSearchStories', story=res)
        except requests.exceptions.ConnectionError:
            tart.send(
                'searchError', text="<b><span style='color:#ff8e00'>Error getting stories</span></b>\nCheck your connection and try again!")
        except SocketError:
            tart.send(
                'searchError', text="<b><span style='color:#ff8e00'>Error getting stories</span></b>\nCheck your connection and try again!")

# POST functions
    def onRequestLogin(self, username, password):
        result = self.sess.login(username, password)
        tart.send('loginResult', result=result)

    def onGetProfile(self, username):
        info = self.sess.getProfile(username)
        print(info)
        if (info == False):
            os.remove(self.COOKIE)
            tart.send(
                'logoutResult', text="Unable to get profile, forcing logout...")
            return
        tart.send('profileRetrieved', email=info[2], about=info[1])

    def onSaveProfile(self, username, email, about):
        res = False
        try:
            res = self.sess.postProfile(username, email, about)
        except:
            tart.send(
                'profileSaved', text="Unable to update profile, check connection and try again")
        if (res == True):
            tart.send('profileSaved', text="Profile updated!")
        else:
            tart.send(
                'profileSaved', text="Unable to update profile, check connection and try again")

    def onSendComment(self, source, text):
        res = self.sess.postComment(source, text)
        text = text.replace('*', '')
        if (res == True):
            tart.send('commentPosted', result="true", comment=text)
            return
        tart.send('commentPosted', result="false", comment="")

    def onPostStory(self, title, url, text):
        res = self.sess.postStory(title, url, text)
        if (res == True):
            tart.send('storyPosted', result='true')
        else:
            tart.send('storyPosted', result='false')

    def onLogout(self):
        self.sess.logout()
        try:
            os.remove(self.COOKIE)
        except OSError:
            tart.send('logoutResult', text="logged out successfully!")

        tart.send('logoutResult', text="logged out successfully!")

# Favouriting functions
    def onSaveArticle(self, article):
        conn = sqlite3.connect("data/favourites.db")
        print(article)
        article = tuple(article)
        cursor = conn.cursor()
        cursor.execute("""CREATE TABLE IF NOT EXISTS articles
                          (title text, articleURL text, saveTime text,
                           poster text, numComments text, isAsk text,
                           domain text, points text, hnid text PRIMARY KEY)
                       """)

        # insert to table
        try:
            cursor.execute(
                "INSERT INTO articles VALUES (?,?,?,?,?,?,?,?,?)", article)
            print("Article saved!")
            # save data to database
            conn.commit()
            tart.send('saveResult', text="Article successfully favourited")
        except sqlite3.IntegrityError:
            print("Article already saved!")
            tart.send('saveResult', text="Article already favourited")

    def onDeleteArticle(self, hnid, selected):
        conn = sqlite3.connect("data/favourites.db")

        hnid = str(hnid)
        cursor = conn.cursor()
        cursor.execute("DELETE FROM articles WHERE hnid=?", (hnid,))
        conn.commit()
        tart.send(
            'deleteResult', text="Article removed from favourites", itemToRemove=selected)

    def onLoadFavourites(self):
        conn = sqlite3.connect("data/favourites.db")

        cursor = conn.cursor()
        cursor.execute("""CREATE TABLE IF NOT EXISTS articles
                  (title text, articleURL text, saveTime text,
                   poster text, numComments text, isAsk text,
                   domain text, points text, hnid text PRIMARY KEY)
                """)
        cursor.execute('SELECT * FROM articles')
        results = readerutils.get_rowdicts(cursor)
        tart.send('fillList', results=results)

# Misc functions
    def onDeleteCache(self):
        print("PYTHON DELETING CACHE")
        workingDir = os.getcwd() + '/data/cache/'
        cursor = self.conn.cursor()
        print("Dropping favourites table")
        cursor.execute("""DROP TABLE IF EXISTS articles""")
        cursor.execute("""CREATE TABLE IF NOT EXISTS articles
                (title text, articleURL text, saveTime text,
                poster text, numComments text, isAsk text,
                domain text, points text, hnid text PRIMARY KEY)
            """)
        tart.send('cacheDeleted', text="Cache cleared!")

    def onCopyComment(self, comment, poster):
        soup = BeautifulSoup(comment)
        from tart import clipboard
        c = clipboard.Clipboard()
        mimeType = 'text/plain'
        c.insert(mimeType, str(soup.text))
        tart.send('commentCopied', poster=poster)

    def onCopy(self, articleLink):
        from tart import clipboard
        c = clipboard.Clipboard()
        mimeType = 'text/plain'
        c.insert(mimeType, articleLink)
        tart.send('copyResult', text=articleLink + " copied to clipboard!")
