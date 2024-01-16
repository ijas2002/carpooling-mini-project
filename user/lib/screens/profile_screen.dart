import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users/global/global.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {


final nameTextEdititingController = TextEditingController();
final phoneTextEdititingController = TextEditingController();
final addressTextEdititingController = TextEditingController();

 DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");

Future <void> showUserNameDialogAlert(BuildContext context,String name){

  nameTextEdititingController.text = name;
  return showDialog(context: context, builder: (context){
    return AlertDialog(
      title: Text("Update"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameTextEdititingController,
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: (){
          Navigator.pop(context);
        }, child: Text("Cancel",style:TextStyle(color: Colors.red))
        ),
        TextButton(
          onPressed: (){
            userRef.child(firebaseAuth.currentUser!.uid).update({
              "name":nameTextEdititingController.text.trim()
            }).then((value){
              nameTextEdititingController.clear();
              Fluttertoast.showToast(msg: "Updated Successfully \n Reload The App to See Changes");

            }).catchError((errorMessage){

              Fluttertoast.showToast(msg: "Error Occured\n$errorMessage");

            });

          Navigator.pop(context);
        }, child: Text("Ok",style:TextStyle(color: Colors.black))
        )
      ],



    );

  });
}

Future <void> showUserAddressDialogAlert(BuildContext context,String address){

  addressTextEdititingController.text = address;
  return showDialog(context: context, builder: (context){
    return AlertDialog(
      title: Text("Update"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: addressTextEdititingController,
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: (){
          Navigator.pop(context);
        }, child: Text("Cancel",style:TextStyle(color: Colors.red))
        ),
        TextButton(
          onPressed: (){
            userRef.child(firebaseAuth.currentUser!.uid).update({
              "address":addressTextEdititingController.text.trim()
            }).then((value){
              addressTextEdititingController.clear();
              Fluttertoast.showToast(msg: "Updated Successfully \n Reload The App to See Changes");

            }).catchError((errorMessage){

              Fluttertoast.showToast(msg: "Error Occured\n$errorMessage");

            });

          Navigator.pop(context);
        }, child: Text("Ok",style:TextStyle(color: Colors.black))
        )
      ],



    );

  });
}

Future <void> showUserPhoneDialogAlert(BuildContext context,String phone){

  phoneTextEdititingController.text = phone;
  return showDialog(context: context, builder: (context){
    return AlertDialog(
      title: Text("Update"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: phoneTextEdititingController,
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: (){
          Navigator.pop(context);
        }, child: Text("Cancel",style:TextStyle(color: Colors.red))
        ),
        TextButton(
          onPressed: (){
            userRef.child(firebaseAuth.currentUser!.uid).update({
              "phone":phoneTextEdititingController.text.trim()
            }).then((value){
              phoneTextEdititingController.clear();
              Fluttertoast.showToast(msg: "Updated Successfully \n Reload The App to See Changes");

            }).catchError((errorMessage){

              Fluttertoast.showToast(msg: "Error Occured\n$errorMessage");

            });

          Navigator.pop(context);
        }, child: Text("Ok",style:TextStyle(color: Colors.black))
        )
      ],



    );

  });
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);

          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            ),
            
          
          ),
          title: Text("Profile Screen",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0.0,
        ),

        body: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(50),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    shape: BoxShape.circle
                  ),
                  child: Icon(Icons.person,color: Colors.white,),
                ),

                SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${userModelCurrentInfo!.name!}",
                      style: TextStyle(
                      fontSize:18,
                      fontWeight: FontWeight.bold),),

                    IconButton(onPressed: (){
                      showUserNameDialogAlert(context, userModelCurrentInfo!.name!);
                    },
                    icon:Icon(Icons.edit))

                           
                  ],
                ),
                Divider(thickness: 1,),
                   Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${userModelCurrentInfo!.phone!}",
                      style: TextStyle(
                      fontSize:18,
                      fontWeight: FontWeight.bold),),

                    IconButton(onPressed: (){
                      showUserPhoneDialogAlert(context, userModelCurrentInfo!.phone!);
                    },
                    icon:Icon(Icons.edit))

                           
                  ],
                ),
                  Divider(thickness: 1,),
                   Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${userModelCurrentInfo!.address!}",
                      style: TextStyle(
                      fontSize:18,
                      fontWeight: FontWeight.bold),),

                    IconButton(onPressed: (){
                      showUserAddressDialogAlert(context, userModelCurrentInfo!.address!);
                    },
                    icon:Icon(Icons.edit))

                           
                  ],
                ),

                Text("${userModelCurrentInfo!.email!}",
                      style: TextStyle(
                      fontSize:18,
                      fontWeight: FontWeight.bold),),

              ],
            ),
            )),

      ),
    );
  }
}