import 'package:clay_containers/clay_containers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/userModel.dart';
import '../../widgets/NumericPad.dart';
import '../homeScreen.dart';
import '../notInvitedScreen.dart';

class VerifyPhone extends StatefulWidget {

  final String phoneNumber;
  final String verificationCode;

  VerifyPhone({@required this.phoneNumber,this.verificationCode});

  @override
  _VerifyPhoneState createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {

  String code = "";

  bool isLoading = false;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            size: 24,
            color: Get.isDarkMode? Colors.white70 : Colors.black38,
          ),
        ),
        title: Text(
          "Verify phone",
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[

              Expanded(
                child: Container(
                  color:Get.isDarkMode? Colors.grey[800] :  Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          "Code is sent to " + widget.phoneNumber,
                          style: TextStyle(
                            fontSize: 22,
                            color:Get.isDarkMode? Colors.white70 :  Color(0xFF818181),
                          ),
                        ),
                      ),

                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[

                            buildCodeNumberBox(code.length > 0 ? code.substring(0, 1) : ""),
                            buildCodeNumberBox(code.length > 1 ? code.substring(1, 2) : ""),
                            buildCodeNumberBox(code.length > 2 ? code.substring(2, 3) : ""),
                            buildCodeNumberBox(code.length > 3 ? code.substring(3, 4) : ""),
                            buildCodeNumberBox(code.length > 4 ? code.substring(4,5) : ""),
                            buildCodeNumberBox(code.length > 5 ? code.substring(5, 6) : ""),

                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),

              Container(
                height: MediaQuery.of(context).size.height * 0.13,
                decoration: BoxDecoration(
                  color:Get.isDarkMode? Colors.grey[800] :  Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[

                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              otpSignIn();
                            });
                          },
                          child: ClayContainer(
                            color: Get.isDarkMode? Colors.grey[800] :  Colors.grey[50],
                            curveType: CurveType.concave,

                            borderRadius: 15,
                            depth: 40,
                            child: Center(
                              child: Text(
                                "Verify and Create Account",
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
                  print(value);
                  setState(() {
                    if(value != -1){
                      if(code.length < 6){
                        code = code + value.toString();
                      }
                    }
                    else{
                      code = code.substring(0, code.length - 1);
                    }
                    print(code);
                  });
                },
              ),

            ],
          )
      ),
    );
  }

  Widget buildCodeNumberBox(String codeNumber) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: ClayContainer(
        color: Get.isDarkMode? Colors.grey[800] :  Colors.grey[100],
        curveType: CurveType.concave,

        borderRadius: 15,
        depth: 20,
        width: 55,
        height: 55,
        child: Center(
          child: Text(
            codeNumber,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color:Get.isDarkMode? Colors.white70 :  Color(0xFF1F1F1F),
            ),
          ),
        ),
      ),
    );
  }
  Future otpSignIn()async{
    setState(() {
      isLoading = true;
    });

    try{
      _firebaseAuth.signInWithCredential(PhoneAuthProvider.credential(verificationId: widget.verificationCode, smsCode: code)).then((userData)async{
        UserModel user;
        if(userData != null ){

          var userExist = await _firestore.collection('users').where('phone', isEqualTo: widget.phoneNumber).get();

          if(userExist.docs.length > 0){
            print("USER ALREADY EXISTS");
            user = UserModel.fromMap(userExist.docs.first);
          }else{
            print("New User Created");
            user = UserModel(
              name: '',
              phone: userData.user.phoneNumber,
              invitesLeft: 5,
              uid: userData.user.uid,
            );
            await _firestore.collection('users').doc(userData.user.uid).set(UserModel().toMap(user));

          }

          var userInvited = await _firestore.collection('invites').where('invitee',isEqualTo: widget.phoneNumber).get();
          if(userInvited.docs.length < 1){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NotInvitedScreen()));
            return;
          }

          setState(() {
            isLoading = false;
          });
          print("Login Successful");

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen(user: user,)));



        }
      });
    }catch(e){
      print(e.toString());

    }
  }
}