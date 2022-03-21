import 'package:clay_containers/clay_containers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clubhouse/constants/app_theme.dart';
import 'package:clubhouse/screens/createAClub.dart';
import 'package:clubhouse/screens/myClubs.dart';
import 'package:clubhouse/screens/splashScreen.dart';

import 'package:clubhouse/widgets/ongoing_club.dart';
import 'package:clubhouse/widgets/upcoming_club.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/userModel.dart';
import './inviteScreen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  HomeScreen({@required this.user});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    final TextEditingController nameController = TextEditingController(text: widget.user.name);
    if(widget.user.name==""){
      Future.microtask(() => showDialog(context: context,
          builder: (context){
            return ClayContainer(
              depth: -50,
              child: AlertDialog(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                title: Text("Your Name",style: GoogleFonts.lobster(
                    fontSize: 22
                ),),
                content: ClayContainer(
                  borderRadius: 10,
                  depth: -50,
                  spread: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter your Full name...",
                          hintStyle: GoogleFonts.cairo()
                      ),

                    ),
                  ),
                ),
                actions: [
                  Center(
                    child: InkWell(

                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1)
                          ),
                          child: Text("Update",style: GoogleFonts.lobster(
                              fontSize: 22
                          ),)),
                      onTap: (){
                        if(nameController.text != ""){
                          FirebaseFirestore.instance.collection('users').doc( widget.user.uid).update({
                            'name':nameController.text,
                          }).then((value) {
                            widget.user.name = nameController.text;
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen(user:  widget.user)));
                          });
                        }
                      },),
                  )
                ],
              ),
            );
          }));
    }



    super.initState();
    
  }
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<ThemeProvider>(context);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Get.isDarkMode? Colors.grey[600]: Colors.grey[200],
        elevation: 10,
        icon: Icon(Icons.add,color:Get.isDarkMode? Colors.white70 : Colors.black,),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateAClub(widget.user)));
          }, label: Text("Create Club", style: GoogleFonts.lobster(
          color: Get.isDarkMode? Colors.white70: Colors.black,
          fontSize: 20
      ),),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color:Get.isDarkMode? Colors.white70 :  Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text("Home",style: GoogleFonts.lobster(color:Get.isDarkMode? Colors.white70 :  Colors.black,
        fontSize: 24),),
        centerTitle: true,
        leading: Icon(Icons.keyboard_backspace,color:Get.isDarkMode? Colors.grey[850] :  Colors.white,),
        actions: [
          IconButton(icon: Icon(Icons.power_settings_new_outlined), onPressed: ()async{
            FirebaseAuth.instance.signOut().then((value){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SplashScreen()));
            });

          })
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                 ClayContainer(
                  borderRadius: 10,
                  depth: 100,
                  spread: 2,
                   color: Get.isDarkMode? Colors.grey[800] : Colors.white,

                   child: IconButton(
                      onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>MyClubsScreen(widget.user)));

                  },
                      icon: Icon(Icons.mic)),
                ),
                ClayContainer(
                  borderRadius: 10,
                  depth: 100,
                  spread: 2,
                  color: Get.isDarkMode? Colors.grey[800] : Colors.white,

                  child: IconButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>InviteScreen(widget.user)));

                  },
                      icon: Icon(Icons.insert_invitation)),
                ),
                ClayContainer(
                  borderRadius: 10,
                  depth: 100,
                  spread: 2,
                  color: Get.isDarkMode? Colors.grey[800] : Colors.white,

                  child: IconButton(onPressed: (){
                    setState(() {
                      Get.isDarkMode ? themeChange.darkTheme = false : themeChange.darkTheme =true;
                      Get.changeTheme(Get.isDarkMode? ThemeData.light(): ThemeData.dark());

                      print(themeChange.darkTheme);

                    });
                  },
                      icon: Icon(Icons.dark_mode)),
                ),
              ],
            ),
            SizedBox(height: 10,),

            OngoingClub(widget.user),
            SizedBox(height: 10,),
            Text("Upcoming Week",style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),),
            SizedBox(height: 10,),
            Icon(Icons.arrow_circle_down),
            UpcomingClub(widget.user)



          ],
        ),
      ),
      
    );
  }
}