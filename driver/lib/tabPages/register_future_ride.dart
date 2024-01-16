import 'package:drivers/tabPages/home_tab.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../global/global.dart';
import '../screens/main_page.dart';



class FutureRideGive extends StatefulWidget {
  const FutureRideGive({super.key});

  @override
  State<FutureRideGive> createState() => _FutureRideGiveState();
}

class _FutureRideGiveState extends State<FutureRideGive> {

  final fromAddressController = new TextEditingController();
  final toAddressController = new TextEditingController();
  final dateController = new TextEditingController();
  final timeController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    //validating al form field
    if(_formKey.currentState!.validate()){

      currentUser = firebaseAuth.currentUser;

      if(currentUser!=null){
        Map userMap ={
          "id":currentUser!.uid,
          "from":fromAddressController.text.trim(),
          "to":toAddressController.text.trim(),
          "date":dateController.text.trim(),
          "time":timeController.text.trim(),
          "booked":false

        };

        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("Future Rides");
        userRef.child(currentUser!.uid).set(userMap);
      }
      await Fluttertoast.showToast(msg: "Successfully Submitted");
      Navigator.push(context,MaterialPageRoute(builder: (c)=>MainScreen()));

    }

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
      appBar: AppBar(title: Text("Ride Give For Future",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.black),),),
      body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
      key: _formKey,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
      TextFormField(
      controller: fromAddressController ,
      decoration: InputDecoration(
      hintText: "From"
      ),

      ),
      TextFormField(
      controller: toAddressController ,
      decoration: InputDecoration(
      hintText: "To"
      ),



      ),

      TextField(
      controller: dateController,
      //editing controller of this TextField
      decoration: InputDecoration(
      icon: Icon(Icons.calendar_today,color:  Colors.black45,), //icon of text field
      labelText:
      "Enter Date of Departure" ,labelStyle: TextStyle(color: Colors.black45),focusedBorder:
      UnderlineInputBorder(
      borderSide: BorderSide(
      color: Color(0xFF632DC6))),//label text of field
      ),
      readOnly: true,
      //set it true, so that user will not able to edit text
      onTap: () async {
      DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      //DateTime.now() - not to allow to choose before today.
      lastDate: DateTime(2101));

      if (pickedDate != null) {
      String formattedDate =
      DateFormat('yyyy-MM-dd ').format(pickedDate);
      setState(() {
      dateController.text =
      formattedDate; //set output date to TextField value.
      });
      } else {
      print("Date is not selected");
      }
      },
      ),

      TextField(
      controller: timeController,
      //editing controller of this TextField
      decoration: InputDecoration(
      icon: Icon(Icons.timer,color:  Colors.black45,), //icon of text field
      labelText: "Enter Time",labelStyle: TextStyle(color: Colors.black45),
      focusedBorder:
      UnderlineInputBorder(
      borderSide: BorderSide(
      color: Color(0xFF632DC6))),
      ),
      readOnly: true,
      //set it true, so that user will not able to edit text
      onTap: () async {
      TimeOfDay? pickedTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
      );

      if (pickedTime != null) {
      DateTime parsedTime = DateFormat('HH:mm')
          .parse(pickedTime.format(context).toString());

      String formattedTime =
      DateFormat('HH:mm').format(parsedTime);

      setState(() {
      timeController.text = formattedTime;
      });
      } else {
      print("Time is not selected");
      }
      },
      ),

      SizedBox(
      height: 10,
      ),

      ElevatedButton(
      style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,

      elevation: 0,
      shape: RoundedRectangleBorder(
      borderRadius:  BorderRadius.circular(32)

      ),
      minimumSize: Size(double.infinity,50)
      ),
      onPressed: (){
      _submit();
      },
      child: Text('Submit Ride',style: TextStyle(fontSize: 20,color: Colors.white),)
      )






      ],
      ),
      ),
      ),

      ),
    );
  }
}
