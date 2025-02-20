class CartItemModel {
  final int quantity;
  final double price;
  final CartProductInfo product;
  final CartMerchantInfo merchant;

  CartItemModel({
    required this.quantity,
    required this.price,
    required this.product,
    required this.merchant,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      product: CartProductInfo.fromJson(json['product'] ?? {}),
      merchant: CartMerchantInfo.fromJson(json['merchant'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'price': price,
      'product': product.toJson(),
      'merchant': merchant.toJson(),
    };
  }
}

class CartProductInfo {
  final int? id;
  final String name;
  final String description;
  final double price;
  final List<String> imageUrls;
  final CartCategoryInfo? category;

  CartProductInfo({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrls,
    this.category,
  });

  factory CartProductInfo.fromJson(Map<String, dynamic> json) {
    return CartProductInfo(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrls: List<String>.from(json['galleries'] ?? []),
      category: json['category'] != null
          ? CartCategoryInfo.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'galleries': imageUrls,
      'category': category?.toJson(),
    };
  }
}

class CartCategoryInfo {
  final int? id;
  final String name;

  CartCategoryInfo({
    this.id,
    required this.name,
  });

  factory CartCategoryInfo.fromJson(Map<String, dynamic> json) {
    return CartCategoryInfo(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class CartMerchantInfo {
  final int? id;
  final String name;
  final String address;
  final String phoneNumber;

  CartMerchantInfo({
    this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
  });

  factory CartMerchantInfo.fromJson(Map<String, dynamic> json) {
    return CartMerchantInfo(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone_number': phoneNumber,
    };
  }
}
