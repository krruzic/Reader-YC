import os

def settings():
	SETTINGS_FILE = 'data/settings.state'
	COOKIE = os.path.join('data/', 'hackernews.cookie')
	HEADERS = {
		'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.29 Safari/537.22',
	}
