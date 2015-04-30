from django.contrib import admin
from csgo_predictor.models import *

admin.site.register(Team, TeamAdmin)
admin.site.register(Map, MapAdmin)
admin.site.register(Match, MatchAdmin)
