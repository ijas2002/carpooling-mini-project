import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users/global/global.dart';
import 'package:users/screens/forgot_password_screen.dart';
import 'package:users/screens/main_page.dart';
import 'package:users/screens/register_screens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    final passwordTextEditingController=TextEditingController();
  final emailTextEditingController=TextEditingController();
   bool _passwordVissible = false;

   

    final _formKey = GlobalKey<FormState>();
      void _submit() async {
    //validating al form field
    if(_formKey.currentState!.validate()){
      await firebaseAuth.signInWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
         password: passwordTextEditingController.text.trim())
         .then((auth) async {

        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
        userRef.child(firebaseAuth.currentUser!.uid).once().then((value) async{
          final snap = value.snapshot;
          if(snap.value!=null){
            currentUser = auth.user;
            await Fluttertoast.showToast(msg: "Successfully LoggedIn");
            Navigator.push(context,MaterialPageRoute(builder: (c)=>MainScreen()));

          }
          else{
            await Fluttertoast.showToast(msg: "No record exist with this email");
            firebaseAuth.signOut();
            Navigator.push(context,MaterialPageRoute(builder: (c)=>MainScreen()));

          }
        });

         }).catchError((errorMessage){
          
          Fluttertoast.showToast(msg: " Error Ocuured \n $errorMessage");
         });

    }
    else{
      Fluttertoast.showToast(msg: "not All fields are valid");
    }

}
  @override
  Widget build(BuildContext context) {
     bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        
        body: ListView(
          padding:  EdgeInsets.all(0),
          children: [
            Image.asset(darkTheme?'images/darkImage.jpg':'images/lightImage.jpg'),

            SizedBox(height: 20,),
            Center(
              
              child: Text("Login", style: TextStyle(
                    color: darkTheme? Colors.amber.shade400:Colors.blue,
                    fontSize: 25,
                    fontWeight:FontWeight.bold,
                  ),),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(15,20,15,50),
            child: Form(
              key: _formKey,
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,

                    children: [
                      TextFormField(
                          inputFormatters:[
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: darkTheme? Colors.black45 : Colors.grey.shade200,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide(width: 0,style:BorderStyle.none)
                            ),
                            prefixIcon: Icon(Icons.mail_outline,color: darkTheme? Colors.amber.shade400 : Colors.grey,),
                          ),
                          autovalidateMode:  AutovalidateMode.onUserInteraction,
                          validator: (text){
                            if(EmailValidator.validate(text!)== true){
                              return null;
                            }
                            if(text==null || text.isEmpty){
                              return 'Email can\'t be empty';
                            }
                            if(text.length<2){
                              return 'Please enter a valid Email';
                            }
                            if(text.length>49){
                              return 'Email can\'t be more than 50';
                            }


                          },
                            onChanged: (text)=>setState((){
                              emailTextEditingController.text=text;
                            }),
                        ),
                      SizedBox(height: 20,),
                       TextFormField(
                          obscureText : !_passwordVissible,
                          inputFormatters:[
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: darkTheme? Colors.black45 : Colors.grey.shade200,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide(width: 0,style:BorderStyle.none)
                            ),
                            prefixIcon: Icon(Icons.password,color: darkTheme? Colors.amber.shade400 : Colors.grey,),
                            suffixIcon:  IconButton(
                              icon: Icon(
                                _passwordVissible?Icons.visibility : Icons.visibility_off,
                                color: darkTheme? Colors.amber.shade400 : Colors.grey,
                              ),
                              onPressed: (){
                                setState(() {
                                  _passwordVissible = !_passwordVissible;
                                });
                              },
                            )
                          ),
                          autovalidateMode:  AutovalidateMode.onUserInteraction,
                          validator: (text){

                            if(text==null || text.isEmpty){
                              return ' Password can\'t be empty';
                            }
                            if(text.length<2){
                              return 'Please enter a valid  Password';
                            }
                            if(text.length>49){
                              return ' Password can\'t be more than 50';
                            }


                          },
                          onChanged: (text)=>setState((){
                            passwordTextEditingController.text=text;
                          }),
                        ),
                         SizedBox(height: 20,),
                        
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary:  darkTheme ? Colors.amber.shade400 : Colors.blue,
                            onPrimary: darkTheme? Colors.black : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius:  BorderRadius.circular(32)

                            ),
                            minimumSize: Size(double.infinity,50)
                          ),
                            onPressed: (){
                              _submit();
                              
                            },
                            child: Text('Login',style: TextStyle(fontSize: 20),)
                        ),
                        SizedBox(height: 20,),
                        GestureDetector(
                          onTap: (){

                            Navigator.push(context, MaterialPageRoute(builder: (c)=>ForgotPasswordScreen()) );
                            
                          },
                          child: Text('Forgot Password',

                          style: TextStyle(color: darkTheme ? Colors.amber.shade400: Colors.blue),
                          ),
                        ),
                        Row(
                          mainAxisAlignment : MainAxisAlignment.center,
                          children: [
                          
                          Text('Does\'t having account'),
                          SizedBox(width: 5,),
                          GestureDetector(
                            onTap:(){
                              
                              Navigator.push(context, MaterialPageRoute(builder: (c)=>RegisterScreen()) );
                            },
                            child : Text('Sign up',
                             style: TextStyle(fontSize:15,color: darkTheme ? Colors.amber.shade400: Colors.blue),)
                          )

                        ],)
                    ],
              ) ,),
            
            ),
           

          ],
        )

      ),
    );
  }
}