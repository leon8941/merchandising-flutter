import 'package:flutter/material.dart';
import 'messageDetail.dart';
import 'login.dart';
import 'User.dart';
import 'Choice.dart';
import 'const.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(new MyApp());

class MyHomePage extends StatefulWidget{
  final String currentUserId;

  MyHomePage({Key key, @required this.currentUserId}) : super(key: key);

  @override
  MyHomePageState createState() => new MyHomePageState(currentUserId: currentUserId);
}

class MyHomePageState extends State<MyHomePage>{
  MyHomePageState({Key key, @required this.currentUserId});

  final String currentUserId;
  bool isLoading = false;
  
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  List<Choice> choices = const <Choice>[
    const Choice("Setting", Icons.settings, 1),
    const Choice("Log Out", Icons.exit_to_app, 2), 
  ];

  Future<bool> onBackPress() {
    return Future.value(false);
  }

  Future<Null> handleSignOut() async {
      this.setState(() {
        isLoading = true;
      });

      await FirebaseAuth.instance.signOut();
      await googleSignIn.disconnect();
      await googleSignIn.signOut();

      this.setState(() {
        isLoading = false;
      });

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyApp()),
          (Route<dynamic> route) => false);
    } 

  void onItemMenuPress(Choice choice){
    if(choice.id == 2) {
      handleSignOut();
    }
  }

  final _users = List<User>.generate(
    20, 
    (count) => User(
      "Message ID $count", 
      "Sender $count")
    );
  final _biggerFont = const TextStyle(fontSize: 20.0);
  final _saved = new Set<String>();

  @override
  Widget build(BuildContext context){
    var snapshots = Firestore.instance.collection('users').snapshots();

    print("build snapshots");
    print(snapshots.toList());

    return Scaffold (
      appBar: AppBar(
        title: Text('Messages'),
        actions: <Widget>[
          new PopupMenuButton<Choice>(
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        choice.icon,
                        color: primaryColor,
                      ),
                      Container(
                        width: 10.0,
                      ),
                      Text(
                        choice.title,
                        style: TextStyle(color: primaryColor),
                      )
                    ],
                  ),
                );
              }).toList();
            },
          )
        ],
      ),
      // body: _buildSuggestions(),
      body: _userList(),
    );
  }

  Widget _userList() {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          //List of users
          _user()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget _user() {
    return Container(
      child: StreamBuilder(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              ),
            );
          } 
          else {
            print("_user() snapshot");
            print(snapshot);
            return _buildUser(snapshot);
          }
        },
      ),
    );
  }

  Widget _buildUser(snapshot) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: snapshot.data.documents.length,
      itemBuilder: (context, i){
        return _buildItem(context, snapshot.data.documents[i]);
      },
    );
  }

  Widget _buildItem(context, DocumentSnapshot document){
    print("currentUserId");
    print(currentUserId);

    print("document['id']");
    print(document['id']);

    if(document['id'] == currentUserId) {
      return Container();
    }
    else {
      return Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: CachedNetworkImage(
                  placeholder: Container(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                    width: 50.0,
                    height: 50.0,
                    padding: EdgeInsets.all(15.0),
                  ),
                  imageUrl: document['photoUrl'],
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              new Flexible(
                child: Container(
                  child: new Column(
                    children: <Widget>[
                      new Container(
                        child: Text(
                          'Nickname: ${document['nickname']}',
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: new EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                      new Container(
                        child: Text(
                          'About me: ${document['aboutMe'] ?? 'Not available'}',
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: new EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {
            Fluttertoast.showToast(msg: "Sign in success");
          },
          // onPressed: () { // To Message Detail
          //   Navigator.push(
          //       context,
          //       new MaterialPageRoute(
          //           builder: (context) => new Chat(
          //                 peerId: document.documentID,
          //                 peerAvatar: document['photoUrl'],
          //               )));
          // },
          color: greyColor2,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }

  Widget _buildSuggestions(){
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _users.length,
      itemBuilder: (context, i){
        return _buildRow(_users[i]);
      },
    );
  }

  Widget _buildRow(User user){
    final bool alreadySaved = _saved.contains(user.senderId);

    return ListTile(
      leading: new Icon(
        Icons.person,
      ),
      title: Text(
        user.senderName,
        style: _biggerFont,
      ),
      trailing: new IconButton(
        icon: new Icon(
          alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.red : null 
        ),
        onPressed: () {
          setState(() {
            if(alreadySaved){
              _saved.remove(user.senderId);
            }
            else{
              _saved.add(user.senderId);
            }
          });
        },
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MessageDetails(peerUser: user)
          ),
        );
      },
      onLongPress: () {
        //Can do something else here such as showing a tooltips.
      },
      
    );
  }

  void _newMessages(){
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context){
          final Iterable<ListTile> tiles = _saved.map(
            (String senderName) {
              return new ListTile(
                title: new Text(
                  senderName,
                  style: _biggerFont,
                ),
              );
            }
          );
          final List<Widget> divided = ListTile
            .divideTiles(
              context: context,
              tiles: tiles
            ).toList();

          return new Scaffold(
            appBar: new AppBar(
              title: const Text('Saved suggestions'),
            ),
            body: new ListView(
              children: divided
            ),
          );
        }
      )
    );
  }
}

