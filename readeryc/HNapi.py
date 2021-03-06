import os
import glob
from bs4 import BeautifulSoup
import requests
import pickle
import re
import html.parser
import cgi
import sqlite3
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
        payload = {'acct': username, 'pw': password, 'goto': 'news'} # random goto value to save some time
        r = self.session.post('https://news.ycombinator.com/login', headers=readerutils.HEADERS, data=payload, allow_redirects=False)
        if ("Bad login" not in r.text):
            print("no bad login")
            cookies = self.session.cookies
            f = open(readerutils.COOKIE, 'wb')
            pickle.dump(requests.utils.dict_from_cookiejar(cookies), f)
            print(cookies)
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

        r = self.session.get(
            readerutils.hnUrl('user?id={}'.format(username)), cookies=cookies)
        soup = BeautifulSoup(r.content)
        id = soup.find('input', {'name': 'id'})['value']
        hmac = soup.find('input', {'name': 'hmac'})['value']
        about = soup.find('textarea', {'name': 'about'}).get_text()
        endpoint = soup.find('form', {'method': 'post'})['action']
        endpoint = endpoint.replace("/", "")

        try:
            uemail = soup.find('input', {'name': 'uemail'})['value']
        except:
            email = ""
        return [hmac, id, about, uemail, endpoint]

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

        params = {
            'id': info[0],
            'hmac': info[1],
            'about': about,
            'uemail': email,
        }

        r = self.session.post(readerutils.hnUrl(info[4]), data=params)
        return True

    def postComment(self, source, comment):
        if (not self.loggedIn):
            raise LoginRequiredException('Not signed in!')

        f = open(readerutils.COOKIE, 'rb')
        cookies = requests.utils.cookiejar_from_dict(pickle.load(f))
        f.close()

        comment = cgi.escape(comment)
        try:
            r = self.session.get(
                readerutils.hnUrl('item?id=' + source))
        except:
            print("error getting page")
            return False
        soup = BeautifulSoup(r.content)
        hmac = soup.find('input', {'name': 'hmac'})['value']
        endpoint = soup.find('form', {'method': 'post'})['action']
        params = {'hmac': hmac, 'text': comment, 'parent': source, 'goto': "item?id=" + source}

        try:
            r = self.session.post(readerutils.hnUrl(endpoint), data=params)
        except Exception:
            print(Exception)
            return False
        if (r.url == ("https://news.ycombinator.com/item?id=" + source)):
            return True
        else:
            print(r.url)
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
            r = self.session.get(readerutils.hnUrl('submit'))
        except:
            return False
        soup = BeautifulSoup(r.content)
        fnid = soup.find('input', {'name': 'fnid'})['value']
        fnop = soup.find('input', {'name': 'fnop'})['value']
        endpoint = soup.find('form', {'method': 'post'})['action']
        endpoint = endpoint.replace("/", "")

        params = {'fnid': fnid, 'fnop': fnop, 'title': title, 'url': link, 'text': text}
        try:
            r = self.session.post(
                readerutils.hnUrl(endpoint), data=params)
        except:
            return False

        if (r.url == "https://news.ycombinator.com/newest"):
            return True
        return False

    def getStories(self, list):
        stories = self.stories.parseStories(readerutils.hnUrl(list), self.session)
        return stories

    def getComments(self, ident, isAsk=False, legacy=False):
        text, comments = self.comments.parseComments(ident, self.session, isAsk, legacy)
        return text, comments

    def getSearchStories(self, startIndex, source):
        res = self.searchStories.parseSearchStories(startIndex, source, self.session)
        return res
