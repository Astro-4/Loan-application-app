import 'package:ceda/Authentication.dart';
import 'package:ceda/DialogBox.dart';
import 'package:flutter/material.dart';

class LoginRegisterPage extends StatefulWidget
{
  LoginRegisterPage({
    this.auth,
    this.onSignedIn,
  });
  final AuthImplementation auth;
  final VoidCallback onSignedIn;

  State<StatefulWidget> createState(){
    return _LoginRegisterState();
  }

}

enum FormType{
  login,
  register
}

class _LoginRegisterState extends State<LoginRegisterPage>{

  DialogBox dialogBox = new DialogBox();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  
  final formKey = new GlobalKey<FormState>();
  FormType _formType = FormType.login;
  String _email = "";
  String _password = "";

  //Methods
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

  void validateAndSubmit() async{
     if(validateAndSave()){
       
       try
       {
         if(_formType == FormType.login){
           String userId = await widget.auth.SignIn(_email, _password);
           //dialogBox.information(context, "Login Successful", "Welcome!");
           print("Login userId = " + userId);
         }

         else{
           String userId = await widget.auth.SignUp(_email, _password);
           //dialogBox.information(context, "Congratulations", "your account has been created successfully!");
           print("Regster userId = " + userId);
         }
         widget.onSignedIn();
       }
       catch(e){
         dialogBox.information(context, "Error", e.toString());
         print("Error = " + e.toString());
       }

     } 
  }

  void goToRegister(){
    formKey.currentState.reset();

    setState(() {
      _formType = FormType.register;
    });
  }

  void goToLogin(){
    formKey.currentState.reset();

    setState(() {
      _formType = FormType.login;
    });
  }

  //Design
  @override
  Widget build(BuildContext context) {
    
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("CEDA LOANS"),
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
      
      logo(),

      SizedBox(height: 20.0,),

      new TextFormField(
        decoration: new InputDecoration(labelText: 'Email'),
        controller: emailController,
        validator: (value){
          return value.isEmpty ? 'Email is required!' : null;
        },

        onSaved: (value){
          return _email = value;
        },
      ),

      SizedBox(height: 10.0,),

      new TextFormField(
        decoration: new InputDecoration(labelText: 'Password'),
        obscureText: true,
        controller: passwordController,
        validator: (value){
//          return value.isEmpty ? 'Password is required!' : null;

        if(value.isEmpty){
          return 'Password is required!';
        }
        if(value.length<6){
          return 'Please enter strong password';
        }
         return null;
        },

        onSaved: (value){
          return _password = value;
        },
      ),

      SizedBox(height: 20.0,),
    ];
  }
  Widget logo(){
    return new Hero(
      tag: 'hero',
      child: new CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 110.0,
        child: Image.asset('images/ceda.jpg'),
      ),
    );
  }

  List<Widget> createButtons(){
    if(_formType == FormType.login){
      return [
        new RaisedButton(
          child: new Text("Login", style: new TextStyle(fontSize: 20.0)),
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: validateAndSubmit,
        ),

        new FlatButton(
          child: new Text("Don't have an Account? Sign Up!", style: new TextStyle(fontSize: 14.0)),
          textColor: Colors.black,
          onPressed: goToRegister,
        ),
      ];  
    }

    else{
      return [
        new RaisedButton(
          child: new Text("Create Account", style: new TextStyle(fontSize: 20.0)),
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: validateAndSubmit,
        ),

        new FlatButton(
          child: new Text("Already have an Account? Login!", style: new TextStyle(fontSize: 14.0)),
          textColor: Colors.red,
          onPressed: goToLogin,
        ),
      ];  
    }

  }
}