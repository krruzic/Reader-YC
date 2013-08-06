import urllib.request
from HNStoryAPI import *
from HNCommentAPI import *


HS = HackerNewsStoryAPI()
HC = HackerNewsCommentAPI()


def onUiReady():
    pass

def onRequestPage(source, sentBy):
    print("source sent:" + source)
    print("sent by: " + sentBy)
    if source == 'Top Posts':
        source = 'news'
    if source == 'Ask HN':
        source = 'ask'
    if source == 'Newest Posts':
        source = 'newest'

    try:
        postList, moreLink = HS.getPage("http://news.ycombinator.com/" + source)
    except urllib.error.URLError:
        print("error from python: " + "URLError")
        return
    except IndexError:
        print("error from python: " + "IndexError")

        return

    stories = []
    for item in postList:
        stories.append(item.getDetails())
    print(stories)
    print("The next page is at: " + moreLink)



def onRequestComments(source):
    print("source sent:" + source)
    try:
        text, commentList, moreLink = HC.getPage(source)
    except urllib.error.URLError:
        return
    except IndexError:
        print("list error")
        return
    print("TEXT: " + text)
    comments = []

    for item in commentList:
        comments.append(item.getDetails())
    print(comments)
    print("More comments at: " + moreLink)

onRequestComments("http://news.ycombinator.com/item?id=5781369")


# class utility(object):
#     """A class used by App to simplify things :)
#     """

#     def cacheWriter(self, comments, url):
#         pageIDStart = url.find('=') + 1
#         pageID = url[pageIDStart:-1] + '.xml'

#         fileToWrite = os.getcwd() + '/cache/' + pageID
#         cacheFile = open(fileToRead, 'w+')

#         cacheFile.write('<articles>\n')
#         for comment in comments:
#             cacheFile.write('\t<item>\n')
#             for detail in comment:
#                 cacheFile.write('\t\t<commentNum>' detail[0] + '</commentNum>')
#                 cacheFile.write('\t\t<poster>' + detail[1] + '</poster>')
#                 cacheFile.write('\t\t<timePosted>' + detail[2] + '</timePosted>')
#                 cacheFile.write('\t\t<indent>' + detail[3] + '</indent>')
#                 cacheFile.write('\t\t<text>' + detail[4] + '</text>')
#         cacheFile.write('</articles>')
#         cacheFile.close()

#     def addFavourite(self, itemDetails):
#         fileToWrite = os.getcwd() + '/history' + '.xml'
#         try:
#             with open(fileToWrite): pass
#         except IOError:
#             print("History file doesn't exist, creating now.")
