#!/bin/bash

yum install httpd -y
service httpd start

echo "
<html>
<h1>
$(date)
" > /var/www/html/index.html
