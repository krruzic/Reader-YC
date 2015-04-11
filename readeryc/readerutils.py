import os


class readerutils():
    SETTINGS_FILE = 'data/settings.state'
    COOKIE = os.path.join('data/', 'hackernews.cookie')
    HEADERS = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:37.0) Gecko/20100101 Firefox/37.0',
    }

    def hnUrl(address):
        return 'https://news.ycombinator.com/{}'.format(address)

    def textReplace(text):
        #text = text.replace('rel="nofollow"', '')
        # Replace unclosed <p>'s with new lines
        text = text.replace('<p>', '\n')
        text = text.replace('</p>', '')  # Remove the crap BS4 adds
        text = text.replace(
            '<pre><code>', '<p style="font-family: Monospace; font-size:5pt; font-weight:100;">')
        text = text.replace('</code></pre>', '</p>')
        text = text.replace('\\n', '\n')
        text = text.replace('\\t', '\t')
        return text

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
        elif isinstance(time, datetime):
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
                return "1 minute ago "
            if second_diff < 3600:
                return str(second_diff // 60) + " minutes ago "
            if second_diff < 7200:
                return "1 hour ago "
            if second_diff < 86400:
                return str(second_diff // 3600) + " hours ago "
        if day_diff == 1:
            return "Yesterday "
        if day_diff < 7:
            return str(day_diff) + " days ago "
        if day_diff == 7:
            return "1 week ago "
        if day_diff < 31:
            return str(day_diff // 7) + " weeks ago "
        if day_diff == 31:
            return "1 month ago "
        if day_diff < 365:
            return str(day_diff // 30) + " months ago "
        if day_diff == 365:
            return "1 year ago "
        return str(day_diff // 365) + " years ago "

    def get_rowdicts(cursor):
        results = []
        for story in list(cursor):
            res = {'title': story[0], 'link': story[1], 'time': story[2],
                   'author': story[3], 'commentCount': story[4], 'askPost': story[5], 'domain': story[6],
                   'score': story[7], 'commentURL': story[8], 'hnid': story[8]
                   }
            results.append(res)
        return results

    def getColour(location):
        gradient = [
            "ff8e00", "FF8B00", "FA8904", "F68608", "F2840C", "ED8110", "E97F13",
            "E57C17", "E07A1A", "DC781D", "D87620", "D37423", "CF7226", "CB7929",
            "C66E2B", "C26C2E"
        ]
        print("location given: ", location)

        if location > 16:
            return "C26C2E"

        return gradient[location]
