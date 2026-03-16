import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForgotnameScreen extends StatefulWidget {
  const ForgotnameScreen({super.key});

  @override
  State<ForgotnameScreen> createState() => _ForgotnameScreenState();
}

class _ForgotnameScreenState extends State<ForgotnameScreen> {
  String selectedCountryCode = '+94'; // Default country code
  bool showPhoneField = false; // Flag to show/hide phone field

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(''),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(226, 16, 37, 89),
                Color.fromARGB(255, 8, 11, 66)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Align(
            alignment: Alignment.center,
            child: ListView(
              shrinkWrap: true,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/microsoft_logo.png',
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Microsoft',
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                const Text(
                  'Recover your username',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                const Text(
                  'Enter an email might be associated with your Microsoft account. If it matches, we\'ll send you a code.',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Show email field only if phone is not visible
                if (!showPhoneField)
                  const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),

                if (showPhoneField) ...[
                  Row(
                    children: [
                      // Country code dropdown
                      DropdownButton<String>(
                        value: selectedCountryCode,
                        onChanged: (newCode) {
                          setState(() {
                            selectedCountryCode = newCode!;
                          });
                        },
                        items: <String>['+94', '+91', '+1', '+44']
                            .map((String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                      ),
                      const SizedBox(width: 8),
                      // Phone number field
                      const Expanded(
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Phone Number',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 2),

                Align(
                  alignment: Alignment.topLeft,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        showPhoneField = true;
                      });
                    },
                    child: const Text('Use phone number instead'),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 59, 96, 155),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
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
