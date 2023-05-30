import 'package:flutter/material.dart';


class ChattingPage extends StatefulWidget {
  const ChattingPage({
    super.key,
  });

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
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
              MediaQuery.of(context).size.width <= 897 ? Container() :
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 0,
                  maxHeight: MediaQuery.of(context).size.height,
                  maxWidth: 400,
                  minWidth: 400,
                ),
                child: Container(
                  color: Colors.white24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 400,
                        height: 60,
                        color: Colors.white,
                        child: Text(
                          'Profile & Settings'
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for(int x = 1;x < 10;x++)
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white12,width: 1)
                                ),
                                height: 75,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.asset(
                                          'assets/images/default.jpeg',
                                          width: 50,
                                          height: 50,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Enricko Putra H',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800
                                            ),
                                          ),
                                          Text(
                                            'Enricko : Woi ${x}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white38,
                                              fontSize: 16,
                                              // fontWeight: FontWeight.w800
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                                minLines: 1,
                                maxLines: 10,
                                // expands: true,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                cursorColor: Colors.white30,
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
                              child: IconButton(
                                icon: Icon(
                                  Icons.send
                                ),
                                onPressed: null,
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