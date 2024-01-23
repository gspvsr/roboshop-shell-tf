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

yum install maven -y &>>$LOGFILE
VALIDATE $? "installing the maven"

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app  &>>$LOGFILE
VALIDATE $? "creating directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip  &>>$LOGFILE
VALIDATE $? "downloading the shipping"

cd /app &>>$LOGFILE
VALIDATE $? "moving to the app directory"  

unzip -o /tmp/shipping.zip  &>>$LOGFILE
VALIDATE $? "unzipping"

mvn clean package  &>>$LOGFILE
VALIDATE $? "cleaning the moven package"

mv target/shipping-1.0.jar shipping.jar  &>>$LOGFILE
VALIDATE $? "moving the file"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>>$LOGFILE
VALIDATE $? "copying shipping service"

systemctl daemon-reload  &>>$LOGFILE
VALIDATE $? "reloading the service"

systemctl enable shipping  &>>$LOGFILE
VALIDATE $? "enabling the service"

systemctl start shipping  &>>$LOGFILE
VALIDATE $? "starting the shipping service"

dnf install mysql -y  &>>$LOGFILE
VALIDATE $? "installing the mysql client"

mysql -h mysql.gspaws.online -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>>$LOGFILE
VALIDATE $? "installing the mysql"

systemctl restart shipping  &>>$LOGFILE
VALIDATE $? "re-starting the mysql"