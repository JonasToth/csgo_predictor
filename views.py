from django.shortcuts import render
from django.views.generic import ListView

from csgo_predictor.models import *

from django.shortcuts import render, get_or_create
from django.views.generic import ListView

from datetime import datetime
from time import strptime

from django.http import HttpResponse

# script calling
import subprocess
from subprocess import call, check_output, Popen
import time
import os

from raspberrypi_control.settings import DEBUG


class TeamList(ListView):
	model = Team
	







# Create your views here.
class ChannelList(ListView):
	model = Channel
	
	
# fetch the data and write into the database
def fetch(request):
	# gets the data from hltv / matches (only the new ones, diff on .csv in the directory)
	csv_data = fetch_data()

	if DEBUG:
		print csv_data
	
	
	for line in csv_data:
		time_, team1_, team2_, map_, result_ = unpack_csv(line)
	
		# get references good for database
		team1, created_team1 	= Team.objects.get_or_create(name = team1_)
		team2, created_team2 	= Team.objects.get_or_create(name = team2_)
		map,   created_map		= Map.objects.get_or_create(name = map_, default = { "ratio" : 0.5 })
	
		m = Match(...)
		m.save()
	
		response+= str(m) + " added.\n"

	return HttpResponse(response)
		
		
def unpack_csv(csv_data):
	"""Helper function for fetch. It will parse the date from the api and
	return python objects with the data"""
	date_str, team1_str, team2_str, map_str, result_str = csv_data.split(',')
	
	return strptime(date_str, "%d.%m.%y"), team1_str, team2_str, map_str, result_str
	

def fetch_data():
	"""Wrapper for the shell-script call. It will fetch the data from twitch
	and return a csv or raise an exception (if twitch screwed)"""
	try:
		dir = os.path.dirname(os.path.realpath(__file__))
		
		p = check_output(['/bin/bash', os.path.join(dir, 'matches_hltv.sh')])
		
		if ",," not in p and "null" not in p:
			return p
	
	except subprocess.CalledProcessError as e:
		if e.returncode == 1:
			raise IOError("Script is used wrong!")
		elif e.returncode == 2:
			raise IOError("Twitch-Api returned bad values. Channel offline?")

