#!/bin/bash
# Simple script to list all available cities

get_city_list() {
    local cities_list="$(curl -s 'http://www2.prevair.org/ineris-web-services.php?url=atmo&date=20170503' | sed 's/\],\[/\n/g')"
    
    while read line; do
      echo "$(echo "$line" |  sed 's/","/\n/g' | \
                    sed -n 5p)"
    done <<< "$cities_list"
}

sorted_list=$(get_city_list | sort)
while read city; do
    echo " - $city"
done <<< "$sorted_list"