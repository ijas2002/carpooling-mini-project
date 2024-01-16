import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:users/global/global.dart';
import 'package:users/screens/login_screens.dart';
import 'package:users/screens/main_page.dart';
// import 'package:users/global/global.dart';

class RegisterScreen extends StatefulWidget {
  // const RegisterScreen({super.key});
  const RegisterScreen({Key? key}) : super(key: key);


  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameTextEditingController=TextEditingController();
  final emailTextEditingController=TextEditingController();
  final phoneTextEditingController=TextEditingController();
  final addressTextEditingController=TextEditingController();
  final confirmTextEditingController=TextEditingController();
  final passwordTextEditingController=TextEditingController();

  bool _passwordVissible = false;

  //global key

  final _formKey = GlobalKey<FormState>();
  void _submit() async {
    //validating al form field
    if(_formKey.currentState!.validate()){
      await firebaseAuth.createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
         password: passwordTextEditingController.text.trim())
         .then((auth) async {
          currentUser=auth.user;

          if(currentUser!=null){
            Map userMap ={
              "id":currentUser!.uid,
              "name":nameTextEditingController.text.trim(),
              "email":emailTextEditingController.text.trim(),
              "address":addressTextEditingController.text.trim(),
              "phone":phoneTextEditingController.text.trim(),

            };

            DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
            userRef.child(currentUser!.uid).set(userMap);
          }
          await Fluttertoast.showToast(msg: "Successfully Registerd");
          Navigator.push(context,MaterialPageRoute(builder: (c)=>MainScreen()));

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
      //when we touch outside any text field this will minimize the keyboard
      onTap: (){
        FocusScope.of(context).unfocus();

      },
      child: Scaffold(
        body: ListView(
          padding:  EdgeInsets.all(0),
          children:[
            Column(
              children: [
                Image.asset(darkTheme?'images/darkImage.jpg':'images/lightImage.jpg'),
                SizedBox(
                  height: 20,
                ),
                Text('Register',
                style: TextStyle(
                  color: darkTheme? Colors.amber.shade400:Colors.blue,
                  fontSize: 25,
                  fontWeight:FontWeight.bold,
                ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15,20,15,50),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          inputFormatters:[
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                            hintText: 'Name',
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: darkTheme? Colors.black45 : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide(width: 0,style:BorderStyle.none)
                            ),
                            prefixIcon: Icon(Icons.person,color: darkTheme? Colors.amber.shade400 : Colors.grey,),
                          ),
                          autovalidateMode:  AutovalidateMode.onUserInteraction,
                          validator: (text){
                            if(text==null || text.isEmpty){
                              return 'Name can\'t be empty';
                            }
                            if(text.length<2){
                              return 'Please enter a valid name';
                            }
                            if(text.length>49){
                              return 'name can\'t be more than 50';
                            }


                          },
                            onChanged: (text)=>setState((){
                              nameTextEditingController.text=text;
                            }),
                        ),
                        SizedBox(height: 10,),

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
                        SizedBox(height: 10,),
                        IntlPhoneField(
                          showCountryFlag: false,
                          dropdownIcon: Icon(
                            Icons.arrow_drop_down,
                          color: darkTheme ? Colors.amber.shade400 : Colors.grey,),
                          decoration: InputDecoration(
                            hintText: 'Phone number',
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: darkTheme? Colors.black45 : Colors.grey.shade200,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide(width: 0,style:BorderStyle.none)
                            ),
 
                          ),
                          controller: phoneTextEditingController,
                          onChanged: (text)=>setState((){
                              phoneTextEditingController.text= text as String;
                            }),
                        ),
                        SizedBox(height: 10,),

                        TextFormField(
                          inputFormatters:[
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                            hintText: 'Address',
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
                              return ' address can\'t be empty';
                            }
                            if(text.length<2){
                              return 'Please enter a valid  address';
                            }
                            if(text.length>49){
                              return ' address can\'t be more than 50';
                            }


                          },
                          onChanged: (text)=>setState((){
                            addressTextEditingController.text=text;
                          }),
                        ),
                        SizedBox(height: 10,),

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
                        SizedBox(height: 10,),

                        TextFormField(
                          obscureText : !_passwordVissible,
                          inputFormatters:[
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                              hintText: 'Confirm Password',
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

                            if(text != passwordTextEditingController.text){
                              return 'password do not match';
                            }
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
                            confirmTextEditingController.text=text;
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
                            child: Text('Register',style: TextStyle(fontSize: 20),)
                        ),
                        SizedBox(height: 20,),
           
                        Row(
                          mainAxisAlignment : MainAxisAlignment.center,
                          children: [
                          
                          Text('alredy having account'),
                          SizedBox(width: 5,),
                          GestureDetector(
                            onTap:(){
                              
                              Navigator.push(context, MaterialPageRoute(builder: (c)=>LoginScreen()) );
                            },
                            child : Text('Sign in',
                             style: TextStyle(fontSize:15,color: darkTheme ? Colors.amber.shade400: Colors.blue),)
                          )

                        ],)




                      ],
                    ),
                  ),
                )
              ],
            )
          ]
        )

      ),
    );
  }
}


