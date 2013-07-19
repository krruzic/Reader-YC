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
        self.onRequestPage('Top Posts', 'True')

    def onRequestPage(self, source, forceReload):
        if source == 'Top Posts':
            source = 'news'
        if source == 'Ask HN':
            source = 'ask'
        if source == 'Newest Posts':
            source = 'newest'

        HNpage = source + '.xml'
        fileToRead = os.getcwd() + '/data/' + HNpage

        if int(self.file_age_in_seconds(fileToRead)) <= 300:
            tart.send('updateList', file=fileToRead)
        else:
            articleXML = open(os.getcwd() + '/data/' + HNpage, 'w+')

            postList = HS.getPage("http://news.ycombinator.com/" + source)
            moreLink = HS.getMoreLink("http://news.ycombinator.com/" + source)

            articleXML.write('<articles>\n')
            for item in postList:
                articleXML.write('\t<item>\n')
                for detail in item.getDetails():
                    articleXML.write("{}\n".format(detail))
                articleXML.write('\t</item>\n')
            articleXML.write('</articles>')
            tart.send('updateList', file=fileToRead) # , more=moreLink
            articleXML.close()

    def onRequestComments(self, source):
        
        HNPage = source + '.xml'
        fileToRead = os.getcwd() + '/data/' + HNPage
        
        commentsXML = open(fileToRead + HNPage, 'w+')
        
        commentList = HC.getComments("")
    
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
