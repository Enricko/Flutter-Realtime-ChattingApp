import 'dart:async';
import 'dart:html' as html;
import 'dart:io';  
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter_chat_bubble/chat_bubble.dart';
import "package:image_picker/image_picker.dart";

import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';


class ChattingPage extends StatefulWidget {
  const ChattingPage({
    super.key,
  });

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  TextEditingController messageController = TextEditingController();
  final listDropdownController = DropdownController();

  final FocusNode unitCodeCtrlFocusNode = FocusNode();
  String? dateSection;

  
  final ref = FirebaseDatabase.instance
  .ref()
  .child('GlobalChats');

  String now = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  
  bool btnHide = true;
  bool readStatus = false;
  bool onReadStatus = false;
  String? _msgUid;

  File? file;
  ImagePicker image = ImagePicker();
  Uint8List webImage = Uint8List(8);
  var url;

  final ScrollController _controller = ScrollController();

  submitMessage(String typeMessage,String image){
    if ((messageController.text.trim() != "" || image != "") && FirebaseAuth.instance.currentUser != null) {
      final key = ref.push().key;

      Future.delayed(Duration(milliseconds: 100)).then((value) {
        Future.delayed(Duration(milliseconds: 100)).then((value) {
          if (messageController.text.trim() != "" || image != "") {
            try {
              ref.child(key!).set({
                'user_uid':FirebaseAuth.instance.currentUser!.uid,
                'user_name':FirebaseAuth.instance.currentUser!.displayName,
                'user_image':FirebaseAuth.instance.currentUser!.photoURL,
                'type_message':typeMessage,
                'message':messageController.text.trim().toString(),
                'image':image.toString(),
                'created_at': DateTime.now().toString(),
              }).whenComplete((){
                ref.child(key).child('reader').child("${FirebaseAuth.instance.currentUser!.uid}").set({
                  'user_uid':FirebaseAuth.instance.currentUser!.uid,
                  'user_name':FirebaseAuth.instance.currentUser!.displayName,
                  'user_image':FirebaseAuth.instance.currentUser!.photoURL,
                  'message_position': _controller.position.maxScrollExtent,
                  'created_at': DateTime.now().toString()
                });
              });
            } catch (e) {
              print(e);
            }
          }
          messageController.text = '';
        });
      });
    }
  }

  getImageCamera() async {
    XFile? img = await image.pickImage(source: ImageSource.camera,imageQuality: 50);
    var f = await img!.readAsBytes();
    setState(() {
      webImage = f;
      file = File(img!.path);
    });

    print(File(img!.path));
  }
  getImageGallery() async {
    XFile? img = await image.pickImage(source: ImageSource.gallery,imageQuality: 50);
    var f = await img!.readAsBytes();
    setState(() {
      webImage = f;
      file = File(img!.path);
    });
    insertImage();
  }

