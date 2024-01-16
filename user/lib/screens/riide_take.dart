import 'package:flutter/material.dart';
import 'package:users/screens/main_page.dart';

import 'list_of_driver_ride.dart';


class RideTakeScreen extends StatefulWidget {
  const RideTakeScreen({super.key});

  @override
  State<RideTakeScreen> createState() => _RideTakeScreenState();
}

class _RideTakeScreenState extends State<RideTakeScreen> {

  final fromAddressController = new TextEditingController();
  final toAddressController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ride Take",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),centerTitle: true,),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
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
                      minimumSize: Size(100,50)
                  ),
                  onPressed: (){
                    print(fromAddressController.text);
                    Navigator.push(context, MaterialPageRoute(builder: (c)=>DriverRideList(sourceLocation: fromAddressController.text,)));

                  },
                  child: Text('Search Ride',style: TextStyle(fontSize: 20,color: Colors.white),)
              )



            ],
          ),

        ),
      )
    );
  }
}
