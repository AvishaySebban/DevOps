#!/usr/bin/python
#Execute example: ./urls.py  --host 10.35.22.67 --file urls.log -v

import os
import urllib2
import argparse

def exitFunction(msg):
  print (msg) 
  exit (1)
  return

def urlTest(HOST_TO_VERIFY,URILLIST_FILE):
    
    URL_PREFIX='http://'+HOST_TO_VERIFY #http://full_ip
    f = open(URILLIST_FILE,'r')   
    count=0
    for uri in f:   #uri = holds the addresses
        print "Going to verify: " + URL_PREFIX + uri
        req = urllib2.Request( URL_PREFIX + uri)
        try:
            resp = urllib2.urlopen(req)
        except urllib2.URLError, e:
            if e.code == 404:
                count +=1
                print "ERROR_CODE: " + str(e.code) + " URL: " + URL_PREFIX + uri
                #print "Error! The number of 404 is:" + str(count)
            else:
                print str(e.code) + " URL: " + URL_PREFIX + uri
        else:
            print "200 URL: " + URL_PREFIX + uri
            body = resp.read()
        
    
    f.close()
    if count != 0:
        exitFunction ("404 found. total:" + str(count))
    return

def main():
 parser = argparse.ArgumentParser()
 parser.add_argument("--host", type=str, help="The Nginx host to verify e.g. 127.0.0.1")
 parser.add_argument("--file", type=str, help="The file to upload e.g. /tmp/file.log")
 parser.add_argument("-v", "--verbose", action="store_true", help="Increase output verbosity")
 args = parser.parse_args()
  
 if args.verbose :
  print ("file: [%s]" % args.host)
  print ("file: [%s]" % args.file)

 if (not args.host ) :
    exitFunction ("The HOST is mandatory")
     
 if (not args.file ) :
    exitFunction ("The FILE is mandatory")

 urlTest(args.host,args.file)

 return
 
            
if __name__ == "__main__":
    main()

