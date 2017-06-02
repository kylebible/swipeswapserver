# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render
from server.models import User, Item, ItemRelationship
from rest_framework import viewsets
from server.serializers import UserSerializer, ItemSerializer, ItemRelationshipSerializer
from django.db.models import Q


class UserViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows users to be viewed or edited.
    """
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get_queryset(self):
        queryset = User.objects.all()
        username = self.request.query_params.get('username', None)
        if username is not None:
            queryset = queryset.filter(username=username)
        return queryset


class ItemViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows groups to be viewed or edited.
    """
    queryset = Item.objects.all()
    serializer_class = ItemSerializer

    def get_queryset(self):
        queryset = Item.objects.all()
        owner = self.request.query_params.get('owner', None)
        notowner = self.request.query_params.get('owner_id', None)
        viewer = self.request.query_params.get('viewed_by', None)
        if owner is not None:
            queryset = queryset.filter(owner=owner)
        if viewer is not None:
            queryset = queryset.exclude(viewed_by=viewer)
        if notowner is not None:
            queryset = queryset.exclude(owner_id=notowner)
        return queryset

class ItemRelationshipViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows groups to be viewed or edited.
    """
    queryset = ItemRelationship.objects.all()
    serializer_class = ItemRelationshipSerializer

    def get_queryset(self):
        queryset = ItemRelationship.objects.all()
        item_wanted = self.request.query_params.get('item_wanted', None)
        item_giving = self.request.query_params.get('item_giving', None)
        item_wanted_owner = self.request.query_params.get('item_wanted__owner', None)
        item_giving_owner = self.request.query_params.get('item_giving__owner', None)
        if item_wanted is not None:
            queryset = queryset.filter(item_wanted=item_wanted,item_giving=item_giving)
        if item_wanted_owner is not None:
            queryset = queryset.filter(item_wanted__owner=item_wanted_owner,match_made=True) | queryset.filter(item_giving__owner=item_giving_owner,match_made=True)
        return queryset

# queryset.filter(match_made=True) & 
#if likeditem.owner.likeditem.owner = current user then match
