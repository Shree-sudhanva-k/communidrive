import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communidrive/src/detailspg.dart';
import 'package:communidrive/src/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhoneNo extends StatefulWidget {
  const PhoneNo({super.key});

  @override
  State<PhoneNo> createState() => _PhoneNoState();
}

class _PhoneNoState extends State<PhoneNo> {
  String phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
          child: ListView(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                width: 150,
                height: 150,
                child: Image.asset(
                  'assets/images/comunidrive.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 150),
                child: const Text(
                  "Hey!!! welcome to comunidrive experience the sharing",
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 150),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Login/Signup"),
                    const SizedBox(height: 8),
                    IntlPhoneField(
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '1234567890',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 255, 87, 52)),
                        ),
                      ),
                      initialCountryCode: 'IN',
                      onChanged: (phone) {
                        setState(() {
                          phoneNumber = phone.completeNumber;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SubmitButton(
                phoneNumber: phoneNumber,
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubmitButton extends StatefulWidget {
  final String phoneNumber;

  const SubmitButton({super.key, required this.phoneNumber});

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  bool isProcessing = false;
  void toggleprocess() {
    setState(() {
      isProcessing = !isProcessing;
    });
  }

  void sendOtp() async {
    if (widget.phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number cannot be empty")),
      );
      return;
    }

    toggleprocess();

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Handle successful automatic verification and sign-in
        },
        verificationFailed: (FirebaseAuthException ex) {
          // Handle verification failure
          print("Verification failed: ${ex.message}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification failed: ${ex.message}")),
          );
        },
        codeSent: (String verificationID, int? resendToken) {
          // Handle code sent
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return OTPVerificationDialog(
                varificationID: verificationID,
                phoneNumber: widget.phoneNumber,
                toggleprocess: toggleprocess,
              );
            },
          );
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          // Handle timeout
        },
      );
    } catch (e) {
      print(e);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OTPVerificationDialog(
          varificationID: "verificationID",
          phoneNumber: widget.phoneNumber,
          toggleprocess: toggleprocess,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isProcessing ? null : sendOtp,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 255, 87, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
      ),
      child: isProcessing
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : const Text("Send OTP"),
    );
  }
}

class OTPVerificationDialog extends StatefulWidget {
  final String varificationID;
  final Function toggleprocess;
  final String phoneNumber;

  const OTPVerificationDialog(
      {super.key,
      required this.varificationID,
      required this.phoneNumber,
      required this.toggleprocess});

  @override
  State<OTPVerificationDialog> createState() => _OTPVerificationDialogState();
}

class _OTPVerificationDialogState extends State<OTPVerificationDialog> {
  String _phoneno = '';

  late String otp;

  @override
  void initState() {
    _phoneno = widget.phoneNumber;

    super.initState();
  }

  void varifyUser() async {
    DocumentSnapshot userdoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_phoneno)
        .get();
    Widget nextPage;
    if (userdoc.exists) {
      nextPage = HomePage(phoneNumber: _phoneno);
    } else {
      nextPage = UserInputForm(phoneNumber: _phoneno);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => nextPage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: contentBox(context),
    );
  }

  contentBox(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: 400,
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    widget.toggleprocess();
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.close, color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Verify OTP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 4-digit OTP sent to your phone number-$_phoneno',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OtpTextField(
                numberOfFields: 6,
                borderColor: const Color(0xFF512DA8),
                showFieldAsBox: true,
                onCodeChanged: (String code) {
                  // Handle code changes
                },
                onSubmit: (String verificationCode) {
                  otp = verificationCode;
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Handle resend OTP
                },
                child: const Text('Resend OTP',
                    style: TextStyle(color: Colors.blue)),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  try {
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                            verificationId: widget.varificationID,
                            smsCode: otp);
                    FirebaseAuth.instance
                        .signInWithCredential(credential)
                        .then((value) async {
                      final SharedPreferences sharedPreference =
                          await SharedPreferences.getInstance();
                      sharedPreference.setString('PhoneNumber', _phoneno);
                      varifyUser();
                    });
                  } catch (ex) {
                    log(ex.toString() as num);
                  }
                },
                // onPressed: () async {
                //   final SharedPreferences sharedPreference =
                //       await SharedPreferences.getInstance();
                //   sharedPreference.setString('PhoneNumber', _phoneno);
                //   varifyUser();
                // },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 255, 87, 52), // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Border radius
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12), // Button padding
                ),
                child: const Text(
                  'Verify',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
