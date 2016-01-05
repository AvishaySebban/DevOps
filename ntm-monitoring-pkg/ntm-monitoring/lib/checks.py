#!/usr/bin/python


import psutil,os
from execute import *
from datetime import timedelta


#------------------------------------------------------------------------------

def checkDisk() :
   print "+++++++++++++++++++++++++++++++++++++++++++++++++++ DISK +++++++++++++++++++++++++++++++++++++++++++++++++++"
   func_return_code=0
   disk = psutil.disk_usage('/')
   ##CRITICAL
   if disk.free >= DISK_MAX_CRITICAL:
       print("CRITICAL!!: The Disk is %s, more than %s" % (disk.free, DISK_MAX_CRITICAL))
       func_return_code=1

   ##WARNING
   elif disk.free >= DISK_MAX_WARNING:
       print ("WARNING!!: The Current Disk is %s, more than %s" % (disk.free, DISK_MAX_WARNING))
       func_return_code=2
   else:
       print("OK.Free DISK=%s" % disk.free)
   
   
   print "\nMore information:"
   print "=================="
   print disk
   
   print "\n"
   return func_return_code
   
#------------------------------------------------------------------------------ 
   
def checkCpu() :
   print "+++ CPU +++"
   func_return_code=0
   cpu = psutil.cpu_times()
   cpu_percent = psutil.cpu_percent()

   ##CRITICAL
   if cpu_percent >= CPU_MAX_CRITICAL:
       print("CRITICAL!!: The CPU is %s, more than %s" % (cpu_percent, CPU_MAX_CRITICAL))
       func_return_code=1

   ##WARNING
   elif cpu_percent >= CPU_MAX_WARNING:
       print ("WARNING!!: The Current CPU is %s, more than %s" % (cpu_percent, CPU_MAX_WARNING))
       func_return_code=2
   else:
       print("OK.Free CPU=%s" % cpu_percent)
   
   
   print "\nMore information:"
   print "=================="
   print cpu
   
   print "\n"
   return func_return_code
#------------------------------------------------------------------------------ 

def checkLoad() :
   print "+++ UPTIME +++"
   func_return_code=0
   with open('/proc/uptime', 'r') as f:
    uptime_seconds = float(f.readline().split()[0])
    uptime_string = str(timedelta(seconds = uptime_seconds))
   
   ##CRITICAL
   if uptime_string >= LOAD_MAX_CRITICAL:
       print("CRITICAL!!: The Load is %s, more than %s" % (uptime_string, LOAD_MAX_CRITICAL))
       func_return_code=1
   ##WARNING
   elif uptime_string >= LOAD_MAX_WARNING:
       print ("WARNING!!: The Current Load is %s, more than %s" % (uptime_string,LOAD_MAX_WARNING))
       func_return_code=2
   else:
       print("Ok.free UPtime=%s" % uptime_string)
   
   
   print "\nMore information:"
   print "=================="
   print uptime_string
   
   print "\n"
   return func_return_code
#------------------------------------------------------------------------------ 

def checkMemo() :
   print "+++ MEM +++"
   func_return_code=0
   mem = psutil.virtual_memory()
   swap = psutil.swap_memory()
       
   ##CRITICAL
   if mem.percent >= MEMO_MAX_CRITICAL:
       print("CRITICAL!!: The Current Memory is %s, more than %s" % (mem.percent, MEMO_MAX_CRITICAL))
       func_return_code=1

   ##WARNING
   elif mem.percent >= MEMO_MAX_WARNING:
       print ("WARNING!!: The Current Memory is %s, more than %s" % (mem.percent, MEMO_MAX_WARNING))
       func_return_code=2
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
   return func_return_code
   

