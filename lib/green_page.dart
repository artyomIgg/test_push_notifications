import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GreenPage extends StatelessWidget {
  const GreenPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RedPage', style: TextStyle(color: Colors.green),),
      ),
    );
  }
}
