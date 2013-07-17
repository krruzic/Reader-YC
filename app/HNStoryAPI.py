import urllib.request
from bs4 import BeautifulSoup
import re

class HackerNewsStoryAPI:
    """
The class for slicing and dicing the HTML and turning it into HackerNewsStory objects.
"""
    numberOfStoriesOnFrontPage = 0

    def getSource(self, url):
        """
Returns the HTML source code for a URL.
"""
        with urllib.request.urlopen(url) as url:
            source = url.read()
        return source

    def getStoryNumber(self, source):
        """
Parses HTML and returns the number of a story.
"""
        numberStart = source.find('>') + 1
        numberEnd = source.find('.')
        return int(source[numberStart:numberEnd])

    def getStoryURL(self, source):
        """
Gets the URL of a story.
"""
        URLStart = source.find('href="') + 6
        URLEnd = source.find('">', URLStart)
        url = source[URLStart:URLEnd]
        # Check for "Ask HN" links.
        if url[0:4] == "item": # "Ask HN" links start with "item".
            url = "http://news.ycombinator.com/" + url

        # Change "&amp;" to "&"
        # url = url.replace("&amp;", "&")

        # Remove 'rel="nofollow' from the end of links, since they were causing some bugs.
        if url[len(url)-13:] == "rel=\"nofollow":
            url = url[:len(url)-13]

        # Weird hack for URLs that end in '" '. Consider removing later if it causes any problems.
        if url[len(url)-2:] == "\" ":
            url = url[:len(url)-2]
        return url

    def getStoryDomain(self, source):
        """
Gets the domain of a story.
"""
        domainStart = source.find('comhead">') + 10
        domainEnd = source.find('</span>')
        domain = source[domainStart:domainEnd]
        # Check for "Ask HN" links.
        if domain[0] == '=':
            return "http://news.ycombinator.com"
        return "http://" + domain[1:len(domain)-2]

    def getStoryTitle(self, source):
        """
Gets the title of a story.
"""
        titleStart = source.find('>', source.find('>')+1) + 1
        titleEnd = source.find('</a>')
        title = source[titleStart:titleEnd]
        title = title.lstrip() # Strip trailing whitespace characters.
        return title

    def getStoryScore(self, source):
        """
Gets the score of a story.
"""
        scoreStart = source.find('>', source.find('>')+1) + 1
        scoreEnd = source.find(' ', scoreStart)
        try:
            score = int(source[scoreStart:scoreEnd])
            if score == 1:
                return str(score) + ' point'
            else:
                return str(score) + ' points'
        except ValueError:
            return ' HN Jobs'

    def getStoryDetails(self, source):
        """
Gets the poster username and the time it was posted
"""
        submitterStart = source.find('user?id=')
        realSubmitterStart = source.find('=', submitterStart) + 1
        submitterEnd = source.find('"', realSubmitterStart)
        submitter = source[realSubmitterStart:submitterEnd]
        if submitter == '<td class=':
            submitter = 'ycombinator'

        timeStart = source.find(submitter + '</a>') + len(submitter) + 5
        timeEnd = source.find('|', timeStart) - 1
        time = source[timeStart:timeEnd]
        if 'ext' in time:
            time = re.findall(r"(\d+ .* ago)", source)
            time = str(time[0]) + ' '
            #print(time)

        return submitter, time

    def getCommentCount(self, source):
        """
Gets the comment count of a story.
"""
        commentStart = source.find('item?id=')
        commentCountStart = source.find('>', commentStart) + 1
        commentEnd = source.find('</a>', commentStart)
        commentCountString = source[commentCountStart:commentEnd]
        if commentCountString == "discuss":
            return 0
        elif commentCountString == "":
            return 0
        else:
            commentCountString = commentCountString.split(' ')[0]
            return commentCountString

    def getHNID(self, source):
        """
Gets the Hacker News ID of a story.
"""
        urlStart = source.find('score_') + 6
        urlEnd = source.find('"', urlStart)
        try:
            return int(source[urlStart:urlEnd])
        except ValueError:
            return -1


    def getCommentsURL(self, source):
        """
Gets the comment URL of a story.
"""
        return "http://news.ycombinator.com/item?id=" + str(self.getHNID(source))


    def getMoreLink(self, page):
        """
Gets the link for more posts found at the bottom of every page.
"""
        source = self.getSource(page)
        soup = BeautifulSoup(source)
        story_details = soup.findAll("td", {"class" : "title"})
        source = str(story_details[len(story_details) - 1])
        linkStart = source.find('href="') + 6

        if len(source) > 49:
            linkEnd = source.find('rel=') - 2
            moreLink = source[linkStart:linkEnd]
            return 'http://news.ycombinator.com' + moreLink
        else:
            linkEnd = source.find('>More<') - 1
            moreLink = source[linkStart:linkEnd]
            return 'http://news.ycombinator.com/' + moreLink


    def getStories(self, source):
        """
Looks at source, makes stories from it, returns the stories.
"""
        # Decodes source to utf-8 and encodes to ascii usable in XML
        source = source.decode('utf-8')
        # print(source)
        self.numberOfStoriesOnFrontPage = 30
        # Create the empty stories.
        newsStories = []
        for i in range(0, self.numberOfStoriesOnFrontPage):
            story = HackerNewsStory()
            newsStories.append(story)

        soup = BeautifulSoup(source)
        # Gives URLs, Domains and titles.
        story_details = soup.findAll("td", {"class" : "title"})
        # Gives score, submitter, comment count and comment URL.
        story_other_details = soup.findAll("td", {"class" : "subtext"})

        # Get story numbers.
        storyNumbers = []
        for i in range(0,len(story_details) - 1, 2):
            story = str(story_details[i]) # otherwise, story_details[i] is a BeautifulSoup-defined object.
            storyNumber = self.getStoryNumber(story)
            storyNumbers.append(storyNumber)

        storyURLs = []
        storyDomains = []
        storyTitles = []
        storyScores = []
        storySubmitters = []
        storyCommentCounts = []
        storyCommentURLs = []
        storyTimes = []
        storyIDs = []

        for i in range(1, len(story_details), 2): # Every second cell contains a story.
            story = str(story_details[i])
            storyURLs.append(self.getStoryURL(story))
            storyDomains.append(self.getStoryDomain(story))
            storyTitles.append(self.getStoryTitle(story))

        for s in story_other_details:
            story = str(s)
            storyScores.append(self.getStoryScore(story))
            storySubmitter, storyTime = self.getStoryDetails(story)
            storySubmitters.append(storySubmitter)
            storyTimes.append(storyTime)
            storyCommentCounts.append(self.getCommentCount(story))
            storyCommentURLs.append(self.getCommentsURL(story))
            storyIDs.append(self.getHNID(story))


        # Associate the values with our newsStories.
        for i in range(0, self.numberOfStoriesOnFrontPage):
            newsStories[i].number = storyNumbers[i]
            newsStories[i].URL = storyURLs[i]
            newsStories[i].domain = storyDomains[i]
            newsStories[i].title = storyTitles[i]
            newsStories[i].score = storyScores[i]
            newsStories[i].submitter = storySubmitters[i]
            newsStories[i].time = storyTimes[i]
            newsStories[i].commentCount = storyCommentCounts[i]
            newsStories[i].commentsURL = storyCommentURLs[i]
            newsStories[i].id = storyIDs[i]

        return newsStories



    ##### End of internal methods. #####

    # The following methods could be turned into one method with
    # an argument that switches which page to get stories from,
    # but I thought it would be simplest if I kept the methods
    # separate.

    def getPage(self, page):
        """
Gets the stories from the specified Hacker News page.
"""
        source = self.getSource(page)
        stories = self.getStories(source)
        return stories


