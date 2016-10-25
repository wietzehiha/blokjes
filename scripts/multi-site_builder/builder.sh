#!/bin/bash
config="sites_config.json"

for (( i = 0; i < `php -f decode.php $config sites_count`; i++ ));
do
  echo "setting up environment ..."

  PWD=`pwd`
  BASE_PATH=$PWD/../..
  #Retrieve all site information
  machine_name=`php -f decode.php $config machine_name $i`
  db_name=`php -f decode.php $config $i database`
  db_username=`php -f decode.php $config $i username`
  db_pass=`php -f decode.php $config $i password`
  db_host=`php -f decode.php $config $i host`
  db_driver=`php -f decode.php $config $i driver`
  permissions=`php -f decode.php $config $i owner`
  site_name=`php -f decode.php $config $i site_name`
  profile=`php -f decode.php $config $i profile`
  domains=`php -f decode.php $config $i domains`

  #Make the multi-site directory
  mkdir $BASE_PATH/web/sites/$machine_name
  cp $BASE_PATH/web/sites/default/default.settings.php $BASE_PATH/web/sites/$machine_name/settings.php
  mkdir $BASE_PATH/web/sites/$machine_name/files

  mkdir $BASE_PATH/web/sites/$machine_name/cnf
  cp $BASE_PATH/scripts/multi-site_builder/sites_config.json $BASE_PATH/web/sites/$machine_name/cnf/config.json

  cd $BASE_PATH/web/sites/$machine_name/files/ && sudo chown -R $permissions . && sudo chmod -R 775 .
  cd $BASE_PATH/web/sites/$machine_name/

  site='$sites'
  IFS=','
  #Loop through domains array and add domains to sites.php
  for domain in $domains;
  do
    echo "$site['$domain'] = '$machine_name';">>$BASE_PATH/web/sites/sites.php
    cp $BASE_PATH/scripts/multi-site_builder/behat_tpl.yml $BASE_PATH/web/sites/$machine_name/cnf/behat_$domain.yml
    #Replace ##site_url## with Domain url in the behat.yml file
    sed -i "s@##site_url##@http://$domain@g" $BASE_PATH/web/sites/$machine_name/cnf/behat_$domain.yml
  done
  unset IFS

  dbconnect="$db_username:$db_pass"
  dburl="$db_driver://$dbconnect@$db_host/$db_name"
  #Drush site-install command
  $BASE_PATH/vendor/bin/drush si -y $profile --db-url=$dburl --site-name=$site_name --account-name=admin --account-pass=adminpass

  cd $BASE_PATH/scripts/multi-site_builder
done
