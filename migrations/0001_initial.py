# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Map',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('name', models.CharField(max_length=60)),
                ('ratio', models.FloatField()),
            ],
            options={
            },
            bases=(models.Model,),
        ),
        migrations.CreateModel(
            name='Match',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('score', models.CommaSeparatedIntegerField(max_length=50, blank=True)),
                ('date', models.DateField(null=True, blank=True)),
                ('map', models.ForeignKey(to='csgo_predictor.Map')),
            ],
            options={
            },
            bases=(models.Model,),
        ),
        migrations.CreateModel(
            name='Team',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('name', models.CharField(max_length=60)),
                ('nationality', models.CharField(max_length=60, null=True, blank=True)),
            ],
            options={
            },
            bases=(models.Model,),
        ),
        migrations.AddField(
            model_name='match',
            name='team1',
            field=models.ForeignKey(related_name=b'team1', to='csgo_predictor.Team'),
            preserve_default=True,
        ),
        migrations.AddField(
            model_name='match',
            name='team2',
            field=models.ForeignKey(related_name=b'team2', to='csgo_predictor.Team'),
            preserve_default=True,
        ),
    ]
