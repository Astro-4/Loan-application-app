import 'package:ceda/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:ceda/DialogBox.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class Complaint extends StatefulWidget{
  Complaint(

  );
  State<StatefulWidget> createState(){
    return _ComplaintState();
  }
}

enum FormType{
  registerComplaint,
}

class _ComplaintState extends State<Complaint>{
  
  //FormType _formType = FormType.registerComplaint;
  String _plot;
  String _contact;
  String _issue;
  String url;
  File sampleImage;
  int _state = 0;
  DialogBox dialogBox = new DialogBox();
  final formKey = new GlobalKey<FormState>();

  TextEditingController plotController = new TextEditingController();
  TextEditingController contactController = new TextEditingController();
  TextEditingController issueController = new TextEditingController();

  Future getImage() async{
    var tempImage = await ImagePicker.pickImage(
        source: ImageSource.camera
    );

    setState(() {
      sampleImage = tempImage;  
    });
  }

  bool validateAndSave(){
    final form = formKey.currentState;

    if(form.validate()){
      form.save();
      return true;
    }

    else{
      return false;
    } 
  }

  void uploadStatusImage() async{

    if(validateAndSave()){
      final StorageReference postImageRef = FirebaseStorage.instance.ref().child("Complaints Images");

      var timeKey = new DateTime.now();

      final StorageUploadTask uploadTask = postImageRef.child(timeKey.toString() + ".jpg").putFile(sampleImage);

      var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
      url = imageUrl.toString();

      print("Image Url = " + url);

      saveToDatabase(url);
      
    }
    
  }

  
  void saveToDatabase(url) async{
    var dbTimeKey = new DateTime.now();
    var formatDate = new DateFormat('MMM d, y');
    var formatTime = new DateFormat('EEEE, HH:mm aaa');  

    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);

    DatabaseReference ref = FirebaseDatabase.instance.reference();
    
    var data = {
      "plot": plotController.text,
      "contact": contactController.text,
      "issue": issueController.text,
      "date": date,
      "time": time,
    };

    await ref.child("Complaints").push().set(data).whenComplete((){
      goToHomePage();
      dialogBox.information(context, "Complaint Registered", "Your complaint has been logged successfully!");
    });
  }

  void goToHomePage(){
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context){
        return new HomePage();
      })
    );
  }

  void animateButton() {
    setState(() {
      _state = 1;
    });

  Timer(Duration(milliseconds: 3300), () {
    setState(() {
       _state = 2;
    });
  });
  }
  
  @override
  Widget build(BuildContext context) {
    
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("Register A Complaint"),
          ),

          body: new Container(
            margin: EdgeInsets.all(15.0),

            child: new Form(
              key: formKey,
              child: new ListView(
//                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: createInputs() + createButtons(),
              ),
            ),
          ),
        );
  }
  List<Widget> createInputs(){
    return [
      SizedBox(height: 10.0,),
      
      SizedBox(height: 20.0,),

      new TextFormField(
        decoration: new InputDecoration(labelText: 'Plot Number'),
        controller: plotController,
        validator: (value){
          return value.isEmpty ? 'Plot Number is required!' : null;
        },

        onSaved: (value){
          return _plot = value;
        },
      ),

      SizedBox(height: 10.0,),

      new TextFormField(
        decoration: new InputDecoration(labelText: 'Contact Number'),
        controller: contactController,
        validator: (value){
          return value.isEmpty ? 'Contact Number is required!' : null;
        },

        onSaved: (value){
          return _contact = value;
        },
      ),

       SizedBox(height: 10.0,),

      new TextFormField(
        decoration: new InputDecoration(labelText: 'Issue'),
        controller: issueController,
        validator: (value){
          return value.isEmpty ? 'State The Issue' : null;
        },

        onSaved: (value){
          return _issue = value;
        },
      ),

      SizedBox(height: 20.0,),
    ];
  }
  List<Widget> createButtons(){
    
      return [
        new FloatingActionButton(
          onPressed: getImage,
          tooltip: 'Add Image',
          child: new Icon(Icons.add_a_photo),
        ),
        
        new RaisedButton(
          child: setUpButtonChild(),
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: () {
                setState(() {
                  if (_state == 0) {
                    animateButton();
                    uploadStatusImage();
                  }
                });
                
          }, 
        ),
      ];  
    
  }

  Widget setUpButtonChild() {
    if (_state == 0) {
      return new Text(
        "Submit",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      );
    } else if (_state == 1 && validateAndSave()) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else {
      _state = 0;
      return new Text(
        "Submit",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          )
      );
    }
  }
}
 