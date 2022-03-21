import 'package:clay_containers/clay_containers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clubhouse/models/userModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'OTPScreens/phoneNumberScreen.dart';
import 'homeScreen.dart';
import 'notInvitedScreen.dart';

class SplashScreen extends StatefulWidget {

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  Future checkCurrentUser()async{
    await Future.delayed(const Duration(seconds: 2));

    if(_firebaseAuth.currentUser !=null){
      var userInvited =  await FirebaseFirestore.instance.collection('invites').where('invitee',isEqualTo: _firebaseAuth.currentUser.phoneNumber).get();
      if(userInvited.docs.length < 1){
        return NotInvitedScreen();
      }
      var userExist = await FirebaseFirestore.instance.collection('users').where('uid',isEqualTo:_firebaseAuth.currentUser.uid).get();
      UserModel user = UserModel.fromMap(userExist.docs.first);
      return HomeScreen(user: user);
    }else{
      return ContinueWithPhone();
    }
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: checkCurrentUser(),
        builder: (context,snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SafeArea(
                child: Scaffold(
                    body: Container(
                      color: Get.isDarkMode? Colors.grey[800]:Colors.grey[300],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Center(
                            child: ClayContainer(
                              color: Get.isDarkMode? Colors.grey[700]: Colors.grey[300],
                              width: 200,
                              height: 200,
                              borderRadius: 20,
                              depth: 20,
                              curveType: CurveType.concave,
                              child: Center(
                                  child: Image.asset("images/microphone.png",
                                    height: 80,
                                    color: Get.isDarkMode? Colors.white54: Colors.black26,
                                  )

                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text("Club House",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                  color: Get.isDarkMode? Colors.white54: Colors.black38
                              ),),
                          )

                        ],
                      ),
                    )
                )


            );
          } else {
            return snapshot.data;
          }
        });
  }
}