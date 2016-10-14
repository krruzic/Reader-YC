import os
import glob
from bs4 import BeautifulSoup
import requests
import html.parser
import cgi
from .readerutils import readerutils as ru
from .models import HNStory, HNComments


class LoginRequiredException(Exception):
    pass


class BadLoginException(Exception):
    pass


class HNapi():
    loggedIn = False

    def __init__(self, username=''):
        if username != '':
            self.loggedIn = True
        self.comments = HNComments()

        self.username = username
        self.session = requests.session()
        self.session.headers.update = ru.HEADERS
        self.session.verify = os.path.dirname(os.path.realpath('__file__')) + '/cacert.pem'

    def login(self, username, password):
        payload = {'acct': username, 'pw': password, 'goto': 'news'} # random goto value to save some time
        r = self.session.post('https://news.ycombinator.com/login',
                              headers=ru.HEADERS, data=payload, allow_redirects=False)
        if ("Bad login" not in r.text):
            print("no bad login")
            cookies = self.session.cookies
            f = open(ru.COOKIE, 'wb')
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
        cookiefile = open(ru.COOKIE, 'w').close() # clear the cookie file

    def get_profile(self, username):
        if(not self.loggedIn):
            raise LoginRequiredException('Not signed in!')

        f = open(ru.COOKIE, 'rb')
        cookies = requests.utils.cookiejar_from_dict(pickle.load(f))
        f.close()

        r = self.session.get(
            ru.hn_url('user?id={}'.format(username)), cookies=cookies)
        soup = BeautifulSoup(r.content)
        hnid = soup.find('input', {'name': 'id'})['value']
        hmac = soup.find('input', {'name': 'hmac'})['value']
        about = soup.find('textarea', {'name': 'about'}).get_text()
        endpoint = soup.find('form', {'method': 'post'})['action']
        endpoint = endpoint.replace("/", "")

        try:
            uemail = soup.find('input', {'name': 'uemail'})['value']
        except:
            uemail = ""
        return [hmac, hnid, about, uemail, endpoint]

    def post_profile(self, username, email, about):
        if(not self.loggedIn):
            raise LoginRequiredException('Not signed in!')
        f = open(ru.COOKIE, 'rb')
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

        r = self.session.post(ru.hn_url(info[4]), data=params)
        return True

    def post_comment(self, source, comment):
        if (not self.loggedIn):
            raise LoginRequiredException('Not signed in!')

        f = open(ru.COOKIE, 'rb')
        cookies = requests.utils.cookiejar_from_dict(pickle.load(f))
        f.close()

        comment = cgi.escape(comment)
        try:
            r = self.session.get(
                ru.hnUrl('item?id=' + source))
        except:
            print("error getting page")
            return False
        soup = BeautifulSoup(r.content)
        hmac = soup.find('input', {'name': 'hmac'})['value']
        endpoint = soup.find('form', {'method': 'post'})['action']
        params = {'hmac': hmac, 'text': comment, 'parent': source, 'goto': "item?id=" + source}

        try:
            r = self.session.post(ru.hn_url(endpoint), data=params)
        except Exception:
            print(Exception)
            return False
        if (r.url == ("https://news.ycombinator.com/item?id=" + source)):
            return True
        else:
            print(r.url)
        return False

    def post_story(self, title, link, text):
        if not self.loggedIn:
            raise LoginRequiredException('Not signed in!')

        f = open(ru.COOKIE, 'rb')
        cookies = requests.utils.cookiejar_from_dict(pickle.load(f))
        f.close()

        if text != '':
            text = cgi.escape(text)

        try:
            r = self.session.get(ru.hn_url('submit'))
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
                ru.hn_url(endpoint), data=params)
        except:
            return False

        if (r.url == "https://news.ycombinator.com/newest"):
            return True
        return False

    def get_stories(self, list):
        storyPage = HNStory(ru.hn_url(list), self.session)
        storyPage.parse_stories()
        return storyPage.stories, storyPage.moreLink

    def get_search_stories(self, props):
        storyPage = HNStory(self.session, ru.search_url(props), "search")
        storyPage.parse_stories()
        return storyPage.stories

    def get_comments(self, ident, isAsk=False, legacy=False):
        commentPage = HNComments(ru.hn_url())
        text, comments = self.comments.parse_comments(ident, self.session, isAsk, legacy)
        return text, comments


