import 'package:clay_containers/clay_containers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clubhouse/models/club.dart';
import 'package:clubhouse/models/userModel.dart';
import 'package:clubhouse/screens/clubScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class UpcomingClub extends StatelessWidget {
  final UserModel user;
  UpcomingClub(this.user);
  @override
  Widget build(BuildContext context) {
     return StreamBuilder<QuerySnapshot>(
       stream: FirebaseFirestore.instance.collection('clubs').where('status', isEqualTo: 'new').where('dateTime',isLessThan: DateTime.now().add(Duration(days: 7))).snapshots(),
       builder: (context,snapshot){
         if(snapshot.hasData){
           if(snapshot.data.docs.length < 1){
             return Container(
               margin: EdgeInsets.only(top: 30),
               child: Column(
                 children: [
                   Icon(Icons.face_sharp,size: 100,),
                   Text("No Clubs available"),
                   Text("Create your own Club"),
                 ],
               ),
             );
           }

           return ListView.builder(
             physics: NeverScrollableScrollPhysics(),
             shrinkWrap: true,
             itemCount: snapshot.data.docs.length,
             itemBuilder: (context,index){
               var data = snapshot.data.docs[index];
               Club clubDetail = new Club.fromMap(data);

               DateTime dateTime = DateTime.parse(clubDetail.dateTime.toDate().toString());
               var formattedDateTime = DateFormat.MMMd().add_jm().format(dateTime);

               return GestureDetector(
                 onTap: ()async{
                   PermissionStatus micStatus = await PermissionHandler().checkPermissionStatus(PermissionGroup.microphone);
                   if(micStatus != PermissionStatus.granted){
                     await PermissionHandler().requestPermissions([PermissionGroup.microphone]);
                   }
                   Navigator.push(context, MaterialPageRoute(builder: (context)=>ClubScreen(clubDetail, user)));
                 },
                 child: Container(
                   margin: EdgeInsets.symmetric(horizontal: 15,vertical: 5),

                   child: ClayContainer(
                     borderRadius: 10,
                     depth: 100,
                     color: Get.isDarkMode? Colors.grey[800] : Colors.white,

                     spread: 2,
                     child: Padding(padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${clubDetail.title}",style: TextStyle(fontSize: 18),),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Icon(Icons.wysiwyg),
                              SizedBox(width: 5,),
                              Text("${clubDetail.category}"),
                              SizedBox(width: 80,),
                              Icon(Icons.alarm),
                              SizedBox(width: 5,),
                              Text("$formattedDateTime"),

                            ],
                          ),
                          SizedBox(height: 15,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(clubDetail.type=='public'?Icons.public:Icons.lock),
                              SizedBox(width: 20,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: clubDetail.speakers.map((speaker)=>Text(speaker.values.last)).toList(),
                              )
                            ],
                          ),
                        ],
                      ),
                     ),
                   ),
                 ),
               );


             });

         }
         return Container(
           height: 300,
           child: Center(
             child: ListTile(
               title: LoadingAnimationWidget.inkDrop(
                 color: Colors.indigo,
                 size: 40,
               ),
               subtitle: Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Text("No Upcoming clubs yet",
                 style: GoogleFonts.lobster(

                 ),
                 textAlign: TextAlign.center,),
               ),
             )
           ),
         );
       });
  }
}