import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'title': 'Fisherman Painting',
      'description': 'Traditional Rajasthani miniature painting depicting a fisherman by the lake. Hand-painted with natural colors on handmade paper.',
      'price': 399,
      'category': 'Painting',
      'platforms': ['amazon', 'etsy', 'flipkart'],
      'images': ['assets/images/fisherman_painting.jpg'],
      'hasCertificate': true,
      'views': 145,
      'sales': 3,
    },
    {
      'id': '2',
      'title': 'Wooden Vase',
      'description': 'Handcrafted wooden vase with intricate carvings. Made from sustainably sourced mango wood.',
      'price': 599,
      'category': 'Handicraft',
      'platforms': ['flipkart', 'custom'],
      'images': ['assets/images/wooden_vase.jpg'],
      'hasCertificate': false,
      'views': 89,
      'sales': 1,
    }
  ];

  List<Map<String, dynamic>> get products => _products;

  void addProduct(Map<String, dynamic> product) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(String id, Map<String, dynamic> updatedProduct) {
    int index = _products.indexWhere((product) => product['id'] == id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((product) => product['id'] == id);
    notifyListeners();
  }

  double getTotalRevenue() {
    return _products.fold(0.0, (sum, product) => 
      sum + (product['price'] * product['sales']));
  }

  int getTotalSales() {
    return _products.fold(0, (sum, product) => sum + product['sales'] as int);
  }

  int getTotalViews() {
    return _products.fold(0, (sum, product) => sum + product['views'] as int);
  }
}