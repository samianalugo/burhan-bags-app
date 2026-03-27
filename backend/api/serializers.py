from rest_framework import serializers
from .models import Product, DailyProfit

class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = '__all__'


class DailyProfitSerializer(serializers.ModelSerializer):
    class Meta:
        model = DailyProfit
        fields = '__all__'
        