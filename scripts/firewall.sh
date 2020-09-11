#!/bin/sh
firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-port 8080/tcp
firewall-cmd --zone=public --permanent --add-port 8983/tcp
firewall-cmd --zone=public --permanent --add-port 9000/tcp
firewall-cmd --reload
firewall-cmd --list-all