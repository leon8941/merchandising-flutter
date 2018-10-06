import 'package:flutter/material.dart';
import 'User.dart';

class MessageDetails extends StatelessWidget {
  final User user;

  MessageDetails(
    {
      Key key, 
      @required this.user
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Message with ${user.senderName}"),
        centerTitle: true,
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            // Navigate back to first screen when tapped!
            Navigator.of(context).pop();
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}
