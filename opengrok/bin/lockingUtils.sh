#########
# lock  #
#########

lockMe()
{
        my_command_lock_file=$1

        if [ -f $my_command_lock_file ]
        then
                #unlock if the lock file is older than 0.5 minutes = 30 sec
                my_command_lock_file_date=`stat -c %Y $my_command_lock_file`
                current_date=`date +%s`
                time_diff=`expr $current_date - $my_command_lock_file_date`
                printToLog "The last script execution time was $time_diff seconds ago"
                _LockPid=$(cat $my_command_lock_file)
                if [ $time_diff -gt 30 ] && [ $_LockPid ] && [ ! -d /proc/$_LockPid ]
                then
                        rm -f $my_command_lock_file
                else
                        printToLog "other instance of this script is still running"
                        exit 1;
                fi
        fi

        touch $my_command_lock_file
        echo $SCRIPT_PID > $my_command_lock_file

        printToLog "Lock file was created: $my_command_lock_file"
        printToLog "--------------------------------------------------------------------"
}

unLockMe()
{
        my_command_lock_file=$1
        rm -f $my_command_lock_file
        printToLog "Lock file was removed: $my_command_lock_file"
}

#########
# PRINT #
#########

printToLog()
{
        msg=$1
        #dateTime=`date '+%m/%d/%y %H:%M:%S.%N'`
        dateTime=`date '+%m/%d/%y %H:%M:%S'`
        echo -e "${dateTime} ${msg}";
}
