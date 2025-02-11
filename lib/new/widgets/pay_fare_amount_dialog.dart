import 'package:car_pooling/new/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class PayFareAmountDialog extends StatefulWidget {

  double? fareAmount;

  PayFareAmountDialog({this.fareAmount});
  @override
  State<PayFareAmountDialog> createState() => _PayFareAmountDialogState();
}

class _PayFareAmountDialogState extends State<PayFareAmountDialog> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery
            .of(context)
            .platformBrightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
            color: darkTheme? Colors.black: Colors.blue,
                borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20,),
            Text("Fare Amount".toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
                color: darkTheme? Colors.amber.shade400: Colors.blue
            ),),
            SizedBox(height: 20,),

            Divider(
              thickness: 2,
              color:  darkTheme? Colors.amber.shade400:Colors.white,
            ),

            SizedBox(height: 10,),

            Text(
              "Rs. "+widget.fareAmount.toString(),
              style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: darkTheme? Colors.amber.shade400: Colors.blue
              ),
            ),

            SizedBox(height: 10,),

            Padding(padding: EdgeInsets.all(10),
            child: Text(
              "This is the total trip fare amount. Please pay it to the driver",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: darkTheme? Colors.amber.shade400: Colors.blue
              ),
            ),
            ),

            SizedBox(height: 10,),

            Padding(padding: EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                Future.delayed(Duration(milliseconds: 10000),(){
                  Navigator.pop(context, "Cash Paid");
                  Navigator.push(context, MaterialPageRoute(builder: (c)=>SplashScreen()));
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: darkTheme? Colors.amber.shade400: Colors.blue
              ),

              child: Row(
                children: [
                  Text("Pay Cash",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkTheme? Colors.black: Colors.blue
                    ),
                  ),

                  Text(
                    "Rs. "+widget.fareAmount.toString(),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkTheme? Colors.black: Colors.blue
                    ),
                  ),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
