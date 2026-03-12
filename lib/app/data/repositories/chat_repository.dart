// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:antarkanma_courier/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:antarkanma_courier/app/data/models/chat_model.dart';
import 'package:antarkanma_courier/app/services/auth_service.dart';
import 'package:antarkanma_courier/config.dart';

class ChatRepository {
  final AuthService _authService = Get.find<AuthService>();
  final String baseUrl = Config.baseUrl;

  Future<List<ChatModel>?> getChatList() async {
    try {
      final token = _authService.getToken();
      if (token == null) {
        debugPrint('No auth token found');
        return null;
      }

      debugPrint('Fetching chat list from: ${Config.baseUrl}/chats');

      // Increased timeout for slow connections
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/chats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 60), // Increased from 45 to 60 seconds
        onTimeout: () {
          debugPrint('Request timeout - server not responding after 60s');
          throw Exception('Connection timeout - server terlalu lambat');
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint(
          'Response body preview: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}...');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final chatsList = data['data']['chats'] as List;
          debugPrint('Successfully fetched ${chatsList.length} chat(s)');
          return chatsList.map((chat) => ChatModel.fromJson(chat)).toList();
        } else {
          debugPrint('Unexpected response format: $data');
          return null;
        }
      } else if (response.statusCode == 401) {
        debugPrint('Unauthorized - token may be invalid');
        return null;
      } else if (response.statusCode == 404) {
        debugPrint('Endpoint not found - check API route');
        return null;
      } else {
        debugPrint('Server error: ${response.statusCode}');
        return null;
      }
    } on SocketException catch (e) {
      debugPrint('Network error: ${e.message}');
      debugPrint('Check if:');
      debugPrint('  1. Server is running (php artisan serve)');
      debugPrint('  2. Device has internet connection');
      debugPrint('  3. ADB reverse is set: adb reverse tcp:8000 tcp:8000');
      return null;
    } on HttpException catch (e) {
      debugPrint('HTTP error: ${e.message}');
      return null;
    } on FormatException catch (e) {
      debugPrint('JSON parse error: ${e.message}');
      debugPrint('Response may not be valid JSON');
      return null;
    } on TimeoutException catch (e) {
      debugPrint('Timeout error: ${e.message}');
      debugPrint('Server took too long to respond (>60s)');
      debugPrint('Try:');
      debugPrint('  1. Check backend performance');
      debugPrint('  2. Use faster network connection');
      return null;
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<Chat?> initiateChat(int orderId,
      {int? customerId, int? merchantId}) async {
    try {
      final token = _authService.getToken();
      if (token == null) return null;

      final Map<String, dynamic> body = {
        'order_id': orderId,
      };

      if (customerId != null) {
        body['recipient_id'] = customerId;
        body['recipient_type'] = 'USER';
      } else if (merchantId != null) {
        body['merchant_id'] = merchantId;
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/chat/initiate'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(Duration(seconds: Config.connectTimeout));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Chat.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error initiating chat: $e');
      return null;
    }
  }

  Future<Chat?> initiateChatWithOrder(int orderId) async {
    try {
      final token = _authService.getToken();
      if (token == null) {
        debugPrint('initiateChatWithOrder: No auth token');
        return null;
      }

      // Get current courier ID from auth service
      final courier = _authService.currentUser.value;
      int? courierId = courier?.courierId;

      // If courierId is not in user model, try to get it from courier profile
      if (courierId == null) {
        debugPrint(
            'initiateChatWithOrder: Courier ID not in user model, fetching from profile...');
        final courierProfile = await _getCourierProfile();
        courierId = courierProfile?['id'];

        if (courierId != null) {
          debugPrint(
              'initiateChatWithOrder: Got courier ID from profile: $courierId');
        } else {
          debugPrint(
              'initiateChatWithOrder: ERROR - Could not determine courier ID');
          debugPrint(
              'initiateChatWithOrder: Courier login should include courier_id in user.courier');
          Get.snackbar(
            'Error',
            'Courier ID tidak ditemukan. Silakan login ulang.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: alertColor.withOpacity(0.8),
            colorText: Colors.white,
          );
          return null;
        }
      }

      debugPrint(
          'initiateChatWithOrder: Initiating chat with order_id: $orderId, courier_id: $courierId');
      debugPrint('initiateChatWithOrder: URL: ${Config.baseUrl}/chat/initiate');

      final response = await http
          .post(
        Uri.parse('$baseUrl/chat/initiate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'order_id': orderId,
          'courier_id': courierId,
        }),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('initiateChatWithOrder: Request timeout after 10 seconds');
          throw Exception('Request timeout - server tidak merespon');
        },
      );

      debugPrint(
          'initiateChatWithOrder: Response status: ${response.statusCode}');
      debugPrint('initiateChatWithOrder: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          debugPrint(
              'initiateChatWithOrder: SUCCESS - Chat ID: ${data['data']['id']}');
          return Chat.fromJson(data['data']);
        } else {
          debugPrint('initiateChatWithOrder: Response not successful - $data');
        }
      } else {
        debugPrint(
            'initiateChatWithOrder: Failed with status: ${response.statusCode}');
        debugPrint('initiateChatWithOrder: Error response: ${response.body}');
      }
      return null;
    } catch (e) {
      debugPrint('initiateChatWithOrder: Exception caught: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getCourierProfile() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        debugPrint('_getCourierProfile: No auth token');
        return null;
      }

      debugPrint(
          '_getCourierProfile: Fetching from ${Config.baseUrl}/courier/profile');

      final response = await http.get(
        Uri.parse('$baseUrl/courier/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('_getCourierProfile: Response status: ${response.statusCode}');
      debugPrint('_getCourierProfile: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          debugPrint(
              '_getCourierProfile: SUCCESS - Courier ID: ${data['data']['id']}');
          return data['data'];
        } else {
          debugPrint('_getCourierProfile: Response not successful - $data');
        }
      } else if (response.statusCode == 404) {
        debugPrint('_getCourierProfile: Endpoint not found (404)');
      } else if (response.statusCode == 401) {
        debugPrint('_getCourierProfile: Unauthorized (401)');
      }
      return null;
    } catch (e) {
      debugPrint('_getCourierProfile: Exception caught: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getChatDetails(int chatId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/chat/$chatId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: Config.connectTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final chatData = data['data'];
          return {
            'recipientId': chatData['recipient_id'] ?? 0,
            'recipientName': chatData['recipient_name'] ?? 'Chat',
            'recipientType': chatData['recipient_type'] ?? '',
            'recipientAvatar': chatData['recipient_avatar'] ?? '',
            'status': chatData['status'] ?? 'ACTIVE',
          };
        }
      }
      return null;
    } catch (e) {
      debugPrint('getChatDetails: Exception caught: $e');
      return null;
    }
  }

  Future<ChatMessage?> sendMessage(int chatId,
      {String? message, File? image}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      // Handle image upload via multipart
      if (image != null) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/chat/$chatId/send'),
        );
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Accept'] = 'application/json';

        // Add image file
        var imageFile = await http.MultipartFile.fromPath(
          'attachment',
          image.path,
        );
        request.files.add(imageFile);

        // Add optional message
        if (message != null && message.isNotEmpty) {
          request.fields['message'] = message;
        }

        var streamedResponse = await request.send().timeout(
              Duration(seconds: Config.connectTimeout),
            );
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['data'] != null) {
            return ChatMessage.fromJson(data['data']);
          }
        }
        return null;
      }

      // Handle text message
      if (message != null) {
        final response = await http
            .post(
              Uri.parse('$baseUrl/chat/$chatId/send'),
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'message': message,
              }),
            )
            .timeout(Duration(seconds: Config.connectTimeout));

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['data'] != null) {
            return ChatMessage.fromJson(data['data']);
          }
        }
      }
      return null;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  Future<PaginatedMessages?> getMessages(
    int chatId, {
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final uri = Uri.parse('$baseUrl/chat/$chatId/messages').replace(
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );

      debugPrint('getMessages: Fetching page $page with $perPage per page');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: Config.connectTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true &&
            data['data'] != null &&
            data['data']['messages'] != null) {
          final messagesList = data['data']['messages'] as List;
          final messages =
              messagesList.map((m) => ChatMessage.fromJson(m)).toList();

          debugPrint(
              'getMessages: Fetched ${messages.length} messages (page $page)');

          return PaginatedMessages(
            messages: messages,
            currentPage: data['data']['current_page'] ?? 1,
            lastPage: data['data']['last_page'] ?? 1,
            total: data['data']['total'] ?? 0,
            perPage: data['data']['per_page'] ?? perPage,
            hasMorePages:
                data['data']['current_page'] < data['data']['last_page'],
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      return null;
    }
  }

  Future<void> markChatAsRead(int chatId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;

      await http.put(
        Uri.parse('$baseUrl/chat/$chatId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: Config.connectTimeout));
    } catch (e) {
      print('Error marking chat as read: $e');
    }
  }

  Future<Map<String, dynamic>?> getOrderData(int orderId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        debugPrint('getOrderData: No auth token');
        return null;
      }

      debugPrint(
          'getOrderData: Fetching order $orderId from ${Config.baseUrl}/orders/$orderId');

      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: Config.connectTimeout));

      debugPrint('getOrderData: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('getOrderData: Full response: $data');

        // Handle different response structures
        Map<String, dynamic>? orderData;

        if (data['data'] != null) {
          orderData = data['data'];
        } else if (data['success'] == true) {
          orderData = data;
        } else {
          orderData = data;
        }

        if (orderData != null) {
          // Try multiple paths to get customer info
          Map<String, dynamic>? customerInfo;

          if (orderData['customer'] != null &&
              orderData['customer'] is Map<String, dynamic>) {
            customerInfo = orderData['customer'] as Map<String, dynamic>;
          } else if (orderData['user'] != null &&
              orderData['user'] is Map<String, dynamic>) {
            customerInfo = orderData['user'] as Map<String, dynamic>;
          }

          if (customerInfo != null) {
            debugPrint('getOrderData: Customer info found: $customerInfo');
            return {
              'customerId': customerInfo['id'] ?? orderData['user_id'],
              'customerName': customerInfo['name'] ?? 'Customer',
              'customerAvatar':
                  customerInfo['profile_photo_path'] ?? customerInfo['photo'],
              'customerPhone':
                  customerInfo['phone_number'] ?? customerInfo['phone'],
            };
          } else {
            debugPrint('getOrderData: No customer info found in response');
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('getOrderData: Exception caught: $e');
      return null;
    }
  }

  Future<ChatMessage?> shareLocation(
    int chatId, {
    required double latitude,
    required double longitude,
    required double locationAccuracy,
    required String message,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        debugPrint('shareLocation: No auth token');
        return null;
      }

      debugPrint(
          'shareLocation: Sharing location to chat $chatId - Lat: $latitude, Lng: $longitude');

      final response = await http
          .post(
        Uri.parse('$baseUrl/chat/$chatId/share-location'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'latitude': latitude,
          'longitude': longitude,
          'location_accuracy': locationAccuracy,
          'message': message,
        }),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('shareLocation: Request timeout after 15 seconds');
          throw Exception('Request timeout - server tidak merespon');
        },
      );

      debugPrint('shareLocation: Response status: ${response.statusCode}');
      debugPrint('shareLocation: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          debugPrint(
              'shareLocation: SUCCESS - Location message sent: ${data['data']['id']}');
          return ChatMessage.fromJson(data['data']);
        } else {
          debugPrint('shareLocation: Response not successful - $data');
        }
      } else {
        debugPrint('shareLocation: Failed with status: ${response.statusCode}');
        debugPrint('shareLocation: Error response: ${response.body}');
      }
      return null;
    } catch (e) {
      debugPrint('shareLocation: Exception caught: $e');
      return null;
    }
  }
}
