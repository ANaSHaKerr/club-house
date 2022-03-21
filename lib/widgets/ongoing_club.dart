import 'package:clay_containers/clay_containers.dart';
import 'package:clubhouse/models/club.dart';
import 'package:clubhouse/models/userModel.dart';
import 'package:clubhouse/screens/clubScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class OngoingClub extends StatelessWidget {
  final UserModel userModel;
  OngoingClub(this.userModel);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15),

      child: ClayContainer(
        borderRadius: 10,
        depth: -100,
        spread: 2,
        color: Get.isDarkMode? Colors.grey[800] : Colors.white,

        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('clubs').where('status',isEqualTo: 'ongoing').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
              if(snapshot.hasData){



                if(snapshot.data.docs.length < 1){

                  return Container(
                    width: double.infinity,
                    child: Text("No Ongoing Club at this moment",style: GoogleFonts.lobster(),
                    textAlign: TextAlign.center,
                    ),
                  );

                }

                return Column(
            children: snapshot.data.docs.map((club){
            DateTime dateTime = DateTime.parse(club['dateTime'].toDate().toString());
            var formattedTime = DateFormat.jm().format(dateTime);
            Club clubDetail = new Club.fromMap(club);
              return GestureDetector(
                 onTap: ()async{
                       PermissionStatus micStatus = await PermissionHandler().checkPermissionStatus(PermissionGroup.microphone);
                       if(micStatus != PermissionStatus.granted){
                         await PermissionHandler().requestPermissions([PermissionGroup.microphone]);
                       }
                       Navigator.push(context, MaterialPageRoute(builder: (context)=>ClubScreen(clubDetail, userModel)));
                     },
                          child: Padding(padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text("$formattedTime",style: TextStyle(color: Colors.green),),
                    SizedBox(width: 20,),
                    Flexible(child: Text("${clubDetail.title}",style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold
                    ),overflow: TextOverflow.ellipsis,))
                  ],
                ),
                ),
              );
            }).toList()
          );

              }
              return LinearProgressIndicator();
            }),
        ),
      )

    );
  }
}