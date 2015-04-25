Reader YC
==


Reader YC is a native hackernews client built with Cascades and Python (using Blackberry-tart). Instead of using often unstable APIs, this app directly scrapes Hackernews for posts, and optionally comments, to ensure maximum uptime. Currently the app is at V1.5.4 (don't usually update the readme), and is available on BlackBerry World

The post scraping is based heavily off of Dimillian's Sublime plugin found [here](https://github.com/Dimillian/Sublime-Hacker-News-Reader)

To fetch comments, the user has a choice to either use BeautifulSoup scraping or the [HN Search API](https://hn.algolia.com). The api is much faster, so I recommend it. However it can be unreliable, and doesn't sort comments properly until a few days after the post was submitted. 
Since 1.5, the scraping is faster and works better. A setting to enable Legacy Scraping can be found within the app.


Here is a current screenshot of the main page:
![image](https://raw.github.com/krruzic/Reader-YC/master/screenshot.png)

An up to date signed BAR file is almost always available at this repo.
## Requirements:
I recommend you use virtualenv for this, makes the process much easier
BeautifulSoup4
    `pip install bs4`
Requests
    `pip install requests`
Tartutil
    `pip install /path/to/bbtart/
The bbtart package is also available on my github.
## Steps to build:
Since making bbtart an installable package, building is a lot easier.
**First Step**
First create a root directory, I called mine 'apps', then

**Install Blackberry Tart**
To do this you'll need to download the bbtart package [here](https://github.com/krruzic/BlackBerry-Tart/)
**REQUEST DEBUG TOKEN BAR FILE**
`blackberry-debugtokenrequest -storepass STOREPASS -devicepin DEVICEPIN debugtoken.bar`

note: the storepass is the password you used to first register for debug tokens with RIM

**BUILD DEBUG BAR:**
after installing bbtart with pip, run `packager.py package -mdebug

**BUILD RELEASE BAR:**
Same as above, except specify the `-mrelease` flag after `package`

**SIGN BAR FILE IF RELEASE:**
`blackberry-signer -storepass STOREPASS NAMEOFBAR`

**INSTALL APP TO DEVICE:**
`blackberry-deploy -installApp -password DEVICEPASS -device DEVICEIP -package NAMEOFBAR`


**SHORTCUT**
I've defined an INI file called deploy.ini, where you can set up all your parameters for building/installing.
Then install becomes a one liner: `packager.py deploy -c path/to/deploy.ini`
I've uploaded my deploy.ini file, which describes all the parameters.

NOTE: The bars will be placed in the current directory

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
* dark theme

###Thanks:
    Huge thanks to all the developers of The BBPY project (Peter Hansen, Xitij Ritesh Patel, etc.) and special thanks to  Jerónimo Barraco for helping with the comment API.
