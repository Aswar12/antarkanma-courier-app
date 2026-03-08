import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:antarkanma_courier/app/data/models/chat_model.dart';
import 'package:antarkanma_courier/app/data/repositories/chat_repository.dart';
import 'package:antarkanma_courier/app/services/auth_service.dart';

class ChatListController extends GetxController {
  final ChatRepository _repository = ChatRepository();
  final AuthService _authService = Get.find<AuthService>();

  final chats = <ChatModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchChats();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> fetchChats() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      debugPrint('fetchChats: Fetching chat list...');
      final chatList = await _repository.getChatList();

      if (chatList != null) {
        debugPrint('fetchChats: Got ${chatList.length} chat(s)');

        // Fix recipient info for each chat
        final currentUserId = _authService.currentUser.value?.id;
        debugPrint('fetchChats: Current user ID: $currentUserId');

        final fixedChats = chatList.map((chat) {
          // If recipient is the current user, swap to show the other party
          if (chat.recipientId == currentUserId) {
            debugPrint(
                'fetchChats: Chat ${chat.id} - recipient is current user, need to swap');
            // This chat was created with wrong recipient, show the user who initiated
            // For now, use a placeholder name
            return ChatModel(
              id: chat.id,
              recipientId: chat.orderId ?? 0, // Use order ID as fallback
              recipientName: 'Customer', // Will be updated when opening chat
              recipientType: 'USER',
              orderId: chat.orderId,
              lastMessage: chat.lastMessage,
              lastMessageAt: chat.lastMessageAt,
              unreadCount: chat.unreadCount,
              recipientAvatar: chat.recipientAvatar,
            );
          }
          return chat;
        }).toList();

        chats.assignAll(fixedChats);
        debugPrint('fetchChats: Displaying ${fixedChats.length} chat(s)');
      } else {
        debugPrint('fetchChats: Chat list is null');
        chats.clear();
      }
    } catch (e) {
      debugPrint('fetchChats: Error: $e');
      errorMessage.value = 'Gagal memuat chat: ${e.toString()}';
      chats.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToChat(ChatModel chat) {
    // If recipient name is "Customer" or courier's own name, don't pass it
    // Let the chat page load the correct name from order
    final currentUserName = _authService.currentUser.value?.name;
    final shouldPassRecipientName = chat.recipientName != 'Customer' &&
        chat.recipientName != currentUserName;

    debugPrint(
        'navigateToChat: chat.id=${chat.id}, chat.orderId=${chat.orderId}');
    debugPrint('navigateToChat: chat.recipientName=${chat.recipientName}');
    debugPrint('navigateToChat: currentUserName=$currentUserName');
    debugPrint(
        'navigateToChat: shouldPassRecipientName=$shouldPassRecipientName');

    Get.toNamed('/chat/${chat.id}', arguments: {
      'chatId': chat.id,
      'orderId': chat.orderId, // ← PASTIKAN INI DIKIRIM!
      if (shouldPassRecipientName) 'recipientName': chat.recipientName,
    });
  }

  int getTotalUnreadCount() {
    return chats.fold(0, (sum, chat) => sum + (chat.unreadCount ?? 0));
  }

  Future<void> markAsRead(int chatId) async {
    try {
      await _repository.markChatAsRead(chatId);
      // Update local state
      final chatIndex = chats.indexWhere((c) => c.id == chatId);
      if (chatIndex != -1) {
        chats[chatIndex].unreadCount = 0;
        chats.refresh();
      }
    } catch (e) {
      debugPrint('Error marking chat as read: $e');
    }
  }

  @override
  Future<void> refresh() async {
    await fetchChats();
  }
}
