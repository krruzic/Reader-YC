import urllib.request
from bs4 import BeautifulSoup
import re


class HackerNewsCommentAPI:
    """The class used for searching the HTML for
       all our comments and their data
    """
    numberOfComments = 0
    isTextPost = 0  # 0 means it is a text post. 1 means it isn't
    dead = False # Keeps track of whether a post is dead or not, so we don't waste time getting the comments
    def getSource(self, url):
        """Returns the HTML source code for a URL.
        """

        print("curling page: " + url)
        with urllib.request.urlopen(url) as url:
            source = url.read()
        print("page curled")
        return source


    def getCommentText(self,source):
        """Gets the comment text for a comment
        """

        linksFound = []
        soup = BeautifulSoup(source)
        # for a in soup.findAll('a',href=True):
        #     linksFound.append(str(a['href']))
        textStart = sourcNoe.find('font') + 21
        textEnd = source.find('</font', textStart)
        text = source[textStart:textEnd]

        # for i in range(len(linksFound)):
        #     text = re.sub('<[^<]+?>.*<[^<]+?>', linksFound[i], text) # replaces href tags with the full links
        if text == '">[deleted]</span': # deleted comment signature
            text = '[deleted]'
        return text

    def getCommentIndent(self,source):
        """Gets the comment's indent
        """

        indentStart = source.find('width=') + 7
        indentEnd = source.find('>', indentStart) - 2
        indent = source[indentStart:indentEnd]
        return indent

    def getCommentDetails(self, source):
        """Gets the time & poster of a comment
        """

        posterStart = source.find('user?id=')
        realPosterStart = source.find('=', posterStart) + 1
        posterEnd = source.find('"', realPosterStart)
        poster = source[realPosterStart:posterEnd]
        if poster == '<span class=': # deleted comment signature
            poster = ''

        time = re.findall(r"</a> (\d+ .* ago)", source) # regex to find post time format: X mins/hours ago
        if not time: # deleted comments won't have a match for this regex
            time = ['']

        return poster, str(time[0])

    def getMoreLink(self, page):
        """Gets the link for more comments
           found at the bottom of threads with >100 comments.
        """

        soup = BeautifulSoup(page)
        story_details = soup.findAll("td", {"class" : "title"})
        source = str(story_details[len(story_details) - 1])
        linkStart = source.find('href="') + 6

        if len(source) > 49:
            linkStart = linkStart + 1
            linkEnd = source.find('rel=') - 2
            moreLink = source[linkStart:linkEnd]
            return moreLink
        else:
            linkEnd = source.find('>More<') - 1
            moreLink = source[linkStart:linkEnd]
            return moreLink

    def getText(self, source):
        """Finds the text portion of text posts,
           and returns it to tart.
        """
        if self.isTextPost == 1: # Not a text post
            return ""

        soup = BeautifulSoup(source)

        text_content = soup.findAll("tr")
        text_content =str(text_content[7])

        textStart = text_content.find('d><td>') + 6
        textEnd = text_content.find('</td', textStart)
        text = text_content[textStart:textEnd]
        if (text == 'td><img height="1" src="s.gif" width="0"/>'):
            self.dead = True
            text = "[dead]"
        #print(text)
        return text
        #tart.send('addText', text=text)


    # def getArticle(self, source):
    #     """Looks at the source,
    #        and creates a list of the article details.
    #     """
    #     article_content = []
    #     soup = BeautifulSoup(source)

    #     article_title = str(soup.find("td", {"class": "title"}))
    #     article_details = soup.find("td", {"class": "subtext"})

    #     titleStart = re.findall(r"item.*>", article_title)
    #     titleStart = titleStart[0].find('">') + 29
    #     titleEnd = article_title.find('</a', titleStart)
    #     title = article_title[titleStart:titleEnd]

    #     timeStart = str(article_details).find('a>') + 2
    #     timeEnd = str(article_details).find('<a', timeStart) - 3
    #     time = str(article_details)[timeStart:timeEnd]

    #     points = str(article_details.find("span", id=True))
    #     pointsStart = points.find('>') + 1
    #     pointsEnd = points.find('</', pointsStart)
    #     points = points[pointsStart:pointsEnd]

    #     poster = str(article_details.find("a", href=True))
    #     posterStart = poster.find('">') + 2
    #     posterEnd = poster.find('</', posterStart)
    #     poster = poster[posterStart:posterEnd]


    #     article_content.append(title)
    #     article_content.append(points)
    #     article_content.append(poster)
    #     article_content.append(time)
    #     #tart.send('articleDetails', details=article_content)
    #     print(article_content)


    def getComments(self, source):
        """Looks at the source,
           makes comments from it, and returns these comments
        """

        # Replaces <p> tags in the comments
        source = source.decode("utf-8")
        soup = BeautifulSoup(source)

        # gets the comment text
        comment_content = soup.findAll("span", {"class": "comment"})
        # gets the indent of the comment
        comment_indent = soup.findAll("img", {"src": "s.gif", "height": "1"})
        # gets the other info, ie) time and poster name
        comment_details = soup.findAll("span", {"class": "comhead"})
        # counts the number of comments
        self.numberOfComments = source.count('span class="comment"')
        print(self.numberOfComments)
        if str(comment_details[0]).find('(') == 23: # link posts first result will actually be the domain name
            self.isTextPost = 1
        else:
            self.isTextPost = 0

        # Create an empty list of comments
        comments = []
        for i in range(0, self.numberOfComments):
            comment = HackerNewsComment()
            comments.append(comment)

        commentsText = []
        commentsIndent = []
        commentsIndentFinal = []
        commentsPoster = []
        commentsTime = []

        for c in range(0, len(comment_content)):
            comment = str(comment_content[c]) # Turns the element into a string (changes it from a BeautifulSoup object)
            commentText = self.getCommentText(comment)
            commentsText.append(commentText)

        for h in range(1, len(comment_indent)): # The first comment is actually the second element of this list.
            comment = str(comment_indent[h])
            commentIndent = self.getCommentIndent(comment)
            if int(commentIndent) % 10 == 0: # Remove the extra img tag deleted comments have
                commentsIndent.append(commentIndent)

        for s in range(self.isTextPost, len(comment_details)):
            comment = str(comment_details[s])
            poster, time = self.getCommentDetails(comment)
            commentsPoster.append(poster)
            commentsTime.append(time)

        # Merge these values to each represent one comment
        for i in range(0, self.numberOfComments):
            comments[i].commentNum = i + 1
            comments[i].text = commentsText[i]
            comments[i].indent = commentsIndent[i]
            comments[i].poster = commentsPoster[i]
            comments[i].timePosted = commentsTime[i]

        return comments

    def getPage(self, url):
        """Gets the comments from the specified Hacker News page.
        """

        source = self.getSource(url)
        text = self.getText(source)
        #articleInfo = self.getArticle(source)
        moreLink = self.getMoreLink(source)
        if (self.dead != True):
            comments = self.getComments(source)
        else:
            comments = []

        return text, comments, moreLink

class HackerNewsComment:
    """A class representing a comment on Hacker News
    """

    commentNum = 0
    text = ""
    indent = 0
    poster = ""
    timePosted = ""

    def getDetails(self):
        """Creates a tuple of the comment details
        """

        self.commentNum = '%03d' % self.commentNum # prepends zeroes to the comment number
        detailList = (str(self.commentNum), self.poster, self.timePosted, self.indent, self.text)
        return detailList
