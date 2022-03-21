import 'package:clay_containers/clay_containers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/userModel.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../widgets/NumericPad.dart';


class InviteScreen extends StatefulWidget {
  final UserModel user;
  InviteScreen(this.user);
  @override
  _InviteScreenState createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final TextEditingController inviteController = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  var selectedName = "";





  @override
  void dispose() {
    inviteController.clear();
    inviteController.dispose();
    super.dispose();
  }

  Future selectContact()async{
    if (await FlutterContacts.requestPermission()) {
      var contact = await FlutterContacts.openExternalPick();
      if(contact != null){
        setState(() {
          inviteController.text = contact.phones.single.normalizedNumber;
          selectedName = contact.name.first;
        });
      }else{
        print("No contact Selected");
      }
    }
  }


  Future inviteFriend()async{
    if(widget.user.invitesLeft < 1){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("No Invite Left"),
      ));
      return;
    }
    if(inviteController.text.trim().length > 8){
      setState(() {
        isLoading = true;
      });
      String number ;
      inviteController.text.startsWith("+") ? number = inviteController.text :
          number = countryCode + inviteController.text;
      _firestore.collection('invites').add({
        'invitee':number,
        'invitedBy': widget.user.phone,
        'date':DateTime.now(),
      }).then((value){
        int invitesLeft = widget.user.invitesLeft - 1;
        _firestore.collection('users').doc(widget.user.uid).update({
          'invitesLeft':invitesLeft,
        }).then((value){
          setState(() {
            widget.user.invitesLeft = invitesLeft;
            isLoading = false;
            inviteController.text = "";
            selectedName = "";
          });
        });
      });
    }
  }


 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Invite Friend",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Get.isDarkMode? Colors.white70 : Colors.black,
          ),
        ),
        backgroundColor: Get.isDarkMode? Colors.grey[800] : Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarTextStyle: Theme.of(context).textTheme.bodyText2, titleTextStyle: Theme.of(context).textTheme.headline6,
      ),
      body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                  top: 0,
                  right: 10,
                  child: ClayContainer(
                    color:  Get.isDarkMode? Colors.grey[800] : Colors.grey[100],
                    curveType: CurveType.convex,

                    depth: 40,
                    borderRadius: 25,
                    height: 50,
                    child: IconButton(
                      icon: Icon(Icons.contacts_outlined),
                      onPressed: (){
                        setState(() {
                          selectContact();
                        });
                      },
                    ),
                  )),
              Column(
                children: <Widget>[

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Get.isDarkMode? Colors.grey[800] :  Color(0xFFFFFFFF),
                            Get.isDarkMode? Colors.grey[700] :  Color(0xFFF7F7F7),
                          ],

                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[

                          SizedBox(
                            height: 130,
                            child: Image.asset(
                                'images/image6.png'
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 64),
                            child: Text(
                              "Invites Left : ${widget.user.invitesLeft}",
                              style: TextStyle(
                                fontSize: 22,
                                color:  Get.isDarkMode? Colors.white70 :Color(0xFF818181),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),

                  ClayContainer(
                    color:  Get.isDarkMode? Colors.grey[800] : Colors.grey[100],
                    curveType: CurveType.convex,
                    spread:Get.isDarkMode ?  0 : 1,
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
                                  "Phone Number",
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
                                  inviteController.text,
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
                                  inviteFriend();
                                });
                              },
                              child: ClayContainer(
                                color:  Get.isDarkMode? Colors.grey[800] : Colors.grey[100],
                                curveType: CurveType.concave,
                                borderRadius: 15,
                                depth: 20,
                                child: Center(
                                  child: Text(
                                    "Invite",
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
                          inviteController.text = inviteController.text + value.toString();
                        }
                        else{
                          inviteController.text = inviteController.text.substring(0, inviteController.text.length - 1);
                        }
                      });
                    },
                  ),

                ],
              )
            ],
          )
      ),
    );

  }
}