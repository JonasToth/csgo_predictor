#!/bin/bash


# this script will aggregate data from http://www.hltv.org/?pageid=188&gameid=2
# parse it and print it on stdout as csv

base_url="http://www.hltv.org/?pageid=188&offset="
data_offset=0
max_offset=7000

current_date=$(date +%s)
last_file=$(ls -CF *.csv)
result_file="hltv_$current_date.csv"

# class="covMainBoxContent" is the parent container for the relevant data
# start in line 635
# end in line 981

while [ "$data_offset" -le "$max_offset" ]
do
	raw_html=$(curl -s -X GET "${base_url}${data_offset}")
	tmp_file="tmp_raw.txt"

	# temporary file for sed 
	echo "$raw_html" > "$tmp_file"

	# sed read the tmp_file and crop of all unneeded stuff
	crop=$(sed -n -e '635,981p' < "$tmp_file")

	# get every not needed div out of there
	# erase all tabulators
	#clear_divs=$(echo "$crop" | sed -e '{/<div style="clear:both\;"><\/div>/d;/<div style="width:606px\;height:22px\;background-color:white">/d;/<div style="padding-left:5px\;padding-top:5px\;">/d;/<div style="clear:both\;height:2px\;"><\/div>/d;/<div style="width:606px\;height:22px\;background-color:#E6E5E5">/d;/<\/div>.$/d;s/\t//g;}')


	clear_tags=$(echo "$crop" | sed -e 's/<[^>]*>//g')
	#echo "$clear_tags"
	# remove tabs
	# show only lines with a number (no empty lines)
	clear_whitespace=$(echo "$clear_tags" | sed -e 's/\t//g' | sed -n -e '/[0-9]/p')

	extracted_tmp="tmp_extracted.txt"
	#echo "$clear_whitespace"
	echo "$clear_whitespace" > "$extracted_tmp"

	while read line
	do
		#echo "$line"
		# bsp: 6/4 15 fnatic (6) Virtus.pro (16)mirage FACEIT League 2015

		# rechts abschneiden nach slash
		day=${line%%/*}
		# links abtrennen vor slash
		month=${line#*/}
		# rechts abtrennen alles nach leerzeichen
		month=${month%% *}
		# links abtrennen was vor leerzeichen kommt
		year=${line#* }
		# rechts abtrennen was nach leerzeichen kommt
		year=${year%% *}
	
		no_date=${line#* }
		no_date=${no_date#* }
	
		# 2 mal alles vor leerzeichen und leerzeichen links loeschen
		match_data=${line#* }
		match_data=${match_data#* }
		#match_data=${match_data%
	
		#echo "$match_data"
	
		# sed -e 's@name1 (runden1) name2 (runden2)map <liga>@name1;name2;map;runden1:runden2@')
		#csv=$(echo "$match_data" | sed -e 's/\([a-zA-Z0-9.][a-zA-Z0-9. ]*\) \([:digit:][:digit:]*\) \([a-zA-Z0-9.][a-zA-Z0-9.]*\) \([:digit:][:digit:]*\)\([a-zA-Z0-9.][a-zA-Z0-9.]*\) *$/\1;\3;\5;\2:\4/')
	
		#echo "$csv"
	
		# delete all to right side after space and brace
		team1=${match_data%% (*}
	
		# delete all to right
		score1=${match_data%%)*}
		# delete to left
		score1=${score1#* (}
	
		# delete left side
		team2=${match_data#*) }
		# delete right side
		team2=${team2% (*}
	
		score2=${match_data%)*}
		score2=${score2##*(}
	
		map=${match_data##*)}
		map=${map%% *}
		
		# is there real data?
		if [ -z $day ]
		then
			continue
		fi
		#test=$(echo "$no_date" | sed -n -e 's/^\(*\)(\([0-9]\+\))\(*\)(\([[:digit:]]\))*$/\1 \2 \3 \4/')
		#echo "$test"
		# csv from the data my friend
		echo "$day"."$month"."$year","$team1","$team2","$map","$score1":"$score2" >> "$result_file"
	done < "$extracted_tmp"
	
	(( data_offset = data_offset + 50))
done

rm -f "$extracted_tmp"
rm -f "$tmp_file"

# do a diff on the new file with an old one
# print out the diff
# the diff will be all new stuff :)

new_stuff=$(diff "$result_file" "$last_file" | sed 's/^< //g' | sed '/^> /d')

echo "$new_stuff"

#rm "$last_file"

exit 0

