import urllib.request, time, os, stat
from .HNStoryAPI import *
from .HNCommentAPI import *
from .HNGetText import *

import tart

HS = HackerNewsStoryAPI()
HC = HackerNewsCommentAPI()
HT = HackerNewsText()


class App(tart.Application):
    def onUiReady(self):
        self.onRequestPage('Top Posts')

    def onRequestPage(self, source):
        print("source sent:" + source)
        if source == 'Top Posts':
            source = 'news'
        if source == 'Ask HN':
            source = 'ask'
        if source == 'Newest Posts':
            source = 'newest'
        else:
            source = source
        postList, moreLink = HS.getPage("http://news.ycombinator.com/" + source)
        stories = []
        #print(postList[0])
        for item in postList:
            #print(item)
            #print(item.getDetails)
            stories.append(item.getDetails())
        #for thing in stories:
         #   print(thing)
        #print(stories)
        print("The next page is at: " + moreLink)
        #print("writing to file....")
        tart.send('addStories', stories=stories, moreLink=moreLink) # , more=moreLink


    def onRequestComments(self, source):
        HNid = source[source.find('='):-1] + '.xml'
        HNPage = HNid + '.xml'
        fileToRead = os.getcwd() + '/data/comments/' + HNPage
        commentsXML = open(fileToRead, 'w+')

        with urllib.request.urlopen(link) as url:
            data = url.read()
        data = urllib.request.urlopen(link).read()
        commentList = HC.getComments(data)

        commentsXML.write('<comments>\n')
        for item in commentList:
            commentsXML.write('\t<item>\n')
            for detail in item.getDetails():
                commentsXML.write("{}\n".format(detail))
            commentsXML.write('\t</item>\n')
        commentsXML.write('</comments>')
        tart.send('fillComments', file=fileToRead)
        commentsXML.close()

    # def onMoreButton(self):
    #     moreLink = HS.getMoreLink("http://news.ycombinator.com/" + )
    #     return moreLink

    def file_age_in_seconds(self, pathname):
        if os.path.isfile(pathname):
            return time.time() - os.stat(pathname)[stat.ST_MTIME]
        else:
            return 1000

    # def onGetComments(self, source):
    #     HNid = source[source.find('='):-1] + '.xml'
    #     commentsXML = open(HNid, 'w')

    #     with urllib.request.urlopen(source) as url:
    #         data = url.read()
    #     data = urllib.request.urlopen(source).read()
    #     commentList = HC.getComments(data)

    #     commentsXML.write('<comments>\n')
    #     for item in commentList:
    #         commentsXML.write('\t<item>\n')
    #         commentsXML.write('%s\n' % item.printComments())
    #         commentsXML.write('\t<\item>\n')
    #     commentsXML.write('<\comments>')

    # def onGetTextPost(self, source):
    #     text = HT.getText(source)
    #     self.onGetComments(source)
    #     tart.send('textBody',text=text)
