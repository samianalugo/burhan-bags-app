from rest_framework import viewsets
from .models import Product, DailyProfit, Sale
from .serializers import ProductSerializer, DailyProfitSerializer
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.db.models import Sum, F
from django.utils import timezone

@api_view(['GET'])
def analytics(request):
    try:
        total_products = Product.objects.count()
        total_sales = Sale.objects.aggregate(total=Sum('quantity'))['total'] or 0
        total_profit = Sale.objects.aggregate(total=Sum('profit'))['total'] or 0
        low_stock = Product.objects.filter(stock__lt=5).count()

        return Response({
            "total_products": total_products,
            "total_sales": total_sales,
            "total_profit": total_profit,
            "low_stock": low_stock
        })
    except Exception as e:
        return Response({"error": str(e)}, status=500)

@api_view(['POST'])
def sell_product(request):
    product_id = request.data.get('product')
    quantity = int(request.data.get('quantity'))

    try: 
        product = Product.objects.get(id=product_id)
    except Product.DoesNotExist:
        return Response({"error": "Product not found"}, status=404)

    if product.stock < quantity:
        return Response({"error": "Not enough stock"}, status=404)
    
    profit = (product.sell_price - product.cost_price) * quantity
    product.stock -= quantity
    product.save()

    Sale.objects.create(product=product, quantity=quantity, profit=profit)

    today = timezone.now().date()
    daily, _ = DailyProfit.objects.get_or_create(date=today, defaults={'profit': 0})
    daily.profit += profit
    daily.save()

    return Response({"message": "Sale recorded successfully", "profit": profit})

@api_view(['GET'])
def total_profit(request):
    total = Sale.objects.aggregate(total=Sum('profit'))['total'] or 0
    return Response({"total_profit": total})

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer


class DailyProfitViewSet(viewsets.ModelViewSet):
    queryset = DailyProfit.objects.all()
    serializer_class = DailyProfitSerializer