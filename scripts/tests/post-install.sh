#!/bin/sh

if [ -f web/sites/default/settings.local.php ]
  then
    rm web/sites/default/settings.local.php
fi

cp web/sites/default/default.development.settings.local.php web/sites/default/settings.local.php
chmod 777 web/sites/default/settings.local.php

