import 'dart:async';

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
  String? dateSection;

  
  final ref = FirebaseDatabase.instance
  .ref()
  .child('GlobalChat');

  bool btnHide = true;
  bool childAddedStatus = false;

  submitMessage(){
    if (messageController.text != '' && FirebaseAuth.instance.currentUser != null) {
      String now = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
      final key = ref.child(now).push().key;

      Future.delayed(Duration(milliseconds: 100)).then((value) {
        Future.delayed(Duration(milliseconds: 100)).then((value) {
          ref.child(now).child(key!).set({
            'user_uid':FirebaseAuth.instance.currentUser!.uid,
            'user_name':FirebaseAuth.instance.currentUser!.displayName,
            'user_image':FirebaseAuth.instance.currentUser!.photoURL,
            'message':messageController.text,
            'created_at': DateTime.now().toString(),
          }).whenComplete((){
            ref.child(now).child(key).child('reader').set({
              {
                'user_uid':FirebaseAuth.instance.currentUser!.uid,
                'user_name':FirebaseAuth.instance.currentUser!.displayName,
                'user_image':FirebaseAuth.instance.currentUser!.photoURL,
                'message_position': _controller.position.maxScrollExtent
              }
            });
          });
          messageController.text = '';
        });
      });
    }
  }
  final ScrollController _controller = ScrollController();

  // This is what you're looking for!
  void _scrollDownIn(double position) {
    Future.delayed(Duration(milliseconds: 100)).then((value) {
      _controller.position.moveTo(
        position,
        duration: Duration(milliseconds: 100),
        curve: Curves.fastOutSlowIn,
      );
      Future.delayed(Duration(milliseconds: 100)).then((value) {
        if (!_controller.position.atEdge) {
          _controller.position.moveTo(
            position,
            duration: Duration(milliseconds: 100),
            curve: Curves.fastOutSlowIn,
          );
        }
      });
    });
  }

  // void _scrollDownAuto() {
  //   // print("${_controller.position.maxScrollExtent} scroll1");
  //   ref.onChildAdded.listen((event) {
  //     if (childAddedStatus) {
  //       // if (_controller.) {
  //         Future.delayed(Duration(milliseconds: 100)).then((value) {
  //           _controller.position.moveTo(
  //             _controller.position.maxScrollExtent,
  //             duration: Duration(milliseconds: 100),
  //             curve: Curves.fastOutSlowIn,
  //           );
  //           Future.delayed(Duration(milliseconds: 100)).then((value) {
  //             if (!_controller.position.atEdge) {
  //               _controller.position.moveTo(
  //                 _controller.position.maxScrollExtent,
  //                 duration: Duration(milliseconds: 100),
  //                 curve: Curves.fastOutSlowIn,
  //               );
  //             }
  //           });
  //         });
  //       // }        
  //     }
  //   });
  // }

  onRead(data){
    final xLen = data.entries.last.value['reader'] as List<dynamic>;
    int xCount = 0;
    for (var x in data.entries.last.value['reader']) {
      xCount++;

      if (x['user_uid'] == FirebaseAuth.instance.currentUser!.uid) {
        break;
      }
      if (xCount == xLen.length) {
        ref.child(data.entries.last.key).child('reader').set({
          {
            'user_uid':FirebaseAuth.instance.currentUser!.uid,
            'user_name':FirebaseAuth.instance.currentUser!.displayName,
            'user_image':FirebaseAuth.instance.currentUser!.photoURL,
            'message_position': _controller.position.maxScrollExtent
          }
        });
      }
    }
  }

  @override
  void initState() {
    _controller.addListener(() {
      if (_controller.position.pixels >
          _controller.position.minScrollExtent + 5) {
        setState(() {
          btnHide = false;
        });
      }
      if (_controller.position.pixels >= _controller.position.maxScrollExtent) {
        setState(() {
          btnHide = true;
        });
      }
    });
    // _scrollDownAuto();
    // ref.onValue.listen((event) {
    //   Map data = event.snapshot.value as Map;
      // outerLoop:
      // for (var i in data.entries.toList().reversed) {
      //   if (i.value['reader'] != null) {
      //     for (var x in i.value['reader']) {
      //       if (x['user_uid'] == FirebaseAuth.instance.currentUser!.uid) {
      //         Future.delayed(Duration(milliseconds: 100)).then((value) {
      //             _controller.position.moveTo(
      //               x['message_position'],
      //               duration: Duration(milliseconds: 100),
      //               curve: Curves.fastOutSlowIn,
      //             );
      //         });
      //         break outerLoop;
      //       }
      //     }
      //   }
      // }
      // onRead(data);
      // print(data.entries.last.value['reader'].length);
      
      // if (data.entries.last.value['reader']) {
        
      // }
      // Map lastRead = data.entries.last.value['reader'].asMap();
      // // Map read = data['reader'] as Map;
      // for (var x in lastRead.entries) {
      //   print(x.value['user_uid']);
      // }
    // });
    
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
                          FirebaseDatabaseListView(
                            controller: _controller,
                            query: ref,
                            reverse: true,
                            itemBuilder: (context, snapshot) {
                              var data = snapshot.value as Map<String,dynamic>;
                              List<Widget> listWidget = [];
                              listWidget.add(
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
                                            "${snapshot.key}",
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
                                )
                              );
                              for (var i in data.entries) {
                                final data = i.value as Map<Object?,Object?>;
                                data['key'] = i.key;
                                listWidget.add(ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: 30,
                                    minWidth: 50,
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                    child: Row(
                                      mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ? MainAxisAlignment.end : MainAxisAlignment.start,
                                      crossAxisAlignment:  FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ?
                                        Row(
                                          mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ? MainAxisAlignment.end : MainAxisAlignment.start,
                                          crossAxisAlignment:  FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,        
                                          children: [
                                            Text(
                                              DateFormat("HH:mm").format(DateTime.parse("${data['created_at']}")),
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
                                                  color: Colors.white10,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ? MainAxisAlignment.end : MainAxisAlignment.start,
                                                  crossAxisAlignment:  FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${data['user_name']}",
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w900
                                                        // overflow: TextOverflow.fade
                                                      ),
                                                    ),
                                                    Text(
                                                      "${data['message']}",
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
                                              imageUrl: '${data['user_image']}',
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
                                        FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ?
                                        Container(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(50),
                                            child: CachedNetworkImage(
                                              imageUrl: '${data['user_image']}',
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
                                          mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid != data['user_uid'] ? MainAxisAlignment.end : MainAxisAlignment.start,
                                          crossAxisAlignment:  FirebaseAuth.instance.currentUser!.uid != data['user_uid'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,        
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
                                                mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ? MainAxisAlignment.end : MainAxisAlignment.start,
                                                crossAxisAlignment:  FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${data['user_name']}",
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w900
                                                        // overflow: TextOverflow.fade
                                                      ),
                                                    ),
                                                    Text(
                                                      "${data['message']}",
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
                                              "${DateFormat("H:m").format(DateTime.parse("${data['created_at']}"))}",
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
                                ));
                                
                              }
                              // }
                              return Column(
                                children: listWidget,
                              );

                              // if (data.length == index + 1) {
                              //   childAddedStatus = true;
                              // }
                              return Container();
                              
                            },
                          ),
                          
                          // FirebaseAnimatedList(
                          //   controller: _controller,
                          //   query: ref.orderByChild('created_at'),
                          //   shrinkWrap: true,
                          //   itemBuilder: (context, snapshot, animation, index){
                          //     Map data = snapshot.value as Map;
                          //     data['key'] = snapshot.key;
                          //     if (data.length == index + 1) {
                          //       childAddedStatus = true;
                          //     }
                          //     dateSection = DateFormat("yyyy-MM-dd").format(DateTime.parse(data['created_at']));

                          //     return ConstrainedBox(
                          //       constraints: BoxConstraints(
                          //         minHeight: 30,
                          //         minWidth: 50,
                          //       ),
                          //       child: Container(
                          //         margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                          //         child: Row(
                          //           mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ? MainAxisAlignment.end : MainAxisAlignment.start,
                          //           crossAxisAlignment:  FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          //           children: [
                          //             FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ?
                          //             Row(
                          //               mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ? MainAxisAlignment.end : MainAxisAlignment.start,
                          //               crossAxisAlignment:  FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,        
                          //               children: [
                          //                 Text(
                          //                   "${DateFormat("HH:mm").format(DateTime.parse(data['created_at']))}",
                          //                   style: TextStyle(
                          //                     fontSize: 11,
                          //                     color: Colors.white70,
                          //                     fontWeight: FontWeight.w600,
                          //                     // overflow: TextOverflow.fade
                          //                   ),
                          //                 ),
                          //                 ConstrainedBox(
                          //                   constraints: BoxConstraints(
                          //                     minHeight: 30,
                          //                     minWidth: 50,
                          //                     maxWidth: MediaQuery.of(context).size.width * 0.8
                          //                   ),
                          //                   child: Container(
                          //                     padding: EdgeInsets.all(15),
                          //                     decoration: BoxDecoration(
                          //                       borderRadius: BorderRadius.circular(15),
                          //                       color: Colors.white10,
                          //                     ),
                          //                     child: Column(
                          //                       mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ? MainAxisAlignment.end : MainAxisAlignment.start,
                          //                       crossAxisAlignment:  FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          //                       children: [
                          //                         Text(
                          //                           data['user_name'],
                          //                           textAlign: TextAlign.end,
                          //                           style: TextStyle(
                          //                             fontSize: 12,
                          //                             color: Colors.white,
                          //                             fontWeight: FontWeight.w900
                          //                             // overflow: TextOverflow.fade
                          //                           ),
                          //                         ),
                          //                         Text(
                          //                           data['message'],
                          //                           style: TextStyle(
                          //                             fontSize: 15,
                          //                             color: Colors.white70,
                          //                             // overflow: TextOverflow.fade
                          //                           ),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                   ),
                          //                 ),
                          //               ],
                          //             ):
                          //             Container(
                          //               child: ClipRRect(
                          //                 borderRadius: BorderRadius.circular(50),
                          //                 child: Image.network(
                          //                   '${data['user_image']}',
                          //                   width: 30,
                          //                   loadingBuilder: (context, child, loadingProgress) {
                          //                     return Container(
                          //                       padding: EdgeInsets.all(3),
                          //                       decoration: BoxDecoration(
                          //                         color: Colors.white12,
                          //                         borderRadius: BorderRadius.circular(50)
                          //                       ),
                          //                       child: Icon(
                          //                         Icons.person,
                          //                         color: Colors.white,
                          //                       ),
                          //                     );
                          //                   },
                          //                   errorBuilder: (context, child, loadingProgress) {
                          //                     return Container(
                          //                       padding: EdgeInsets.all(3),
                          //                       decoration: BoxDecoration(
                          //                         color: Colors.white10,
                          //                         borderRadius: BorderRadius.circular(50)
                          //                       ),
                          //                       child: Icon(
                          //                         Icons.person,
                          //                         color: Colors.white,
                          //                       ),
                          //                     );
                          //                   },
                          //                 ),
                          //               ),
                          //             ),
                          //             SizedBox(
                          //               width: 10,
                          //             ),
                          //             FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ?
                          //             Container(
                          //               child: ClipRRect(
                          //                 borderRadius: BorderRadius.circular(50),
                          //                 child: Image.network(
                          //                   '${data['user_image']}',
                          //                   width: 30,
                          //                   loadingBuilder: (context, child, loadingProgress) {
                          //                     return Container(
                          //                       padding: EdgeInsets.all(3),
                          //                       decoration: BoxDecoration(
                          //                         color: Colors.white10,
                          //                         borderRadius: BorderRadius.circular(50)
                          //                       ),
                          //                       child: Icon(
                          //                         Icons.person,
                          //                         color: Colors.white,
                          //                       ),
                          //                     );
                          //                   },
                          //                   errorBuilder: (context, child, loadingProgress) {
                          //                     return Container(
                          //                       padding: EdgeInsets.all(3),
                          //                       decoration: BoxDecoration(
                          //                         color: Colors.white10,
                          //                         borderRadius: BorderRadius.circular(50)
                          //                       ),
                          //                       child: Icon(
                          //                         Icons.person,
                          //                         color: Colors.white,
                          //                       ),
                          //                     );
                          //                   },
                          //                 ),
                          //               ),
                          //             ):
                          //             Row(
                          //               mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid != data['user_uid'] ? MainAxisAlignment.end : MainAxisAlignment.start,
                          //               crossAxisAlignment:  FirebaseAuth.instance.currentUser!.uid != data['user_uid'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,        
                          //               children: [
                          //                 ConstrainedBox(
                          //                   constraints: BoxConstraints(
                          //                     minHeight: 30,
                          //                     minWidth: 50,
                          //                     maxWidth: MediaQuery.of(context).size.width * 0.8
                          //                   ),
                          //                   child: Container(
                          //                     padding: EdgeInsets.all(15),
                          //                     decoration: BoxDecoration(
                          //                       borderRadius: BorderRadius.circular(15),
                          //                       color: Color(0xFF526D82),
                          //                     ),
                          //                     child: Column(
                          //                     mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ? MainAxisAlignment.end : MainAxisAlignment.start,
                          //                     crossAxisAlignment:  FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          //                       children: [
                          //                         Text(
                          //                           data['user_name'],
                          //                           textAlign: TextAlign.end,
                          //                           style: TextStyle(
                          //                             fontSize: 12,
                          //                             color: Colors.white,
                          //                             fontWeight: FontWeight.w900
                          //                             // overflow: TextOverflow.fade
                          //                           ),
                          //                         ),
                          //                         Text(
                          //                           data['message'],
                          //                           style: TextStyle(
                          //                             fontSize: 15,
                          //                             color: Colors.white70,
                          //                             // overflow: TextOverflow.fade
                          //                           ),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                   ),
                          //                 ),
                          //                 Text(
                          //                   "${DateFormat("H:m").format(DateTime.parse(data['created_at']))}",
                          //                   style: TextStyle(
                          //                     fontSize: 11,
                          //                     color: Colors.white70,
                          //                     fontWeight: FontWeight.w600,
                          //                     // overflow: TextOverflow.fade
                          //                   ),
                          //                 ),
                          //               ],
                          //             )
                                    
                          //           ],
                          //         ),
                          //       ),
                          //     );
                          //   },
                          //   defaultChild: Center(
                          //     child: CircularProgressIndicator(),
                          //   ),
                          // ),
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
                                    borderSide: BorderSide(color:Colors.white24, width: 3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:Colors.white24, width: 3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:Colors.white, width: 3),
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