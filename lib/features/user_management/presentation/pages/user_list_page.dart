import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user_bloc.dart';
import '../widgets/user_list_item.dart';
import 'user_form_page.dart';
import 'login_page.dart';
import '../../../../core/services/auth_service.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final isAdmin = authService.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('User Management'),
            Text(
              isAdmin ? '👑 Admin' : '👤 ${authService.getDisplayName()}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserInitial || state is LoginSuccess) {
            context.read<UserBloc>().add(LoadUsersEvent());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserBloc>().add(LoadUsersEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is UsersLoaded) {
            // Filter users based on permission
            final displayUsers = isAdmin
                ? state.users
                : state.users.where((u) => u.username == authService.currentUser?.username).toList();

            if (displayUsers.isEmpty) {
              return Center(
                child: Text(
                  isAdmin
                      ? 'No users found. Add a new user to get started.'
                      : 'Your account information is not available.',
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<UserBloc>().add(LoadUsersEvent());
              },
              child: ListView.builder(
                itemCount: displayUsers.length,
                itemBuilder: (context, index) {
                  final user = displayUsers[index];
                  final canEdit = authService.canEdit(user.username);
                  final canDelete = authService.canDelete(user.username);

                  return UserListItem(
                    user: user,
                    onEdit: canEdit ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserFormPage(user: user),
                        ),
                      );
                    } : null,
                    onDelete: canDelete ? () {
                      _showDeleteConfirmation(context, user.username);
                    } : null,
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: isAdmin ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ) : null,
    );
  }

  void _showDeleteConfirmation(BuildContext context, String username) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete user "$username"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<UserBloc>().add(DeleteUserEvent(username));
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear auth session
              AuthService().logout();

              Navigator.pop(dialogContext);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

