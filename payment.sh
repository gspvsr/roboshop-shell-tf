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


yum install python36 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "installing the python36"

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "creating the directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "download the payment.zip"

cd /app &>> $LOGFILE
VALIDATE $? "re-directing to the app"

unzip -o /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "unzipping the file"

cd /app &>> $LOGFILE
VALIDATE $? "moving to the app"

pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "python dependencies are installing"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "copying the payment.service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading the payment"

systemctl start payment &>> $LOGFILE
VALIDATE $? "starting the system"