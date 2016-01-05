#!/bin/bash 

export PYTHONPATH=$PYTHONPATH:/tmp/ntm-monitoring-pkg/psutil:/tmp/ntm-monitoring-pkg/ntm-monitoring/conf:/tmp/ntm-monitoring-pkg/ntm-monitoring/lib


export PYTHONPATH=$PYTHONPATH:/opt/ntm-monitoring-pkg/psutil:/opt/ntm-monitoring-pkg/ntm-monitoring/bin:/opt/ntm-monitoring-pkg/ntm-monitoring/conf:/opt/ntm-monitoring-pkg/ntm-monitoring/lib



./Cpu.py
./Disk.py
./Load.py
./Memo.py
