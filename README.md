Reader YC
==
app UUID: 425c7891-ab84-4cb4-a628-6cfeaec6fd1b



Reader YC is a native hackernews client built with Cascades and Python (using Blackberry-tart). Instead of using often unstable APIs, this app directly scrapes Hackernews for posts, and optionally comments, to ensure maximum uptime. Currently the app is at V1.5.4 (don't usually update the readme), and is available on BlackBerry World

The post scraping is based heavily off of Dimillian's Sublime plugin found [here](https://github.com/Dimillian/Sublime-Hacker-News-Reader) (This is no longe

To fetch comments, the user has a choice to either use BeautifulSoup scraping or the [HN Search API](https://hn.algolia.com). The api is much faster, so I recommend it. However it can be unreliable, and doesn't sort comments properly until a few days after the post was submitted. 
Since 1.5, the scraping is faster and works better. A setting to enable Legacy Scraping can be found within the app.


Here is a current screenshot of the main page:
![image](https://raw.github.com/krruzic/Reader-YC/master/screenshot.png)

An up to date signed BAR file is almost always available at this repo.
## Requirements:
BeautifulSoup4
    `pip install bs4`
Requests
    `pip install requests`

## Steps to build:
Since the release of tart V1.1, I have switched to the recommended method of building described [here](http://hg.microcode.ca/blackberry-py/wiki/Building%20HelloWorld)

**First Step**
First create a root directory, I called mine 'apps', then

**Install Blackberry Tart**
To do this you'll need to grab the tartV1.1 zip found [here](http://blackberry-py.microcode.ca/downloads/), and extract it to the root directory you created previously

**REQUEST DEBUG TOKEN BAR FILE**
`blackberry-debugtokenrequest -storepass STOREPASS -devicepin DEVICEPIN debugtoken.bar`

note: the storepass is the password you used to first register for debug tokens with RIM

**BUILD DEBUG BAR:**
cd into the bin folder and execute the tart.sh or tart.cmd file with these parameters: `package ../Reader-YC/`. If you want to change some details like permissions, just edit the tart-project.ini file in Reader-YC.

**BUILD RELEASE BAR:**
Same as above, except specify the `-mrelease` flag after `package`

**SIGN BAR FILE IF RELEASE:**
`blackberry-signer -storepass STOREPASS NAMEOFBAR`

**INSTALL APP TO DEVICE:**
`blackberry-deploy -installApp -password DEVICEPASS -device DEVICEIP -package NAMEOFBAR`


NOTE: The bars will be placed in the bin directory after being built.


###Current Features:
* Get the main hackernews pages in a nice tabbed format
* Infinite scrolling
* View articles, comments, and text posts
* Different sections of the apps accessible by tabs
* Threading of all requests
* Login, and edit profile
* View about/help pages, email the dev (me)
* Select method to retrieve comments with
* Post comments to any story
* Active frame showing recent stories
* Settings to always open in browser, and to use reader mode
* Clear cached stuff (No clue why you'd want to)
* Post stories
* Favourite posts to save for later

###Thanks:
    Huge thanks to all the developers of The BBPY project (Peter Hansen, Xitij Ritesh Patel, etc.) and special thanks to  Jerónimo Barraco for helping with the comment API.
