#!/bin/sh

continent="$@"
if [[ $continent ==  "" ]]; then
    echo "Continent name not provided!"
    exit
fi

country_capitals_filename="country_capitals.txt"
capitals_lat_long_filename="capitals_lat_long.txt"

if [[ ! -f  ./"$country_capitals_filename" ]]; then
    echo "Source file for countries and capitals not present!"
    exit
fi

if [[ ! -f ./"$capitals_lat_long_filename" ]]; then
    echo "Source file for capitals and their location not present!"
    exit
fi

country_capitals_filename_csv="country_capitals.csv"
capitals_lat_long_filename_csv="capitals_lat_long.csv"
joined_filename="country_capitals_lat_long.csv"

cat \
    "$country_capitals_filename" | \
    tr [:lower:] [:upper:] | \
    tr \\t \, | \
    tr -s \\n | \
    sort -t \, -k3,3 > \
    "$country_capitals_filename_csv"

cat \
    "$capitals_lat_long_filename" | \
    tr [:lower:] [:upper:] | \
    sort -t \, -k1,1 > \
    "$capitals_lat_long_filename_csv"

join \
    -a 1 \
    -1 3 -2 1 \
    -t \, \
    -o 1.1,1.2,2.1,2.2,2.3 \
    "$country_capitals_filename_csv" "$capitals_lat_long_filename_csv" > \
    "$joined_filename"

lowercase_continent=`echo "$continent" | tr '[:upper:]' '[:lower:]' | sed -e 's/^"//' -e 's/"$//'`
city_info_file_name_prefix=`echo "$lowercase_continent" | sed -e 's/ /_/'`
echo "$city_info_file_name_prefix"
city_info_file="$city_info_file_name_prefix"_cities.csv

if [[ -f ./"$city_info_file" ]]; then
    rm -f ./$city_info_file
fi

touch ./$city_info_file


while IFS= read -r line
do
    continent_name=`echo "$line" | cut -f 1 -d  \, | tr '[:upper:]' '[:lower:]'`
    if [[ "$continent_name" == "$lowercase_continent" ]]; then
        echo "$line" >> ./$city_info_file
    fi
done < "$joined_filename"

header_row="CONTINET,COUNTRY,CAPITAL,LATITUDE,LONGITUDE"
sed -i '1 i '"$header_row"'' ./"$city_info_file"

rm -f ./$country_capitals_filename_csv ./$capitals_lat_long_filename_csv ./$joined_filename

echo "File processing complete"