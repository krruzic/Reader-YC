import urllib.request, time, os, stat
from .HNStoryAPI import *
from .HNCommentAPI import *
from .HNGetText import *

import tart

HS = HackerNewsStoryAPI()
HC = HackerNewsCommentAPI()
HT = HackerNewsText()


class App(tart.Application):
    def onManualExit(self):
        print("exiting app, deleting files")
        folder = os.getcwd() + '/data/'
        for the_file in os.listdir(folder):
            if (the_file != 'ask.xml') or (the_file != 'new.xml') or (the_file != 'top.xml'):
                file_path = os.path.join(folder, the_file)
                if os.path.isfile(file_path):
                    os.unlink(file_path)
        tart.send('continueExit')

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

        HNpage = source + '.xml'
        #print("Page to curl: " + HNpage)
        fileToRead = os.getcwd() + '/data/' + HNpage

        print("opening file to write...")
        articleXML = open(fileToRead, 'w+')

        postList, moreLink = HS.getPage("http://news.ycombinator.com/" + source)
        print("The next page is at: " + moreLink)
        #print("writing to file....")
        articleXML.write('<articles>\n')
        for item in postList:
            articleXML.write('\t<item>\n')
            for detail in item.getDetails():
                articleXML.write("{}\n".format(detail))
            articleXML.write('\t</item>\n')
        articleXML.write('</articles>')
        tart.send('updateList', file=fileToRead, moreLink=moreLink) # , more=moreLink
        articleXML.close()

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
