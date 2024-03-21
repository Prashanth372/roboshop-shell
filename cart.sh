#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then    
    echo -e "$R ERROR:: Please run this scirpt with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}    

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Module disabled nodeJS"

dnf module enable nodejs:18 -y &>>$LOGFILE
VALIDATE $? "Enable NodeJS 18 version"

dnf install nodejs -y  &>>$LOGFILE
VALIDATE $? "Installing NodeJS"


#Once user is created, if you run this script 2nd time then it will be fail
#this command will defintely fail
# IMPROVEMENT : Firest check the user already exist or not, if not exist then create
########useradd roboshop &>>$LOGFILE

#write a condition to check if directory already exist or not
########mkdir /app &>>$LOGFILE

#########curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>>$LOGFILE

VALIDATE $? "Downloading cart artifact"

cd /app &>>$LOGFILE

VALIDATE $? "Moving to app directory"

######unzip /tmp/cart.zip &>>$LOGFILE

VALIDATE $? "Unzipping cart"

cd /app &>>$LOGFILE

npm install &>>$LOGFILE

VALIDATE $? "Installing dependencies"

#Give full path of cart.service as we are inside /app
cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>>$LOGFILE

VALIDATE $? "copying cart.service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon-reload"

systemctl enable cart &>>$LOGFILE

VALIDATE $? "enabling cart"

systemctl start cart &>>$LOGFILE

VALIDATE $? "starting cart"

