from readeryc import HNapi
from bs4 import BeautifulSoup
import requests


api = HNapi()

def testGetComments(cid):
    return api.getComments(cid, False, True)


def testGetStories(list):
    return api.getStories(list)

def testSearchStories(start, source):
    return api.getSearchStories(start, source)

text, comments = testGetComments('9317159')
# for c in comments:
#     print(c)
stories, next = testGetStories('news')
# for s in stories:
#     print(s)
res = testSearchStories(0, ['test', ''])