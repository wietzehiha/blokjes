#!/bin/bash

PWD=`pwd`
BASE_PATH=$PWD/../..
directories=(`ls -l $BASE_PATH/web/sites | egrep '^d' | awk '{print $9}'`)

for directory in "${directories[@]}"
do
  dir="${directory}/cnf/"
  if [ -d "$BASE_PATH/web/sites/$dir" ]
  then
    domains=`php -f decode.php $BASE_PATH/web/sites/${directory}/cnf/config.json 0 domains`
    IFS=','
    for domain in $domains;
    do
      echo "testing $domain in ${directory}"
      cd $BASE_PATH/
      vendor/bin/behat -c web/sites/${directory}/cnf/behat_$domain.yml

      BEHAT_RETURN=$?

      if [ "$BEHAT_RETURN" != "0" ]
      then
      exit $BEHAT_RETURN
      fi

      cd $BASE_PATH/scripts/multi-site_builder

    done
    unset IFS
  fi

done
