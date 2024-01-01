import 'package:flutter/material.dart';
import 'package:movie_magic/login_page.dart';
import 'package:movie_magic/signup_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242A32),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/MovieWiz.png'),
            ),
            // Replace with your image path
            const SizedBox(height: 70), // Add some spacing
            const Text(
              'Movie Magic', // Replace with your desired title
              style: TextStyle(
                fontSize: 40, // Adjust the font size as needed
                color: Colors.white, // Text color
              ),
            ),
            const Text(
              'Search and Browse Movies', // Replace with your desired title
              style: TextStyle(
                fontSize: 16, // Adjust the font size as needed
                color: Colors.white, // Text color
              ),
            ),
            const SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: double.infinity,
                height: 60, // Make the button take up full width
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)))),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: const Text(
                    'Log In',
                    style: TextStyle(fontSize: 24, color: Color(0xFF242A32)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: double.infinity,
                height: 60, // Make the button take up full width
                child: OutlinedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0x00242a32)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)))),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
