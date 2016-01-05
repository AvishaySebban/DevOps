#!/usr/bin/python

import logging
from SendMail import *
from Conf import *
import sys 
import time
 
from logging.handlers import RotatingFileHandler

SMTP_SERVER="10.35.20.31"
reciever = "avishay.saban@nantmobile.com"
sender = "monitoring-ntm@nantmobile.com"

def startScript(script_name,log_name):
    print ("\nThe test module name is : %s , using LOG_FILE=%s\n" % (script_name,log_name))
    return

def endScript(exit_code):
    if EXIT_CODE > 0 :
        print ("TEST WAS ALERTED, EXIT_CODE=%d" % EXIT_CODE)
        sys.exit(EXIT_CODE)
	return

def setLogFile(logPathFile):
    logging.basicConfig(filename=logPathFile, level=logging.DEBUG)
    orig_stdout = sys.stdout
    log_file = open(logPathFile,"a")
    sys.stdout = log_file
    sys.stderr = log_file
    print "============================== Start log date: [current date time]"
    return (orig_stdout,log_file)

# def create_rotating_log(log_file):
    # """
    # Creates a rotating log
    # """
    # logger = logging.getLogger("Rotating Log")
    # logger.setLevel(logging.INFO)
 
    # add a rotating handler
    # handler = RotatingFileHandler(log_file, maxBytes=20,
                                  # backupCount=1)
    # logger.addHandler(handler)
 
    # for i in range(10):
        # logger.info("This is test log line %s" % i)
        # time.sleep(1.5)
 
	
def unsetLogFile(origStdout,log_file):
    print "============================== End log date: [current date time]"
    sys.stdout = origStdout
    log_file.close()	

def create_Alert(type,name,file):
    subject = "The alert type is: " + type + " for " + name + "."
    body = "BODY_TEXT_123"
    print ("%s" % subject)
    if type == 'WARNING' :
        print "!!!!!!!!!!!!!!!!!!!!!!!!!!! - " + type
    elif type == 'CRITICAL' :
        print "++++++++++++++++++++++++++ - " + type
    result = sendMail(sender,reciever,subject,body,file,SMTP_SERVER)
    if result > 0 :
        print "Mail was not sent !"
    else :
        print "Mail was sent !"
    return



