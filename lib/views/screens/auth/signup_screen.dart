import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/controllers/auth_controller.dart';
import '/views/screens/auth/login_screen.dart';
import 'package:sketch_travel/views/widgets/text_input_field.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({Key? key}) : super(key: key);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Register for App',
                style: TextStyle(
                  fontSize: 35,
                  color: buttonColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 25),
              Obx(() { // <-- Dùng Obx để lắng nghe thay đổi
                return Stack(
                  children: [
                    // === SỬA LỖI HIỂN THỊ ẢNH ===
                    authController.profilePhoto != null
                        ? CircleAvatar(
                      radius: 64,
                      // Dùng MemoryImage thay vì FileImage
                      backgroundImage: MemoryImage(authController.profilePhoto!),
                      backgroundColor: Colors.grey[300],
                    )
                        : CircleAvatar(
                      radius: 64,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, size: 80, color: Colors.white),
                    ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: () => authController.pickImage(),
                        icon: const Icon(Icons.add_a_photo),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 25),
              TextInputField(
                controller: _usernameController,
                labelText: 'Tên đầy đủ',
                icon: Icons.person,
              ),
              const SizedBox(height: 25),
              TextInputField(
                controller: _emailController,
                labelText: 'Email',
                icon: Icons.email,
              ),
              const SizedBox(height: 25),
              TextInputField(
                controller: _passwordController,
                labelText: 'Password',
                icon: Icons.lock,
                isObscure: true,
              ),
              const SizedBox(height: 30),
              Container(
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: InkWell(
                  onTap: () => authController.registerUser(
                    _usernameController.text.trim(),
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                    authController.profilePhoto, // <-- Truyền Uint8List (bytes)
                  ),
                  child: const Center(
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(fontSize: 16),
                  ),
                  InkWell(
                    onTap: () => Get.to(() => LoginScreen()),
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 18, color: buttonColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}