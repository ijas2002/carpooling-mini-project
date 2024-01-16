import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';
import '../splashScreen/splash_screen.dart';
import 'login_screens.dart';


class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({super.key});

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {

  final carModelTextEditingController = TextEditingController();
  final carNumberTextEditingController= TextEditingController();
  final carColorTextEditingController = TextEditingController();

  List<String> carTypes = ["Car","CNG","Bike"];
  String? selectedcarType;

  final _formKey = GlobalKey<FormState>();

  _submit() async {
    if(_formKey.currentState!.validate()) {
      Map driverCarInfoMap ={
        "car_model":carModelTextEditingController.text.trim(),
        "car_number":carNumberTextEditingController.text.trim(),
        "car_color":carColorTextEditingController.text.trim(),
        "type":selectedcarType

      };

      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");
      userRef.child(currentUser!.uid).child("car_details").set(driverCarInfoMap);

      await Fluttertoast.showToast(msg: "Car details Added Successfully");
      Navigator.push(context,MaterialPageRoute(builder: (c)=>SplashScreen()));
    }
  }


  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness==Brightness.dark;


    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding:EdgeInsets.all(8),
          children: [
            Column(
              children: [
                Image.asset(darkTheme? "images/darkImage.jpg":"images/lightImage.jpg"),

                SizedBox(height: 20,),

                Text("Add Car Details",
                  style:TextStyle(
                    color: darkTheme? Colors.amber.shade400 : Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold
                  )
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
                            hintText: 'Car Name',
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
                              return 'car model Name can\'t be empty';
                            }
                            if(text.length<2){
                              return 'Please enter a valid car model name';
                            }
                            if(text.length>49){
                              return 'car model name can\'t be more than 50';
                            }


                          },
                          onChanged: (text)=>setState((){
                            carModelTextEditingController.text=text;
                          }),
                        ),
                        SizedBox(height: 10,),

                        TextFormField(
                          inputFormatters:[
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                            hintText: 'Car Number',
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

                            if(text==null || text.isEmpty){
                              return 'car model can\'t be empty';
                            }
                            if(text.length<2){
                              return 'Please enter a valid car model';
                            }
                            if(text.length>49){
                              return 'Number can\'t be more than 50';
                            }


                          },
                          onChanged: (text)=>setState((){
                            carNumberTextEditingController.text=text;
                          }),
                        ),
                        SizedBox(height: 10,),

                        TextFormField(
                          inputFormatters:[
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                            hintText: 'Car Color',
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

                            if(text==null || text.isEmpty){
                              return 'car color can\'t be empty';
                            }
                            if(text.length<2){
                              return 'Please enter a valid car color';
                            }
                            if(text.length>49){
                              return 'car color can\'t be more than 50';
                            }


                          },
                          onChanged: (text)=>setState((){
                            carColorTextEditingController.text=text;
                          }),
                        ),

                        SizedBox(height: 10,),
                        DropdownButtonFormField(

                            decoration: InputDecoration(
                              hintText: "please choose car Type",
                              prefixIcon: Icon(Icons.car_crash,color: Colors.grey)
                              ,filled: true,
                              fillColor: Colors.grey.shade200,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(width: 0,style:BorderStyle.none)
                              ),
                            ),
                            items: carTypes.map((car){
                              return DropdownMenuItem(
                                child: Text(car,style: TextStyle(color: Colors.grey),),
                                value: car,
                              );
                            }).toList(),

                            onChanged: (newValue){
                              setState(() {
                                selectedcarType = newValue.toString();
                              });
                            }
                        ),



                        SizedBox(height: 10,),


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
          ],

        ),
      ),
    );
  }
}