class HackerNewsStory:
    """
A class representing a story on Hacker News.
"""
    id = 0 # The Hacker News ID of a story.
    number = -1 # What rank the story is on HN.
    title = "" # The title of the story.
    domain = "" # The website the story is from.
    URL = "" # The URL of the story.
    score = -1 # Current score of the story.
    submitter = "" # The person that submitted the story.
    commentCount = -1 # How many comments the story has.
    commentsURL = "" # The HN link for commenting (and upmodding).
    time = "" # The time the HN link was posted
    number = '%02d' % number # prepends zeroes to the article number

    def getDetails(self):
        self.number = '%02d' % self.number # prepends zeroes to the article number
        detailList = [1,2,3,4,5,6,7,8,9,10]
        detailList[0] = '\t\t<postNumber>' + str(self.number) + '</postNumber>'
        detailList[1] = '\t\t<title>' + self.title + '</title>'
        detailList[2] = '\t\t<domain>' + self.domain + '</domain>'
        detailList[3] = '\t\t<points>' + str(self.score) + '</points>'
        detailList[4] = '\t\t<poster>' + self.submitter + '</poster>'
        detailList[5] = '\t\t<timePosted>' + self.time + '</timePosted>'
        detailList[6] = '\t\t<commentCount>' + str(self.commentCount) + '</commentCount>'
        detailList[7] = '\t\t<articleURL>' + self.URL + '</articleURL>'
        detailList[8] = '\t\t<commentsURL>' + self.commentsURL + '</commentsURL>'
        detailList[9] = '\t\t<HNID>' + str(self.id) + '</HNID>'

        for i in range(0,len(detailList)):
            detailList[i] = detailList[i].encode('ascii', 'xmlcharrefreplace').decode('ascii')
        return detailList