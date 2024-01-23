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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$LOGFILE
VALIDATE $? "download and installing the redis"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE
VALIDATE $? "enabling the redis module 6.2"

dnf install redis -y &>> $LOGFILE
VALIDATE $? "enabling the redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf /etc/redis/redis.conf &>> $LOGFILE
VALIDATE $? "allowing remote connections to redis"

systemctl enable redis &>> $LOGFILE
VALIDATE $? "enabling the redis"

systemctl start redis &>> $LOGFILE
VALIDATE $? "starting the redis"