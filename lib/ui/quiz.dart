import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizAnswers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Firestore.instance
        .collection('channel_test/en/rounds')
        .snapshots()
        .listen((data) => data.documents.forEach((doc) => print(doc["title"])));
    return null;
  }
}

class BookList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          Firestore.instance.collection('channel_test/en/rounds').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        print("Jimlab");
        print(snapshot.toString());
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Text('Loading...');
          default:
            return new ListView(
              children:
                  snapshot.data.documents.map((DocumentSnapshot document) {
                return new ListTile(
                  title: new Text(document['category']),
                  subtitle: new Text(document['difficulty']),
                );
              }).toList(),
            );
        }
      },
    );
  }
}

class QuizContent extends StatefulWidget {
  QuizContent({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _QuizContentState createState() => _QuizContentState();
}

class _QuizContentState extends State<QuizContent> {
  int _counter = 0;
  int _selectedAnswer = -1;
  int _correctAnswer = -1;
  DocumentSnapshot _data;


  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  _QuizContentState() {
    Firestore.instance.document('channel_test/en').snapshots().listen((data) {
      print(data.data.toString());
      setState(() {
        print("setting the state");
        _data = data;
        _correctAnswer = _data.data['correctAnswerIndex'];
        if(_correctAnswer == -1){
          _selectedAnswer = -1;
        }
      });
    });
  }
  Color getTileColor(int index){
    if(_selectedAnswer == index) {
      if(_correctAnswer == -1){
        return Colors.blue[200];
      }
      else if(_correctAnswer == index) {
        return Colors.green[400];
      }
      else{
        Colors.red[200];
      }
    }
    return Colors.white;
  }
  Widget answerTile(int index) {
    String text = _data.data['answers'][index];
    return Container(
      color: _correctAnswer == index? Colors.green[200] : Colors.white,
      child: Card(
        margin: EdgeInsets.all(20),
        color: getTileColor(index),
        child: InkWell(
          onTap: (){
            if(_correctAnswer != -1) return;
            setState(() {
              _selectedAnswer = index;
            });
          },
//          highlightColor: Colors.green[200],
          child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(text),
              )),
        ),
      ),
    );
  }

  Widget questionTile(String text) {
    return Center(
      child: Padding(padding: EdgeInsets.all(20), child: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return Center(child: Text("Loading..."));
    } else {
      if (_data.data['correctAnswerIndex'] == -1) {
        // guessing time

      } else {
        //display survey, then
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          questionTile(_data.data['question']),
          answerTile(0),
          answerTile(1),
          answerTile(2),
          answerTile(3)
        ],
      );
    }
    return BookList();
  }
}

class QuizPage extends StatelessWidget {
  final Widget body;

  const QuizPage({Key key, this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the QuizPage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Realtimequiz"),
        ),
        body: QuizContent());
  }
}
