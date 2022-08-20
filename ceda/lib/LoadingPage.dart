import 'package:ceda/loader.dart';
import 'package:flutter/material.dart';


class LoadingPage extends StatefulWidget{
  @override
  _LoadingPage createState() => new _LoadingPage();
}

class _LoadingPage extends State<LoadingPage>{

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: Loader(),
      ),
    );
  }
}