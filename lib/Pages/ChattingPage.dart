import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';


class ChattingPage extends StatefulWidget {
  const ChattingPage({
    super.key,
  });

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  TextEditingController messageController = TextEditingController();
  final FocusNode unitCodeCtrlFocusNode = FocusNode();
  String? dateSection;

  
  final ref = FirebaseDatabase.instance
  .ref()
  .child('GlobalChat');

  String now = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  
  bool btnHide = true;
  bool readStatus = false;
  bool onReadStatus = false;
  String? _msgUid;

  final ScrollController _controller = ScrollController();

  submitMessage(){
    if (messageController.text.trim() != "" && FirebaseAuth.instance.currentUser != null) {
      final key = ref.child(now).push().key;

      Future.delayed(Duration(milliseconds: 100)).then((value) {
        Future.delayed(Duration(milliseconds: 100)).then((value) {
          if (messageController.text.trim() != "") {
            ref.child(now).child(key!).set({
              'user_uid':FirebaseAuth.instance.currentUser!.uid,
              'user_name':FirebaseAuth.instance.currentUser!.displayName,
              'user_image':FirebaseAuth.instance.currentUser!.photoURL,
              'message':messageController.text.trim(),
              'created_at': DateTime.now().toString(),
            }).whenComplete((){
              ref.child(now).child(key).child('reader').child("${FirebaseAuth.instance.currentUser!.uid}").set({
                'user_uid':FirebaseAuth.instance.currentUser!.uid,
                'user_name':FirebaseAuth.instance.currentUser!.displayName,
                'user_image':FirebaseAuth.instance.currentUser!.photoURL,
                'message_position': _controller.position.maxScrollExtent,
                'created_at': DateTime.now().toString()
              });
            });
          }
          messageController.text = '';
        });
      });
    }
  }

  // // This is what you're looking for!
  // void _scrollDownIn(double position) {
  //   Future.delayed(Duration(milliseconds: 100)).then((value) {
  //     _controller.position.moveTo(
  //       position,
  //       duration: Duration(milliseconds: 100),
  //       curve: Curves.fastOutSlowIn,
  //     );
  //     Future.delayed(Duration(milliseconds: 100)).then((value) {
  //       if (!_controller.position.atEdge) {
  //         _controller.position.moveTo(
  //           position,
  //           duration: Duration(milliseconds: 100),
  //           curve: Curves.fastOutSlowIn,
  //         );
  //       }
  //     });
  //   });
  // }

  Future<void> lastRead()async {
    ref.onValue.listen((event) {
      if(readStatus == false){
        Map data = event.snapshot.value as Map<String,dynamic>;
        int count = 0;
        outerLoop:
        for (var i in data.entries.toList().reversed) {
          Map msg = i.value as Map<String,dynamic>;
          for (var x in msg.entries.toList().reversed) {
            count++;
            if (x.value['reader'] != null) {
              final read = x.value['reader'] as Map<String,dynamic>;
              if (read.containsKey(FirebaseAuth.instance.currentUser!.uid)) {
                for (var y in read.entries.toList().reversed) {
                  if (y != null && y.value['user_uid'] == FirebaseAuth.instance.currentUser!.uid) {
                    if (count > 1) {
                      _msgUid = x.key;
                    }
                    Future.delayed(Duration(milliseconds: 1000)).then((value) {
                      _controller.position.jumpTo(
                         _controller.position.maxScrollExtent - y.value['message_position'],
                      );
                    });
                    readStatus = true;
                    break outerLoop;
                  }
                }
              };
            }
          }
        }
      }
    });
  }
  Future<void> onRead()async {
    ref.get().then((event) {
      var count = 0;
      // if (onReadStatus) {
        Map data = event.value as Map<String,dynamic>;
        for (var i in data.entries.toList().reversed) {
          final msg = i.value as Map<String,dynamic>;
          for (var x in msg.entries.toList().reversed) {
            if (x.value['reader'] != null) {
              final read = x.value['reader'] as Map<String?,dynamic>;
              if (!read.containsKey(FirebaseAuth.instance.currentUser!.uid)) {
                Future.delayed(Duration(milliseconds: 1000)).then((value) {
                  ref.child(i.key).child(x.key!).child('reader').child("${FirebaseAuth.instance.currentUser!.uid}").set({
                    'user_uid':FirebaseAuth.instance.currentUser!.uid,
                    'user_name':FirebaseAuth.instance.currentUser!.displayName,
                    'user_image':FirebaseAuth.instance.currentUser!.photoURL,
                    'message_position': _controller.position.maxScrollExtent,
                    'created_at': DateTime.now().toString()
                  });
                });
              }
            }else{
              Future.delayed(Duration(milliseconds: 1000)).then((value) {
                ref.child(i.key).child(x.key!).child('reader').child("${FirebaseAuth.instance.currentUser!.uid}").set({
                  'user_uid':FirebaseAuth.instance.currentUser!.uid,
                  'user_name':FirebaseAuth.instance.currentUser!.displayName,
                  'user_image':FirebaseAuth.instance.currentUser!.photoURL,
                  'message_position': _controller.position.maxScrollExtent,
                  'created_at': DateTime.now().toString()
                });
              });
            }
          }
        }
      // }
    });
    // print('object');
  }

