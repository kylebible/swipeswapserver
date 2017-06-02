from server.models import User, Item, ItemRelationship
from rest_framework import serializers


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id','first_name','last_name','email','username','password')


class ItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = Item
        fields = ('id','item_name', 'item_detail', 'item_value', 'image_URL', 'owner', 'viewed_by')

class ItemRelationshipSerializer(serializers.ModelSerializer):
    class Meta:
        model = ItemRelationship
        fields = ('id','item_wanted', 'item_giving', 'match_made')
    def to_representation(self, instance):
        representation = super(ItemRelationshipSerializer, self).to_representation(instance)
        # print(FollowingSerializer(instance.following.all(), many=True).data)
        representation['item_wanted'] = ItemSerializer(instance.item_wanted).data
        representation['item_giving'] = ItemSerializer(instance.item_giving).data
        return representation
    
