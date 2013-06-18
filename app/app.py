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
        # file_count = sum((len(f) for _, _, f in os.walk(os.getcwd() + '/data/')))
        # print(str(file_count) + " files")
        # dirList=os.listdir(os.getcwd() + '/data/')
        # os.remove(os.getcwd() + '/data/' + 'news.xml')
        # for fname in dirList:
        #     print (fname)
        if int(self.file_age_in_seconds(fileToRead)) <= 300 and forceReload == 'False':
            tart.send('updateList', file=fileToRead)
        else:
            articleXML = open(os.getcwd() + '/data/' + HNpage, 'w+')

            postList = HS.getPage("http://news.ycombinator.com/" + source)

            articleXML.write('<articles>\n')
            for item in postList:
                articleXML.write('\t<item>\n')
                for detail in item.getDetails():
                    articleXML.write("{}\n".format(detail))
                articleXML.write('\t</item>\n')
            articleXML.write('</articles>')
            #print (articleXML.read())
            tart.send('updateList', file=fileToRead)
            articleXML.close()

    def file_age_in_seconds(self, pathname):
        return time.time() - os.stat(pathname)[stat.ST_MTIME]

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
