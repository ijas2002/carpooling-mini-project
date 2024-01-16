import 'package:drivers/screens/profile_screen.dart';
import 'package:flutter/material.dart';

import '../global/global.dart';
import '../splashScreen/splash_screen.dart';



class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: 220,
      child: Drawer(
        child: Padding(
          padding:  EdgeInsets.fromLTRB(30, 50, 0,20),
         
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              
              children: [
              Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.lightBlue,shape: BoxShape.circle),
            child: Icon(Icons.person,color: Colors.white,),
           ),
      
           SizedBox(height: 20,),
           
           Text(userModelCurrentInfo!.name!,style: TextStyle(
            fontSize: 20,fontWeight: FontWeight.bold
           ),),
      
           SizedBox(height: 10,),
           GestureDetector(
            onTap: (){

              Navigator.push(context,MaterialPageRoute(builder: (c)=>ProfileScreen()));


      
            },
      
            child: Text("Edit Profile",
            style: TextStyle(
            fontSize: 20,fontWeight: FontWeight.bold,color: Colors.blue
           ),
            ),
           ),
           SizedBox(height: 10,),
      
           Text("Your Trip",style: TextStyle(
            fontSize: 15,fontWeight: FontWeight.bold
           ),),
      
           SizedBox(height: 10,),
      
           Text("Payment",style: TextStyle(
            fontSize: 15,fontWeight: FontWeight.bold
           ),),
           SizedBox(height: 10,),
      
           Text("Notifications",style: TextStyle(
            fontSize: 15,fontWeight: FontWeight.bold
           ),),
      
           SizedBox(height: 10,),
      
           Text("Promos",style: TextStyle(
            fontSize: 15,fontWeight: FontWeight.bold
           ),),
      
           SizedBox(height: 10,),
      
           Text("Help",style: TextStyle(
            fontSize: 15,fontWeight: FontWeight.bold
           ),),
      
           SizedBox(height: 10,),
      
           Text("Free Trip",
           style: TextStyle(
            fontSize: 15,fontWeight: FontWeight.bold
           ),
           ),
      

            ],),

          GestureDetector(
            onTap: (){
              firebaseAuth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (c)=>SplashScreen()));
            },
            child: Text("LogOut", style: TextStyle(
            fontSize: 15,fontWeight: FontWeight.bold,color: Colors.red
           ),),
          )

      
           
           
      
          ],
        ),
        
        
        
        ),
      ),

      
    );
  }
}