#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2...$R FAILED $N"
        exit 1
    else 
        echo -e "$2....$G SUCCESS $N"
    fi
}

USERID=$(id -u)

    if [ $USERID -ne 0 ]
    then
        echo "ERROR :: Please install with Root Access"
        exit 1 # you can give other than 0
    else
        echo "you are root user"
    fi 


dnf module disable nodejs -y  &>> $LOGFILE
VALIDATE $? "dIsabling current nodejs"

dnf module enable nodejs:18 -y  &>> $LOGFILE
VALIDATE $? "Enabling Nodejs:18"

dnf install nodejs -y  &>> $LOGFILE
VALIDATE $? "Installing the nodeJS:18"

id roboshop #if roboshop user does not exist, then it is failure
    if [ $? -ne 0 ]
    then
        useradd roboshop
        VALIDATE $? "roboshop user creation"
    else
        echo -e "roboshop user already exist $Y SKIPPING $N"
    fi


mkdir -p /app
VALIDATE $? "creating app directory"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip  &>> $LOGFILE
VALIDATE $? "Downloading user application"

cd /app 

unzip -o /tmp/user.zip  &>> $LOGFILE
VALIDATE $? "unzipping user"

npm install  &>> $LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "Copying user service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "user daemon reload"

systemctl enable user &>> $LOGFILE
VALIDATE $? "Enable user"

systemctl start user &>> $LOGFILE
VALIDATE $? "Starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo  &>> $LOGFILE
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Installing MongoDB client"

mongo --host mongodb.gspaws.online </app/schema/user.js &>> $LOGFILE
VALIDATE $? "Loading catalouge data into MongoDB"