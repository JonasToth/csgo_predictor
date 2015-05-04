#!/bin/bash


usage() {
	echo "Help for the bash script for fetching matchdata from"
	echo "hltv.org."
	echo
	echo "This script basically gets a given number of the latestet"
	echo "matches, which will then be compared to a previous fetch"
	echo "of that data. It prints the difference of these two data"
	echo "sets(only new Matches)"
	echo "It's intended use is for automating betting ;)"
	echo
	echo
	echo "--start_offset 	Number of offset to begin with(default = 0)"
	echo "--max_offset 		Number of maximum data (default = 100)"
	echo "--debug			Goes into Debugmode, additional information given."
	
}

# this script will aggregate data from http://www.hltv.org/?pageid=188&gameid=2
# parse it and print it on stdout as csv
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
last_file="$DIR/last.csv"

# checking if u can save the current fetch for a diff call on next fetch
if [ ! -f "$last_file" ]
then
	t=$(touch "$last_file")

	# could not create the file for saving the last fetched data
	if [ -n "$t" ]
	then
		echo "Could not create file for saving last data!"
		exit 1
	fi
fi

DEBUG=false

base_url="http://www.hltv.org/?pageid=188&offset="
# fetch the last 150 matches, this script should be called at least on a daily base
# so this will cover all new matches
data_offset=0
max_offset=100


# --------------------------------------------------------------------

if [ "$DEBUG" = true ]
then
	echo "Parsing command line..."
fi

while [ -n "$1" ]
do
	if [ "$DEBUG" = true ]
	then
		echo "$1"
	fi
	[ "$1" = "--debug" ] && DEBUG=true && shift && continue
	[ "$1" = "--start_offset" ] && data_offset="$2" && shift && shift && continue
	[ "$1" = "--max_offset" ] && max_offset="$2" && shift && shift && continue

done

# initialisation end
# --------------------------------------------------------------------



# class="covMainBoxContent" is the parent container for the relevant data
# save the result in tmp directory for further processing
# the result is from the current fetch. this will then be copied to a local file
# for comparison
result_file="/tmp/data_fetch_hltv.csv"

# clear the result file, otherwise it gets a big mess on bad circumstances
$(rm -f "$result_file")

while [ "$data_offset" -le "$max_offset" ]
do
	raw_html=$(curl -s -X GET "${base_url}${data_offset}")

	# sed read the tmp_file and crop of all unneeded stuff
	crop=$(echo "$raw_html" | sed -e '0,/http:\/\/static.hltv.org\/\/images\/dots.gif/d')
	crop=$(echo "$crop"		| sed -e '/class="covMainBox covMainBoxFooter"/,$d')
	
	if [ "$DEBUG" = true ]
	then
		echo "$crop"
		echo 
	fi


	clear_tags=$(echo "$crop" | sed -e 's/<[^>]*>//g')
	if [ "$DEBUG" = true ]
	then
		echo "$clear_tags"
		echo 
	fi
	# remove tabs
	# show only lines with a number (no empty lines)
	# numbers have to be in the result lines!
	clear_whitespace=$(echo "$clear_tags" | sed -e 's/\t//g' | sed -n -e '/[0-9]/p')
	
	# from here on the data is in prepared for processing
	raw_data="$clear_whitespace"
	if [ "$DEBUG" = true ]
	then
		echo "$clear_whitespace"
		echo
	fi
	
	while IFS= read -r line
	do
		if [ "$DEBUG" = true ]
		then
			echo "$line"
		fi
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
		if [ -z "$day" ]
		then
			continue
		fi
		#test=$(echo "$no_date" | sed -n -e 's/^\(*\)(\([0-9]\+\))\(*\)(\([[:digit:]]\))*$/\1 \2 \3 \4/')
		#echo "$test"
		# csv from the data my friend
		echo "$day"."$month"."$year","$team1","$team2","$map","$score1":"$score2" >> "$result_file"
	done <<< "$raw_data"
	
	(( data_offset = data_offset + 50))
done

# do a diff on the new file with an old one
# print out the diff
# the diff will be all new stuff :)

if [ -f "$last_file" ]
then
	new_stuff=$(diff "$result_file" "$last_file" | sed 's/^< //g' | sed '/^> /d' | sed -e '/^\w\w*,\w\w*$/d')
else
	new_stuff=$(cat "$result_file")
fi

# copy the result file to last.csv file
$(cp "$result_file" "$last_file")
echo "$new_stuff"

exit 0
