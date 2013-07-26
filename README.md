Reader|YC
=========

Reader|YC is a native hackernews client built with Cascades and Python (using Blackberry-tart). Instead of using often unstable APIs, this app directly scrapes Hackernews for posts (and soon comments) to ensure maximum uptime. 
The post scraping is based heavily off of Dimillian's Sublime plugin found [here] (https://github.com/Dimillian/Sublime-Hacker-News-Reader)

Here is a current screenshot of the main page:
![image](https://raw.github.com/krruzic/Reader-YC/master/screenshot.png)

## Steps to build:
Since the release of tart V1, I have switched to the recommended method of building described [here] (http://hg.microcode.ca/blackberry-py/wiki/Building%20HelloWorld)


**Install Blackberry Tart**
To do this you'll need to grab the tartV1 zip found [here] (http://blackberry-py.microcode.ca/downloads/), then clone the Mercurial repo with `hg clone https://bitbucket.org/microcode/blackberry-py`. Take the bin directory and the tart.ini out of that, and place them in the same directory you extracted the zip into.

Now, clone this repo and place into that root directory too.

**REQUEST DEBUG TOKEN BAR FILE**
`blackberry-debugtokenrequest -storepass STOREPASS -devicepin DEVICEPIN debugtoken.bar`

note: the storepass is the password you used to first register for debug tokens with RIM


**BUILD DEBUG BAR:**
cd into the bin folder and execute the tart.sh or tart.cmd file with these parameters: `package -mdebug ../Reader-YC/`. If you want to change some details like permissions, just edit the tart-project.ini file in Reader-YC.

**BUILD RELEASE BAR:**
Same as above, except use `-mrelease` instead of `-mdebug`

**SIGN BAR FILE IF RELEASE:**
`blackberry-signer -storepass STOREPASS NAMEOFBAR`

**INSTALL APP TO DEVICE:**
`blackberry-deploy -installApp -password DEVICEPASS -device DEVICEIP -package NAMEOFBAR`


NOTE: The bars will be placed in the bin directory after being built.


## Features:
###Current Features:
* Get the main hackernews pages (top, ask HN, new). Just top in this build
* Infinite scrolling ~~DOES NOT WORK WELL~~
* View linked posts

###Current Issues:
* ~~Sometimes the main page (top posts) doesn't load, and I'm not too sure why.~~

* Does not handle a lack of internet connectivity. At all.

* If you close the app while it is making a request, the app will go into a greyed-out "zombie" state for a while (less than a minute with release only, but still)

###Coming Feature roadmap (dates are really guesses):
* View text posts, comments and articles all from within the app V1.0 (Will be available on BB-World at this point)
  ~~ETA: July 1~~ MOVED TO END OF JULY
  
* Comment caching for recent articles  V1.1
	ETA: End of July hopefully
	
* Favouriting posts for later viewing from a 'History' option
	ETA: Week after V1.2
	
* Collapsable comments, load more results V1.3
	ETA: End of Summer
	
* Logging in and upvoting/commenting V2.0
	ETA: Probably never, but I do hope to add this

