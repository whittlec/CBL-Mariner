#!/bin/bash

# ./analyze-log.sh LOGFILE_NAME
# Analyze mariner build log for performance markers

LOGFILE_NAME=$1

grep "Building (" $LOGFILE_NAME
grep "Executing(" $LOGFILE_NAME | grep -v "license" | awk '{print $1$2$3}'
grep "brp-strip" $LOGFILE_NAME | awk '{print $1$2$3$4$5}'
grep "Summary:" $LOGFILE_NAME
grep "  Hits:" $LOGFILE_NAME | head -1
grep "  Cache size" $LOGFILE_NAME
grep "Executing(%license" $LOGFILE_NAME | awk '{print $1$2$3}'
grep "Processing files:" $LOGFILE_NAME | awk '{print $1$2$3$4$5}'
grep "Wrote: " $LOGFILE_NAME | awk '{print $1$2$3$4$5}'
grep "Built (-" $LOGFILE_NAME | awk '{print $1$2$3$4$5}'
