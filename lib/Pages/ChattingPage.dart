import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
  final ref = FirebaseDatabase.instance
  .ref()
  .child('GlobalChat');

  bool btnHide = true;

  submitMessage(){
    if (messageController.text != '' && FirebaseAuth.instance.currentUser != null) {
      // final key = ref.push().key;
      ref.push().set({
        'user_uid':FirebaseAuth.instance.currentUser!.uid,
        'user_name':FirebaseAuth.instance.currentUser!.displayName,
        'user_image':FirebaseAuth.instance.currentUser!.photoURL,
        'message':messageController.text,
        'created_at': DateTime.now().toString()
      });
      messageController.text = '';
    }
  }
  final ScrollController _controller = ScrollController();

  // This is what you're looking for!
  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
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
        backgroundColor: Colors.blueGrey[800],
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
              //     color: Colors.white24,
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
                      child: FirebaseAnimatedList(
                        controller: _controller,
                        query: ref.orderByChild('created_at'),
                        // reverse: true,
                        shrinkWrap: true,
                        itemBuilder: (context, snapshot, animation, index){
                          Map data = snapshot.value as Map;
                          data['key'] = snapshot.key;

                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: 30,
                              minWidth: 50,
                              maxWidth: 50
                            ),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                              child: Row(
                                mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ? MainAxisAlignment.end : MainAxisAlignment.start,
                                crossAxisAlignment:  FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  FirebaseAuth.instance.currentUser!.uid == data['user_uid'] ?
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
                                            data['user_name'],
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900
                                              // overflow: TextOverflow.fade
                                            ),
                                          ),
                                          Text(
                                            data['message'],
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white70,
                                              // overflow: TextOverflow.fade
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ):

                                  Container(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.network(
                                        '${data['user_image']}',
                                        width: 30,
                                        loadingBuilder: (context, child, loadingProgress) {
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
                                        errorBuilder: (context, child, loadingProgress) {
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
                                      child: Image.network(
                                        '${data['user_image']}',
                                        width: 30,
                                        loadingBuilder: (context, child, loadingProgress) {
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
                                        errorBuilder: (context, child, loadingProgress) {
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
                                            data['user_name'],
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900
                                              // overflow: TextOverflow.fade
                                            ),
                                          ),
                                          Text(
                                            data['message'],
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white70,
                                              // overflow: TextOverflow.fade
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                      ),
                    ),
                    btnHide == true ? Container() :
                    Stack(
                      children: [
                        Positioned(
                          // bottom: 130,
                          // right: 20,
                          child:ElevatedButton(
                            onPressed: (){
                              _scrollDown();
                            },
                            child: Icon(Icons.arrow_downward),
                          ),
                        ),
                      ],
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 350,
                        minHeight: 60
                      ),
                      child: Container(
                        color: Colors.white24,
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
                                    borderSide: BorderSide(color:Colors.white24, width: 3),
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