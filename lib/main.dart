import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Find Gender of Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Find Gender of Name'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  TextEditingController _controller;

  String _url = "https://api.genderize.io/";

  Response response;

  String yourName;

  StreamController _streamController;

  Stream _stream;

  getGenderofyourName() async {



    if(_controller.text != null)
    {
      response = await http.get(_url+'?name=${_controller.text}');
      _streamController.add("waiting");
      _streamController.add(json.decode(response.body));

    }


  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _streamController = StreamController.broadcast();
    _stream = _streamController.stream;
    _controller = TextEditingController();

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: Center(
        child: Container(
          height: 300.0,
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.white70, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Predict the Gender of your name",style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold,letterSpacing: 0.5),),
                  ),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter your name..',
                    ),

                  ),
                  Container(
                    height: 45.0,
                    width: double.infinity,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.blue)),
                      onPressed: () async {

                        _controller.text != "" ?
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            getGenderofyourName();

                            return AlertDialog(
                              title: Text('Hello! '+_controller.text),
                              content: DataBody(),
                              actions: <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        ):
                        showDialog<void>(

                          context: context,
                          builder: (BuildContext context) {

                            return AlertDialog(
                              title: Text("Hey !!"),
                              content: Text("Enter something"),
                              actions: <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        )
                        ;
                      },
                      color: Colors.blue,
                      textColor: Colors.white,
                      child: Text("Check".toUpperCase(),
                          style: TextStyle(fontSize: 14,letterSpacing: 0.8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }
  Widget DataBody()
  {
    return StreamBuilder(
      stream: _stream,
      builder: (BuildContext ctx, AsyncSnapshot snapshot) {
        if (snapshot.data == "waiting") {
          return Center(child: Text("Waiting of the image....."));
        }
        return Container(
          height: 72.0, // Change as per your requirement
          width: 300.0,
          child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int i) {
                return Center(
                  child: Expanded(
                    child: ListBody(
                      children: [
                        Center(
                          child:  snapshot.data != null ? Card(
                              elevation: 2.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    snapshot.data['gender'] == 'male' ? Image.asset('assets/boy.png',width: 50.0,height: 50.0,) : Image.asset('assets/female.png',width: 50.0,height: 50.0),
                                    Text(snapshot.data['name'].toString().toUpperCase(),style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),
                                    Text(snapshot.data['gender'].toString().toUpperCase(),style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold)),
                                    CircularPercentIndicator(
                                      radius: 40.0,
                                      lineWidth: 7.0,
                                      percent: snapshot.data['probability'],
                                      center:Text(((snapshot.data['probability']*100).round()).toString()+"%",style: TextStyle(fontSize: 9.5,fontWeight: FontWeight.bold),),
                                      // progressColor: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0)
                                      progressColor: Colors.green,
                                    ),
                                  ],
                                ),
                              )):  Container(child: Text("Waiting of the result.....")),
                        )
                      ],
                    ),
                  ),
                );
              }),
        );
      },
    );
  }
}
