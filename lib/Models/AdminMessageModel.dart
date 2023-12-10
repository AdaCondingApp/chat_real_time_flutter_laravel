import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMessageModel {
  String IdFrom;
  String nameIdFrom;
  String IdTo;
  String content;
  bool isWrite;
  String date;

  AdminMessageModel(this.IdFrom, this.nameIdFrom, this.IdTo, this.content,
      this.isWrite, this.date);

/*  AdminMessageModel.fromJson(Map<String, dynamic> map) {
    this.IdFrom = map['IdFrom'];
    this.IdTo = map['IdTo'];
    this.content = map['content'];
    this.isWrite = map['isWrite'];
    this.date = map['date'];
  }

 */
}
