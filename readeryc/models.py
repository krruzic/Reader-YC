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
        text_content = str(soup.findAll("tr")[7])
        textStart = text_content.find('d><td>') + 6
        textEnd = text_content.find('</td', textStart)
        text = text_content[textStart:textEnd]
        if ('<form action="/r"' in text):
            return ""
        # Replace unclosed <p>'s with new lines
        text = text.replace('<p>', '\n')
        text = text.replace('</p>', '')  # Remove the crap BS4 adds

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

        # soupStart = time.time()
        soup = BeautifulSoup(page.content)
        # soupEnd = time.time()
        # print("Souping: ", soupEnd - soupStart)
        if (isAsk == "true"):
            print("Getting text...")
            text = self.legacyText(soup)
        else:
            text = ''

        comment_tables = soup.find_all('table', 0)
        comment_tables = list(map(str, comment_tables))

        del comment_tables[0:4]
        if (len(comment_tables) == 0):
            return text, []
        del comment_tables[-1]

        comments = []
        totalTime = 0
        itercomments = iter(comment_tables)
        for table in itercomments:
            # startTime = time.time()
            comment = {}
            comment['indent'] = None
            comment['author'] = None
            comment['time'] = None
            comment['text'] = None
            comment['id'] = None

            soup = BeautifulSoup(table)
            head = soup.find_all('span', 'comhead')
            body = soup.find_all('span', 'comment')
            body = list(map(str, body))

            for img in soup.find_all('img', {"src": "s.gif"}):
                indent = (img.get('width'))
            if int(indent) % 10 == 0:
                comment['indent'] = int(indent)
            else:
                next(itercomments)
                # comment['indent'] = indent
                # comment['author'] = ''
                # comment['time'] = ''
                # comment['text'] = '[deleted]'
                # comment['id'] = ''

            authorStart = str(head).find('user?id=') + 8
            authorEnd = str(head).find('">', authorStart)
            if (comment['author'] == None):
                comment['author'] = str(head)[authorStart:authorEnd]

            timeStart = str(head).find('</a>') + 5
            timeEnd = str(head).find(' |')
            if (comment['time'] == None):
                comment['time'] = str(head)[timeStart:timeEnd]

            if (comment['id'] == None):
                comment['id'] = head[0].find_all('a')[1]['href'].split('item?id=')[1]

            textStart = 44
            textEnd = body[0].find('</font>')
            if (comment['text'] == None):
                comment['text'] = body[0][textStart:textEnd]

            comments.append(comment)
            # endTime = time.time()
            # print("Time to parse 1 comment: ", endTime - startTime)
            # totalTime = totalTime + (endTime - startTime)
        # print("Time to parse ", len(comment_tables), " comments: ", totalTime)
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
        # print("Souping: ", soupEnd - soupStart)
        story_tables = soup.find_all('table', 0)
        story_tables = list(map(str, story_tables))

        del story_tables[0:2]
        del story_tables[-1]

        for st in story_tables:
            metadata = soup.find_all("td", "subtext")

        head = soup.find_all("td", "title", valign=False)

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
                story['domain'] = i.find_all("span")[0].text
                story['domain'] = re.search(r'\(([^)]*)\)', story['domain']).group(
                    1)  # Remove brackets from domain
            except:
                story['domain'] = "news.ycombinator.com"

            if 'point' in m.text:
                story_time = re.search(r'by \S+ (\d+.*?)\s+\|', m.text).group(1) + ' '
                story['time'] = story_time
                story['score'] = re.search("(\d+)\s+points?", m.text).group(1)
                story['author'] = m.a.text.strip()
                story['hnid'] = m.span['id'].split('_')[1]
                story['commentURL'] = "https://news.ycombinator.com/item?id=" + \
                    story['hnid']
                if 'discuss' in m.text:  # Zero comments
                    story['commentCount'] = '0'
                else:
                    try:
                        story['commentCount'] = re.search(
                            "(\d+)\s+comments?", m.text).group(1)
                    except AttributeError:
                        # I found an instance where there was just the text
                        # 'comments', without any count. I'm assuming that
                        # even stranger things could happen
                        story['commentCount'] = '?'
            else:  # Jobs post
                story['time'] = m.text.strip()
                story['commentCount'] = '0'
                story['score'] = '0'
                story['author'] = 'ycombinator'

            # print("Time to parse 1 story: ", endTime - startTime)
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
        if (moreLink != 'news2'):
            moreLink = moreLink[1:]
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
            _id = e['objectID']
            title = e['title']
            points = e['points']
            articleURL = e['url']
            parsed_uri = urlparse(articleURL)
            domain = '{uri.scheme}://{uri.netloc}/'.format(uri=parsed_uri)
            num_comments = e['num_comments']
            parts = articleURL.split('//', 1)
            poster = e['author']
            commentURL = 'https://news.ycombinator.com/item?id=' + str(_id)

            if e['story_text'] != "":  # Javascript uses lowercase for bools...
                isAsk = 'true'
                domain = "http://news.ycombinator.com/"
                articleURL = commentURL
            else:
                isAsk = 'false'
            timestamp = readerutils.prettyDate(
                datetime.strptime(e['created_at'], incomplete_iso_8601_format))
            result = {
                'title': title,
                'poster': poster,
                'points': points,
                'num_comments': str(num_comments),
                'timestamp': timestamp,
                'id': str(_id),
                'domain': domain,
                'articleURL': articleURL,
                'commentURL': commentURL,
                'isAsk': isAsk
            }
            res.append(result)

        return res
