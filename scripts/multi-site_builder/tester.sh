#!/bin/bash

PWD=`pwd`
BASE_PATH=$PWD/../..
directories=(`ls -l $BASE_PATH/web/sites | egrep '^d' | awk '{print $9}'`)
choices=('All' 'Folders' 'Domains')

echo "What do you intend to test?"
select choice in "${choices[@]}"
do
  if [ "$choice" == "All" ]
    then
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
          cd $BASE_PATH
          vendor/bin/behat -c web/sites/${directory}/cnf/behat_$domain.yml
          cd $BASE_PATH/scripts/multi-site_builder
        done
        unset IFS
      fi
    done
    break
  elif [ "$choice" == "Folders" ]
    then
    echo "Which folder do you want to test?"
    select dir in "${directories[@]}"
    do
      echo "testing domains in ${dir}"
      domains=`php -f decode.php $BASE_PATH/web/sites/${dir}/cnf/config.json 0 domains`

      IFS=','
      for domain in $domains;
      do
        echo "testing $domain"
        cd $BASE_PATH
        vendor/bin/behat -c web/sites/${dir}/cnf/behat_$domain.yml
        cd $BASE_PATH/scripts/multi-site_builder
      done
      unset IFS
      break
    done
    break
  elif [ "$choice" == "Domains" ]
    then
    echo "Choose which domain you want to test."
    declare -A domains_arr

    for dir in "${directories[@]}"
    do
      if [ -d "$BASE_PATH/web/sites/$dir/cnf" ]
        then
        machine_name=`php -f decode.php $BASE_PATH/web/sites/${dir}/cnf/config.json machine_name 0`
        domains=`php -f decode.php $BASE_PATH/web/sites/${dir}/cnf/config.json 0 domains`

        IFS=','
        for domain in $domains
        do
          domains_arr[$domain]=$dir
        done
        unset IFS
      fi
    done

    select chosen_domain in "${!domains_arr[@]}"
    do
      echo "you selected ${chosen_domain}"
      cd $BASE_PATH
      vendor/bin/behat -c web/sites/${domains_arr[$chosen_domain]}/cnf/behat_$chosen_domain.yml
      cd $BASE_PATH/scripts/multi-site_builder
      break
    done
    break
  else
    echo "Oops! Try again."
  fi
done
