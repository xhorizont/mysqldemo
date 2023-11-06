import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import package file manually

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.red, //primary color for theme
        ),
        home: const WriteSQLdata() //set the class here
        );
  }
}

class WriteSQLdata extends StatefulWidget {
  const WriteSQLdata({super.key});

  @override
  State<StatefulWidget> createState() {
    return WriteSQLdataState();
  }
}

class WriteSQLdataState extends State<WriteSQLdata> {
  TextEditingController namectl = TextEditingController();
  TextEditingController addressctl = TextEditingController();
  TextEditingController classctl = TextEditingController();
  TextEditingController rollnoctl = TextEditingController();
  //text controller for TextField

  late bool error, sending, success;
  late String msg;

  String phpurl = "https://ai.xdata.si/test/write.php";
  // do not use http://localhost/ for your local
  // machine, Android emulation do not recognize localhost
  // insted use your local ip address or your live URL
  // hit "ipconfig" on Windows or  "ip a" on Linux to get IP Address

  @override
  void initState() {
    error = false;
    sending = false;
    success = false;
    msg = "";
    super.initState();
  }

  Future<void> sendData() async {
    var res = await http.post(Uri.parse(phpurl), body: {
      "name": namectl.text,
      "address": addressctl.text,
      "class": classctl.text,
      "rollno": rollnoctl.text,
    }); //sending post request with header data

    if (res.statusCode == 200) {
      print(res.body); //print raw response on console
      var data = json.decode(res.body); //decoding json to array
      if (data["error"]) {
        setState(() {
          //refresh the UI when error is recieved from server
          sending = false;
          error = true;
          msg = data["message"]; //error message from server
        });
      } else {
        namectl.text = "";
        addressctl.text = "";
        classctl.text = "";
        rollnoctl.text = "";
        //after write success, make fields empty

        setState(() {
          sending = false;
          success = true; //mark success and refresh UI with setState
        });
      }
    } else {
      //there is error
      setState(() {
        error = true;
        msg = "Napaka pri pošiljanju.";
        sending = false;
        //mark error and refresh UI with setState
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Zapis podatkov z PHP & MySQL"),
          backgroundColor: Colors.redAccent), //appbar

      body: SingleChildScrollView(
          //enable scrolling, when keyboard appears,
          // hight becomes small, so prevent overflow
          child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Text(error ? msg : "Enter Student Information"),

                  Text(success ? "Write Success" : "Poslano"),

                  TextField(
                    controller: namectl,
                    decoration: const InputDecoration(
                      labelText: "Ime:",
                      hintText: "Vnesite polno ime",
                    ),
                  ), //text input for name

                  TextField(
                    controller: addressctl,
                    decoration: const InputDecoration(
                      labelText: "Naslov:",
                      hintText: "Polni naslov",
                    ),
                  ), //text input for address

                  TextField(
                    controller: classctl,
                    decoration: const InputDecoration(
                      labelText: "Razred:",
                    ),
                  ), //text input for class

                  TextField(
                    controller: rollnoctl,
                    decoration: const InputDecoration(
                      labelText: "ID:",
                      hintText: "",
                    ),
                  ), //text input for roll no

                  Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              //if button is pressed, setstate sending = true, so that we can show "sending..."
                              setState(() {
                                sending = true;
                              });
                              sendData();
                            },
                            child: Text(
                              sending ? "Pošiljanje..." : "Vnesi",
                              //if sending == true then show "Sending" else show "SEND DATA";
                            ),
                            //background of button is darker color, so set brightness to dark
                          )))
                ],
              ))),
    );
  }
}
