import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'stuhomescreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool passkey = true;

  Future<void> login() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final UserCredential userCredential =
          await auth.signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passController.text.trim());
      String? userId = userCredential.user?.uid;
      if (userId != null && userId.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        print('User not found');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/4820.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                const Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 70, 144, 152),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Email';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Color.fromARGB(255, 70, 144, 152)),
                      prefixIcon: Icon(Icons.email, color: Color.fromARGB(255, 70, 144, 152)),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 70, 144, 152),
                          width: 2,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Password';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Color.fromARGB(255, 70, 144, 152)),
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            passkey = !passkey;
                          });
                        },
                        child: Icon(
                          passkey ? Icons.visibility_off : Icons.visibility,
                          color: Color.fromARGB(255, 70, 144, 152),
                        ),
                      ),
                      prefixIcon: Icon(Icons.lock, color:Color.fromARGB(255, 70, 144, 152)),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 70, 144, 152),
                          width: 2,
                        ),
                      ),
                    ),
                    obscureText: passkey,
                    keyboardType: TextInputType.visiblePassword,
                    controller: _passController,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Add logic for "Forgot Password" here
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color:Color.fromARGB(255, 70, 144, 152),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: false, // Set your own value here
                              onChanged: (value) {
                                // Add logic for "Remember Me" here
                              },
                              checkColor: Color.fromARGB(255, 70, 144, 152),
                              activeColor: Color.fromARGB(255, 70, 144, 152),
                            ),
                            const Text(
                              'Remember Me',
                              style: TextStyle(
                                color: Color.fromARGB(255, 70, 144, 152),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(top: 90),
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          login();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 70, 144, 152),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign Up button
                TextButton(
                  onPressed: () {
                    // Navigate to the sign-up page (SignUpScreen)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: const Text(
                    'Don\'t have an account? Sign Up',
                    style: TextStyle(
                      color: Color.fromARGB(255, 70, 144, 152),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: LoginScreen(),
  ));
}
