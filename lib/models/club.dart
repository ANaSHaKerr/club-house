

import 'package:cloud_firestore/cloud_firestore.dart';

class Club{
  String clubId;
  String title;
  String category;
  String createdBy;
  List speakers;
  Timestamp dateTime;
  String type;
  String status;

  Club({
    this.category,
    this.clubId,
    this.dateTime,
    this.createdBy,
    this.speakers,
    this.title,
    this.type,
    this.status
  });

  factory Club.fromMap(QueryDocumentSnapshot documentSnapshot){
    return Club(
      clubId: documentSnapshot.id,
      title: documentSnapshot['title'],
       category: documentSnapshot['category'],
        createdBy: documentSnapshot['createdBy'],
         speakers: documentSnapshot['invited'],
          dateTime: documentSnapshot['dateTime'],
           type: documentSnapshot['type'],
           status: documentSnapshot['status'],
    );
  }
}