import 'package:ceda/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:ceda/DialogBox.dart';
import 'dart:async';


class UploadPhotoPage extends StatefulWidget{
  
  State<StatefulWidget> createState(){
    return _UploadPhotoPageState();
  }

}

class _UploadPhotoPageState extends State<UploadPhotoPage>{
  
  File sampleImage;
  String _myValue;
  String url;
  final formkey = new GlobalKey<FormState>();
  DialogBox dialogBox = new DialogBox();
  int _state = 0;

  Future getImage() async{
    var tempImage = await ImagePicker.pickImage(
        source: ImageSource.gallery
    );

    setState(() {
      sampleImage = tempImage;  
    });
  }

  bool validateAndSave(){
    final form = formkey.currentState;

    if(form.validate()){
      form.save();
      return true;
    }
    else{
      return false;
    }
  }

  void uploadStatusImage() async{

    CircularProgressIndicator();
    if(validateAndSave()){
      final StorageReference postImageRef = FirebaseStorage.instance.ref().child("Post Images");

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

    DatabaseReference ref =  await FirebaseDatabase.instance.reference().child("Posts");
    
    var data = {
      "image": url,
      "description": _myValue,
      "date": date,
      "time": time,
    };

    await ref.push().set(data).whenComplete((){
      goToHomePage();
      dialogBox.information(context, "Post created", "Successfully!");
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
        title: new Text("Upload Image"),
        centerTitle: true,
      ),

      body: new Center(
        child: sampleImage == null? Text("Select an Image"): enableUpload(),
      ),

      floatingActionButton: new FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Add Image',
        child: new Icon(Icons.add_a_photo),
      ),

    );
  
  }

  Widget enableUpload(){
    return Container(
      child: new Form(
        key: formkey,
        child: new ListView(
          children: <Widget>[
            Image.file(sampleImage, height: 330.0, width: 660.0,),

            SizedBox(height: 15.0,),

            TextFormField(
              decoration: new InputDecoration(labelText: 'Description'),
              validator: (value){
                return value.isEmpty ? 'Description is required' : null;
              },

              onSaved: (value){
                return _myValue = value;
              },
            ),

            SizedBox(height: 15.0,),

            MaterialButton(
              elevation: 10.0,
              child: setUpButtonChild(),
              textColor: Colors.white,
              color: Colors.pink,

              onPressed: () {
                  setState(() {
                    if (_state == 0) {
                      animateButton();
                      uploadStatusImage();
                    }
                  });
                  
                }, 
            )
          ],
        
        ),
      ),
    );
  }
  Widget setUpButtonChild() {
    if (_state == 0) {
      return new Text(
        "Upload Image",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      );
    } else if (_state == 1) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else {
      return Icon(Icons.check, color: Colors.white);
    }
  }
} 