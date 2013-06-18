from bs4 import BeautifulSoup
import re
import urllib.request

class HackerNewsText:

    def getText(source):
        with urllib.request.urlopen(source) as url:
            source = url.read()

        source = source.decode("utf-8").replace('<p>', '\n')

        soup = BeautifulSoup(source)

        text_content = soup.findAll("tr")

        text_content =str(text_content[7])
        textStart = text_content.find('d><td>') + 6
        textEnd = text_content.find('</', textStart)
        text = text_content[textStart:textEnd]

        return text
