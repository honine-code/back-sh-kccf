#!/bin/bash
#####################################
#    ORACLE INTRAWARE DMP BACKUP    #
#      Aintop Leedh 2022-07-05      #
#####################################
#   DATE          : 날짜             #
#   BACKUP_SERVER : 백업받을 경로       #
#####################################

DATE=`date '+%Y%m%d_%H.%M.%S'`
BACKUP_SERVER=/kccfdata_backup/gw/oracle/

cd ${BACKUP_SERVER}
exp intraware/intraware#0201 owner=intraware file=intra_$DATE.dmp log=intra_$DATE.log compress=n buffer=4096000

## 생성일이 2일이 지난 덤프와 로그는 삭제
find ${BACKUP_SERVER} -name '*.dmp' -mtime +2 -exec rm {} \;
find ${BACKUP_SERVER} -name '*.log' -mtime +2 -exec rm {} \;