# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models

# Create your models here.

class User(models.Model):
    first_name = models.CharField(max_length=225)
    last_name = models.CharField(max_length=225)
    email = models.CharField(max_length=225)
    username = models.CharField(max_length=55)
    password = models.CharField(max_length=225)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.first_name + " " + self.last_name

class Item(models.Model):
    item_name = models.CharField(max_length=255)
    item_value = models.IntegerField()
    item_detail = models.CharField(max_length=255, null=True)
    owner = models.ForeignKey(User, related_name = "items", null=True)
    viewed_by = models.ManyToManyField(User, blank=True)
    image_URL = models.CharField(max_length=255, null=True)
    matched_items = models.ManyToManyField("self", through="ItemRelationship", symmetrical=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.item_name

class ItemRelationship(models.Model):
    item_wanted = models.ForeignKey(Item, related_name = "items_wanted", null=True)
    item_giving = models.ForeignKey(Item, related_name = "items_giving", null=True)
    match_made = models.BooleanField(default=False)

    class Meta:
         unique_together = ('item_wanted', 'item_giving')


# check if buying item is selling item and selling item is buying item, switch match to true. if not there, make new entry