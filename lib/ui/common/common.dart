import 'package:flutter/material.dart';
import 'package:realtimequiz/ui/text_styles.dart';

class MyButton extends StatelessWidget {
  final String text;
  final Function onPress;

  const MyButton({Key key, this.text, this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text(text,
          style: TextStyle(
              fontFamily: 'Mukta', fontWeight: FontWeight.w700, fontSize: 28, color: Colors.white)),
      onPressed: onPress,
    );
  }
}

class MyScaffold extends StatelessWidget {
  final Widget child;

  const MyScaffold({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Stack(
        children: <Widget>[
          Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          child
        ],
      )
    );
  }
}

class MyHeadline extends StatelessWidget {
  final String text;

  const MyHeadline({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Text(text, style: headlineStyle());
  }
}
