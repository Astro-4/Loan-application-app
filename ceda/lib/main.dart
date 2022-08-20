import 'package:ceda/Authentication.dart';
import 'package:ceda/Mapping.dart';
import 'package:flutter/material.dart';

void main()
{
  runApp(new CedaApp());
}

class CedaApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {

    return new MaterialApp
    (
      title: "CEDA LOANS",
      debugShowCheckedModeBanner: false,
      theme: new ThemeData
      (
        primarySwatch: Colors.blue,
      ),

      home: MappingPage(auth: Auth(),),
      
    );

  }
}