import 'package:firebase_auth/firebase_auth.dart';
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

class QuizPage extends StatefulWidget {
  QuizPage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  // TODO pass channel name in constructor
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  int _counter = 0;
  String channel = "channel_test/en";
  int _selectedAnswer = -1;
  int _correctAnswer = -1;
  bool _showEvaluation = true;
  DocumentSnapshot _data;

  _QuizPageState() {
    Firestore.instance.document(channel).snapshots().listen((data) {
      print(data.data.toString());
      setState(() {
        print("setting the state");
        print(data);
        _data = data;
        _showEvaluation = true;
        _correctAnswer = _data.data['correctAnswerIndex'];
        if (_correctAnswer == -1) {
          _selectedAnswer = -1;
        }
      });
      if (_data.data['correctAnswerIndex'] == -1) {
        controller.duration = const Duration(seconds: 10);
      } else {
        controller.duration = const Duration(seconds: 20);
      }
      if (data.data["results"] == null) {
        controller.reset();
        controller.forward();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 10), vsync: this);
//    animation = Tween<double>(begin: 0, end: 300).animate(controller)
//      ..addListener(() {
//        setState(() {
//          // The state that has changed here is the animation object’s value.
//        });
//      });
    controller
      ..addListener(() {
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
      });
    //controller.forward();
  }

  Color getTileColor(int index) {
    if (_correctAnswer == index) {
      return Colors.green[300];
    }
    if (_selectedAnswer == index) {
      if (_correctAnswer == -1) {
        return Colors.blue[200];
      } else {
        return Colors.red[200];
      }
    }
    return Colors.white;
  }

  Color getChipColor() {
    switch (_data.data['difficulty']) {
      case 'easy':
        return Colors.green[300];
        break;
      case 'hard':
        return Colors.red[300];
        break;
      case 'medium':
        return Colors.orange[300];
        break;
      default:
        return Colors.green[200];
    }
  }

  Widget answerTile(int index) {
    String text = _data.data['answers'][index];
    return Container(
      //color: _correctAnswer == index ? Colors.green[200] : Colors.transparent,
      child: Card(
        margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        color: getTileColor(index),
        child: InkWell(
          onTap: () async {
            if (_correctAnswer != -1) return;
            setState(() {
              _selectedAnswer = index;
            });
            FirebaseUser user = await _auth.currentUser();
            Firestore.instance
                .document(channel)
                .collection("guesses")
                .document(user.uid)
                .setData({"index": _selectedAnswer});
          },
//          highlightColor: Colors.green[200],
          child: Column(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(text),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                    child: Text(
                        _data.data["results"] != null
                            ? _data.data["results"]["guesses"][index.toString()]
                                .toString()
                            : "",
                        textAlign: TextAlign.right),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget questionTile(String text) {
    return Card(
      child: Column(
        children: <Widget>[
          Center(
            child: Padding(padding: EdgeInsets.all(14), child: Text(text)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                CircularProgressIndicator(
                  value: controller.value,
                  strokeWidth: 8,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

//  Widget chips() {
//    return Row(
//      children: <Widget>[
//        Padding(
//          padding: const EdgeInsets.all(8.0),
//          child: Chip(
//            backgroundColor: getChipColor(),
//            label: Text(_data.data['difficulty']),
//          ),
//        ),
//        Padding(
//          padding: const EdgeInsets.all(8.0),
//          child: Chip(
//            backgroundColor: Colors.blue[200],
//            label: Text(_data.data['category']),
//          ),
//        )
//      ],
//    );
//  }

  Widget evaluationPage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
//        chips(),
        questionTile(_data.data['question']),
        answerTile(_correctAnswer),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton.icon(
                  color: Colors.green[200],
                  onPressed: () async {
                    FirebaseUser user = await _auth.currentUser();
                    Firestore.instance
                        .document(channel)
                        .collection("upvotes")
                        .document(user.uid)
                        .setData({"upvoted": true});
                    setState(() {
                      _showEvaluation = false;
                    });
                  },
                  label: Text("Upvote"),
                  icon: Icon(Icons.thumb_up)),
              FlatButton.icon(
                  color: Colors.red[200],
                  onPressed: () async {
                    FirebaseUser user = await _auth.currentUser();
                    Firestore.instance
                        .document(channel)
                        .collection("downvotes")
                        .document(user.uid)
                        .setData({"upvoted": true});
                    setState(() {
                      _showEvaluation = false;
                    });
                  },
                  label: Text("Downvote"),
                  icon: Icon(Icons.thumb_down))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 12),
          child: Center(child: Text("Was there an issue with his question?")),
        ),
        Center(
          child: FlatButton.icon(
              color: Colors.orange[200],
              onPressed: () async {
                FirebaseUser user = await _auth.currentUser();
                Firestore.instance
                    .document(channel)
                    .collection("issues")
                    .document(user.uid)
                    .setData({"issue": true});
                setState(() {
                  _showEvaluation = false;
                });
              },
              label: Text("Bad Content"),
              icon: Icon(Icons.warning)),
        ),
      ],
    );
  }

  Widget content(){
    if (_data == null) {
      return Center(child: Text("Loading..."));
    } else {
      if (_data.data['correctAnswerIndex'] == -1) {
        // guessing time
      } else if (_showEvaluation) {
        //display survey, then
        return evaluationPage();
      }
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
//            chips(),
            questionTile(_data.data['question']),
            answerTile(0),
            answerTile(1),
            answerTile(2),
            answerTile(3)
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the QuizPage object that was created by
          // the App.build method, and use it to set our appbar title.
//          title: Text("Realtimequiz"),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(22.0),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  children: <Widget>[
                    Text(_data.data['category'], style: TextStyle(color: Colors.white, fontSize: 20),),
                    Text(_data.data['difficulty'], style: TextStyle(color: Colors.white),),
                  ],
                ),
              )),
        ),
        body: content()
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}