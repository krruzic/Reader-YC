import re, sqlite3
import time, os, glob

import tart

DATABASE = 'data/data.db'
ADD_ENTRY = '''INSERT INTO entries VALUES (:url, :title, :pubtime, :image, :summary, :tags)'''


MAKE_SCHEMA = '''CREATE TABLE IF NOT EXISTS entries (
    title        TEXT,
    domain       TEXT,
    score        TEXT,
    submitter    TEXT,
    time         TEXT,
    commentCount TEXT,
    url          TEXT,
    commentsURL  TEXT,
    id           TEXT,
    askPost      TEXT
    )
'''

LOAD_ENTRIES = '''SELECT * FROM entries'''
ADD_ENTRY = '''INSERT INTO entries VALUES ()'''

class HackerNewsSaveAPI:
    """ This class just saves articles to
        a 'favourites.db' file
    """

    def addEntry(self, details):
