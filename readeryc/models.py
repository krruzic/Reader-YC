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

    def flatten(self, comments, level=0):
        # comments is a list

        if not comments:
            return []  # exit case

        res = []
        # add the level key so you can keep track of the original level

        for comment in comments:
            if ('created_at' in comment):
                comment['text'] = comment['text'][3:]
                comment['indent'] = level * 40
                parts = comment['created_at'].split('.')
                dt = datetime.strptime(parts[0], "%Y-%m-%dT%H:%M:%S")
                # returns a relative date
                comment['time'] = readerutils.prettyDate(dt)
                # adds the item to the result
                res.append(comment)
            # removes the childs from the item (important)
            childs = comment.pop('children', [])
            # and the flattened childs later
            res += self.flatten(childs, level + 1)
            # in the next loop the next sibling will be added

        return res

    def apiFetch(self, source, isAsk):

        toFlatten = source.json()
        text = ""
        if (isAsk == "true"):
            text = toFlatten['text'][3:]

        # toFlatten = json.loads(decoded)
        print("Flattening comments")
        if ('message' in toFlatten):
            if (toFlatten['message'] == 'ObjectID does not exist'):
                return text, []
        comments = self.flatten(toFlatten['children'])
        return text, comments  # possibly zero comments

    def legacyText(self, soup):
        """ Returns the text of an 'Ask HN' post
        """
        text = ""
        for child in soup.find_all('td')[10].contents:
            text = text + str(child)
        return text

    def legacyFetch(self, page, isAsk):
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

        soup = BeautifulSoup(page.content)
        if (isAsk == "true"):
            print("Getting text...")
            text = self.legacyText(soup)
        else:
            text = ''

        comment_tables = soup.find_all('table', 0)
        del comment_tables[0:4]
        if (len(comment_tables) == 0):
            return text, []
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
            comments.append(comment)
        return text, comments

    def parseComments(self, source, isAsk=False, legacy=False):
        """Gets the comments and text of the post
        """

        scrapeURL = 'https://news.ycombinator.com/item?id=%s' % source
        commentsURL = 'http://hn.algolia.com/api/v1/items/{0}'.format(source)
        text = ""

        if (legacy == True):
            print("scraping to fetch comments")
            r = requests.get(scrapeURL, headers=readerutils.HEADERS)
            text, comments = self.legacyFetch(r, isAsk)
        elif (legacy == False):
            print("using api to fetch comments")
            r = requests.get(commentsURL, headers=readerutils.HEADERS)
            text, comments = self.apiFetch(r, isAsk)
        return text, comments


class HNStory():

    def parseData(self, page):
        """ Extract all the stories from a story page.
        Returns dicts representing stories EG)
        {
            title: 'example'
            time: '100 days ago '
            points: '1298 points'
            author: 'pg'
        }
        """
        soup = BeautifulSoup(page)
        story_tables = soup.find_all('table', 0)
        del story_tables[0:2]
        del story_tables[-1]

        metadata = story_tables[0].find_all("td", "subtext")
        head = story_tables[0].find_all("td", "title", align=False)
        stories = []
        for i, m in zip(head, metadata):
            story = {
                'title': None, 'domain': None, 'score': None, 'author': None, 'time': None, 'commentCount': None,
                'link': None, 'commentURL': 'news.ycombinator.com/item?id=-1', 'hnid': '-1', 'askPost': 'false'
            }
            story['title'] = i.find_all('a')[0].text
            story['link'] = i.find("a")["href"]
            if 'item?id='in story['link']:
                story['link'] = 'https://news.ycombinator.com/' + story['link']
                story['askPost'] = "true"
            try:
                story['domain'] = i.find("span", "sitebit comhead").text
                story['domain'] = re.search(r'\(([^)]*)\)', story['domain']).group(
                    1)  # Remove brackets from domain
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
                        story['commentCount'] = hrefs[2].get_text().split()[0]
                    except AttributeError:
                        story['commentCount'] = '?'
            else:  # Jobs post
                story['time'] = m.text.strip()
                story['commentCount'] = '0'
                story['score'] = '0'
                story['author'] = 'ycombinator'
            stories.append(story)
        return stories, head[-1].find_all('a')[0]['href']

    def parseStories(self, source):
        url = source
        print("curling page: " + url)
        r = requests.get(url=url, headers=readerutils.HEADERS)
        page = r.content
        print("page curled")
        if ("Unknown or expired link." in str(page)):
            raise ExpiredLinkException("Expired link!")
        stories, moreLink = self.parseData(page)
        return stories, moreLink


class HNSearchStory():

    def parseSearchStories(self, pageNumber, source):
        """
        Queries the HNSearch API and returns
        tuples of the results
        """
        author = ""
        print("STARTING: " + str(pageNumber))
        if (source[1] != ""):
            author = ",author_" + source[1]
        url = "http://hn.algolia.com/api/v1/search_by_date?query={0}&page={1}&tags=story{2}".format(
            quote(source[0]), pageNumber, author)
        # reads the returned data
        r = requests.get(url, headers=readerutils.HEADERS)
        print("Page curled")
        items = r.json()

        # The time is returned in this format
        incomplete_iso_8601_format = '%Y-%m-%dT%H:%M:%S.000Z'
        res = []
        for e in items['hits']:

            articleURL = e['url']
            parsed_uri = urlparse(articleURL)
            commentURL = 'https://news.ycombinator.com/item?id=' + str(e['objectID'])
            if e['story_text'] != "":  # Javascript uses lowercase for bools...
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
            res.append(result)

        return res
