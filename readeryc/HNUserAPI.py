from bs4 import BeautifulSoup
import re, requests


def getSource(url):
    HEADERS = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.29 Safari/537.22',
    }

    """Returns the HTML source code for a URL.
    """

    print("curling page: " + url)
    r = requests.get(url=url, headers=HEADERS)
    source = r.content
    print("page curled")
    return source

def getUserPage(source):
    """Looks through the user page source,
       and returns the account details
    """

    source = getSource("http://news.ycombinator.com/user?id=" + source)
    if ("No such user." in source):
        return []
    if ("We've limited requests for this url." in source):
        return []
    soup = BeautifulSoup(source)

    details = [] # List of details extracted from the source
    results = [] # List of results to return
    usefulCount = 0 # We don't want all elements from our comprehesion
    for item in soup.findAll('tr'):
        usefulCount = usefulCount + 1
        if (usefulCount > 4):
            details.append(item)

    usefulCount = 0 # Reset for the next list comprehesion
    for item in details:
        usefulCount = usefulCount + 1
        if (usefulCount <= 5): # The first 5 results are just text:
                               # username, created, karma, avg, about
            start = str(item).find('<td>') + 4
            end = str(item).find('</td', start)
            result = str(item)[start:end]
            results.append(result)
        else: # The other two are links to the user's comments and submissions
            start = str(item).find('="') + 2
            end = str(item).find('><u', start) - 1
            result = 'https://news.ycombinator.com/{0}'.format(str(item)[start:end])
            results.append(result)
    return results