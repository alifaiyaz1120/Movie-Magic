import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:movie_magic/Backend/backend.dart';
import 'package:movie_magic/Backend/google_signin_api.dart';
import 'package:movie_magic/login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final LocalStorage storage = LocalStorage('MovieApp.json');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF242A32),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.only(top: 100.0, left: 20, right: 20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Welcome!',
                      style: TextStyle(
                        color: Colors.white, // Set text color to white
                        fontSize: 24, // Set font size
                        fontWeight: FontWeight.bold, // Set font weight to bold
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Sign up for Movie Magic',
                      style: TextStyle(
                        color: Colors.white, // Set text color to white
                        fontSize: 18, // Set font size
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    _buildInputField('First Name', firstNameController),
                    const SizedBox(height: 20.0),
                    _buildInputField('Last Name', lastNameController),
                    const SizedBox(height: 20.0),
                    _buildInputField('Email', emailController),
                    const SizedBox(height: 20.0),
                    _buildInputField('Password', passwordController,
                        isSensitive: true),
                    const SizedBox(height: 20.0),
                    _buildInputField(
                        'Confirm Password', confirmPasswordController,
                        isSensitive: true, validator: (value) {
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    }),
                    const SizedBox(height: 20.0),
                    _buildSignUpButton(),
                    _buildGoogleSignUpButton(),
                  ],
                ),
              )),
        ));
  }

  Widget _buildInputField(String fieldName, TextEditingController controller,
      {bool isSensitive = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: fieldName,
        labelStyle: const TextStyle(color: Colors.white),
        border: const OutlineInputBorder(),
        fillColor: const Color(0xFF485360),
        filled: true,
      ),
      obscureText: isSensitive,
      validator: (value) {
        if (value != null && value.isEmpty) {
          return '$fieldName cannot be empty';
        }
        return validator?.call(value);
      },
    );
  }

  Widget _buildSignUpButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: () {
          if (!formKey.currentState!.validate()) {
            return;
          }
          String firstName = firstNameController.text;
          String lastName = lastNameController.text;
          String email = emailController.text;
          String password = passwordController.text;

          _registerUser(firstName, lastName, email, password);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1), // Set button background color to white
          foregroundColor:
              const Color(0xFF242A32), // Set button text color to #242A32
          minimumSize: const Size(215, 50),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            'Sign Up',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignUpButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisSize:
              MainAxisSize.min, // Set the mainAxisSize to min to center content
          children: [
            ElevatedButton.icon(
              onPressed: () {
                googleSignIn();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF242A32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 4,
              ),
              icon: Image.asset('assets/images/google_logo.png',
                  height: 30, width: 30),
              label: const Text(
                'Log in with your Google account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Function to add users to Postgres DB
  void _registerUser(
      String firstName, String lastName, String email, String password) async {
    try {
      final results = await createUser(firstName, lastName, email, password);

      if (results != false) {
        storage.setItem('userID', results);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future googleSignIn() async {
    final user = await GoogleSignInApi.login();

    String displayName = user?.displayName as String;
    String email = user?.email as String;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sign in Failed')));
    } else {
      final results = await GSignIn(email, displayName);
      if (results != false) {
        storage.setItem('userID', results);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    }
  }
}

void main() {
  runApp(const MaterialApp(
    home: SignupPage(),
  ));
}
