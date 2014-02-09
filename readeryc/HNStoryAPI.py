import requests, re, time
from bs4 import BeautifulSoup


def parseStories(page):
    """ Extract all the stories from a story page.
    Returns dicts representing stories EG)
    {
        title: 'example'
        time: '100 days ago '
        points: '1298 points'
        author: 'pg'
    }
    """
    soupStart = time.time()
    soup = BeautifulSoup(page)
    soupEnd = time.time()
    #print("Souping: ", soupEnd - soupStart)
    story_tables = soup.find_all('table', 0)
    story_tables = list(map(str, story_tables))

    del story_tables[0:2]
    del story_tables[-1]

    for st in story_tables:
        metadata = soup.find_all("td", "subtext")

    head = soup.find_all("td", "title", valign=False)

    stories = []
    totalTime = 0

    for i, m in zip(head, metadata):
        story ={'title': None, 
            'domain': None, 
            'score': None, 
            'author': None, 
            'time': None, 
            'commentCount': None, 
            'link': None, 
            'commentURL': 'news.ycombinator.com/item?id=-1', 
            'hnid': '-1', 
            'askPost': 'false'}
        startTime = time.time()
        story['title'] = i.find_all('a')[0].text
        story['link'] = i.find("a")["href"]
        if 'item?id='in story['link']:
            story['link'] = 'news.ycombinator.com/' + story['link']
            story['askPost'] = "true"
        try:
            story['domain'] = i.find_all("span")[0].text
            story['domain'] = re.search(r'\(([^)]*)\)', story['domain']).group(1) # Remove brackets from domain
        except:
            story['domain'] = "news.ycombinator.com"

        if 'point' in m.text:
            story_time = re.search(r'by \S+ (\d+.*?)\s+\|', m.text).group(1) + ' '
            story['time'] = story_time
            story['score'] = re.search("(\d+)\s+points?", m.text).group(1)
            story['author'] = m.a.text.strip()
            story['hnid'] = m.span['id'].split('_')[1]
            story['commentURL'] = "https://news.ycombinator.com/item?id=" + story['hnid']
            if 'discuss' in m.text: # Zero comments
                story['commentCount'] = '0'
            else:
                try:
                    story['commentCount'] = re.search("(\d+)\s+comments?", m.text).group(1)
                except AttributeError:
                    # I found an instance where there was just the text
                    # 'comments', without any count. I'm assuming that
                    # even stranger things could happen
                    story['commentCount'] = '0'
        else: # Jobs post
            story['time'] = m.text.strip()
            story['commentCount'] = '0'
            story['score'] = '0'
            story['author'] = 'ycombinator'

        endTime = time.time()
        totalTime = totalTime + (endTime - startTime)

        #print("Time to parse 1 story: ", endTime - startTime)
        stories.append(story)

    print("Time to parse ", len(stories), " stories: ", totalTime)

    return stories, head[-1].find_all('a')[0]['href']


def getStoryPage(source):
    HEADERS = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.29 Safari/537.22',
    }

    url = source
    print("curling page: " + url)
    r = requests.get(url=url, headers=HEADERS)
    page = r.content
    print("page curled")
    stories, moreLink = parseStories(page)
    return stories, moreLink