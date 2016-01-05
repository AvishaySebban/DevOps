#!/usr/bin/python

import psutil,os
import psutil
from Functions import *
from Conf import *
from datetime import timedelta

TEST_NAME="LOAD_ALERT"

def main() :

   with open('/proc/uptime', 'r') as f:
    uptime_seconds = float(f.readline().split()[0])
    uptime_string = str(timedelta(seconds = uptime_seconds))
   
   #msg=Create_Mail_Notification(Subject)
   LOG_NAME="tests_"+ TEST_NAME + ".log"
   LOG_FILE=LOG_BASE_DIR + "/" + LOG_NAME
   
   startScript(TEST_NAME,LOG_FILE)
   #Start Log file.
   (origStdout,log_file)=setLogFile(LOG_FILE)

   ##CRITICAL
   if uptime_string >= LOAD_MAX_CRITICAL:
       print("CRITICAL!!: The Load is %s, more than %s" % (uptime_string, LOAD_MAX_CRITICAL))
       create_Alert(ALERT_TYPE_CRITICAL,TEST_NAME,LOG_FILE)
       EXIT_CODE=1

   ##WARNING
   elif uptime_string >= LOAD_MAX_WARNING:
       print ("WARNING!!: The Current Load is %s, more than %s" % (uptime_string, LOAD_MAX_WARNING))
       create_Alert(LOAD_MAX_WARNING,TEST_NAME,LOG_FILE)
       EXIT_CODE=2
   else:
       print("Ok.free UPtime=%s" % uptime_string)
   
   
   print "\nMore information:"
   print "=================="
   print uptime_string
   
   print "\n"
   
   unsetLogFile(origStdout,log_file)
   endScript(EXIT_CODE)


if __name__ == "__main__":
   main()











