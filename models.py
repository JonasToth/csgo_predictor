from django.db import models
from django.contrib import admin
class Map (models.Model):
	name	= models.CharField(max_length = 60)
	ratio	= models.FloatField()
	
	def __unicode__(self):
		return self.name


class MapAdmin(admin.ModelAdmin):
	list_display	= ("name", "ratio")	
	search_fields 	= ("name", )
	ordering		= ("name", )

class Team(models.Model):
	name		= models.CharField(max_length = 60)
	nationality = models.CharField(max_length = 60, blank = True, null = True)
	
	def __unicode__(self):
		return self.name

class TeamAdmin(admin.ModelAdmin):
	list_display 	= ("name",)
	search_fields 	= ("name", )
	ordering		= ("name", )


class Match(models.Model):
	team1		= models.ForeignKey(Team, related_name = "team1")
	team2		= models.ForeignKey(Team, related_name = "team2")
	map			= models.ForeignKey(Map)
	score		= models.CommaSeparatedIntegerField(max_length = 50, blank = True)
	date		= models.DateField(blank = True, null = True)
	
	def __unicode__(self):
		return self.team1.name + ":" + self.team2.name + " " + self.score


class MatchAdmin(admin.ModelAdmin):
	list_display 	= ("team1", "team2", "map", "score", "date")
	search_fields 	= ("team1", "team2", "map", "date")
	list_filter 	= ("date", )
	ordering		= ("-date", )
