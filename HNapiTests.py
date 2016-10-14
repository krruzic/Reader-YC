import unittest
from readeryc import HNapi

class apiTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.hnapi = HNapi()
        self.expectProfile = [
            'testprofile', 'testuser@gmail.com']
    
    def testLogin(self):
        self.assertTrue(self.hnapi.login('testusercpsc', 'testing1'), "Log in worked")
        
    def testPostComment(self):
        self.hnapi.logout() # make sure we are logged out
        self.hnapi.login('testusercpsc', 'testing1') # login
        self.assertTrue(self.hnapi.post_comment('133223', "This is a test comment"))
        
    def testFailedPostComment(self):
        self.hnapi.logout() # make sure we are logged out
        self.assertFalse(self.hnapi.post_comment('133223', "This is a test comment"))
        
    def testGetProfile(self):
        self.hnapi.logout()
        self.hnapi.login('testusercpsc', 'testing1') # login
        # the third array element is the user's bio
        self.assertEquals(self.hnapi.get_profile('testusercpsc')[2], "testprofile")
        # the fourth is the user's email
        self.assertEquals(self.hnapi.get_profile('testusercpsc')[3], "testuser@gmail.com")
        
    def testPostProfile(self):
        self.hnapi.logout()
        self.hnapi.login('testusercpsc', 'testing1') # login
        self.assertTrue(self.hnapi.post_profile('testusercpsc',
                'testuser@gmail.com', 'testprofile')) # see if the POST works
        
        # Now we check if the values were updated
        # the third array element is the user's bio
        self.assertEquals(self.hnapi.get_profile('testusercpsc')[2], "testprofile")
        # the fourth is the user's email
        self.assertEquals(self.hnapi.get_profile('testusercpsc')[3], "testuser@gmail.com")

    def testGetAPIComments(self):
        # we can't actually check if the comments are exactly what we expect
        # so let's just make sure we get SOMETHING
        self.assertIsNot(self.hnapi.get_comments("item?id=12703769", False, False), [])
        
    def testGetScrapedComments(self):
        # same as above, we just check to make sure the array isn't empty
        self.assertIsNot(self.hnapi.get_comments("item?id=12703769", False, True), [])

    def testGetStories(self):
        # same as above, we just check to make sure the array isn't empty
        self.assertIsNot(self.hnapi.get_stories("news"), [])
        
        
    def testGetSearchStories(self):
        # test is our search term, 0 is page start and the last value is poster
        props = ['test', 0, '']
        # same as above, we just check to make sure the array isn't empty
        self.assertIsNot(self.hnapi.get_search_stories(props), [])
    
    @classmethod
    def tearDownClass(self):
        pass
    
if __name__ == '__main__':
    unittest.main()
