#!/bin/bash
# Function file for jarvis-quality-air-france plugin - French

pg_aq_france_index() {
    local date=`date +%Y%m%d`
    local url="http://www2.prevair.org/ineris-web-services.php?url=atmo&date=$date"
    
    # Convert city to
        # Upper case
        # Dash instead of space
        # Put 'le' & 'la' in brackets
    local pg_aq_france_city_converted=$(awk '{ print toupper($0) }' <<< $pg_aq_france_city | \
                sed 's/^LE /(LE)/' | \
                sed 's/^LA /(LA)/' | \
                sed 's/ /-/g')
    
    # Get page: curl -s $url
    # Replace table boundaries `],[` by new lines: sed 's/\],\[/\n/g'
    # Select city line: grep $pg_aq_france_city
    # Replace table boundaries `","` by new lines: sed 's/","/\n/g'
    # Select 8th line: sed -n 8p
    local index="$(curl -s $url | \
                sed 's/\],\[/\n/g' | \
                grep $pg_aq_france_city_converted | \
                sed 's/","/\n/g' | \
                sed -n 8p)"
    
    # Error message without results
    if [ -z "$index" ]; then
        echo "Pas de résultats pour $pg_aq_france_city, vérifiez la ville"
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
        "8" | "9")
            index="mauvais"
            ;;
        "10")
            index="très mauvais"
            ;;
        *)
            index="ERROR"
    esac
    
    # Return speech
    echo -n "L'indice de pollution "
    if [ -z "$pg_aq_france_default_city" ]; then
        echo -n "à $pg_aq_france_city "
    fi
    echo "est $index"
}
