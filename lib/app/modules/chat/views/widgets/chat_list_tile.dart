import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:antarkanma_courier/theme.dart';
import 'package:antarkanma_courier/app/data/models/chat_model.dart';
import '../../controllers/chat_list_controller.dart';

class ChatListTile extends StatelessWidget {
  final ChatModel chat;

  const ChatListTile({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatListController>();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.width15,
        vertical: Dimensions.height5,
      ),
      padding: EdgeInsets.all(Dimensions.height12),
      decoration: BoxDecoration(
        color: backgroundColor1,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => controller.navigateToChat(chat),
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        child: Row(
          children: [
            // Avatar
            Container(
              width: Dimensions.width50,
              height: Dimensions.height50,
              decoration: BoxDecoration(
                color: logoColorSecondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(chat.recipientType),
                color: logoColorSecondary,
                size: Dimensions.font24,
              ),
            ),
            SizedBox(width: Dimensions.width12),

            // Chat Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.recipientName,
                          style: primaryTextStyle.copyWith(
                            fontSize: Dimensions.font14,
                            fontWeight: semiBold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: Dimensions.width8),
                      Text(
                        _formatTime(chat.lastMessageAt),
                        style: secondaryTextStyle.copyWith(
                          fontSize: Dimensions.font10,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage ?? 'No messages',
                          style: secondaryTextStyle.copyWith(
                            fontSize: Dimensions.font12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount != null &&
                          chat.unreadCount! > 0) ...[
                        SizedBox(width: Dimensions.width8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width6,
                            vertical: Dimensions.height2,
                          ),
                          decoration: BoxDecoration(
                            color: alertColor,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: Dimensions.width20,
                            minHeight: Dimensions.height20,
                          ),
                          child: Text(
                            chat.unreadCount! > 9
                                ? '9+'
                                : chat.unreadCount.toString(),
                            style: primaryTextStyle.copyWith(
                              fontSize: Dimensions.font10,
                              fontWeight: bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toUpperCase()) {
      case 'MERCHANT':
        return Icons.store;
      case 'COURIER':
        return Icons.delivery_dining;
      case 'USER':
        return Icons.person;
      default:
        return Icons.chat_bubble;
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';

    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return DateFormat('HH:mm').format(dateTime);
      } else if (difference.inDays == 1) {
        return 'Kemarin';
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE', 'id_ID').format(dateTime);
      } else {
        return DateFormat('dd/MM/yy').format(dateTime);
      }
    } catch (e) {
      return '';
    }
  }
}
