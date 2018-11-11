import 'package:flutter/material.dart';
import 'messageDetail.dart';
import 'login.dart';
import 'User.dart';

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
    return Scaffold (
      appBar: AppBar(
        title: Text('Hi ' + this.currentUserId + 'Messages'),
        actions: <Widget>[
          new IconButton(
            icon: const Icon(
              Icons.add
            ),
            onPressed: _newMessages
          ),
        ],
      ),
      body: _buildSuggestions(),
    );
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

