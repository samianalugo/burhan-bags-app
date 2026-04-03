from django.db import models
from django.contrib.auth.models import AbstractUser


class User(AbstractUser):
    username = None
    email = models.EmailField(unique=True)
    tel_number = models.CharField(max_length=20, blank=True, default='')

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

class Product(models.Model):
    name = models.CharField(max_length=200)
    stock = models.IntegerField()
    cost_price = models.FloatField()
    sell_price = models.FloatField()

    def __str__(self):
        return self.name

class Sale(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.IntegerField()
    profit = models.FloatField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.product.name} - {self.quantity}"

class DailyProfit(models.Model):
    date = models.DateField(unique=True)
    profit = models.FloatField(default=0)

    def __str__(self):
        return f"{self.date} - {self.profit}"
        