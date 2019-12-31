#!/bin/sh
# usage ${BENCHPATH}/bin/memusage.sh bismark /path/to/read_1.fastq 

## only track maximal memory usage (virtual and residual)
## for process and all child processes by use of ps,
## process is idenfied by processName and potentially
## scriptName (in case multiple processes with the
## sam processName run simultaneously

# test input arguments
if [ $# -ne 2 -a $# -ne 1 ]
then
   echo "Invalid call with '$*'" && exit -1
fi

# In case the monitored process has not yet started
# keep searching until its PID is found
PROCESS_PID=""
while :
do
    PID=""
    PIDS=$(ps as | grep $1 | grep -Ev "grep|time|memusage" | awk '{print $2}')
    for i in $PIDS
    do
	if [ $# -eq 2 ]
	then
	    ps -p $i -o cmd= | grep -q "$2"
	    if [ $? -ne 0 ]
	    then
		i=""
	    fi
	fi

	if [ "$i" != "" ]
	then
	    if [ "$PID" == "" ]
	    then
		PID=$i
	    else
		echo 1>&2 "memusage: multiple processes found for memory tracking. Exit forced."
		exit -1
	    fi	    
	fi
    done
    if [ "$PID" != "" ]
    then
	break
    fi
done


# define variables and output header
PERIOD=1        
MAXRSS=0
MAXVSZ=0
TIME=0
echo -e "#pid\tcomm\ttime\ttime\trss\tvsz"

# while counter for processing time, memory usage
# on selected PIDS
while :
do
 if [ -d /proc/"$PID" ]
 then
     RSS=0
     VSZ=0
     
     ## get PIDS of child processes
     PIDS=$(pstree -p $PID | grep -o "([[:digit:]]*)" | grep -o "[[:digit:]]*")

     for i in $PID $PIDS
     do
	 TMP=`ps -p $i -o rss=`
	 if [ "$TMP" != "" ]
	 then
	     RSS=$(($RSS+$TMP))
	 fi
	 
	 TMP=$(ps -p $i -o vsz=)
	 if [ "$TMP" != "" ]
	 then
	     VSZ=$(($VSZ+$TMP))
	 fi
     done

     if [ $RSS -gt $MAXRSS ]
     then
	 MAXRSS=$RSS
     fi
     
     if [ $VSZ -gt $MAXVSZ ]
     then
	 MAXVSZ=$VSZ
     fi
     
     TMP=$(ps -p $PID -o time=)
     if [ "$TMP" != "" ]
     then
	 TIME=$TMP
     fi

     sleep $PERIOD
 else
     echo -e $PID"\t"$(basename $1)"\t"$TIME"\t"$TIME"\t"$MAXRSS"\t"$MAXVSZ
     exit 0
 fi
done
