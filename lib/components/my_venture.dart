import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jet_palz/models/user_model.dart';
import '../models/venture_model.dart';

class MyVentureWidget extends StatefulWidget {
  const MyVentureWidget({
    Key? key,
    required this.userRef,
    required this.ventureRef,
  }) : super(key: key);

  final DocumentReference? userRef;
  final DocumentReference? ventureRef;

  @override
  State<MyVentureWidget> createState() => _MyVentureWidgetState();
}

class _MyVentureWidgetState extends State<MyVentureWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StreamBuilder<VentureModel>(
                stream: FirebaseFirestore.instance
                    .collection('ventures')
                    .doc(widget.ventureRef!.id)
                    .snapshots()
                    .map((snapshot) => VentureModel.fromDocument(snapshot)),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  final textVenturesRecord = snapshot.data as VentureModel?;
                  return Text(textVenturesRecord!.country!);
                },
              ),
              Row(
                children: [
                  StreamBuilder<VentureModel>(
                    stream: FirebaseFirestore.instance
                        .collection('ventures')
                        .doc(widget.ventureRef!.id)
                        .snapshots()
                        .map((snapshot) => VentureModel.fromDocument(snapshot)),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      final textVenturesRecord = snapshot.data as VentureModel?;
                      return Text(
                        '${textVenturesRecord!.memberList!.length.toString()} / ${textVenturesRecord.maxPeople.toString()}',
                      );
                    },
                  ),
                  Icon(Icons.people_alt),
                ],
              ),
            ],
          ),
          Container(
            constraints: BoxConstraints(
              maxWidth: 300.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<UserModel>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userRef!.id)
                      .snapshots()
                      .map((snapshot) => UserModel.fromDocument(snapshot)),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final textUsersRecord = snapshot.data as UserModel?;
                    return Text(textUsersRecord!.displayName);
                  },
                ),
                StreamBuilder<VentureModel>(
                  stream: FirebaseFirestore.instance
                      .collection('ventures')
                      .doc(widget.ventureRef!.id)
                      .snapshots()
                      .map((snapshot) => VentureModel.fromDocument(snapshot)),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final textVenturesRecord = snapshot.data as VentureModel?;
                    return Text(textVenturesRecord!.industry!);
                  },
                ),
              ],
            ),
          ),
          Row(
            children: [
              Flexible(
                child: StreamBuilder<VentureModel>(
                  stream: FirebaseFirestore.instance
                      .collection('ventures')
                      .doc(widget.ventureRef!.id)
                      .snapshots()
                      .map((snapshot) => VentureModel.fromDocument(snapshot)),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final textVenturesRecord = snapshot.data as VentureModel?;
                    return Text(textVenturesRecord!.description!);
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: Text('Leave'),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Month {}'),
                    Text('Length'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
