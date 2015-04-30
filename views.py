from django.shortcuts import render
from django.views.generic import ListView

from csgo_predictor.models import *

from django.shortcuts import render
from django.views.generic import ListView

from datetime import datetime
from time import strptime, mktime

from django.http import HttpResponse

# script calling
import subprocess
from subprocess import call, check_output, Popen
import time
import os

from raspberrypi_control.settings import DEBUG


class TeamList(ListView):
	model = Team
	






# fetch the data and write into the database
def fetch(request):
	# gets the data from hltv / matches (only the new ones, diff on .csv in the directory)
	csv_data = fetch_data()

	if DEBUG:
		print csv_data
	
	response = HttpResponse()
	
	response.write("<pre>" + csv_data + "</pre>")
	
	for line in csv_data.split('\n'):
		#print line
		try:
			time_, team1_, team2_, map_, result_ = unpack_csv(line)
		except ValueError:
			continue
	
		# get references good for database
		team1, created_team1 	= Team.objects.get_or_create(name = team1_)
		team2, created_team2 	= Team.objects.get_or_create(name = team2_)
		map,   created_map		= Map.objects.get_or_create(name = map_, defaults = { "ratio" : 0.5, })
		time = datetime.fromtimestamp(mktime(time_))
		
		r = result_.split(':')
		result = list()
		result.append(int(r[0]))
		result.append(int(r[1]))
		
		if DEBUG:
			print time
			print team1
			print team2
			print map
			print result
			print time
		
		m = Match(team1 = team1, team2 = team2, map = map, date = time, score = result)
		m.save()

	return HttpResponse(response)
		
		
def unpack_csv(csv_data):
	"""Helper function for fetch. It will parse the date from the api and
	return python objects with the data"""
	#print csv_data
	
	date_str, team1_str, team2_str, map_str, result_str = csv_data.split(',')
	
	if DEBUG:
		print date_str
		print team1_str
		print team2_str
		print map_str
		print result_str
	
	return strptime(date_str, "%d.%m.%y"), team1_str, team2_str, map_str, result_str
	

def fetch_data():
	"""Wrapper for the shell-script call. It will fetch the data from twitch
	and return a csv or raise an exception (if twitch screwed)"""
	try:
		dir = os.path.dirname(os.path.realpath(__file__))
		
		p = check_output(['/bin/bash', os.path.join(dir, 'matches_hltv.sh')])
		
		#print p
		return p
	
	except subprocess.CalledProcessError as e:
		if e.returncode == 1:
			raise IOError("Script is used wrong!")
		elif e.returncode == 2:
			raise IOError("Twitch-Api returned bad values. Channel offline?")

