#!/bin/bash
#####################################
#     HANDY SANC BACKUP SCRIPT      #
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
#   REAL_SANCBOX  : 운영문서 경로       #
#   BACKUP_SANCBOX: 백업받을 문서 경로   #
#                                   #
#   YEAR          : 연도             #
#   MONTH         : 월              #
#   TODAY         : 오늘             #
#   YESTERDAY     : 전일             #
#   NEWYEAR       : 새 연도           #
#   NEWMONTH      : 새 월             #
#   WEEK          : 현재 주(몇째 주 인지) #
#   LASTDAY       : 이번달의 마지막 일    #
#   wCURRENT_DATE : 토요일 구하기 위한 변수#
#   wCURRENT_WEEK : 토요일 구하기 위한 변수#
#   LASTWEEK_DAY  : 이번달의 마지막 토요일 #
#####################################

DATE=`date '+%Y%m%d_%H.%M.%S'`
LOG_DIR=/data/handy/at_backup/logs/sanc/
LOG="${LOG_DIR}/sanc_backup_$DATE.log"
ERR_LOG="${LOG_DIR}/sanc_backup_err_$DATE.log"

RSYNC=/usr/bin/rsync
RSYNC_OPTION="-avrh --bwlimit=40960 "

REAL_SANCBOX=/data/handy/hoffice/sancbox/
BACKUP_SANCBOX=/kccfdata_backup/gw/handy/hoffice/sancbox/

YEAR=`date '+%Y'`
MONTH=`date '+%-m'`
TODAY=`date '+%-d'`
YESTERDAY=`date +%-d --date '1 days ago'`
NEWYEAR=0
NEWMONTH=0

## 월:1 화:2 수:3 목:4 금:5 토:6 일:0
WEEK=`date '+%w'`

## 이번달 마지막날짜
LASTDAY=`cal $MONTH $YEAR | awk '{for(i=1;i<=NF;i++) lastday=$i } END{print lastday }'`

## 마지막주 토요일구하기
for ((i=$LASTDAY ; i >= $LASTDAY-7 ; i--));
do
  wCURRENT_DATE=$(date --date=$YEAR-$MONTH-$i +"%Y%m%d")
  wCURRENT_WEEK=`date -d "$wCURRENT_DATE" +%w`
  if [ $wCURRENT_WEEK = 6 ]  ; then
  LASTWEEK_DAY=$i
  fi
done

## 연도가 변경된 경우 디렉토리 생성
if [ $MONTH = 1 -a $TODAY = 1 ] ; then
  mkdir ${BACKUP_SANCBOX}/${YEAR} && chown -R handy:dba ${BACKUP_SANCBOX}/${YEAR}
fi

## 달이 변경된 경우 디렉토리 생성
if [ $TODAY = 1 ] ; then
  mkdir ${BACKUP_SANCBOX}/${YEAR}/${MONTH} && chown -R handy:dba ${BACKUP_SANCBOX}/${YEAR}/${MONTH}
fi

## 매일 결재디렉토리 생성
  mkdir ${BACKUP_SANCBOX}/${YEAR}/${MONTH}/${TODAY} && chown -R handy:dba ${BACKUP_SANCBOX}/${YEAR}/${MONTH}/${TODAY}

## 1월1일이라면 연도를 작년으로 구해야함.
if [ $MONTH = 1 -a $TODAY = 1 ] ; then
  YEAR=`date +%Y --date '1 YEAR ago'`
  NEWYEAR=1
fi

## 1일이라면 월을 전달로 구해야함.
if [ $TODAY = 1 ] ; then
  MONTH=`date +%-m --date '1 month ago'`
  NEWMONTH=1
fi

## 1월1일 작년 1년치
if [ $NEWYEAR = 1 -a $NEWMONTH = 1 ] ; then
  DATA=${REAL_SANCBOX}/${YEAR}/
  BACKUP_SERVER=${BACKUP_SANCBOX}/${YEAR}/

## 매월 미지막주 토요일 1년치
elif [ $TODAY = $LASTWEEK_DAY ] ; then
  DATA=${REAL_SANCBOX}/${YEAR}/
  BACKUP_SERVER=${BACKUP_SANCBOX}/${YEAR}/

## 매주 토요일 1달치
elif [ $WEEK = 6 -a $NEWYEAR = 0 ] ; then
  DATA=${REAL_SANCBOX}/${YEAR}/${MONTH}/
  BACKUP_SERVER=${BACKUP_SANCBOX}/${YEAR}/${MONTH}/

## 매일은 이전일
else
  DATA=${REAL_SANCBOX}/${YEAR}/${MONTH}/${YESTERDAY}/
  BACKUP_SERVER=${BACKUP_SANCBOX}/${YEAR}/${MONTH}/${YESTERDAY}/
fi

#echo "현재연도:"`date '+%Y'`
#echo "현재월:"`date '+%-m'`
#echo "오늘날짜:"$TODAY
#echo "백업연도:"$YEAR
#echo "백업월:"$MONTH
#echo "어제날짜:"$YESTERDAY
#echo "마지막날짜:"$LASTDAY
#echo "현재요일:"$WEEK
#echo "마지막주토요일날짜:"$LASTWEEK_DAY
#echo "대상폴더:"$DATA
#echo "백업폴더:"$BACKUP_SERVER

${RSYNC} ${RSYNC_OPTION} ${DATA} ${BACKUP_SERVER} 1>> $LOG 2>> $ERR_LOG

## 생성일이 60일이 지난 로그는 삭제
find ${LOG_DIR} -name '*.log' -mtime +60 -exec rm {} \;