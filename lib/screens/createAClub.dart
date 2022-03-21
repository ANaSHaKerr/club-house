import 'package:clay_containers/clay_containers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clubhouse/models/userModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


class CreateAClub extends StatefulWidget {
  final UserModel user;
  CreateAClub(this.user);

  @override
  _CreateAClubState createState() => _CreateAClubState();
}

class _CreateAClubState extends State<CreateAClub> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _speakerController = TextEditingController();
  List<String> categories = [];
  List<Map> speakers = [];
  String selectedCategory = "";
  DateTime _dateTime;
  String type = "private";

  @override
  void initState() {
    fetchCategories();
    super.initState();

  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future fetchCategories()async{
    FirebaseFirestore.instance.collection('categories').get().then((value) {
      value.docs.forEach((element) {
        categories.add(element.data()['title']);
      });

      setState(() {

      });

    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color:Get.isDarkMode? Colors.white70 : Colors.black),
        centerTitle: true,
        title: Text("Create your Club",style: GoogleFonts.lobster(
            color: Get.isDarkMode? Colors.white70 : Colors.black,fontSize: 24),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ClayContainer(
                    borderRadius: 10,
                    depth: -50,
                    spread: 1,
                    color: Get.isDarkMode? Colors.grey[800]: Colors.grey[300],

                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextFormField(
                        validator: (value){
                          if(value==''){
                            return "Field is required";
                          }
                          return null;
                        },
                        controller:_titleController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter Discussion Topic/Title"
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30,),
                  ClayContainer(
                    borderRadius: 10,
                    depth: -50,
                    spread: 1,
                    color: Get.isDarkMode? Colors.grey[800]: Colors.grey[300],

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropDown<String>(
                        hint: Text("Select Category"),
                        items: categories,
                        onChanged: (value){
                          selectedCategory = value;
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 20,),
                  ListTile(
                    leading:  ClayContainer(
                      borderRadius: 10,
                      depth: -50,
                      spread: 1,
                      color: Get.isDarkMode? Colors.grey[800]: Colors.grey[300],

                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: speakers.length < 1 ? Icon(Icons.mic,color: Get.isDarkMode ? Colors.white70 : Colors.black,):Text("${speakers.length}",
                        style: TextStyle(color: Get.isDarkMode ? Colors.white70 :Colors.black,fontWeight: FontWeight.bold),),

                      ),
                    ),
                    title: Text("Invite Speakers"),
                    subtitle: Text("Optional"),
                    trailing:  ClayContainer(
                      borderRadius: 10,
                      depth: 100,
                      spread: 2,
                      color: Get.isDarkMode? Colors.grey[800]: Colors.white70,
                      curveType: CurveType.convex,
                      child: TextButton(onPressed: ()async{

                        if (await FlutterContacts.requestPermission()) {
                          var contact = await FlutterContacts.openExternalPick();
                          if(contact != null){
                            var phone = contact.phones.single.normalizedNumber;
                            FirebaseFirestore.instance.collection("users").where('phone',isEqualTo:phone).get().then((value){

                              if(value.docs.length > 0){
                                speakers.add({
                                  'name':value.docs.first.data()['name'],
                                  'phone':phone
                                });
                                //_speakerController.text="";
                                setState(() {

                                });

                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red,content: Text("No User Found. Please invite your Friend.",style: TextStyle(color: Colors.white),)));

                              }
                            });
                          }
                        }


                      }, child: Text("Add" , style: GoogleFonts.lobster(
                        color: Get.isDarkMode? Colors.white70: Colors.black38
                      ),)),
                    ),
                  ),



                  ...speakers.map((user){
                    var name = user.values.first;
                    var phone = user.values.last;
                    return ListTile(
                      leading: Icon(Icons.person),
                      title: Text(name),
                      subtitle: Text(phone),
                    );
                  }),

                  SizedBox(height: 20,),

                  Text("Select Date Time below",style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: 5,),

                  SizedBox(
                    height: 180,
                    child: ClayContainer(
                        borderRadius: 10,
                        depth: -100,
                        spread: 2,
                      color: Get.isDarkMode? Colors.grey[800]: Colors.grey[300],

                      child: CupertinoDatePicker(
                          initialDateTime: DateTime.now(),
                          mode: CupertinoDatePickerMode.dateAndTime,
                          onDateTimeChanged: (DateTime dateTime){
                            _dateTime = dateTime;
                          }),
                    ),
                  ),

                  SizedBox(height: 15,),
                  ClayContainer(
                    borderRadius: 10,
                    depth: -100,
                    spread: 2,
                    color: Get.isDarkMode? Colors.grey[800]: Colors.grey[300],

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text("Discussion Type: "),
                          Radio(value: "private", groupValue: type, onChanged: (value){
                            setState(() {
                              type = value;
                            });
                          }),
                          Text("Private",style: TextStyle(fontSize: 16),),
                          Radio(value: "public", groupValue: type, onChanged: (value){
                            setState(() {
                              type = value;
                            });
                          }),
                          Text("Public",style: TextStyle(fontSize: 16),),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 30,),

                  ClayContainer(
                    borderRadius: 10,
                    depth: 100,
                    width: 200,
                    color: Get.isDarkMode? Colors.grey[800]: Colors.grey[300],

                    spread: 2,
                    child: TextButton(onPressed: ()async{
                      if(selectedCategory ==''){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red,content: Text("Select a Category",style: TextStyle(color: Colors.white,))));
                        return;
                      }
                      if(_formKey.currentState.validate()){
                        _formKey.currentState.save();
                        speakers.insert(0,{
                          'name':widget.user.name,
                          'phone':widget.user.phone
                        });

                        await FirebaseFirestore.instance.collection('clubs').add({
                          'title':_titleController.text,
                          'category':selectedCategory,
                          'createdBy':widget.user.phone,
                          'invited':speakers,
                          'createdOn':DateTime.now(),
                          'dateTime':_dateTime,
                          'type':type,
                          'status':'new' // new,ongoing,finished,cancelled
                        });
                        Navigator.pop(context);
                      }
                    }, child: Text("Create",
                    style: GoogleFonts.lobster(
                      color: Get.isDarkMode? Colors.white70: Colors.black,
                      fontSize: 20
                    ),)),
                  )

                ],
              )),
        ),
      ),

    );
  }
}