import 'package:clay_containers/clay_containers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/NumericPad.dart';
import 'codeScreen.dart';


class ContinueWithPhone extends StatefulWidget {
  @override
  _ContinueWithPhoneState createState() => _ContinueWithPhoneState();
}

class _ContinueWithPhoneState extends State<ContinueWithPhone> {
  String phoneNumber = "";
  bool isLoading = false;
  var verificationCode;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sign With Phone",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color:Get.isDarkMode? Colors.white70 :  Colors.black,
          ),
        ),
        backgroundColor:Get.isDarkMode? Colors.grey[800] :  Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarTextStyle: Theme.of(context).textTheme.bodyText2, titleTextStyle: Theme.of(context).textTheme.headline6,
      ),
      body: SafeArea(
          child: Column(
            children: <Widget>[

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Get.isDarkMode? Colors.grey[800] :   Color(0xFFFFFFFF),
                        Get.isDarkMode? Colors.grey[800] :  Color(0xFFF7F7F7),
                      ],

                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      SizedBox(
                        height: 130,
                        child: Image.asset(
                            'images/holding-phone.png'
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 64),
                        child: Text(
                          "You'll receive a 6 digit code to verify next.",
                          style: TextStyle(
                            fontSize: 22,
                            color: Color(0xFF818181),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),

              ClayContainer(
                color:Get.isDarkMode? Colors.grey[800] :   Colors.grey[100],
                curveType: CurveType.convex,

                depth: 10,
                height: MediaQuery.of(context).size.height * 0.13,

                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[


                      Container(
                        width: 230,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[

                            Text(
                              "Enter your phone",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),

                            SizedBox(
                              height: 8,
                            ),

                            Text(
                              phoneNumber,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          ],
                        ),
                      ),

                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                           setState(() {
                             phoneAuth();
                           });
                          },
                          child: ClayContainer(
                            color: Get.isDarkMode? Colors.grey[800] :  Colors.grey[100],
                            curveType: CurveType.concave,
                            spread: Get.isDarkMode ? 0.5 :1,

                            borderRadius: 15,
                            depth: 20,
                            child: Center(
                              child: Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),

              NumericPad(
                onNumberSelected: (value) {
                  setState(() {
                    if(value != -1){
                      phoneNumber = phoneNumber + value.toString();
                    }
                    else{
                      phoneNumber = phoneNumber.substring(0, phoneNumber.length - 1);
                    }
                  });
                },
              ),

            ],
          )
      ),
    );
  }
  Future phoneAuth()async{
    setState(() {
      isLoading = true;
    });


    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: countryCode+ phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential){
          _firebaseAuth.signInWithCredential(credential).then((userData)async{
            if(userData!=null){
              await _firestore.collection('users').doc(userData.user.uid).set({
                'name':'',
                'phone':userData.user.phoneNumber,
                'uid':userData.user.uid,
                'invitesLeft':5,
              });

              setState(() {
                isLoading = false;
              });
            }
          });

        },
        verificationFailed: (FirebaseAuthException error){
          print("Firebase Error : ${error.message}");
        },
        codeSent: (String verificationId,int resendToken){
          setState(() {
            isLoading = false;
            verificationCode = verificationId;
            Navigator.push(context, MaterialPageRoute(builder: (context)=>VerifyPhone(phoneNumber: countryCode+ phoneNumber,verificationCode: verificationId,)));
          });
        },
        codeAutoRetrievalTimeout: (String verificationId){
          setState(() {
            isLoading = false;
            verificationCode = verificationId;
            Navigator.push(context, MaterialPageRoute(builder: (context)=>VerifyPhone(phoneNumber: countryCode+ phoneNumber,verificationCode: verificationId,)));

          });
        },timeout: Duration(seconds: 120));

  }
}