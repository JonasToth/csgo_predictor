#!/bin/bash

# this script will get all available bets from csgolounge
# its a little like matches_hltv.sh

trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

debug=true
base_url="http://csgolounge.com"

# get the html yeah
raw_html=$(curl -s -X GET "${base_url}")

# strip everything out, only the match data is needed
matches=$(echo "$raw_html" | sed -e '1,/<article class="standard" id="bets"/d' | sed -e '/<\/article>/,$d')

# debugging output
#echo "$matches"
#exit 0
# strip html to get the raw data, and analyze that
strip_span=$(echo "$matches" | sed -r -e 's/<span[^>]*>.*<\/span>//g')
strip_html=$(echo "$strip_span" | sed -e 's/<[^>]*>//g')

# strip whitespaces, strip delete "vs" line
strip_whitespace=$(echo "$strip_html" | sed -r -e 's/^\s+//g' | sed -r -e '/^\s*$/d' | sed -e '/vs/d')
# debugging output
#echo "$strip_whitespace"
#exit 0
# process the bets
# output til here is something like this:
# 2 hours ago LIVE
# 
#EML
#XPC40%
#neXtP60%
#
#12 hours from now  
#RGN Tournament
#TMP42%
#Winout58%

#exit 0
# put the stuff into one line
#one_lined=$(echo "$strip_whitespace" | sed -n -r -e 's/^([\w ]+)$^([\w ]+)$^([\w ]+)(\d+)\%$^([\w ]+)(\d+)\%$/\1,\2,\3,\4,\5,\6/p')
#testing=$(echo "$strip_whitespace" | sed -r -e 's/(^.*$)(^.*)/\1,\2/g')

#echo "$one_lined"

counter=0
#league=""
#time=""
#team1=""
#team2=""
#val1=0
#val2=0

#array=( "$strip_whitespace" )

while read line
do
	if [ "$debug" = true ]
	then
		echo Counter: "$counter"
		echo The Line: "$line"
	fi
	
	# its a time line
	# set the counter to the correct value, so the script doesnt mess up completly if something changes slidly?
	if [ "$line" == *"now"* ] || [ "$line" == *"ago"* ]
	then
		(( counter=0 ))
	fi

	if [ "$counter" -eq 0 ]
	then
		time="$line"
		#echo -n "$time",
		if [ "$debug" = true ]
		then
			echo "$time"
		fi
	
	elif [ "$counter" -eq 1 ]
	then
		league="$line"
		#echo -n "$league",
		if [ "$debug" = true ]
		then
			echo "$league"
		fi
	
	elif [ "$counter" -eq 2 ]
	then
		csv=$(echo "$line" | sed -r -e 's/([a-zA-Z\.!\?_'\'']+)(.*)%/\1;\2/g')
		team1=${csv%%;*} # cut right
		val1=${csv##*;}  # cut left
		#echo -n "$team1,$val1",
		if [ "$debug" = true ]
		then
			echo csv: "$csv"
			echo team1: "$team1" 
			echo val1: "$val1"
			
			echo testvars "$team2"
			echo testvars "$val2"
		fi
	
	elif [ "$counter" -eq 3 ]
	then
		csv=$(echo "$line" | sed -r -e 's/([a-zA-Z\.!\?_'\'']+)(.*)%/\1;\2/g')
		team2=${csv%%;*} # cut right
		val2=${csv##*;}  # cut left
		#echo -n "$team2,$val2"

		if [ "$debug" = true ]
		then
			echo csv: "$csv"
			echo team2: "$team2"
			echo val2: "$val2"
		
			echo
		fi
		# print as csv
		
		#echo "==$league=="
		#echo "==$time=="
		#echo "==$team1=="
		#echo "==$team2=="
		#echo "==$val1=="
		#echo "==$val2=="
		
		trim $league
		echo -n ","
		trim $time
		echo -n ","
		trim $team1
		echo -n ","
		trim $team2
		echo -n ","
		trim $val1
		echo -n ","
		trim $val2
		echo
		
		#printf "%s %s %s %s %s %s\n" "$league" "$time" "$team1" "$team2" "$val1" "$val2"
		#csv_line="$league,$time,$team1,$team2,$val1,$val2"
		#echo "$csv_line"
	else
		echo "FEHLER MY FRIEND"
		exit 2
	fi
	(( counter+=1 ))
	counter=$(( $counter % 4 ))
done <<< "$strip_whitespace"
