import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/user.dart';
import '../bloc/user_bloc.dart';
import '../../../../core/utils/cloudinary_uploader.dart';
import '../../../../core/services/auth_service.dart';
import 'login_page.dart';
class UserFormPage extends StatefulWidget {
  final User? user;

  const UserFormPage({super.key, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _selectedImagePath;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _usernameController.text = widget.user!.username;
      _emailController.text = widget.user!.email;
      // Don't set password - it's hashed in DB and we don't want to show it
      _selectedImagePath = widget.user!.imageUrl;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String? finalImageUrl = _selectedImagePath;

      // Upload to Cloudinary if local path
      if (_selectedImagePath != null && !_selectedImagePath!.startsWith('http') && !kIsWeb) {
        try {
          finalImageUrl = await CloudinaryUploader.uploadImage(filePath: _selectedImagePath!);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Image upload failed: $e')),
            );
          }
        }
      }

      // If editing and password is empty, keep the old password
      final password = widget.user != null && _passwordController.text.isEmpty
          ? widget.user!.password
          : _passwordController.text;

      final user = User(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: password,
        imageUrl: finalImageUrl,
      );

      if (widget.user != null) {
        context.read<UserBloc>().add(UpdateUserEvent(user));
      } else {
        context.read<UserBloc>().add(CreateUserEvent(user));
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit User' : 'Add New User'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker Section
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    ),
                    child: _selectedImagePath != null
                        ? ClipOval(
                            child: _buildImage(),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade600),
                              const SizedBox(height: 8),
                              Text(
                                'Add Photo',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Username Field
              TextFormField(
                controller: _usernameController,
                enabled: !isEditing, // Disable when editing (username is primary key)
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                  helperText: isEditing ? 'Username cannot be changed' : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a username';
                  }
                  if (value.trim().length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an email';
                  }
                  final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  helperText: isEditing ? 'Leave blank to keep current password' : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  // When editing, password can be empty (keep old password)
                  if (!isEditing && (value == null || value.isEmpty)) {
                    return 'Please enter a password';
                  }
                  // If password is provided, validate length
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: () async { await _submitForm(); },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isEditing ? 'Update User' : 'Create User',
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              // Delete Account Button (only for users editing their own account)
              if (isEditing && AuthService().canDelete(widget.user!.username)) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => _showDeleteAccountConfirmation(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text(
                    'Delete Account',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account?\n\n'
          'This action cannot be undone and you will be logged out immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final username = widget.user!.username;
              context.read<UserBloc>().add(DeleteUserEvent(username));

              // Logout and redirect to login
              AuthService().logout();

              // Close dialog
              Navigator.pop(dialogContext);
              // Close form page
              Navigator.pop(context);
              // Navigate to login page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (_selectedImagePath == null) {
      return const SizedBox();
    }

    // For web or network images
    if (kIsWeb || _selectedImagePath!.startsWith('http')) {
      return Image.network(
        _selectedImagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error, size: 40, color: Colors.red);
        },
      );
    }

    // For local files (mobile/desktop only)
    // On web, XFile.path returns a blob URL which can be used with Image.network
    if (kIsWeb) {
      return Image.network(
        _selectedImagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error, size: 40, color: Colors.red);
        },
      );
    }

    return Image.file(
      File(_selectedImagePath!),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.error, size: 40, color: Colors.red);
      },
    );
  }
}

