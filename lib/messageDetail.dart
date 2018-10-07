import 'package:flutter/material.dart';
import 'User.dart';
import 'dart:async';
import 'const.dart';
import 'Message.dart';

final currentUser = "cat";

class MessageDetails extends StatelessWidget {
  final User peerUser;

  MessageDetails(
    {
      Key key, 
      @required this.peerUser
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats with ${peerUser.senderName}"),
        centerTitle: true,
      ),
      body: new ChatScreen(
        peerUser: peerUser
      )
    );
  }
}

class ChatScreen extends StatefulWidget {
  final User peerUser;

  ChatScreen(
    {
      Key key, 
      @required this.peerUser
    }
  ) : super (key:key);

  @override 
  State createState() => new ChatScreenState(peerUser: peerUser);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key, @required this.peerUser});

  User peerUser;
  String peerId;
  String peerName;

  Future<bool> onBackPress() {
    Navigator.of(context).pop();

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              //Need to build a list of Sample Messages for Mockup purposes
              buildListMessage(),

              //Will show Sticker
              buildSticker(),

              //Show Input
              buildInput()

            ],
          )
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildListMessage() {
    List<Message> messages = generateMockupMessages();

    return Flexible(
      child: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: messages.length,
        itemBuilder: (context, index) => buildItem(index, messages[index]),
      ),
    );
  }

  // // TO BE CONTINUE ON USING STREAM TO POPULATE THE MESSAGES  
  // Widget buildListMessage() {
  //   int _counter = 0;
  //   final StreamController _streamController = StreamController();
    
  //   @override
  //   void dispose(){
  //     _streamController.close();
  //     super.dispose();
  //   }

  //   for (var i = 0; i < 10; i ++){
  //     _streamController.sink.add(i);
  //   }
    
  //   return Flexible(
  //     //child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor))), *Will use this line of code after successful build the chat bubbles
  //     child: StreamBuilder(
  //       stream: _streamController.stream,
  //       initialData: _counter,
  //       builder: (context, snapshot){
  //         if (!snapshot.hasData) {
  //           return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor));
  //         }
  //         else {
  //           // return Text("This message id is : ${snapshot.data} !");
  //           return ListView.builder(
  //             padding: EdgeInsets.all(10.0),
  //             itemBuilder: (context, index) => buildItem(index, snapshot.data),
  //             itemCount: snapshot.data,
  //           );
  //         }
  //       },
  //     ),
  //   );
  // }

  Widget buildItem(int index, Message message) {
    if (message.senderId == currentUser) { // display right chat bubble
      return Row(
        children: <Widget>[
          Container(
            child: Text(
              message.messageText,
              style: TextStyle(color: primaryColor),
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(color: greyColor2, borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(bottom: message.senderId == currentUser ? 20.0 : 10.0, right: 10.0),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } 
    else {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
              message.messageText,
              style: TextStyle(color: primaryColor),
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(color: greyColor, borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(bottom: message.senderId == currentUser ? 20.0 : 10.0, right: 10.0),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      );
    }
  }

  Widget buildSticker() {
    return Container();
  }

  Widget buildInput() {
    return Container();
  }

  List<Message> generateMockupMessages() {
    final _messages = List<Message>();

    _messages.add(
      new Message(
        "1", 
        "Hi, This is cat.",
        "cat"
      )
    );
    _messages.add(
      new Message(
        "2", 
        "Why u eat my food?",
        "cat"
      )
    );
    _messages.add(
      new Message(
        "3", 
        "Hi cat",
        "dog"
      )
    );
    _messages.add(
      new Message(
        "4", 
        "Because I am hungry.",
        "dog"
      )
    );
    _messages.add(
      new Message(
        "5", 
        "FU*K YOU!",
        "cat"
      )
    );

    return _messages;
  }
 
} 
