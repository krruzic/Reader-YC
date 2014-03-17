import os, glob
from bs4 import BeautifulSoup
import requests, pickle, re, html.parser, cgi, sqlite3
from .readerutils import readerutils
from .models import HNStory, HNComments, HNSearchStory

class LoginRequiredException(Exception):
    pass

class BadLoginException(Exception):
    pass

class HNapi():
    loggedIn = False
    def __init__(self, username=''):
        if username != '':
            self.loggedIn = True
        self.stories = HNStory()
        self.comments = HNComments()
        self.searchStories = HNSearchStory()

        self.username = username
        self.session = requests.session()

    def login(self, username, password):
        result = False
        sess = requests.session()
        res = sess.get('https://news.ycombinator.com/newslogin', headers=readerutils.HEADERS)
        soup = BeautifulSoup(res.content)

        fnid = soup.find('input')['value']
        params = {'u': username, 'p': password, 'fnid': fnid}
        r = sess.post('https://news.ycombinator.com/y', headers=readerutils.HEADERS, params=params)
        if ("Bad login" not in r.text):
            print("no bad login")
            cookies = sess.cookies
            f = open(readerutils.COOKIE, 'wb')
            pickle.dump(requests.utils.dict_from_cookiejar(cookies), f)
            f.close()
            self.username = username
            self.loggedIn = True
            return True
        return False

    def logout(self):
        self.loggedIn = False
        self.username = ''

    def getProfile(self, username):
        if(not self.loggedIn):
            raise LoginRequiredException('Not signed in!')

        f = open(readerutils.COOKIE, 'rb')
        cookies = requests.utils.cookiejar_from_dict(pickle.load(f))
        f.close()
        r = self.session.get(readerutils.hnUrl('user?id={}'.format(username)), headers=readerutils.HEADERS, cookies=cookies)
        soup = BeautifulSoup(r.content)
        fnid = str(soup.find('input', attrs=dict(name='fnid'))['value'])
        about = soup.find('textarea', {'name': 'about'}).get_text() 
        try:
            email = soup.find('input', {'name': 'email'})['value']
        except:
            email = ""
        return [fnid, about, email]

    def postProfile(self, username, email, about):
        if(not self.loggedIn):
            raise LoginRequiredException('Not signed in!')
        f = open(readerutils.COOKIE, 'rb')
        cookies = requests.utils.cookiejar_from_dict(pickle.load(f))
        f.close()

        about = cgi.escape(about)
        email = cgi.escape(email)

        info = self.getProfile(username)
        if info == False:
            return False

        params =  {
            'fnid': info[0],
            'about': about,
            'email': email,
        }

        r = self.session.post(readerutils.hnUrl('x'), headers=readerutils.HEADERS, params=params, cookies=cookies)
        return True

    def postComment(self, source, comment):
        if(not self.loggedIn):
            raise LoginRequiredException('Not signed in!')

        f = open(readerutils.COOKIE, 'rb')
        cookies = requests.utils.cookiejar_from_dict(pickle.load(f))
        f.close()

        comment = cgi.escape(comment)
        try:
            r = self.session.get(readerutils.hnUrl('reply?id=' + source), headers=readerutils.HEADERS, cookies=cookies)
        except:
            return False
        soup = BeautifulSoup(r.content)
        fnid = soup.find('input')['value']
        params = {'fnid': fnid, 'text': comment}

        try:
            r = self.session.post(readerutils.hnUrl('r'), params=params, headers=readerutils.HEADERS, cookies=cookies)
        except:
            return False

        if(r.url == "https://news.ycombinator.com/news"):
            return True
        return False

    def postStory(self, title, link, text):
        if(not self.loggedIn):
            raise LoginRequiredException('Not signed in!')

        f = open(readerutils.COOKIE, 'rb')
        cookies = requests.utils.cookiejar_from_dict(pickle.load(f))
        f.close()

        if text != '':
            text = cgi.escape(text)

        try:
            r = self.session.get(readerutils.hnUrl('submit'), headers=readerutils.HEADERS, cookies=cookies)
        except:
            return False
        soup = BeautifulSoup(r.content)
        fnid = str(soup.find('input', attrs=dict(name='fnid'))['value'])
        params = {'fnid': fnid, 't': title, 'u': link, 'x': text}
        try:
            r = self.session.post(readerutils.hnUrl('r'), params=params, headers=readerutils.HEADERS, cookies=cookies)
        except:
            return False
            
        if(r.url == "https://news.ycombinator.com/news"):
            return True
        return False

    def getStories(self, list):
        stories = self.stories.parseStories(readerutils.hnUrl(list))
        return stories

    def getComments(self, ident, isAsk=False, legacy=False):
        text, comments = self.comments.parseComments(ident, isAsk, legacy)
        return text, comments

    def getSearchStories(self, startIndex, source):
        res = self.searchStories.parseSearchStories(startIndex, source)
        return res
