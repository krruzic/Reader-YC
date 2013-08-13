Reader|YC
=========
app UUID: 425c7891-ab84-4cb4-a628-6cfeaec6fd1b


Reader|YC is a native hackernews client built with Cascades and Python (using Blackberry-tart). Instead of using often unstable APIs, this app directly scrapes Hackernews for posts (and soon comments) to ensure maximum uptime. Currently the app is at V0.8, almost ready for release.

The post scraping is based heavily off of Dimillian's Sublime plugin found [here](https://github.com/Dimillian/Sublime-Hacker-News-Reader)

Here is a current screenshot of the main page:
![image](https://raw.github.com/krruzic/Reader-YC/master/screenshot.png)

## Steps to build:
Since the release of tart V1.1, I have switched to the recommended method of building described [here](http://hg.microcode.ca/blackberry-py/wiki/Building%20HelloWorld)

**First Step**
First create a root directory, I called mine 'apps', then

**Install Blackberry Tart**
To do this you'll need to grab the tartV1.1 zip found [here](http://blackberry-py.microcode.ca/downloads/), and extract it to the root directory you created previously

Now, clone this repo and place it in the root directory too.

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


## Features:
###Current Features:
* Get the main hackernews pages in a nice tabbed format
* Infinite scrolling, load more comments
* View articles, comments, and text posts
* Different sections of the apps accessible by tabs
* View user pages
* Request multiple pages at a time :D
* Throttling requests on userpages
* icons, ICONS EVERYWHERE

###Current Issues:
* ~~Sometimes the main page (top posts) doesn't load, and I'm not too sure why.~~
* ~~Does not handle a lack of internet connectivity. At all.~~
* If you close the app while it is making a request, the app will go into a greyed-out "zombie" state until the request is completed


###Coming Feature roadmap (dates are really guesses):
* View text posts, comments and articles all from within the app V1.0 (Will be available on BB-World at this point)
  ~~ETA: July 1~~ MOVED TO August 15th
  NOTE: This is almost done, I just need to pretty things up a bit.

* Favouriting posts for later viewing from a 'Favourites' tab, as well as view user pages V1.1
	ETA: Week after V1.0

* ~~Comment caching for recent articles  V1.1~~
	ETA: Never, idea scrapped

* V1.2
        A tutorial that shows when first launched, this will add some flair to the app
        Collapsable comments, Searching for posts and comments ETA: End of Summer

* Logging in and upvoting/commenting V2.0
	ETA: Probably never, but I do hope to add this

###Thanks:
    Huge thanks to all the developers of The BBPY project (Peter Hansen, Xitij Ritesh Patel, etc.) and special thanks to  Jerónimo Barraco for helping with the comment API.