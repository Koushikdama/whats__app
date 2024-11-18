// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatting_app/User_info/Controller/userController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: must_be_immutable
class PasswordScreen extends ConsumerStatefulWidget {
  String password;
  static const routeName = "/user-chat-lock-screen";
  PasswordScreen({
    Key? key,
    required this.password,
  }) : super(key: key);

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends ConsumerState<PasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _newPassword;
  String? _confirmPassword;
  bool _isOldPasswordVisible =
      false; // State variable for old password visibility
  bool _isNewPasswordVisible =
      false; // State variable for new password visibility
  bool _isConfirmPasswordVisible =
      false; // State variable for confirm password visibility
  void updatelock(WidgetRef ref, BuildContext context, String password) {
    ref
        .watch(authControllerProvider)
        .updatelock(context: context, password: password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              widget.password != ""
                  ? TextFormField(
                      decoration: InputDecoration(
                        labelText: 'OLD Password',
                        hintText: 'Enter old password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isOldPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isOldPasswordVisible = !_isOldPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_isOldPasswordVisible,
                      onChanged: (value) {
                        // You may want to save the old password if needed
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        // Add any additional validation for the old password here if needed
                        return null;
                      },
                    )
                  : const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter new password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isNewPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isNewPasswordVisible = !_isNewPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isNewPasswordVisible,
                onChanged: (value) {
                  _newPassword = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  // Check if password is at least 4 characters long
                  if (value.length < 4) {
                    return 'Password must be at least 4 characters';
                  }
                  // Regular expression to allow letters, numbers, and special characters
                  if (!RegExp(r'^[a-zA-Z0-9!@#$%^&*(),.?":{}|<>]+$')
                      .hasMatch(value)) {
                    return 'Password can only contain letters, numbers, and special characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter new password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isConfirmPasswordVisible,
                onChanged: (value) {
                  _confirmPassword = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  // Check if the password matches the new password
                  if (_newPassword != value) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Proceed with the password change
                    updatelock(ref, context, _newPassword!);
                  }
                },
                child: const Text('SET password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
