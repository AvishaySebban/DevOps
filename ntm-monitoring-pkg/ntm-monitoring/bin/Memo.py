#!/usr/bin/python

import psutil,os
import psutil
from Functions import *
from Conf import *
from datetime import timedelta


TEST_NAME="MEMORY_ALERT"



def main() :

   mem = psutil.virtual_memory()
   swap = psutil.swap_memory()
   
   #msg=Create_Mail_Notification(Subject)
   LOG_NAME="tests_"+ TEST_NAME + ".log"
   LOG_FILE=LOG_BASE_DIR + "/" + LOG_NAME
   
   startScript(TEST_NAME,LOG_FILE)
   #Start Log file.
   (origStdout,log_file)=setLogFile(LOG_FILE)

   ##CRITICAL
   if mem.percent >= MEMO_MAX_CRITICAL:
       print("CRITICAL!!: The Current Memory is %s, more than %s" % (mem.percent, MEMO_MAX_CRITICAL))
       create_Alert(ALERT_TYPE_CRITICAL,TEST_NAME,LOG_FILE)
       EXIT_CODE=1

   ##WARNING
   elif mem.percent >= MEMO_MAX_WARNING:
       print ("WARNING!!: The Current Memory is %s, more than %s" % (mem.percent, MEMO_MAX_WARNING))
       create_Alert(ALERT_TYPE_WARNING,TEST_NAME,LOG_FILE)
       EXIT_CODE=2
   else:
       print("OK.Free MEMORY=%s" % mem.percent)
   
   print "More information:"
   print "==================="
   print mem
   print "\n"
   print("Swap memory usage:")
   print "===================="
   print swap
   print "\n"
   
   unsetLogFile(origStdout,log_file)
   endScript(EXIT_CODE)


if __name__ == "__main__":
   main()
