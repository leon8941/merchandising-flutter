import 'package:flutter/material.dart';
import 'Message.dart';

class MessageDetails extends StatelessWidget {
  final Message message;

  MessageDetails(
    {
      Key key, 
      @required this.message
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Message with ${message.senderName}"),
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
