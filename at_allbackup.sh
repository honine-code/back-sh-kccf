#!/bin/bash
#####################################
#      HANDY All BACKUP SCRIPT      #
#      Aintop Leedh 2022-07-05      #
#####################################
#   DATE          : 날짜             #
#   LOG_DIR       : 로그를 저장할 경로   #
#   LOG           : 로그명            #
#   ERR_LOG       : 에러로그명         #
#   RSYNC         : RSYNC 데몬       #
#   RSYNC_OPTION  : RSYNC 옵션       #
#   DATA          : REAL DATA 경로   #
#   BACKUP_SERVER : 백업받을 경로       #
#####################################


DATE=`date '+%Y%m%d_%H.%M.%S'`
LOG_DIR=/data/handy/at_backup/logs/all/
LOG="${LOG_DIR}/backup_$DATE.log"
ERR_LOG="${LOG_DIR}/backup_err_$DATE.log"

RSYNC=/usr/bin/rsync
RSYNC_OPTION="-avrh --bwlimit=40960 --exclude=not_backup.txt"
DATA=/data/handy/
BACKUP_SERVER=/kccfdata_backup/gw/handy/

${RSYNC} ${RSYNC_OPTION} ${DATA} ${BACKUP_SERVER} 1>> $LOG 2>> $ERR_LOG

## 생성일이 60일이 로그는 삭제
find ${LOG_DIR} -name '*.log' -mtime +60 -exec rm {} \;