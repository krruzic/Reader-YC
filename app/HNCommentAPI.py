from bs4 import BeautifulSoup
import re

#import tart

class HackerNewsCommentAPI:
    """
The class used for searching the HTML for all our comments and their data
"""
    numberOfComments = 0
    isTextPost = 0  # 0 means it is a text post. 1 means it isn't

    def getCommentText(self,source):
        """
Gets the comment text for a comment
"""
        linksFound = []
        soup = BeautifulSoup(source)
        for a in soup.findAll('a',href=True):
            linksFound.append(str(a['href']))
        textStart = source.find('font') + 21
        textEnd = source.find('</font', textStart)
        text = source[textStart:textEnd]

        for i in range(len(linksFound)):
            text = re.sub('<[^<]+?>.*<[^<]+?>', linksFound[i], text) # replaces href tags with the full links
        if text == '">[deleted]</span': # deleted comment signature
            text = '[deleted]'
        return text

    def getCommentIndent(self,source):
        """
Gets the comment's indent
"""
        indentStart = source.find('width=') + 7
        indentEnd = source.find('>', indentStart) - 2
        indent = source[indentStart:indentEnd]
        return indent

    def getCommentDetails(self, source):
        """
Gets the time & poster of a comment
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

    def getComments(self,source):
        """
Looks at the source, makes comments from it, and returns these comments
"""
        # Replaces <p> and <i> tags in the comments
        source = source.decode("utf-8")
        source = source.replace('<p>', '\n').replace('<i>', '').replace('</i>','')
        soup = BeautifulSoup(source)

        # gets the comment text
        comment_content = soup.findAll("span", {"class": "comment"})
        # gets the indent of the comment
        comment_indent = soup.findAll("img", {"src": "s.gif", "height": "1"})
        # gets the other info, ie) time and poster name
        comment_details = soup.findAll("span", {"class": "comhead"})
        # counts the number of comments
        self.numberOfComments = source.count('span class="comment"')

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
            comment = str(comment_content[c]) # turns the element into a string (changes it from a BeautifulSoup object)
            commentText = self.getCommentText(comment)
            commentsText.append(commentText)

        for h in range(1, len(comment_indent)): # The first comment is actually the second element of this list.
            comment = str(comment_indent[h])
            commentIndent = self.getCommentIndent(comment)
            if int(commentIndent) % 10 == 0: # if statement to remove the extra img tag deleted comments have
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

class HackerNewsComment:
    """
A class representing a comment on Hacker News
"""
    commentNum = 0
    text = ""
    indent = 0
    poster = ""
    timePosted = ""

    def printComments(self):
        """
Prints the details of the comment in xml format
"""
        print('\t\t<commentNum>', '%03d' % self.commentNum, '</commentNum>')
        print('\t\t<poster>' + self.poster + '</poster>')
        print('\t\t<timePosted>' + self.timePosted + '</timePosted>')
        print('\t\t<indent>' + self.indent + '</indent>')
        print('\t\t<text>' + self.text + '</text>')