  @override
  void initState() {
    _controller.addListener(() {
      // if (_controller.position.pixels >
      //     _controller.position.minScrollExtent + 5) {
      //   setState(() {
      //     btnHide = false;
      // print(_controller.position.atEdge);
      //   });
      // }
      if (_controller.position.pixels <= _controller.position.minScrollExtent + 10) {
        setState(() {
          onReadStatus = true;
          // onRead();
        });
      }else{
        setState(() {
          onReadStatus = false;
        });
      }
    });
    if (kIsWeb) {
      html.window.onKeyPress.listen((html.KeyboardEvent e) {
        unitCodeCtrlFocusNode.requestFocus();
      });
    }
    Timer.periodic(
      Duration(seconds: 5),
      (timer){
        onRead();
      }
    );
    // _scrollDownAuto();
    if (readStatus == false) {
      lastRead();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ChattingApp',
          style: TextStyle(
            color: Colors.white60,
            fontWeight: FontWeight.w900
          ),
        ),
        backgroundColor: Color(0xFF526D82),
      ),
      body: SafeArea(
        child: Container(
          child: Row(
            children: [
              // MediaQuery.of(context).size.width <= 897 ? Container() :
              // ConstrainedBox(
              //   constraints: BoxConstraints(
              //     minHeight: 0,
              //     maxHeight: MediaQuery.of(context).size.height,
              //     maxWidth: 400,
              //     minWidth: 400,
              //   ),
              //   child: Container(
              //     color: Color(0xFF526D82),
              //     child: Column(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Container(
              //           width: 400,
              //           height: 60,
              //           color: Colors.white,
              //           child: Text(
              //             'Profile & Settings'
              //           ),
              //         ),
              //         Expanded(
              //           child: SingleChildScrollView(
              //             child: Column(
              //               mainAxisSize: MainAxisSize.min,
              //               children: [
              //                 for(int x = 1;x < 10;x++)
              //                 Container(
              //                   decoration: BoxDecoration(
              //                     border: Border.all(color: Colors.white12,width: 1)
              //                   ),
              //                   height: 75,
              //                   padding: EdgeInsets.symmetric(horizontal: 10),
              //                   child: Row(
              //                     mainAxisAlignment: MainAxisAlignment.start,
              //                     crossAxisAlignment: CrossAxisAlignment.center,
              //                     children: [
              //                       Container(
              //                         child: ClipRRect(
              //                           borderRadius: BorderRadius.circular(50),
              //                           child: Image.asset(
              //                             'assets/images/default.jpeg',
              //                             width: 50,
              //                             height: 50,
              //                           ),
              //                         ),
              //                       ),
              //                       Container(
              //                         margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              //                         child: Column(
              //                           mainAxisAlignment: MainAxisAlignment.start,
              //                           crossAxisAlignment: CrossAxisAlignment.start,
              //                           children: [
              //                             Text(
              //                               'Enricko Putra H',
              //                               textAlign: TextAlign.center,
              //                               style: TextStyle(
              //                                 color: Colors.white,
              //                                 fontSize: 18,
              //                                 fontWeight: FontWeight.w800
              //                               ),
              //                             ),
              //                             Text(
              //                               'Enricko : Woi ${x}',
              //                               textAlign: TextAlign.center,
              //                               style: TextStyle(
              //                                 color: Colors.white38,
              //                                 fontSize: 16,
              //                                 // fontWeight: FontWeight.w800
              //                               ),
              //                             )
              //                           ],
              //                         ),
              //                       )
              //                     ],
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // Positioned(
                          //   // left: MediaQuery.of(context).size.width * 0.5,
                          //   child: Container(  
                          //     margin: EdgeInsets.symmetric(vertical: 15),
                          //     padding: EdgeInsets.symmetric(vertical: 1,horizontal: 5),
                          //     decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(5),
                          //       color: Colors.white,
                          //     ),
                          //     child: Text(
                          //       "$dateSection",
                          //       style: TextStyle(
                          //         color: Colors.black,
                          //         fontWeight: FontWeight.w800
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // FirebaseDatabaseListView(
                          //   controller: _controller,
                          //   query: ref,
                          //   shrinkWrap: true,
                          //   reverse: true,
                          //   itemBuilder: (context, snapshot) {
                                  
                          //   },
                          // ),
                          FirebaseDatabaseQueryBuilder(
                            query: ref,
                            builder: (BuildContext context, FirebaseQueryBuilderSnapshot snapshot, Widget? child) { 
                              if (snapshot.hasData) {
                                final s = snapshot.docs.reversed.toList();
                                return ListView.builder(
                                  itemCount: s.length,
                                  shrinkWrap: true,
                                  reverse: true,
                                  controller: _controller,
                                  physics: ClampingScrollPhysics(),
                                  itemBuilder: (BuildContext context, int index) { 
                                    final data = s[index].value as Map<String,dynamic>;
                                    final val = data.entries.toList().reversed.toList();
                                    return ListView.builder(
                                      itemCount: val.length,
                                      shrinkWrap: true,
                                      reverse: true,
                                      physics: ClampingScrollPhysics(),
                                      itemBuilder: (BuildContext context, int index) { 
                                        return Column(
                                          children: [
                                            val.length != index + 1 ? Container() :
                                            Container(
                                              margin: EdgeInsets.symmetric(vertical: 15),
                                              child: Row(
                                                  children: <Widget>[
                                                      const Expanded(
                                                          child: Divider(
                                                            height: 3,
                                                            color: Color(0xFF9DB2BF),
                                                          )
                                                      ),       
                                                      Text(
                                                        DateFormat("yyyy-MM-dd").format(DateTime.parse("${val[index].value['created_at']}")),
                                                        style: TextStyle(
                                                          color: Color(0xFFDDE6ED),
                                                          fontWeight: FontWeight.w800
                                                        ),
                                                      ),        
                                                      const Expanded(
                                                          child: Divider(
                                                            height: 3,
                                                            color: Color(0xFF9DB2BF),
                                                          )
                                                      ),
                                                  ]
                                              ),
                                            ),
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                minHeight: 30,
                                                minWidth: 50,
                                              ),
                                              child: Container(
                                                margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                                child: Row(
                                                  mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid == val[index].value['user_uid'] ? MainAxisAlignment.end : MainAxisAlignment.start,
                                                  crossAxisAlignment:  FirebaseAuth.instance.currentUser!.uid == val[index].value['user_uid'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                                  children: [
                                                    FirebaseAuth.instance.currentUser!.uid == val[index].value['user_uid'] ?
                                                    Row(
                                                      mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid == val[index].value['user_uid'] ? MainAxisAlignment.end : MainAxisAlignment.start,
                                                      crossAxisAlignment:  FirebaseAuth.instance.currentUser!.uid == val[index].value['user_uid'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,        
                                                      children: [
                                                        Text(
                                                          DateFormat("HH:mm").format(DateTime.parse("${val[index].value['created_at']}")),
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors.white70,
                                                            fontWeight: FontWeight.w600,
                                                            // overflow: TextOverflow.fade
                                                          ),
                                                        ),
                                                        ConstrainedBox(
                                                          constraints: BoxConstraints(
                                                            minHeight: 30,
                                                            minWidth: 50,
                                                            maxWidth: MediaQuery.of(context).size.width * 0.8
                                                          ),
                                                          child: Container(
                                                            padding: EdgeInsets.all(15),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(15),
                                                              color: Color(0xFF526D82),
                                                            ),
                                                            child: Column(
                                                              mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid == val[index].value['user_uid'] ? MainAxisAlignment.end : MainAxisAlignment.start,
                                                              crossAxisAlignment:  FirebaseAuth.instance.currentUser!.uid == val[index].value['user_uid'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  "${val[index].value['user_name']}",
                                                                  textAlign: TextAlign.end,
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.w900
                                                                    // overflow: TextOverflow.fade
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "${val[index].value['message']}",
                                                                  style: TextStyle(
                                                                    fontSize: 15,
                                                                    color: Colors.white70,
                                                                    // overflow: TextOverflow.fade
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ):
                                            
                                                    Container(
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(50),
                                                        child: CachedNetworkImage(
                                                          imageUrl: '${val[index].value['user_image']}',
                                                          width: 30,
                                                          placeholder: (context, url) {
                                                            return Container(
                                                              padding: EdgeInsets.all(3),
                                                              decoration: BoxDecoration(
                                                                color: Colors.white10,
                                                                borderRadius: BorderRadius.circular(50)
                                                              ),
                                                              child: Icon(
                                                                Icons.person,
                                                                color: Colors.white,
                                                              ),
                                                            );
                                                          },
                                                          errorWidget: (context, url, error) {
                                                            return Container(
                                                              padding: EdgeInsets.all(3),
                                                              decoration: BoxDecoration(
                                                                color: Colors.white10,
                                                                borderRadius: BorderRadius.circular(50)
                                                              ),
                                                              child: Icon(
                                                                Icons.person,
                                                                color: Colors.white,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    FirebaseAuth.instance.currentUser!.uid == val[index].value['user_uid'] ?
                                                    Container(
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(50),
                                                        child: CachedNetworkImage(
                                                          imageUrl: '${val[index].value['user_image']}',
                                                          width: 30,
                                                          placeholder: (context, url) {
                                                            return Container(
                                                              padding: EdgeInsets.all(3),
                                                              decoration: BoxDecoration(
                                                                color: Colors.white10,
                                                                borderRadius: BorderRadius.circular(50)
                                                              ),
                                                              child: Icon(
                                                                Icons.person,
                                                                color: Colors.white,
                                                              ),
                                                            );
                                                          },
                                                          errorWidget: (context, url, error) {
                                                            return Container(
                                                              padding: EdgeInsets.all(3),
                                                              decoration: BoxDecoration(
                                                                color: Colors.white10,
                                                                borderRadius: BorderRadius.circular(50)
                                                              ),
                                                              child: Icon(
                                                                Icons.person,
                                                                color: Colors.white,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ):
                                                    Row(
                                                      mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid != val[index].value['user_uid'] ? MainAxisAlignment.end : MainAxisAlignment.start,
                                                      crossAxisAlignment:  FirebaseAuth.instance.currentUser!.uid != val[index].value['user_uid'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,        
                                                      children: [
                                                        ConstrainedBox(
                                                          constraints: BoxConstraints(
                                                            minHeight: 30,
                                                            minWidth: 50,
                                                            maxWidth: MediaQuery.of(context).size.width * 0.8
                                                          ),
                                                          child: Container(
                                                            padding: EdgeInsets.all(15),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(15),
                                                              color: Color(0xFF526D82),
                                                            ),
                                                            child: Column(
                                                            mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid == val[index].value['user_uid'] ? MainAxisAlignment.end : MainAxisAlignment.start,
                                                            crossAxisAlignment:  FirebaseAuth.instance.currentUser!.uid == val[index].value['user_uid'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  "${val[index].value['user_name']}",
                                                                  textAlign: TextAlign.end,
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.w900
                                                                    // overflow: TextOverflow.fade
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "${val[index].value['message']}",
                                                                  style: TextStyle(
                                                                    fontSize: 15,
                                                                    color: Colors.white70,
                                                                    // overflow: TextOverflow.fade
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          "${DateFormat("HH:mm").format(DateTime.parse("${val[index].value['created_at']}"))}",
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors.white70,
                                                            fontWeight: FontWeight.w600,
                                                            // overflow: TextOverflow.fade
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            _msgUid == val[index].key ?
                                            Container(
                                              margin: EdgeInsets.symmetric(vertical: 15),
                                              child: Row(
                                                  children: <Widget>[
                                                      const Expanded(
                                                          child: Divider(
                                                            height: 3,
                                                            color: Color.fromARGB(255, 238, 79, 79),
                                                          )
                                                      ),       
                                                      Text(
                                                        "New Message",
                                                        style: TextStyle(
                                                          color: Color.fromARGB(255, 255, 34, 34),
                                                          fontWeight: FontWeight.w800
                                                        ),
                                                      ),        
                                                      const Expanded(
                                                          child: Divider(
                                                            height: 3,
                                                            color: Color.fromARGB(255, 238, 79, 79),
                                                          )
                                                      ),
                                                  ]
                                              ),
                                            ):Container(),
                                          ],
                                        ); 
                                      },
                                    );
                                    
                                    
                                    // return Column(
                                    //   children: listWidget,
                                    // );  
                                  },
                                );
                              }
                              return Container();
                            },
                          ),
                        ],
                      ),
                    ),
                    // btnHide == true ? Container() :
                    // Stack(
                    //   children: [
                    //     Positioned(
                    //       // bottom: 130,
                    //       // right: 20,
                    //       child:ElevatedButton(
                    //         onPressed: (){
                    //           _scrollDown();
                    //         },
                    //         child: Icon(Icons.arrow_downward),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 350,
                        minHeight: 60
                      ),
                      child: Container(
                        color: Color(0xFF526D82),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 15),
                              child: IconButton(
                                icon: Icon(
                                  Icons.attachment,
                                  color: Colors.white24,
                                  size: 30,
                                ),
                                onPressed: null,
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: messageController,
                                keyboardType: TextInputType.text,
                                minLines: 1,
                                maxLines: 10,
                                autofocus: true,
                                focusNode: unitCodeCtrlFocusNode,
                                // expands: true,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                cursorColor: Colors.white30,
                                onFieldSubmitted: (value){
                                  submitMessage();
                                },
                                decoration: InputDecoration(
                                  hintText: 'Kirim Pesan',
                                  hintStyle: TextStyle(
                                    color: Colors.white
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors.white
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color:Color(0xFF27374D), width: 3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:Color(0xFF9DB2BF), width: 3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:Color(0xFF9DB2BF), width: 3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 15),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.send,
                                    color: Colors.white60,
                                  ),
                                  hoverColor: Colors.white54,
                                  onPressed: (){
                                    // FirebaseAuth.instance.;
                                    submitMessage();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
    );
  }
}