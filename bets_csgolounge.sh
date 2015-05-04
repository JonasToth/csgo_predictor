#!/bin/bash

# this script will get all available bets from csgolounge
# its a little like matches_hltv.sh

trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

DEBUG=false
base_url="http://csgolounge.com"


##############################################
# command line argument fetching 
##############################################

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

done


#################### command line end #######

# get the html yeah
raw_html=$(curl -s -X GET "${base_url}")
#raw_html=$(cat 'csgolounge.html')

# strip everything out, only the match data is needed
matches=$(echo "$raw_html" | sed -n -e '/id="bets"/,/<\/article>/p')

if [ "$DEBUG" = true ]
then
	echo "$matches"
fi

# remove whitespace at beginning of line 
crop_whitespace=$(echo "$matches" | sed -r -e 's/^(\s+)(.*)$/\2/g')

# start from here my friend
# go throught the output line by line and parse the html for information
# u can get the match and some other variables and give them to output
# if the bet is still available ( bla bla from now )
# and if all values are given, no shit like faceit betting

if [ "$DEBUG" = true ]
then
	echo "$crop_whitespace"
fi

in_match=false
bet_possible=false
match_id=0
league=""
team1=""
score1=""
team2=""
score2=""
time=""

while IFS= read -r line
do
	# from here u start to get the information
	# if u are outside of this field its just bullshit
	# it will reset all data (see above the loop)
	if [[ "$line" == *"class=\"matchmain\""* ]]
	then
		if [ "$DEBUG" = true ]
		then
			echo "Start match"
		fi
		in_match=true
		bet_possible=false
		match_id=0
		league=""
		team1=""
		team2=""
		score1=""
		score2=""
		time=""
		continue
	fi
	# parse further or ignore it
	if [ "$in_match" = true ]
	then
		###############################################################################
		# find the time
		##############################################################################
		if [[ "$line" == *"class=\"whenm\""* ]]
		then
			time=$(echo "$line" | sed -e 's/<[^>]*>//g')
			if [ "$DEBUG" = true ]
			then
				echo "Found time: $time"
			fi
			if [[ "$time" == *"ago"* ]]
			then
				bet_possible=false
			else
				bet_possible=true
			fi
			continue
		fi

		##############################################################################
		# find the match id TODO
		#############################################################################
		if [[ "$line" == *"<a href=\"match?m="* ]]
		then
			match_id=$(echo "$line" | sed -r -e 's/.*m=([[:digit:]]+)".*/\1/g')

			if [ "$DEBUG" = true ]
			then
				echo "Found match_id $match_id"
			fi
			continue
		fi

		##############################################################################
		# find league or event
		##############################################################################
		if [[ "$line" == *"class=\"eventm\""* ]]
		then
			league=$(echo "$line" | sed -e 's/<[^>]*>//g')

			if [ "$DEBUG" = true ]
			then
				echo "Found league $league"
			fi
			continue
		fi

		#############################################################################
		# get the first team, this is only executed if the variables are empty
		# u cant distinguish between the two teams by html, so fill them one after 
		# another
		#############################################################################
		if [[ "$line" == *"class=\"teamtext\""* ]] && [[ -z "$team1" ]]
		then
			team1=$(echo "$line" | sed -r -e 's/.*<b>([^<]+)<\/b>.*/\1/g')
			score1=$(echo "$line" | sed -r -e 's/.*<i>([[:digit:]]+)%<\/i>.*/\1/g')

			if [ "$DEBUG" = true ]
			then
				echo "Found team1 $team1 with predict of $score1"
			fi
			continue

		elif [[ "$line" == *"class=\"teamtext\""* ]] && [[ -n "$team1" ]]
		then
			team2=$(echo "$line" | sed -r -e 's/.*<b>([^<]+)<\/b>.*/\1/g')
			score2=$(echo "$line" | sed -r -e 's/.*<i>([[:digit:]]+)%<\/i>.*/\1/g')

			if [ "$DEBUG" = true ]
			then
				echo "Found team2 $team2 with predict of $score2"
			fi 
			continue
		fi


		#########################################################################
		# check if iam finished with parsing and can output the data i found
		########################################################################
		if [ "$bet_possible" = true ] && [ -n "$team1" ] && [ -n "$team2" ] && [ -n "$league" ] && [ -n "$score1" ] && [ -n "$score2" ] && [ -n "$match_id" ] && [ -n "$time" ]
		then
			# this will give csv output
			trim "$team1"
			echo -n ","
			trim "$team2"
			echo -n ","
			trim "$score1"
			echo -n ","
			trim "$score2"
			echo -n ","
			trim "$league"
			echo -n ","
			trim "$time"
			echo -n ","
			trim "$match_id"
			echo
			
			in_match=false
			continue
		fi
	fi

done <<< "$crop_whitespace"

exit 0
