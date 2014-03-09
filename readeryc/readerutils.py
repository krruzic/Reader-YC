import os

class readerutils():
    SETTINGS_FILE = 'data/settings.state'
    COOKIE = os.path.join('data/', 'hackernews.cookie')
    HEADERS = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.29 Safari/537.22',
    }
    gradient = ["ff8e00", "FF8B00", "FA8904", "F68608", "F2840C", "ED8110", "E97F13",  
            "E57C17", "E07A1A", "DC781D", "D87620", "D37423", "CF7226", "CB7929", 
            "C66E2B", "C26C2E"]

    def hnUrl(address):
        return 'https://news.ycombinator.com/{}'.format(address)

    def prettyDate(time):
        """ 
        Get a datetime object or a int() Epoch timestamp and return a
        pretty string like 'an hour ago', 'Yesterday', '3 months ago',
        'just now', etc
        """

        from datetime import datetime
        now = datetime.utcnow()
        if type(time) is int:
            diff = now - datetime.fromtimestamp(time)
        elif isinstance(time,datetime):
            diff = now - time
        elif not time:
            diff = now - now
        second_diff = diff.seconds
        day_diff = diff.days

        if day_diff < 0:
            return "Just now "

        if day_diff == 0:
            if second_diff < 10:
                return "Just now "
            if second_diff < 60:
                return str(second_diff) + " seconds ago "
            if second_diff < 120:
                return  "1 minute ago "
            if second_diff < 3600:
                return str( second_diff // 60 ) + " minutes ago "
            if second_diff < 7200:
                return "1 hour ago "
            if second_diff < 86400:
                return str( second_diff // 3600 ) + " hours ago "
        if day_diff == 1:
            return "Yesterday "
        if day_diff < 7:
            return str(day_diff) + " days ago "
        if day_diff < 31:
            return str(day_diff // 7) + " weeks ago "
        if day_diff < 365:
            return str(day_diff // 30) + " months ago "
        if str(day_diff // 365) == '1':
            return str(day_diff // 365) + " year ago "
        return str(day_diff // 365) + " years ago "

        
    def get_rowdicts(cursor):
        return list(cursor)
