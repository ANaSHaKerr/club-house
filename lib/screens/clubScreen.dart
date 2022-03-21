import 'package:clay_containers/clay_containers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clubhouse/models/club.dart';
import 'package:clubhouse/models/userModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../constants/agora.dart';

class ClubScreen extends StatefulWidget {
  final UserModel user;
  final Club club;
  ClubScreen(this.club,this.user);

  @override
  _ClubScreenState createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  RtcEngine _engine;
  ClientRole role = ClientRole.Audience;
  List updatedSpeakers = [];

  void addSpeaker(){
    updatedSpeakers.add({
      "name":widget.user.name,
      'phone':widget.user.phone,
    });
  }

  @override
  void initState() { 
    updatedSpeakers = widget.club.speakers;

    listenDatabase();
    widget.club.speakers.forEach((speaker) {
      if(speaker['phone'] == widget.user.phone){
        setState(() {
          role = ClientRole.Broadcaster;
        });
      }
     });
     if(role == ClientRole.Audience){
       initialize();
     }
    super.initState();
    
  }

  void listenDatabase(){
    FirebaseFirestore.instance.collection('clubs').doc(widget.club.clubId).snapshots().listen((event) {
      var clubData = event.data();
      if(clubData['status'] != widget.club.status){
        setState(() {
          widget.club.status = clubData['status'];
        });
      }
       List allSpeakers = clubData['invited'];
       updatedSpeakers = allSpeakers;
    });
  }

  @override
  void dispose() { 
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  Future<void> initialize()async{
    if(AGORA_ID.isEmpty){
      setState(() {
        _infoStrings.add("APP_ID missing, please provide it");
         _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.joinChannel(null, widget.club.clubId, null, 0);
  }

  Future<void> _initAgoraRtcEngine()async{
    _engine = await RtcEngine.create(AGORA_ID);
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(role);
  }

   void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    }, leaveChannel: (stats) {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    }));
  }

