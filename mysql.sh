#!/bin/bash
 
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shellscript-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
    if [ $? -ne 0 ]
    then
        echo -e "$2 ..$R failure $N"
        exit 1
    else
        echo -e "$2 ..$G success $N"
    fi

}


CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then 
        echo "ERROR:: you must have sudo access to execute this script"
        exit 1 #other then  0
    fi
}    

echo "Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT
dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing MYSQL Sever"

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $?  "Enabling Mysql server"

systemctl start mysqld LOG_FILE_NAME &>>$LOG_FILE_NAME
VALIDATE $? "starting mysql server"

mysql -h mysql.online -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE_NAME

if [ $? -ne 0 ]

then 
    echo "MYSQL Root password not setup" &>>$LOG_FILE_NAME
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "sessing Root Password"
else
    echo -e "MYSQL Root password already setup ... $Y SKIPPING $N"
fi

