#!/usr/bin/env python
#-*- coding:utf-8 -*-

from django.conf.urls import patterns, url, include
from django.views.generic.edit import UpdateView

from csgo_predictor.views import *
from django.contrib.auth.decorators import login_required, permission_required

"""
	URLconf für twitch_stat app
"""

urlpatterns = patterns('csgo_predictor.views',
	url('^$', TeamList.as_view()),
	url('^fetch/$', fetch),
)
