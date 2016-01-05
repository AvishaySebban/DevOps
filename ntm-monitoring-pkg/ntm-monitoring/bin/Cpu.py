#!/usr/bin/python

import psutil
from Functions import *
from Conf import *

TEST_NAME="CPU_ALERT"

def main() :

   cpu = psutil.cpu_times()
   cpu_percent = psutil.cpu_percent()
   
   #Creating the log file
   LOG_NAME="tests_"+ TEST_NAME + ".log" #Log file name
   LOG_FILE=LOG_BASE_DIR + "/" + LOG_NAME #Path log file name 
   
   startScript(TEST_NAME,LOG_FILE)
   #Start Log file.
   (origStdout,log_file)=setLogFile(LOG_FILE)

   ##CRITICAL
   if cpu_percent >= CPU_MAX_CRITICAL:
       print("CRITICAL!!: The CPU is %s, more than %s" % (cpu_percent, CPU_MAX_CRITICAL))
       create_Alert(ALERT_TYPE_CRITICAL,TEST_NAME,LOG_FILE)
       EXIT_CODE=1

   ##WARNING
   elif cpu_percent >= CPU_MAX_WARNING:
       print ("WARNING!!: The Current CPU is %s, more than %s" % (cpu_percent, CPU_MAX_WARNING))
       create_Alert(ALERT_TYPE_WARNING,TEST_NAME,LOG_FILE)
       EXIT_CODE=2
   else:
       print("OK.Free CPU=%s" % cpu_percent)
   
   
   print "\nMore information:"
   print "=================="
   print cpu
   
   print "\n"
   
   #End Log file.
   unsetLogFile(origStdout,log_file)
   endScript(EXIT_CODE)


if __name__ == "__main__":
   main()
