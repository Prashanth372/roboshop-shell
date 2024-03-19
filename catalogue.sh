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
# IMPROVEMENT : First check the user already exist or not, if not exist then create
useradd roboshop &>>$LOGFILE

#write a condition to check if directory already exist or not
mkdir /app &>>$LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOGFILE

VALIDATE $? "Downloading catalogue artifact"

cd /app &>>$LOGFILE

VALIDATE $? "Moving to app directory"

unzip /tmp/catalogue.zip &>>$LOGFILE

VALIDATE $? "Unzipping catalogue"

cd /app &>>$LOGFILE

npm install &>>$LOGFILE

VALIDATE $? "Installing dependencies"

#Give full path of catalogue.service as we are inside /app
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE

VALIDATE $? "Copying catalogue.service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon-reload"

systemctl enable catalogue &>>$LOGFILE

VALIDATE $? "enabling catalogue"

systemctl start catalogue &>>$LOGFILE

VALIDATE $? "starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "Copying mongo.repo"

dnf install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "Installing Mongo Client"

mongo --host mongodb.suvarnalaxmiinfradevelopers.online </app/schema/catalogue.js &>>$LOGFILE

VALIDATE $? "Loading catalogue data into mongoDB"

