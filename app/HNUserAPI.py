import urllib.request
from bs4 import BeautifulSoup
import re

import tart


def getSource(url):
    """Returns the HTML source code for a URL.
    """

    print("curling page: " + url)
    with urllib.request.urlopen(url) as url:
        source = url.read()
    print("page curled")
    return source

def getUserPage(source):
    """Looks through the user page source,
       and returns the account details
    """
    source = getSource("http://news.ycombinator.com/user?id=" + source)
    if (source.decode('ascii') == "No such user."):
        tart.send('userError', text="<b><span style='color:#fe8515'>That user doesn't exist</span></b>\nUsernames are case sensitive!")
        return []
    if (source.decode('ascii') == "We've limited requests for this url."):
        tart.send('userError', text="<b><span style='color:#fe8515'>HN has limited user page requests</span></b>\nWait a bit, then try again")
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