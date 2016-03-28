#!/usr/bin/python

import sys
import json
import urllib2, base64

# Hold the configuration values in a "proprties file" format
import stashConf

#print "Reading %s" % stashConf.api_repos_url
try:
	project = sys.argv[1]
except IndexError:
	project = stashConf.default_project

fullUrl = stashConf.api_url_project_base + project + stashConf.url_suffix


# You need the replace to handle encodestring adding a trailing newline 
# (https://docs.python.org/2/library/base64.html#base64.encodestring)
base64string = base64.encodestring('%s:%s' % (stashConf.username, stashConf.password)).replace('\n', '')
# print "Encoded authorization string is %s" % base64string

request = urllib2.Request(fullUrl)

# Add the authorization header
request.add_header("Authorization", "Basic %s" % base64string)   
repos = urllib2.urlopen(request)

#print "Reading json output"
reposJson = repos.read()
reposData = json.loads(reposJson)

size = reposData["size"]
#print "Found %s repositories\n" % size

for i in range(0,size):
	print "%s=%s" % (reposData["values"][i]["name"], reposData["values"][i]["cloneUrl"])

#print "\nDone\n"
