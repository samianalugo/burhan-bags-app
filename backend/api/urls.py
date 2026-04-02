from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ProductViewSet, DailyProfitViewSet
from .views import total_profit, sell_product, analytics
from .views import register, login

router = DefaultRouter()
router.register(r'products', ProductViewSet)
router.register(r'profits', DailyProfitViewSet)

urlpatterns = [
    #router endpoints
    path('', include(router.urls)),

    #custom endpoints
    path('profit/', total_profit),
    path('sales/', sell_product),
    path('analytics/', analytics),
    path('register/', register),
    path('login/', login),
]

