#!/usr/bin/python


import psutil,os
from execute import *
from functions import *
from datetime import timedelta
import time


#------------------------------------------------------------------------------

def checkDisk() :
   func_return_code=0
   disk = psutil.disk_usage('/')
   ##CRITICAL
   if disk.percent >= DISK_MAX_CRITICAL:
       func_return_code=1
   ##WARNING
   elif disk.percent >= DISK_MAX_WARNING:
       func_return_code=2

   print ("checkDisk: disk_usage=%d [Warning if greater than %d | Critical if greater than %d | RETURN CODE=%d] " % (disk.percent,DISK_MAX_WARNING,DISK_MAX_CRITICAL,func_return_code))
   return (func_return_code,str(disk.percent),bytes2human(disk.free))
   
#------------------------------------------------------------------------------ 
   
def checkCpu() :
   func_return_code=0
   cpu = psutil.cpu_times()
   cpu_percent = psutil.cpu_percent()
   ##CRITICAL
   if cpu_percent >= CPU_MAX_CRITICAL:
       func_return_code=1
   ##WARNING
   elif cpu_percent >= CPU_MAX_WARNING:
       func_return_code=2

   print ("checkCpu: cpu_percent=%d [Warning if greater than %d | Critical if greater than %d | RETURN CODE=%d] " % (cpu_percent,CPU_MAX_WARNING,CPU_MAX_CRITICAL,func_return_code))
   return (func_return_code,str(cpu_percent))
	   
#------------------------------------------------------------------------------ 

def checkLoad() :
   func_return_code=0
   load = os.getloadavg()
   
   ##CRITICAL
   if load[0] >= LOAD_MAX_CRITICAL or load[1] >= LOAD_MAX_CRITICAL or load[2] >= LOAD_MAX_CRITICAL:
       func_return_code=1
   ##WARNING
   elif load[0] >= LOAD_MAX_WARNING or load[1] >= LOAD_MAX_WARNING or load[2] >= LOAD_MAX_WARNING:
       func_return_code=2

   print ("checkLoad: load=%s [Warning if greater than %d | Critical if greater than %d | RETURN CODE=%d] " % (str(load),LOAD_MAX_WARNING,LOAD_MAX_CRITICAL,func_return_code))
   return (func_return_code,str(load))
   
#------------------------------------------------------------------------------ 

def checkUptime() :
   func_return_code=0
   with open('/proc/uptime', 'r') as f:
    uptime_seconds = float(f.readline().split()[0])
    uptime_string = str(timedelta(seconds = uptime_seconds))
    uptime = int(uptime_string.split(' ', 1)[0]);
   
   ##CRITICAL
   if uptime >= UPTIME_MAX_CRITICAL:
       func_return_code=1
   ##WARNING
   elif uptime >= UPTIME_MAX_WARNING:
       func_return_code=2

   print ("checkUptime: uptime=%d [Warning if greater than %d | Critical if greater than %d | RETURN CODE=%d] " % (uptime,UPTIME_MAX_WARNING,UPTIME_MAX_CRITICAL,func_return_code))
   return (func_return_code,uptime)
   
#------------------------------------------------------------------------------ 

def checkMemo() :
   func_return_code=0
   mem = psutil.virtual_memory()
   swap = psutil.swap_memory()
       
   ##CRITICAL
   if mem.percent >= MEMO_MAX_CRITICAL:
       func_return_code=1
   ##WARNING
   elif mem.percent >= MEMO_MAX_WARNING:
       func_return_code=2
  
   print ("checkMemo: mem.percent=%d days [Warning if greater than %d | Critical if greater than %d | RETURN CODE=%d] " % (mem.percent,MEMO_MAX_WARNING,MEMO_MAX_CRITICAL,func_return_code))
   return (func_return_code,str(mem.percent))
   

