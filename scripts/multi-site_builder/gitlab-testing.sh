#!/bin/bash

cd /etc/apache2/sites-enabled/
sed -i "s@#PROJECT_DIR#@$CI_PROJECT_DIR@g" 000-default.conf