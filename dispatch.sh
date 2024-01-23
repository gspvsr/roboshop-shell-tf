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

yum install golang -y &>> $LOGFILE
VALIDATE $? "Installing the go-language package"

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "moving to the directory"

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> $LOGFILE
VALIDATE $? "downloading the dispatch.zip"

cd /app &>> $LOGFILE
VALIDATE $? "moving to the app diectory"

unzip -o /tmp/dispatch.zip &>> $LOGFILE
VALIDATE $? "unzipping the zip file"

cd /app &>> $LOGFILE
VALIDATE $? "moving to the app directory"

go mod init dispatch &>> $LOGFILE
VALIDATE $? "initiating the dispatch"

go get &>> $LOGFILE 
VALIDATE $? "getting the file"

go build &>> $LOGFILE
VALIDATE $? "building the file"
    
cp /home/centos/roboshop-shell/dispatach.service /etc/systemd/system/dispatch.service &>> $LOGFILE
VALIDATE $? "copying the dispatch.service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "releading the file"

systemctl enable dispatch &>> $LOGFILE
VALIDATE $? "enabling the dispatch"

systemctl start dispatch &>> $LOGFILE
VALIDATE $? "roboshop dispatching file creation"