import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';

class UserListItem extends StatelessWidget {
  final User user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserListItem({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildAvatar(),
        title: Text(
          user.username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email),
            const SizedBox(height: 2),
            Text(
              '••••••••',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildAvatar() {
    if (user.imageUrl != null && user.imageUrl!.isNotEmpty) {
      if (kIsWeb || user.imageUrl!.startsWith('http')) {
        return CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(user.imageUrl!),
          onBackgroundImageError: (exception, stackTrace) {},
          child: Container(), // Empty container to show error icon
        );
      } else {
        return CircleAvatar(
          radius: 30,
          backgroundImage: FileImage(File(user.imageUrl!)),
          onBackgroundImageError: (exception, stackTrace) {},
        );
      }
    }

    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.grey[300],
      child: Text(
        user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}

