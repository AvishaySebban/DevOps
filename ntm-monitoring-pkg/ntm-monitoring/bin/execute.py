#!/usr/bin/python

import sys,os
os.environ["PYTHONPATH"] = ":/opt/ntm-monitoring-pkg/psutil:/opt/ntm-monitoring-pkg/ntm-monitoring/bin:/opt/ntm-monitoring-pkg/ntm-monitoring/conf:/opt/ntm-monitoring-pkg/ntm-monitoring/lib"

from Functions import *
from checks import *
from Conf import *
import psutil,os
import argparse


def main() :

   #Key Function to present
   parser = argparse.ArgumentParser()
   parser.add_argument("--cpu", action="store_true", help="verify the cpu usage")
   parser.add_argument("--disk", action="store_true", help="verify the disk usage")
   parser.add_argument("--mem", action="store_true", help="verify the mem usage")
   parser.add_argument("--load", action="store_true", help="verify the load usage")
   parser.add_argument("--all", action="store_true", help="verify the all server usage")
   args = parser.parse_args()

   TEST_NAME="ntm-monitoring-checks"
   EXIT_CODE=0

   #Creating the log file
   LOG_NAME="tests_"+ TEST_NAME + ".log" #Log file name
   LOG_FILE=LOG_BASE_DIR + "/" + LOG_NAME #Path log file name 

   startScript(TEST_NAME,LOG_FILE)
   #Start Log file.
   (origStdout,log_file)=setLogFile(LOG_FILE)

   # DISK
   if args.disk or args.all :
     exit_code_current=checkDisk()
     if exit_code_current > EXIT_CODE:
       EXIT_CODE=exit_code_current

   # CPU
   if args.cpu or args.all :
     exit_code_current=checkCpu()
     if exit_code_current > EXIT_CODE:
       EXIT_CODE=exit_code_current

   #MEMO
   if args.mem or args.all:
     exit_code_current=checkMemo()
     if exit_code_current > EXIT_CODE:
       EXIT_CODE=exit_code_current

	#LOAD
   if args.load or args.all:
     exit_code_curren=checkLoad()
     if exit_code_current > EXIT_CODE:
       EXIT_CODE=exit_code_current
   
   
   if EXIT_CODE >= 2:
      create_Alert(ALERT_TYPE_CRITICAL,TEST_NAME,LOG_FILE)
   elif EXIT_CODE >= 1:
      create_Alert(ALERT_TYPE_WARNING,TEST_NAME,LOG_FILE)

	#End Log file.
   unsetLogFile(origStdout,log_file)
   endScript(EXIT_CODE)
     
if __name__ == "__main__":
   main()
