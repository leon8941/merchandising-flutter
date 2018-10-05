import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "New List",
      home: MyHomePage(),
      theme: new ThemeData(
        primaryColor: Colors.deepPurpleAccent
      ),
    );
  }
}
 
class MyHomePage extends StatefulWidget{
  @override
  MyHomePageState createState() => new MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>{
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 20.0);
  final _saved = new Set<WordPair>();

  @override
  Widget build(BuildContext context){
    return Scaffold (
      appBar: AppBar(
        title: Text('Messages'),
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
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context,i){
        if (i.isOdd) return Divider();
        final index = i ~/ 2;
        // The syntax "i ~/ 2" divides i by 2 and returns an integer result.
        // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
        if (index >= _suggestions.length){
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair){
    final bool alreadySaved = _saved.contains(pair);

    return ListTile(
      title: Text(
        pair.asPascalCase,
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
              _saved.remove(pair);
            }
            else{
              _saved.add(pair);
            }
          });
        },
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MessageDetails()
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
            (WordPair pair) {
              return new ListTile(
                title: new Text(
                  pair.asPascalCase,
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


class MessageDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Message with A"),
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
