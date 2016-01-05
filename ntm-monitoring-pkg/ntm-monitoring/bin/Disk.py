#!/usr/bin/python

import psutil
from Functions import *
from Conf import *

TEST_NAME="DISK_ALERT"

def main() :

   disk = psutil.disk_usage('/')
   
   #msg=Create_Mail_Notification(Subject)
   LOG_NAME="tests_"+ TEST_NAME + ".log"
   LOG_FILE=LOG_BASE_DIR + "/" + LOG_NAME
   
   startScript(TEST_NAME,LOG_FILE)
   #Start Log file.
   (origStdout,log_file)=setLogFile(LOG_FILE)

   ##CRITICAL
   if disk.free >= DISK_MAX_CRITICAL:
       print("CRITICAL!!: The Disk is %s, more than %s" % (disk.free, DISK_MAX_CRITICAL))
       create_Alert(ALERT_TYPE_CRITICAL,TEST_NAME,LOG_FILE)
       EXIT_CODE=1

   ##WARNING
   elif disk.free >= DISK_MAX_WARNING:
       print ("WARNING!!: The Current Disk is %s, more than %s" % (disk.free, DISK_MAX_WARNING))
       create_Alert(ALERT_TYPE_WARNING,TEST_NAME,LOG_FILE)
       EXIT_CODE=2
   else:
       print("OK.Free DISK=%s" % disk.free)
   
   
   print "\nMore information:"
   print "=================="
   print disk
   
   print "\n"
   
   unsetLogFile(origStdout,log_file)
   endScript(EXIT_CODE)


if __name__ == "__main__":
   main()










