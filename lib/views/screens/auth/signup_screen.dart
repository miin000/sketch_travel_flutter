import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Thêm import Get
import '/constants.dart';
import '/controllers/auth_controller.dart';
import '/views/screens/auth/login_screen.dart';
import '/views/widgets/text_input_field.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  SignupScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SketchTravel', // Đổi tên app
                  style: TextStyle(
                      fontSize: 35, color: buttonColor, fontWeight: FontWeight.w900),
                ),
                const Text(
                  'Register',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                ),
                const SizedBox(
                  height: 25,
                ),
                Stack(
                  children: [
                    // Bọc CircleAvatar trong Obx để cập nhật UI
                    Obx(() {
                      return CircleAvatar(
                        radius: 64,
                        // Nếu đã chọn ảnh thì hiển thị, nếu không thì hiển thị ảnh mặc định
                        backgroundImage: authController.profilePhoto != null
                            ? FileImage(authController.profilePhoto!)
                            : const NetworkImage(
                            'https://t4.ftcdn.net/jpg/00/84/67/19/360_F_84671939_jxymoYZO8Oeacc3JRBDE8bSXBWj0ZfA9.jpg')
                        as ImageProvider,
                        backgroundColor: Colors.black,
                      );
                    }),
                    Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                          onPressed: () => authController.pickImage(),
                          icon: const Icon(Icons.add_a_photo),
                        ))
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: TextInputField(
                    controller: _usernameController,
                    labelText: 'Username',
                    icon: Icons.person,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: TextInputField(
                    controller: _emailController,
                    labelText: 'Email',
                    icon: Icons.email,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: TextInputField(
                    controller: _passwordController,
                    labelText: 'Password',
                    isObscure: true,
                    icon: Icons.lock,
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                  child: InkWell(
                    onTap: () => authController.registerUser(
                      _usernameController.text,
                      _emailController.text,
                      _passwordController.text,
                      authController.profilePhoto,
                    ),
                    child: const Center(
                      child: Text(
                        'Register',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(fontSize: 20),
                    ),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Text(
                        " Login", // Thêm khoảng trắng
                        style: TextStyle(fontSize: 20, color: buttonColor),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
