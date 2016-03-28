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
  
   return (func_return_code,str(cpu_percent))
	   
#------------------------------------------------------------------------------ 

def checkLoad() :
   func_return_code=0
   with open('/proc/uptime', 'r') as f:
    uptime_seconds = float(f.readline().split()[0])
    uptime_string = str(timedelta(seconds = uptime_seconds))
   
   ##CRITICAL
   if uptime_string >= LOAD_MAX_CRITICAL:
      
       func_return_code=1
   ##WARNING
   elif uptime_string >= LOAD_MAX_WARNING:
       
       func_return_code=2


   return (func_return_code,str(uptime_string))
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
  
 
   return (func_return_code,str(mem.percent))
   

