#!/bin/bash
#####################################
#     HANDY SANC BACKUP SCRIPT      #
#      Aintop Leedh 2022-07-05      #
#####################################
#   DATE          : ��¥             #
#   LOG_DIR       : �α׸� ������ ���   #
#   LOG           : �α׸�            #
#   ERR_LOG       : �����α׸�         #
#   RSYNC         : RSYNC ����       #
#   RSYNC_OPTION  : RSYNC �ɼ�       #
#   DATA          : REAL DATA ���   #
#   BACKUP_SERVER : ������� ���       #
#   REAL_SANCBOX  : ����� ���       #
#   BACKUP_SANCBOX: ������� ���� ���   #
#                                   #
#   YEAR          : ����             #
#   MONTH         : ��              #
#   TODAY         : ����             #
#   YESTERDAY     : ����             #
#   NEWYEAR       : �� ����           #
#   NEWMONTH      : �� ��             #
#   WEEK          : ���� ��(��° �� ����) #
#   LASTDAY       : �̹����� ������ ��    #
#   wCURRENT_DATE : ����� ���ϱ� ���� ����#
#   wCURRENT_WEEK : ����� ���ϱ� ���� ����#
#   LASTWEEK_DAY  : �̹����� ������ ����� #
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

## ��:1 ȭ:2 ��:3 ��:4 ��:5 ��:6 ��:0
WEEK=`date '+%w'`

## �̹��� ��������¥
LASTDAY=`cal $MONTH $YEAR | awk '{for(i=1;i<=NF;i++) lastday=$i } END{print lastday }'`

## �������� ����ϱ��ϱ�
for ((i=$LASTDAY ; i >= $LASTDAY-7 ; i--));
do
  wCURRENT_DATE=$(date --date=$YEAR-$MONTH-$i +"%Y%m%d")
  wCURRENT_WEEK=`date -d "$wCURRENT_DATE" +%w`
  if [ $wCURRENT_WEEK = 6 ]  ; then
  LASTWEEK_DAY=$i
  fi
done

## ������ ����� ��� ���丮 ����
if [ $MONTH = 1 -a $TODAY = 1 ] ; then
  mkdir ${BACKUP_SANCBOX}/${YEAR} && chown -R handy:dba ${BACKUP_SANCBOX}/${YEAR}
fi

## ���� ����� ��� ���丮 ����
if [ $TODAY = 1 ] ; then
  mkdir ${BACKUP_SANCBOX}/${YEAR}/${MONTH} && chown -R handy:dba ${BACKUP_SANCBOX}/${YEAR}/${MONTH}
fi

## ���� ������丮 ����
  mkdir ${BACKUP_SANCBOX}/${YEAR}/${MONTH}/${TODAY} && chown -R handy:dba ${BACKUP_SANCBOX}/${YEAR}/${MONTH}/${TODAY}

## 1��1���̶�� ������ �۳����� ���ؾ���.
if [ $MONTH = 1 -a $TODAY = 1 ] ; then
  YEAR=`date +%Y --date '1 YEAR ago'`
  NEWYEAR=1
fi

## 1���̶�� ���� ���޷� ���ؾ���.
if [ $TODAY = 1 ] ; then
  MONTH=`date +%-m --date '1 month ago'`
  NEWMONTH=1
fi

## 1��1�� �۳� 1��ġ
if [ $NEWYEAR = 1 -a $NEWMONTH = 1 ] ; then
  DATA=${REAL_SANCBOX}/${YEAR}/
  BACKUP_SERVER=${BACKUP_SANCBOX}/${YEAR}/

## �ſ� �������� ����� 1��ġ
elif [ $TODAY = $LASTWEEK_DAY ] ; then
  DATA=${REAL_SANCBOX}/${YEAR}/
  BACKUP_SERVER=${BACKUP_SANCBOX}/${YEAR}/

## ���� ����� 1��ġ
elif [ $WEEK = 6 -a $NEWYEAR = 0 ] ; then
  DATA=${REAL_SANCBOX}/${YEAR}/${MONTH}/
  BACKUP_SERVER=${BACKUP_SANCBOX}/${YEAR}/${MONTH}/

## ������ ������
else
  DATA=${REAL_SANCBOX}/${YEAR}/${MONTH}/${YESTERDAY}/
  BACKUP_SERVER=${BACKUP_SANCBOX}/${YEAR}/${MONTH}/${YESTERDAY}/
fi

#echo "���翬��:"`date '+%Y'`
#echo "�����:"`date '+%-m'`
#echo "���ó�¥:"$TODAY
#echo "�������:"$YEAR
#echo "�����:"$MONTH
#echo "������¥:"$YESTERDAY
#echo "��������¥:"$LASTDAY
#echo "�������:"$WEEK
#echo "������������ϳ�¥:"$LASTWEEK_DAY
#echo "�������:"$DATA
#echo "�������:"$BACKUP_SERVER

${RSYNC} ${RSYNC_OPTION} ${DATA} ${BACKUP_SERVER} 1>> $LOG 2>> $ERR_LOG

## �������� 60���� ���� �α״� ����
find ${LOG_DIR} -name '*.log' -mtime +60 -exec rm {} \;