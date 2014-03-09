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

        self.username = username
        self.session = requests.session()

    def login(self, username, password):
        res = self.session.get(readerutils.hnUrl('newslogin'), headers=readerutils.HEADERS)
        fnid = soup.find('input')['value']
        soup = BeautifulSoup(res.content)
        params = {'u': username, 'p': password, 'fnid': fnid}
        r = self.session.post(readerutils.hnUrl('y'), headers=readerutils.HEADERS, params=params)
        if ("Bad login" not in r.text):
            print("no bad login")
            cookies = r.cookies
            f = open(readerutils.COOKIE, 'wb')
            pickle.dump(requests.utils.dict_from_cookiejar(cookies), f)
            f.close()
            self.username = username
            self.loggedIn = True
            return True
        return False

    def getProfile(self, username):
        if(not self.loggedIn):
            raise LoginRequiredException('Not signed in!')

        f = open(readerutils.COOKIE, 'rb')
        cookies = requests.utils.cookiejar_from_dict(pickle.load(f))
        f.close()

        h = html.parser.HTMLParser() # To decode the HTML entities
        r = self.session.get(readerutils.hnUrl('user?id=' + username), headers=readerutils.HEADERS, cookies=cookies)
        soup = BeautifulSoup(r.content)
        fnid = str(soup.find('input', attrs=dict(name='fnid'))['value'])

        options = soup.findAll('option')
        for i in options:
            if "selected" not in str(i):
                options.remove(i)
        print(options)
        try:
            showdead = options[0].text        
            noprocrast = options[2].text
        except IndexError:
            return False
            
        maxvisit = str(soup.find('input', {'name': 'maxvisit'})['value'])
        minaway = str(soup.find('input', {'name': 'minaway'})['value'])
        delay = str(soup.find('input', {'name': 'delay'})['value'])
        about = soup.find('textarea', {'name': 'about'}).get_text() 
        email = soup.find('input', {'name': 'email'})['value']
        return [fnid, about, email, showdead, noprocrast, maxvisit, minaway, delay]

    def postProfile(self, username, email, about):
        if(not self.loggedIn):
            raise LoginRequiredException('Not signed in!')
        f = open(COOKIE, 'rb')
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
            'showdead': info[3],
            'noprocrast': info[4],
            'maxvisit': info[5],
            'minaway': info[6],
            'delay': info[7]
        }

        r = self.session.post(readerutils.hnUrl('x'), headers=readerutils.HEADERS, params=params, cookies=cookies)
        return True

    def postComment(self, source, comment):
        if(not self.loggedIn):
            raise LoginRequiredException('Not signed in!')

        f = open(readerutils.COOKIE, 'rb')
        cookies = requests.utils.cookiejar_from_dict(pickle.load(f))
        f.close()
        print("Posting comment!")

        comment = cgi.escape(comment)
        try:
            r = self.session.get(readerutils.hnUrl('reply?id=' + source), headers=readerutils.HEADERS, cookies=cookies)
        except:
            return False
        soup = BeautifulSoup(r.content)
        fnid = str(soup.find('input', attrs=dict(name='fnid'))['value'])
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

    def getStories(self, list):
        page = HNStory()
        if list not in ('newest', 'ask', 'news'):
            raise IndexError('{} is not a valid list.'.format(list))
        stories = page.parseStories(readerutils.hnUrl(list))
        return stories

    def getComments(self, ident, isAsk=False, legacy=False):
        page = HNComments()
        text, comments = page.parseComments(ident, isAsk, legacy)
        return text, comments

    def getSearchStories(self, startIndex, source):
        page = HNSearchStory()
        res = page.parseSearchStories(startIndex, source)
        return res
