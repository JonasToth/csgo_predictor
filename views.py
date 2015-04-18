from django.shortcuts import render
from django.views.generic import ListView

from csgo_predictor.models import *


class TeamList(ListView):
	model = Team
