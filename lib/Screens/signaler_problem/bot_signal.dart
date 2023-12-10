import 'package:chat_flutter_laravel_tuto/Models/AdminMessageModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for using json.decode()

class SignalBotScreen extends StatefulWidget {
  @override
  _SignalBotScreenState createState() => _SignalBotScreenState();
}

class _SignalBotScreenState extends State<SignalBotScreen> {
  var currentUserID = null;
  var display;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: current id => Login
    currentUserID = "current_id";

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<List<AdminMessageModel>> _getChatAdmin() async {
    var apiUrl =
        "https://votresite.com/api/conversation/UID_admin_a_qui_parler/${currentUserID}";

    final data = await http.get(Uri.parse(apiUrl));

    var jsonData = json.decode(data.body);

    List<AdminMessageModel> messages_ = [];

    for (var msg in jsonData) {
      AdminMessageModel newJoke = AdminMessageModel(
          msg["IdFrom"],
          msg["nameIdFrom"],
          msg["IdTo"],
          msg["content"],
          msg["isWrite"],
          msg["date"]);
      messages_.add(newJoke);
    }
    setState(() {
      display = messages_;
    });
    return messages_;
  }

  Future storeMessage(String IdTo, String message) async {
    var url = Uri.parse(
        "https://votresite.com/api/conversation/send/" + currentUserID);
    await http.post(url, body: {"IdTo": IdTo, "content": message});
    _getChatAdmin(); //refresh

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Message envoyé')));
    await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 300,
        duration: const Duration(
          milliseconds: 200,
        ),
        curve: Curves.easeInOut);
  }

  TextEditingController messageTextEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text(
          'Signaler un problème ',
          style: TextStyle(color: Colors.white),
        ),
        leading: const Icon(
          CupertinoIcons.info_circle,
          color: Colors.white,
        ),
      ),
      body: Stack(alignment: Alignment.bottomRight, children: [
        Container(
          margin: EdgeInsets.only(bottom: 40),
          child: FutureBuilder(
            future: _getChatAdmin()!,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (display != null) {
                if (snapshot.data == null) {
                  return Container(
                    child: Center(
                      child: Text("Loading..."),
                    ),
                  );
                } else {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        padding: EdgeInsets.only(
                            left: 14, right: 4, top: 10, bottom: 10),
                        child: Align(
                          alignment: (snapshot.data[index].IdFrom ==
                                  "UID_admin_a_qui_parler"
                              ? Alignment.topLeft
                              : Alignment.topRight),
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: (snapshot.data[index].IdFrom ==
                                      "UID_admin_a_qui_parler"
                                  ? Colors.grey.shade200
                                  : Colors.blue[200]),
                            ),
                            padding: EdgeInsets.all(3),
                            child: ListTile(
                                title: Text(
                              snapshot.data[index].content,
                              style: TextStyle(fontSize: 15),
                            )),
                          ),
                        ),
                      );
                    },
                  );
                }
              }
              return Container();
            },
          ),
        ),
        SizedBox(),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          color: Colors.white,
          child: TextField(
            controller: messageTextEditController,
            decoration: InputDecoration(
                fillColor: Colors.black,
                border: InputBorder.none,
                hintText: 'Saisir votre message...',
                hintStyle: TextStyle()),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: InkWell(
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              if (messageTextEditController.text.isEmpty) return;
              var content = messageTextEditController.text.trim();
              print(content);

              await storeMessage('UID_admin_a_qui_parler', content);
              messageTextEditController.clear();
            },
            child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        colors: [
                          Colors.deepOrange,
                          Colors.orangeAccent,
                          Colors.orangeAccent,
                          Colors.deepOrange,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
                child: Icon(Icons.send)),
          ),
        ),
      ]),
    );
  }
}
