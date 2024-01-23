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

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "installing nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "enabling nginx"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "starting the nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "removing the default website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "downloading and add the web artifact"

cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "configuring the html"

unzip /tmp/web.zip &>> $LOGFILE
VALIDATE $? "unzipping web application"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATE $? "copying the roboshop.conf"

systemctl restart nginx &>> $LOGFILE
VALIDATE $? "restarting the nginx"
