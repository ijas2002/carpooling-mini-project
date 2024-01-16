import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users/global/global.dart';
import 'package:users/screens/login_screens.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}


class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
   final emailTextEditingController=TextEditingController();
   final _formKey = GlobalKey<FormState>();

   Future<void> _submit() async {
    //validating al form field
 
    
      firebaseAuth.sendPasswordResetEmail(
        email: emailTextEditingController.text.trim(),
         )
         .then((value) {       
           Fluttertoast.showToast(msg: "Mail sent Successfully ");
          

         }).onError((error, StackTrace){
          
          Fluttertoast.showToast(msg: " Error Ocuured \n ${error.toString()}");
         });


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
              
              child: Text("Forgot Password Screen", style: TextStyle(
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
                            child: Text('Sent Reset PassWord Link',style: TextStyle(fontSize: 20),)
                        ),
                        SizedBox(height: 20,),
               
                        Row(
                          mainAxisAlignment : MainAxisAlignment.center,
                          children: [
                          
                          Text('Already having account'),
                          SizedBox(width: 5,),
                          GestureDetector(
                            onTap:(){
                              
                              Navigator.push(context, MaterialPageRoute(builder: (c)=>LoginScreen()) );
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