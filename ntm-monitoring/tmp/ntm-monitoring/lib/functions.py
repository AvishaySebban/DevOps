#!/usr/bin/python
import socket
import logging
from sendMail import *
from conf import *
import sys,os 
import time
from time import gmtime, strftime
import zipfile

host_name = socket.gethostname()
host_ip = socket.gethostbyname(socket.gethostname()) 
 
ROTATE_CMD="sudo /usr/sbin/logrotate /etc/logrotate.d/ntm-monitoring"

def startScript(script_name,log_name):
    print ("\nThe test module name is : %s , using LOG_FILE=%s\n" % (script_name,log_name))
    return

def rotateLog():
	os.system("ROTATE_CMD")
	return

def setLogFile(logPathFile):
    rotateLog
    logDir=os.path.dirname(logPathFile)
    if not os.path.exists(logDir):
       os.makedirs(logDir)
    logging.basicConfig(filename=logPathFile, level=logging.DEBUG)
    orig_stdout = sys.stdout
    log_file = open(logPathFile,"a")
    sys.stdout = log_file
    sys.stderr = log_file
    
	  #print static format output
    templ = "%-2s,%-2s,%-2s,%-2s,%-5s,%-5s,%-5s,%-5s,%-5s,%-5s,%-5s,%-5s,%-5s"
    print(templ % ("Year","Month","Day", "Time","Severity","DISK(%)","DISK-FREE","CPU(%)", "MEMORY(%)","UPTIME","UPTIME(seconds)","HOST-NAME","HOST-IP"))
    
    return (orig_stdout,log_file)
 
	
def unsetLogFile(origStdout,log_file):
    
    sys.stdout = origStdout
    log_file.close()	
	
def endScript(exit_code):
    if EXIT_CODE > 0 :
        print ("TEST WAS ALERTED, EXIT_CODE=%d" % EXIT_CODE)
        sys.exit(EXIT_CODE)
	return	


def create_Alert(type,name,fileList,zfilename):
    subject = type + " | " + name + "."
    sub = host_name + " | " + host_ip + "."
    body = "THIS IS AN AUTOMATED MESSAGE - PLEASE DO NOT REPLY DIRECTLY TO THIS EMAIL: NTM-Monitoring\n" + "\n Severity: \n 0 = NORMAL \n 1 = CRITICAL \n 2 = WARNING"
    
    ## Remove the old ZIP file (if file exists, delete it)
    if os.path.isfile(zfilename):
        os.remove(zfilename)
        print "The old ZIP file was deleted"
    else:    ## Show an error ##
        print("Error: %s file not found" % zfilename)
    
    #Start Compress a new ZIP File
    zf = zipfile.ZipFile(zfilename, "w", zipfile.ZIP_DEFLATED) # <--- this is the change you need to make
    for fname in fileList:
        print "writing: ", fname
        zf.write(fname)
    zf.close()
    result = sendMail(SENDER_NAME, SENDER, RECIEVER, subject, sub, body, zfilename, SMTP_SERVER)
    if result > 0 :
        print "Mail was not sent !"
    else :
        print "Mail was sent !"
    return
	

#Convert 2 Human
def bytes2human(n):
   if n is None:
    return n
   symbols = ('K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y')
   prefix = {}
   for i, s in enumerate(symbols):
      prefix[s] = 1 << (i + 1) * 10
   for s in reversed(symbols):
      if n >= prefix[s]:
            value = float(n) / prefix[s]
            return '%.1f%s' % (value, s)
   return "%sB" % n

def writeToFile(msg,filePath):
   f = open(filePath, 'a')
   f.write(msg)
   f.close()
