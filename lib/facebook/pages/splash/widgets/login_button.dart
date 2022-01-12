import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_notifications/facebook/widgets/rounded_button.dart';

import '../splash_controller.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashController>(
      builder: (_, controller, __) {
        final isLogged = controller.isLogged!;
        return RoundedButton(
          onPressed: () async {
            if (isLogged) {
              await controller.logout();
            } else {
              final isOk = await controller.login();
              if (!isOk) {
                final SnackBar snackBar = SnackBar(
                  content: Text(
                    "Login Cancelled",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.redAccent,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            }
          },
          fullWidth: false,
          backgroundColor: Color(0xff29434e),
          borderColor: Color(0xff29434e),
          label: isLogged ? "Log Out" : "Sign In with Facebook",
        );
      },
    );
  }
}