#!/bin/sh
firewall-cmd --zone=public --permanent --add-port 8080/tcp
firewall-cmd --zone=public --permanent --add-port 8983/tcp
firewall-cmd --reload
firewall-cmd --list-all