import 'package:drivers/splashScreen/splash_screen.dart';
import 'package:flutter/material.dart';

class FareAmountCollectionDialog extends StatefulWidget {

  double? totalFareAmount;
   FareAmountCollectionDialog({this.totalFareAmount});

  @override
  State<FareAmountCollectionDialog> createState() => _FareAmountCollectionDialogState();
}

class _FareAmountCollectionDialogState extends State<FareAmountCollectionDialog> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness==Brightness.dark;


    return  Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
          color: darkTheme? Colors.black:Colors.blue,
          borderRadius: BorderRadius.circular(20)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20,),
            Text(
              //trip fare amount
              "Trip Fare Amount",

                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkTheme? Colors.amber.shade400:Colors.white,

                  ),

            ),
            Text(
              "Rs"+widget.totalFareAmount.toString(),

              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: darkTheme? Colors.amber.shade400:Colors.white,

              ),
            ),
            SizedBox(height: 10,),
            Padding(padding: EdgeInsets.all(8),
              child: Text(
                "this is Total Trip Amount PLease collect it from user",
                textAlign: TextAlign.center,
                style: TextStyle(
                  // fontSize: 50,
                  // fontWeight: FontWeight.bold,
                  color: darkTheme? Colors.amber.shade400:Colors.white,

                ),

              ),
             

            ),
            SizedBox(
height: 10,
            ),
            Padding(padding: EdgeInsets.all(8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary:  darkTheme? Colors.amber.shade400:Colors.white,
                ),
                onPressed: (){
                  Future.delayed(Duration(microseconds: 2000),(){
                    Navigator.push(context, MaterialPageRoute(builder: (c)=>SplashScreen()));
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "collect cash",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkTheme? Colors.black:Colors.blue,

                      ),
                    ),
                    Text(
                      "Rs."+widget.totalFareAmount.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkTheme? Colors.black:Colors.blue,

                      ),
                    )
                  ],
                ) ,
              ),


            )
          ],
        ),
      ),
    );
  }
}
