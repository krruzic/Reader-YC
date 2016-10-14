from readeryc import HNapi
from bs4 import BeautifulSoup
import requests


api = HNapi()

def testGetComments(cid):
    return api.get_comments(cid, False, True)


def testGetStories(list):
    return api.get_stories(list)

def testSearchStories(props):
    return api.get_search_stories(props)

def testGetUser(username, password):
    res = api.login(username, password)
    if res:
        return api.get_profile(username)


text, comments = testGetComments('item?id=9317159')
print(text)
#for c in comments:
#    print(c)
#stories, next = testGetStories('news')
#print(stories)
#print(next)
#res = testSearchStories(['test', 0, ''])
#res = testGetUser('deft', '278lban')
#print(res)
