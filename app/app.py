import urllib.request
from .HNStoryAPI import HackerNewsStoryAPI
from .HNCommentAPI import HackerNewsCommentAPI
from .HNUserAPI import HackerNewsUserAPI

import tart

HS = HackerNewsStoryAPI()
HC = HackerNewsCommentAPI()
HU = HackerNewsUserAPI()

class App(tart.Application):
    """ The class that directly communicates with Tart and Cascades
    """

    def onUiReady(self):
        pass

    def onRequestPage(self, source, sentBy):
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

        print("The next page is at: " + moreLink)
        if (sentBy == 'topPage'):
            print("sending stories to Top")
            tart.send('addTopStories', stories=stories, moreLink=moreLink, sentTo=sentBy)
        elif (sentBy == 'askPage'):
            print("sending stories to Ask")
            tart.send('addAskStories', stories=stories, moreLink=moreLink, sentTo=sentBy)
        else:
            print("sending stories to New")
            tart.send('addNewStories', stories=stories, moreLink=moreLink, sentTo=sentBy)



    def onRequestComments(self, source):
        print("source sent:" + source)
        try:
            text, commentList, moreLink = HC.getPage(source)
        except urllib.error.URLError:
            tart.send('commentError', text="Error getting comments. Check your connection \nand try again")
            tart.send('addText', text='')
            return
        except IndexError:
            tart.send('commentError', text="Link expired. \nHit refresh to reload data.")
            tart.send('addText', text='')
            return
        print("TEXT: " + text)
        tart.send('addText', text=text)
        comments = []

        for item in commentList:
            comments.append(item.getDetails())
        print("More comments at: " + moreLink)
        tart.send('addComments', comments=comments, moreLink=moreLink)

    def onRequestUserPage(self, source):
        print("source sent: " + source)

        source = source.strip() # strips leading and trailing whitespaces
        source = source.split(' ', 1)[0] # Takes just the first word passed
        try:
            detailList = HU.getUserPage("http://news.ycombinator.com/user?id=" + source)
            tart.send('userInfoReceived', details=detailList)
        except userError:
            tart.send('userError', text="That user doesn't exist, \nusernames are case sensitive")
            return
        except urllib.error.URLError:
            tart.send('userError', text="Error getting user page, Check your connection \nand try again")
        return


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
