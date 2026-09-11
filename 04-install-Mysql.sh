#!/bin/bash

# condition to install mysql server

USERID=$(id -u)        # checking wheather user is root user or not

if [ $USERID -ne 0 ]
then
    echo "ERROR: You must be root user to run this script"
    exit 1
else
    echo "You are root user, you can run this script"
fi

dnf install mysql -y

# it is our responsibility to check installation is success or not

if [ $? -eq 0 ]
then
    echo "mysql installation is success"
else
    echo "mysql installation is failed"
fi