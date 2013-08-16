import urllib.request, threading
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
        self.onRequestPage("topPage", "topPage")
        # self.onRequestPage("Ask HN", "askPage")
        # self.onRequestPage("Newest Posts", "newestPage")

    def onRequestPage(self, source, sentBy):
        t = threading.Thread(target=self.story_routine, args=(source, sentBy))
        t.start()

    def story_routine(self, source, sentBy):
        print("source sent:" + source)
        print("sent by: " + sentBy)
        if source == 'topPage':
            source = 'news'
        if source == 'askPage':
            source = 'ask'
        if source == 'newestPage':
            source = 'newest'

        try:
            postList, moreLink = HS.getPage("https://news.ycombinator.com/" + source)
        except urllib.error.URLError:
            if (sentBy == 'topPage'):
                tart.send('topListError', text="Error getting news feed, check your connection and try again")
            elif (sentBy == 'askPage'):
                tart.send('askListError', text="Error getting news feed, check your connection and try again")
            elif (sentBy == 'newestPage'):
                tart.send('newListError', text="Error getting news feed, check your connection and try again")
            print("error from python: " + "URLError")
            return
        except IndexError:
            print("error from python: " + "IndexError")
            if (sentBy == 'topPage'):
                tart.send('topListError', text="Expired Link! Unable to load more content...")
            elif (sentBy == 'askPage'):
                tart.send('askListError', text="Expired Link! Unable to load more content...")
            elif (sentBy == 'newestPage'):
                tart.send('newListError', text="Expired Link! Unable to load more content...")
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



    def onRequestComments(self, source, askPost, deleteComments):
        print("source sent:" + source)
        try:
            HC.getPage(source, askPost, deleteComments)
        except urllib.error.URLError:
            tart.send('commentError', text="Error getting comments. Check your connection \nand try again")
            tart.send('addText', text='')

    def onRequestUserPage(self, source):
        print("source sent: " + source)

        source = source.strip() # strips leading and trailing whitespaces
        source = source.split(' ', 1)[0] # Takes just the first word passed
        try:
            detailList = HU.getUserPage("http://news.ycombinator.com/user?id=" + source)
            if (detailList != []):
                tart.send('userInfoReceived', details=detailList)
        except urllib.error.URLError:
            tart.send('userError', text="Error getting user page, Check your connection \nand try again")

    def onDownloadInvite(self):
        rc = bbmsp_send_download_invitation()


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