  Widget toolbar(){
    if(widget.club.status == "finished"){
      return Container(
        height: 80,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20,vertical:12),
        child: Column(children: [
          Text("Club is finished",style: TextStyle(
            fontSize: 20,color: Colors.black
          ),),
          SizedBox(height: 5,),
          Text("Thank you for listening",style: TextStyle(fontSize: 18),),
        ],),
      );
    }else if(widget.club.status=="new"){
      if(widget.club.createdBy==widget.user.phone){
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 12),
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClayContainer(
                borderRadius: 10,
                depth: 100,
                spread: 2,
                width: 150,

                color: Get.isDarkMode? Colors.grey[800] : Colors.white,
                child: TextButton.icon(
                    onPressed: (){
                  Navigator.pop(context);
                }, icon: Icon(Icons.exit_to_app,color: Get.isDarkMode? Colors.white70 : Colors.black,), label: Text("Exit Club",
                style: TextStyle(color: Get.isDarkMode? Colors.white70 : Colors.black,),)),
              ),

              ClayContainer(
                borderRadius: 10,
                depth: 100,
                spread: 2,
                width: 150,

                color: Get.isDarkMode? Colors.grey[800] : Colors.white,
                child: TextButton.icon(

                    onPressed: ()async{
                     await FirebaseFirestore.instance.collection('clubs').doc(widget.club.clubId).update({
                        "status":"ongoing"
                      });
                      setState(() {
                        widget.club.status = "ongoing";
                      });
                      await initialize();
              }, icon: Icon(CupertinoIcons.mic_circle_fill,color: Get.isDarkMode? Colors.white70 : Colors.black,),
                  label: Text("Start the Club",style: TextStyle(color: Get.isDarkMode? Colors.white70 : Colors.black,),),),
                )
            ],),
        );
      }else{
        DateTime dateTime = DateTime.parse(widget.club.dateTime.toDate().toString());
        var formattedDateTime = DateFormat.MMMMEEEEd().add_jm().format(dateTime);
        return Container(
          height: 80,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 12),
          child: Column(
            children: [
              Text("Club is scheduled to start on",style: TextStyle(
                fontSize: 20,color:Colors.black,
              ),),
              SizedBox(height: 5,),
              Text("$formattedDateTime",style: TextStyle(fontSize: 18,color: Colors.red),),
            ],
          ),
        );
      }
    }else if(role == ClientRole.Audience){
      return Container(

        padding: EdgeInsets.symmetric(horizontal: 20,vertical:12),
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClayContainer(
              borderRadius: 10,
              depth: 100,
              spread: 2,
              width: 150,

              color: Get.isDarkMode? Colors.grey[800] : Colors.white,
              child: TextButton.icon(  onPressed: (){
                Navigator.pop(context);
              }, icon: Icon(Icons.exit_to_app), label: Text("Exit Club")),
            ),
            SizedBox(width: 15,),
            widget.club.type == "public" ? ElevatedButton.icon(onPressed: (){
              addSpeaker();
              FirebaseFirestore.instance.collection('clubs').doc(widget.club.clubId).update({
                'invited':updatedSpeakers
              }).then((value){
                setState(() {
                  role = ClientRole.Broadcaster;
                });
                initialize();
              });

            }, icon: Icon(CupertinoIcons.hand_raised), label: Text("Join Discussion")):SizedBox.shrink()
          ],
        ),
      );
    }else if(role == ClientRole.Broadcaster){
       return Container(
         height: 80,
         child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
           children: [
             ClayContainer(
               borderRadius: 25,
               depth: 100,
               spread: 2,
               width: 40,
               height: 40,
               color: Get.isDarkMode? Colors.grey[800] : Colors.white,
               child: InkWell(
                 onTap: _onToggleMute,
                 child: Icon(
                   muted ? Icons.mic_off : Icons.mic,
                   color: Get.isDarkMode? Colors.white70 : Colors.black,
                   size: 25,
                 ),

               ),
             ),

             widget.club.createdBy == widget.user.phone ? ClayContainer(
               borderRadius: 10,
               depth: 100,
               spread: 2,
               width: 150,

               color: Get.isDarkMode? Colors.grey[800] : Colors.white,
               child: TextButton.icon(
                   onPressed: (){
                    FirebaseFirestore.instance.collection('clubs').doc(widget.club.clubId).update({
                      'status':'finished'
                    });
                    Navigator.pop(context);
               }, icon: Icon(Icons.exit_to_app,color: Get.isDarkMode ? Colors.white70 :Colors.black,),
                   label: Text("End Club",style: TextStyle(color: Get.isDarkMode ? Colors.white70 :Colors.black,),)),
             ):
             ClayContainer(
               borderRadius: 10,
               depth: 100,
               spread: 2,
               width: 150,

               color: Get.isDarkMode? Colors.grey[800] : Colors.white,
               child: TextButton.icon(
                   onPressed: (){
                    Navigator.pop(context);
               }, icon: Icon(Icons.exit_to_app,color: Get.isDarkMode ? Colors.white70 :Colors.black,),
                   label: Text("Exit Club",style: TextStyle(
                     color: Get.isDarkMode ? Colors.white70 :Colors.black,
                   ),)),
             )
           ],
         ),
       );
    }
  }


  void _onToggleMute(){
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
    updatedSpeakers.forEach((speaker) {
      if(speaker['phone']==widget.user.phone){
        speaker['mic'] = muted;
      }
     });

     FirebaseFirestore.instance.collection('clubs').doc(widget.club.clubId).update({
       'invited':updatedSpeakers
     });
  }



  @override
  Widget build(BuildContext context) {
    print("Agora Events");
    print(_infoStrings.toString());
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color:Get.isDarkMode ? Colors.white70: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height,
          width: double.infinity,

          child:  ClayContainer(
            borderRadius: 40,
            depth: 100,
            spread: 1,
            color: Get.isDarkMode? Colors.grey[800] : Colors.white,
            child: Column(
              children: [
              Icon(Icons.mic,size: 140,color: Colors.grey,),
                SizedBox(height: 20,),
                Text(widget.club.title,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                Text(widget.club.category,style: TextStyle(fontSize: 20),),
                SizedBox(height: 50,),

                Row(
                  children: [
                    Expanded(child: Divider()),
                     Text(" Speakers ",style: TextStyle(color: Colors.grey),),
                      Expanded(child: Divider()),
                  ],
                ),

                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('clubs').doc(widget.club.clubId).snapshots(),
                  builder: (context,AsyncSnapshot snapshot){
                    if(snapshot.hasData){
                      var speakers = snapshot.data.data();

                      return Expanded(child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: speakers['invited'].length,
                        itemBuilder: (context,index){
                          return ListTile(
                            leading:  ClayContainer(
                              borderRadius: 20,
                              depth: 100,
                              spread: 2,
                              color: Get.isDarkMode? Colors.grey[800] : Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.person,size: 25,),
                              ),
                            ),
                            trailing:speakers['invited'][index]['mic'] == true ? Icon(Icons.mic_off):Icon(Icons.mic,color: Colors.green,),

                            title: Text(speakers['invited'][index]['name'],
                            style: TextStyle(fontWeight: FontWeight.bold),),
                          );

                      }));
                    }
                    return LoadingAnimationWidget.inkDrop(
                      color: Colors.indigo,
                      size: 40,
                    );
                  }),
              ],
            ),
          ),
        ),
      ),

      bottomSheet: toolbar(),
      
    );
  }
}