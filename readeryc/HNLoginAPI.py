import os, glob
from bs4 import BeautifulSoup
import requests, pickle, re, html.parser, cgi
from .readerutils import readerutils
    
def login(username, password):
    r = requests.get('https://news.ycombinator.com/newslogin')
    print("SOUPING")
    soup = BeautifulSoup(r.content)
    try:
        fnid = soup.find('input', attrs=dict(name='fnid'))['value']
    except:
        return "false"
    result = "false"
    sess = requests.session()
    res = sess.get('https://news.ycombinator.com/newslogin', headers=readerutils.HEADERS)
    fnid = soup.find('input')['value']
    soup = BeautifulSoup(res.content)
    params = {'u': username, 'p': password, 'fnid': fnid}
    r = sess.post('https://news.ycombinator.com/y', headers=readerutils.HEADERS, params=params)
    if ("Bad login" not in r.text):
        print("no bad login")
        cookies = sess.cookies
        f = open(readerutils.COOKIE, 'wb')
        pickle.dump(requests.utils.dict_from_cookiejar(cookies), f)
        f.close()
        username = username
        result = "true"
    return result

def getProfile(username):
    f = open(readerutils.COOKIE, 'rb')
    cookies = requests.utils.cookiejar_from_dict(pickle.load(f))
    f.close()

    h = html.parser.HTMLParser() # To decode the HTML entities
    r = requests.get('https://news.ycombinator.com/user?id={0}'.format(username), headers=readerutils.HEADERS, cookies=cookies)
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
        print("Error getting userpage, force logout!")
        return []
        
    maxvisit = str(soup.find('input', {'name': 'maxvisit'})['value'])
    minaway = str(soup.find('input', {'name': 'minaway'})['value'])
    delay = str(soup.find('input', {'name': 'delay'})['value'])

    #print(r.content)
    about = soup.find('textarea', {'name': 'about'}).text 
    about = h.unescape(about)
    about = about.replace('<i>', '*')
    about = about.replace('<\i>', '*')
    about = re.sub("<.*?>", "", about)
    about = about[1:]
    email = soup.find('input', {'name': 'email'})['value']
    email = h.unescape(email)
    return [fnid, about, email, showdead, noprocrast, maxvisit, minaway, delay]

def saveProfile(username, email, about):
    f = open(COOKIE, 'rb')
    cookies = requests.utils.cookiejar_from_dict(pickle.load(f))
    f.close()
    #h = html.parser.HTMLParser() # To decode the HTML entities
    about = cgi.escape(about)
    email = cgi.escape(email)

    info = getProfile(username)
    params =  {
        'fnid': info[0],
        'about': about,
        'email': email,
        'showdead': info[3],#soup.find('select', {'name': 'showdead'})['selected'].text,
        'noprocrast': info[4],#soup.find('select', {'name': 'noprocrast'})['selected'].text,
        'maxvisit': info[5],
        'minaway': info[6],
        'delay': info[7]
    }
    print("Sending parameters")
    for i in params:
        print(i)

    r = requests.post('https://news.ycombinator.com/x', headers=HEADERS, params=params, cookies=cookies)
    return True

def postComment(source, comment):
    f = open(readerutils.COOKIE, 'rb')
    cookies = requests.utils.cookiejar_from_dict(pickle.load(f))
    f.close()
    print("Posting comment!")

    comment = cgi.escape(comment)
    try:
        r = requests.get('https://news.ycombinator.com/reply?id={0}'.format(source), headers=readerutils.COOKIE, cookies=cookies)
    except:
        return False
    soup = BeautifulSoup(r.content)
    fnid = str(soup.find('input', attrs=dict(name='fnid'))['value'])
    params = {
    'fnid': fnid,
    'text': comment
    }
    try:
        r = requests.post('https://news.ycombinator.com/r', params=params, headers=readerutils.HEADERS, cookies=cookies)
    except:
        return False
    print(r.url, r.headers, r.history)
    if(r.url == "https://news.ycombinator.com/news"):
        return True
    return False

# def checkLogin():