  insertImage()async{
    try {
      var metadata = SettableMetadata(
        contentType: "image/jpeg",
      );
      var imagefile = FirebaseStorage.instance
          .ref()
          .child("GlobalChat")
          .child("${FirebaseAuth.instance.currentUser!.uid}-${DateTime.now()}.png");
        
      UploadTask task = imagefile.putData(webImage);
      if (!kIsWeb) {
        UploadTask task = imagefile.putFile(file!);
      }
      TaskSnapshot snapshot = await task;
      url = await snapshot.ref.getDownloadURL();
      setState(() {
        url = url;
      });
      if (url != null) {
        print(url);
        submitMessage("image",url);
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> lastRead()async {
    ref.onValue.listen((event) {
      if(readStatus == false){
        Map data = event.snapshot.value as Map<String,dynamic>;
        int count = 0;
        outerLoop:
        for (var x in data.entries.toList().reversed) {
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
    });
  }
  
  Future<void> onRead()async {
    ref.get().then((event) {
      var count = 0;
      // if (onReadStatus) {
        Map data = event.value as Map<String,dynamic>;
        for (var x in data.entries.toList().reversed) {
          if (x.value['reader'] != null) {
            final read = x.value['reader'] as Map<String?,dynamic>;
            if (!read.containsKey(FirebaseAuth.instance.currentUser!.uid)) {
              Future.delayed(Duration(milliseconds: 1000)).then((value) {
                ref.child(x.key!.toString()).child('reader').child("${FirebaseAuth.instance.currentUser!.uid}").set({
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
              ref.child(x.key!.toString()).child('reader').child("${FirebaseAuth.instance.currentUser!.uid}").set({
                'user_uid':FirebaseAuth.instance.currentUser!.uid,
                'user_name':FirebaseAuth.instance.currentUser!.displayName,
                'user_image':FirebaseAuth.instance.currentUser!.photoURL,
                'message_position': _controller.position.maxScrollExtent,
                'created_at': DateTime.now().toString()
              });
            });
          }
        }
    });
    // print('object');
  }

  static DateTime returnDateAndTimeFormat(String time){
    var dt = DateTime.parse(time);
    return DateTime(dt.year, dt.month , dt.day);

  }

  static String groupMessageDateAndTime(String time){

    var dt = DateTime.parse(time);

    final todayDate = DateTime.now();

    final today = DateTime(todayDate.year, todayDate.month, todayDate.day);
    final yesterday = DateTime(todayDate.year, todayDate.month, todayDate.day - 1);
    String difference = '';
    final aDate = DateTime(dt.year, dt.month, dt.day);


    if(aDate == today) {
      difference = "Today" ;
    } else if(aDate == yesterday) {
      difference = "Yesterday" ;
    }
    else {
      difference = DateFormat.yMMMd().format(dt).toString() ;
    }

    return difference ;

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
          _msgUid = "";
        });
      }else{
        setState(() {
          onReadStatus = false;
        });
      }
    });
    if (kIsWeb) {
      // if (Platform.isAndroid) {
      // } else if (Platform.isIOS) {
      // }else if(Platform.isWindows){
      //   html.window.onKeyPress.listen((html.KeyboardEvent e) {
      //     unitCodeCtrlFocusNode.requestFocus();
      //   });
      // }
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

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
                          FirebaseDatabaseQueryBuilder(
                            query: ref, 
                            builder: (BuildContext context, FirebaseQueryBuilderSnapshot snapshot, Widget? child) { 
                              if (snapshot.hasData) {
                                final val = snapshot.docs.toList().reversed.toList();
                                return ListView.builder(
                                  itemCount: val.length,
                                  controller:_controller,
                                  reverse:true,
                                  shrinkWrap:true,
                                  itemBuilder:(context, index) {
                                    final data = val[index].value as Map;
                                    final DateTime date = returnDateAndTimeFormat(data['created_at'].toString());
                                    String? newDate;
                                    bool isSameDate = false;

                                    if (index == 0 && val.length == 1) {
                                      newDate = groupMessageDateAndTime(date.toString()).toString();
                                    } else if(index == 0) {
                                      newDate = "";
                                    } else if(index == val.length - 1) {
                                      newDate = groupMessageDateAndTime(date.toString()).toString();
                                    }else{
                                      final addData = val[index+1].value as Map;
                                      final subData = val[index-1].value as Map;
                                      isSameDate = date.isAtSameMomentAs(returnDateAndTimeFormat(addData['created_at'].toString()));
                                      newDate = isSameDate ? "" : returnDateAndTimeFormat(subData['created_at'].toString()).toString();
                                    }

                                    return Column(
                                      children: [
                                        newDate!.isNotEmpty ?
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
                                                    DateFormat("yyyy-MM-dd").format(DateTime.parse("${data['created_at']}")),
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
                                        ):Container(),
                                        
                                        ConstrainedBox(
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
                                                    ChatBubble(
                                                      clipper: ChatBubbleClipper2(type: BubbleType.sendBubble),
                                                      alignment: Alignment.topRight,
                                                      backGroundColor: Color.fromARGB(255, 41, 142, 224),
                                                      child: ConstrainedBox(
                                                        constraints: BoxConstraints(
                                                          minHeight: 30,
                                                          minWidth: 50,
                                                          maxWidth: screenWidth <= 600 ? screenWidth * 0.6 : screenWidth * 0.8
                                                        ),
                                                        child: Container(
                                                          padding: EdgeInsets.all(15),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(15),
                                                            color: Colors.transparent,
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
                                                              SizedBox(height: 5,),
                                                              data['type_message'] == "image" ?
                                                              GestureDetector(
                                                                onTap: () async{
                                                                  await showDialog(
                                                                    context: context,
                                                                    barrierDismissible: true,
                                                                    builder: (BuildContext context) { 
                                                                      return AlertDialog(
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                        ),
                                                                        backgroundColor: Color.fromARGB(255, 68, 68, 68),
                                                                        content: Builder(builder: (context){
                                                                          return Container(
                                                                            width: screenWidth * 0.7,
                                                                            child: PhotoView(
                                                                              imageProvider: NetworkImage(data['image'])
                                                                            ),
                                                                          );
                                                                        }),
                                                                      );
                                                                    }
                                                                  );
                                                                },
                                                                child: CachedNetworkImage(
                                                                  imageUrl: data['image'],
                                                                  filterQuality: FilterQuality.medium,
                                                                  fit: BoxFit.fitWidth,    
                                                                  width: 250,
                                                                  placeholder: (context, url) {
                                                                    return Container(
                                                                      width: 50,
                                                                      child: Center(child: CircularProgressIndicator()),
                                                                    );
                                                                  },
                                                                  errorWidget: (context, url, error) {
                                                                    return Container(
                                                                      width: 100,
                                                                      padding: EdgeInsets.all(3),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.white10,
                                                                        borderRadius: BorderRadius.circular(50)
                                                                      ),
                                                                      child: Column(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.image,
                                                                            color: Colors.white,
                                                                          ),
                                                                          Text(
                                                                            "Image Error",
                                                                            style: TextStyle(
                                                                              fontSize: 15,
                                                                              color: Colors.white70,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },                           
                                                                ),
                                                              ):
                                                              Text(
                                                                "${data['message']}",
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Color.fromARGB(255, 255, 255, 255),
                                                                  // overflow: TextOverflow.fade
                                                                ),
                                                              ),
                                                            ],
                                                          ),
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
                                                    ChatBubble(
                                                      clipper: ChatBubbleClipper1(type: BubbleType.receiverBubble),
                                                      alignment: Alignment.topRight,
                                                      backGroundColor: Color(0xFF526D82),
                                                      child: ConstrainedBox(
                                                        constraints: BoxConstraints(
                                                          minHeight: 30,
                                                          minWidth: 50,
                                                          maxWidth: screenWidth <= 600 ? screenWidth * 0.6 : screenWidth * 0.8
                                                        ),
                                                        child: Container(
                                                          padding: EdgeInsets.all(15),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(15),
                                                            color: Colors.transparent,
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
                                                              SizedBox(height: 5,),
                                                              data['type_message'] == "image" ?
                                                              GestureDetector(
                                                                onTap: () async{
                                                                  await showDialog(
                                                                    context: context,
                                                                    barrierDismissible: true,
                                                                    builder: (BuildContext context) { 
                                                                      return AlertDialog(
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                        ),
                                                                        backgroundColor: Color.fromARGB(255, 68, 68, 68),
                                                                        content: Builder(builder: (context){
                                                                          return Container(
                                                                            width: screenWidth * 0.7,
                                                                            child: PhotoView(
                                                                              imageProvider: NetworkImage(data['image'])
                                                                            ),
                                                                          );
                                                                        }),
                                                                      );
                                                                    }
                                                                  );
                                                                },
                                                                child: CachedNetworkImage(
                                                                  imageUrl: data['image'],
                                                                  filterQuality: FilterQuality.medium,
                                                                  fit: BoxFit.fitWidth,    
                                                                  width: 250,
                                                                  placeholder: (context, url) {
                                                                    return Container(
                                                                      width: 50,
                                                                      child: Center(child: CircularProgressIndicator()),
                                                                    );
                                                                  },
                                                                  errorWidget: (context, url, error) {
                                                                    return Container(
                                                                      width: 100,
                                                                      padding: EdgeInsets.all(3),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.white10,
                                                                        borderRadius: BorderRadius.circular(50)
                                                                      ),
                                                                      child: Column(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.image,
                                                                            color: Colors.white,
                                                                          ),
                                                                          Text(
                                                                            "Image Error",
                                                                            style: TextStyle(
                                                                              fontSize: 15,
                                                                              color: Colors.white70,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },                           
                                                                ),
                                                              ):
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
                                                    ),
                                                    Text(
                                                      "${DateFormat("HH:mm").format(DateTime.parse("${data['created_at']}"))}",
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
                              }
                              return Container();
                            }, 
                          )
                        ],
                      ),
                    ),
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
                              child: Transform.rotate(
                                angle: 315 * math.pi / 180,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.attach_file,
                                    size: 30,
                                    color: Color(0xFFDDE6ED),
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                        backgroundColor:
                                            Colors.transparent,
                                        context: context,
                                        constraints: BoxConstraints(
                                          maxHeight: 165,
                                          maxWidth: 325
                                        ),
                                        builder: (builder) =>
                                            bottomSheet());
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: messageController,
                                keyboardType: TextInputType.text,
                                minLines: 1,
                                maxLines: 10,
                                // focusNode: unitCodeCtrlFocusNode,
                                // expands: true,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                cursorColor: Colors.white30,
                                onFieldSubmitted: (value){
                                  submitMessage("message",'');
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
                                    submitMessage("message",'');
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
  Widget bottomSheet() {
    return Container(
      height: 165,
      child: Card(
        color: Color.fromARGB(255, 59, 74, 94),
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // iconCreation(
                  //     Icons.insert_drive_file, Colors.indigo, "Document"),
                  // SizedBox(
                  //   width: 40,
                  // ),
                  // iconCreation(Icons.camera_alt, Colors.pink, "Camera",
                  //   (){
                  //     getImageCamera();
                  //   }
                  // ),
                  // SizedBox(
                  //   width: 40,
                  // ),
                  iconCreation(Icons.insert_photo, Colors.purple, "Gallery",
                    (){
                      getImageGallery();
                    }
                  ),
                ],
              ),
              // SizedBox(
              //   height: 30,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     iconCreation(Icons.headset, Colors.orange, "Audio"),
              //     SizedBox(
              //       width: 40,
              //     ),
              //     iconCreation(Icons.location_pin, Colors.teal, "Location"),
              //     SizedBox(
              //       width: 40,
              //     ),
              //     iconCreation(Icons.person, Colors.blue, "Contact"),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData icons, Color color, String text, dynamic onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              // semanticLabel: "Help",
              size: 29,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFDDE6ED)
              // fontWeight: FontWeight.w100,
            ),
          )
        ],
      ),
    );
  }

}
