#!/bin/bash
# Function file for jarvis-quality-air-france plugin - French

pg_aq_france_index() {
    local date=`date +%Y%m%d`
    local url="http://www2.prevair.org/ineris-web-services.php?url=atmo&date=$date"
    
    # Convert city to upper case
    pg_aq_france_city=$(awk '{ print toupper($0) }' <<< $pg_aq_france_city)
    
    # Get page: curl -s $url
    # Replace table boundaries `],[` by new lines: sed 's/\],\[/\n/g'
    # Select city line: grep $pg_aq_france_city
    # Replace table boundaries `","` by new lines: sed 's/","/\n/g'
    # Select 8th line: sed -n 8p
    local index="$(curl -s $url | sed 's/\],\[/\n/g' | grep $pg_aq_france_city | sed 's/","/\n/g' | sed -n 8p)"
    
    # Error message without results
    if [ -z "$index" ]; then
        echo "Pas de résultats, vérifiez la ville"
        exit 0;
    fi
    
    # Convert value to text
    case "$index" in
        "1" | "2")
            index="très bon"
            ;;
        "3" | "4")
            index="bon"
            ;;
        "5")
            index="moyen"
            ;;
        "6" | "7")
            index="médiocre"
            ;;
        "8" | "8")
            index="mauvais"
            ;;
        "10")
            index="très mauvais"
            ;;
        *)
            index="ERROR"
    esac
    
    # Return speech
    echo "L'indice de pollution est $index"
}
