from bs4 import BeautifulSoup
import re
import json
import os
import requests
from datetime import *
from .readerutils import readerutils
from urllib.parse import quote, urlparse


class NoResultsFoundException(Exception):
    pass


class ExpiredLinkException(Exception):
    pass


class HNComments():

    def __init__(self, pageURL):
        self.pageURL = pageURL
        self.comments = []
        self.soup = None

    def flatten(self, comments, level=0):
        # comments is a list

        if not comments:
            return []  # exit case

        # add the level key so you can keep track of the original level

        for c in comments:
            if ('created_at' in c):
                c['text'] = c['text'][3:]
                c['indent'] = level * 40
                parts = c['created_at'].split('.')
                dt = datetime.strptime(parts[0], "%Y-%m-%dT%H:%M:%S")
                # returns a relative date
                c['time'] = readerutils.pretty_date(dt)
                # adds the item to the result
                res.append(c)
            # removes the childs from the item (important)
            childs = c.pop('children', [])
            # and the flattened childs later
            res += self.flatten(childs, level + 1)
            # in the next loop the next sibling will be added

        return res

    def api_fetch(self, source, isAsk):

        toFlatten = source.json()
        if (isAsk == "true"):
            self.text = toFlatten['text'][3:]

        # toFlatten = json.loads(decoded)
        print("Flattening comments")
        if ('message' in toFlatten):
            if (toFlatten['message'] == 'ObjectID does not exist'):
                return self.text, []
        self.comments = self.flatten(toFlatten['children'])

    def legacy_text(self):
        """ Returns the text of an 'Ask HN' post
        """
        for child in self.soup.find_all('td')[10].contents:
            self.text += str(child)

    def legacy_fetch(self, page, isAsk):
        """ Extract all the comments from a comments page.
            Returns None if this page has no comments.
            Otherwise returns dicts of comments EG)
            {
            text: 'example'
            time: '100 days ago '
            indent: '80'
            author: 'pg'
            }
        """

        self.soup = BeautifulSoup(page.content)
        if (isAsk == "true"):
            print("Getting text...")
            self.text = self.legacy_text(self.soup)
        else:
            self.text = ''

        comment_tables = self.soup.find_all('table', 0)
        del comment_tables[0:4]
        if (len(comment_tables) == 0):
            return self.text, []
        del comment_tables[-1]

        comments = []
        itercomments = iter(comment_tables)
        for table in comment_tables:
            # startTime = time.time()
            comment = {'indent': None, 'author': "Deleted",
                       'time': "???", 'text': "", 'id': ""}
            head = table.find('span', 'comhead')
            body = table.find('span', 'comment')
            for img in table.find_all('img', {"src": "s.gif"}):
                comment['indent'] = int(img.get('width'))
            try:
                hrefs = head.find_all('a')
                comment['author'] = hrefs[0].get_text()
                comment['time'] = hrefs[1].get_text()
                comment['id'] = hrefs[1]['href'].split('item?id=')[1]
                for child in body.find('font').contents:
                    comment['text'] = comment['text'] + str(child)
            except:
                comment['text'] = '[deleted]'
            self.comments.append(comment)

    def parse_comments(self, source, sess, isAsk=False, legacy=False):
        """Gets the comments and text of the post
        """

        scrapeURL = 'https://news.ycombinator.com/item?id=%s' % source
        commentsURL = 'http://hn.algolia.com/api/v1/items/{0}'.format(source)
        text = ""

        if (legacy == True):
            self.pageURL = scrapeURL
            print("scraping to fetch comments")
            r = sess.get(scrapeURL)
            self.legacy_fetch(r, isAsk)
        elif (legacy == False):
            self.pageURL = commentsURL
            print("using api to fetch comments")
            r = sess.get(commentsURL)
            self.apiFetch(r, isAsk)


class HNStory():
    def __init__(self, sess, pageURL, st=''):
        self.sess = sess
        self.stories = []
        self.story_type = st
        if st != '':
            self.content = self.sess.get(url=pageURL).content
            if ("Unknown or expired link." in str(self.content)):
                raise ExpiredLinkException("Expired link!")
        else:
            self.content = self.sess.get(url=pageURL).json
        self.soup = None

    def parse_data(self):
        """ Extract all the stories from a story page.
        Returns dicts representing stories EG)
        {
            title: 'example'
            time: '100 days ago '
            points: '1298 points'
            author: 'pg'
        }
        """
        story = {
                'title': None, 'domain': None, 'score': None, 'author': None, 'time': None, 'commentCount': None,
                'link': None, 'commentURL': 'news.ycombinator.com/item?id=-1', 'hnid': '-1', 'askPost': 'false'
        }

        soup = BeautifulSoup(self.content)
        story_tables = soup.find_all('table', 0)
        del story_tables[0:2]
        del story_tables[-1]

        metadata = story_tables[0].find_all("td", "subtext")
        head = story_tables[0].find_all("td", "title", align=False)
        for i, m in zip(head, metadata):
            story['title'] = i.find_all('a')[0].textl
            story['link'] = i.find("a")["href"]
            if 'item?id='in story['link']:
                story['link'] = 'https://news.ycombinator.com/' + story['link']
                story['askPost'] = "true"
            try:
                story['domain'] = i.find("span", "sitebit comhead").text
                story['domain'] = re.search(r'\(([^)]*)\)', story['domain']).group(1)  # Remove brackets from domain
            except:
                story['domain'] = "news.ycombinator.com"
            if 'point' in m.text:
                hrefs = m.find_all('a')
                story['author'] = hrefs[0].get_text()
                story['time'] = hrefs[1].get_text()
                story['score'] = m.find('span').get_text().split()[0]
                story['hnid'] = m.span['id'].split('_')[1]
                story['commentURL'] = "https://news.ycombinator.com/item?id=" + \
                    story['hnid']
                if 'discuss' in m.text:  # Zero comments
                    story['commentCount'] = '0'
                else:
                    try:
                        story['commentCount'] = hrefs[3].get_text().split()[0]
                    except AttributeError:
                        story['commentCount'] = '?'
            else:  # Jobs post
                story['time'] = m.text.strip()
                story['commentCount'] = '0'
                story['score'] = '0'
                story['author'] = 'ycombinator'
            self.stories.append(story)
            self.moreLink = head[-1].find_all('a')[0]['href']

    def parse_stories(self):
        if self.story_type == "search":
            self.parse_search_data()
        else:
            self.parse_data()

    def parse_search_data(self):
        # The time is returned in this format
        incomplete_iso_8601_format = '%Y-%m-%dT%H:%M:%S.000Z'
        res = []
        for e in self.content['hits']:

            articleURL = e['url']
            parsed_uri = urlparse(articleURL)
            commentURL = 'https://news.ycombinator.com/item?id=' + str(e['objectID'])
            if e['story_text'] != "":
                isAsk = 'true'
                domain = "news.ycombinator.com"
                articleURL = commentURL
            else:
                isAsk = 'false'
                domain = '{uri.netloc}'.format(uri=parsed_uri)
            timestamp = readerutils.prettyDate(
                datetime.strptime(e['created_at'], incomplete_iso_8601_format))
            result = {
                'title': e['title'], 'poster': e['author'], 'points': e['points'], 'num_comments': str(e['num_comments']),
                'timestamp': timestamp, 'id': str(e['objectID']), 'domain': domain,
                'articleURL': articleURL, 'commentURL': commentURL, 'isAsk': isAsk
            }
            self.stories.append(result)
