import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

MethodChannel native = const MethodChannel("wireguard");
void main() {
  runApp(const Pro());
}

class Pro extends StatelessWidget {
  const Pro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Pro",
      home: const Home(),
      theme: ThemeData(
          cardTheme: const CardTheme(
              margin: EdgeInsets.all(10),
              elevation: 10,
              shadowColor: Colors.black,
              color: Color.fromARGB(255, 226, 238, 239))),
      routes: {
        "GetConfig": (BuildContext context) {
          return const GetConfig();
        },
        "Connect": (BuildContext context) {
          return Connect();
        },
        "Browse": (context) {
          return const Browse();
        }
      },
    );
  }
}

class Payment extends StatelessWidget {
  const Payment({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> list = [
      Card(
        color: const Color.fromARGB(255, 226, 238, 239),
        child: Column(
          children: [
            Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: const Text(
                    "Connect to JioNet without Mobile Number",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.w100,
                        fontSize: 30,
                        letterSpacing: 1,
                        wordSpacing: 5),
                  ),
                )),
            Expanded(
                flex: 2,
                child: Container(
                    margin: const EdgeInsets.fromLTRB(200, 10, 10, 10),
                    width: 150,
                    child: ElevatedButton(
                        onPressed: () {
                          SharedPreferences.getInstance().then((preferences) {
                            if (preferences.containsKey("Config")) {
                              print(preferences.getString('Config'));
                              Navigator.pushNamed(context, "Connect");
                            } else {
                              Navigator.pushNamed(context, "GetConfig");
                            }
                          });
                        },
                        child: const Text(
                          "Go",
                          style: TextStyle(letterSpacing: 2, fontSize: 20),
                        ))))
          ],
        ),
      ),
    ];
    return Container(
      color: Colors.white,
      child: GridView(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent  (
            maxCrossAxisExtent: 600, childAspectRatio: 1.5),
        children: list,
      ),
    );
  }
}

bool hh = true;

class GetConfig extends StatefulWidget {
  const GetConfig({super.key});

  @override
  State<GetConfig> createState() => _GetConfigState();
}


WebViewController controller = WebViewController();
bool end = false;

class _GetConfigState extends State<GetConfig> {
  @override
  void initState() {
    super.initState();
    controller.setJavaScriptMode(JavaScriptMode.unrestricted).then(
      (value) {
        controller.addJavaScriptChannel("FlutterChannel",
            onMessageReceived: (JavaScriptMessage message) {
          SharedPreferences.getInstance().then(
            (value) {
              String msg = message.message;
              var list = msg.split('}').join("\n").split("\n");
              for (var element in list) {
                print(element);
              }
              print(list.length);
              List<String> Address = [],
                  PrivateKey = [],
                  Endpoint = [],
                  PublicKey = [],
                  DNS = [];
              Map<String, List<String>> info = {
                'Address': Address,
                'PrivateKey': PrivateKey,
                'Endpoint': Endpoint,
                'PublicKey': PublicKey,
                'DNS': DNS
              };
              for (var element in list) {
                if (element.contains("Address")) {
                  info['Address']!.add(element.split(' = ')[1]);
                  print(element.split(' = ')[1]);
                } else if (element.contains("PrivateKey")) {
                  info['PrivateKey']!.add(element.split(' = ')[1]);
                  print(element.split(' = ')[1]);
                } else if (element.contains("Endpoint")) {
                  info['Endpoint']!.add(element.split(' = ')[1]);
                  print(element.split(' = ')[1]);
                } else if (element.contains("PublicKey")) {
                  info['PublicKey']!.add(element.split(' = ')[1]);
                  print(element.split(' = ')[1]);
                } else if (element.contains("DNS")) {
                  info['DNS']!.add(element.split(' = ')[1]);
                  print(element.split(' = ')[1]);
                }
              }
              print(jsonEncode(info));
              value.setString("Config", jsonEncode(info)).then((value) {
                setState(() {
                  view = 3;
                });
              });
            },
          );
        }).then((value) {
          controller.setNavigationDelegate(NavigationDelegate(
            onPageFinished: (url) {
              if (url == "https://account.protonvpn.com/downloads") {
                if (hh) {
                  hh = false;
                  Timer(const Duration(seconds: 15), () {
                    controller.runJavaScript('''
                    var elem = document.getElementsByTagName("button")
                    var el = document.getElementsByClassName("button-solid-norm")
                    var text = ""
                    var j = elem.length-1;
                    for(var i=0;i<5;i++) {
                       
                       setTimeout(function (){
                          j = j-1
                          elem[j].click()
                          setTimeout(function (){
                            var ele = document.getElementsByTagName("textarea")
                            text += ele[ele.length-1].textContent 
                            text += "}"
                            setTimeout(function (){
                              el[2].click()
                            },5000)
                          },10000) 
                       },i*30000)                   
                    }
                    setTimeout(function (){
                       FlutterChannel.postMessage(text)
                    },200000)
                  ''');
                  });
                }
              }
              if (url == "https://account.protonvpn.com/dashboard") {
                setState(() {
                  view = 2;
                });
                controller.loadRequest(
                    Uri.https("account.protonvpn.com", "/downloads"));
              }
              if (url == "https://account.protonvpn.com/login") {
                Timer(const Duration(seconds: 1), () {
                  Navigator.push(
                      context,
                      DialogRoute(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor:
                                  const Color.fromARGB(255, 226, 238, 239),
                              title: const Text("Attention !"),
                              content: const Text(
                                  "Please login to your ProtonVPN account, If you don't have an account click on Create Account below"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "OK",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.blue),
                                    ))
                              ],
                            );
                          }));
                });
              }
            },
          )).then((value) {
            controller
                .loadRequest(Uri.https("account.protonvpn.com", "/login"));
          });
        });
      },
    );
  }

  String messag = "";
  int view = 0;
  @override
  Widget build(BuildContext context) {
    switch (view) {
      case 0:
        return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 226, 238, 239),
              foregroundColor: Colors.blue,
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back)),
            ),
            body: WebViewWidget(controller: controller));
      case 1:
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 226, 238, 239),
            foregroundColor: Colors.blue,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back)),
          ),
          body: Stack(
            children: [
              WebViewWidget(controller: controller),
              AlertDialog(
                backgroundColor: const Color.fromARGB(255, 226, 238, 239),
                title: const Text("Attention !"),
                content: const Text(
                    "Please login to your ProtonVPN account, If you don't have an account click on Create Account below"),
                actions: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          view = 0;
                        });
                      },
                      child: const Text(
                        "OK",
                        style: TextStyle(fontSize: 20, color: Colors.blue),
                      ))
                ],
              )
            ],
          ),
        );
      case 2:
        return Stack(
          children: [
            WebViewWidget(controller: controller),
            Container(
              color: Colors.white,
              child: const AlertDialog(
                backgroundColor: Color.fromARGB(255, 226, 238, 239),
                title: Text("info"),
                content: Text(
                    "Please wait until we fetch some configuration files. This process takes 5 minutes"),
              ),
            )
          ],
        );
      case 3:
        return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 226, 238, 239),
              foregroundColor: Colors.blue,
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back)),
            ),
            body: const AlertDialog(
              backgroundColor: Color.fromARGB(255, 226, 238, 239),
              title: Text("info"),
              content: Text(
                  "All set, you can now go back and click on Go to connect"),
            ));

      default:
        return Container(
          color: Colors.green,
        );
    }
  }
}

class Connect extends StatelessWidget {
  Connect({super.key});

  var client = http.Client();
  void bypass() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 226, 238, 239),
        foregroundColor: Colors.blue,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Container(
        color: const Color.fromARGB(255, 226, 238, 239),
        child: Column(
          children: [
            Container(
              height: 200,
            ),
            Center(
              child: ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.blue)),
                  onPressed: () async {
                    var prefs = await SharedPreferences.getInstance();
                    var config = prefs.getString("Config");
                    var json = jsonDecode(config!);
                    int t = 7;
                    int k = 0;
                    native.invokeMethod("wg_down");
                    native.invokeMethod("wg_down");
                    Timer(const Duration(seconds: 1), () {
                      native.invokeMethod("wg_up", [
                        json['Address'][k].toString().trim(),
                        json['PrivateKey'][k].toString().trim(),
                        json['Endpoint'][k].toString().trim(),
                        json['PublicKey'][k].toString().trim(),
                        json['DNS'][k].toString().trim(),
                      ]);
                    });
                    ++k;
                    Timer.periodic(const Duration(seconds: 1), (timer) {
                      if (end == true) {
                        timer.cancel();
                        native.invokeMethod("wg_down");
                        return;
                      }
                      Socket.connect("8.8.8.8", 53,
                              timeout: const Duration(seconds: 1))
                          .then((value) {
                        print('ip ${value.remoteAddress}');
                        value.destroy();
                        print('connectedd and destroyed');
                        t = 0;
                      }).onError((error, stackTrace) {
                        ++t;
                        print('not connectedd $t $k');
                        if (t == 8) {
                          t = 0;
                          print('changing since not connectedd');
                          native.invokeMethod("wg_down");
                          native.invokeMethod("wg_down");
                          Timer(const Duration(seconds: 1), () {
                            native.invokeMethod("wg_up", [
                              json['Address'][k].toString().trim(),
                              json['PrivateKey'][k].toString().trim(),
                              json['Endpoint'][k].toString().trim(),
                              json['PublicKey'][k].toString().trim(),
                              json['DNS'][k].toString().trim(),
                            ]);
                          });
                          ++k;
                          if (k == 5) k = 0;
                        }
                      });
                    });
                    Timer(const Duration(seconds: 60), () {
                      client
                          .get(Uri.https(
                              "wrongname.s3.ap-south-1.amazonaws.com",
                              "/free-provpn"))
                          .then((value) {
                        print(value.body);
                        if (value.body.contains(
                            "ThisFileContainsSomeRandomTextToVerifySomethingThatYouDontNeedToKnow")) {
                          print("received and matched");
                        } else {
                          print("ending program");
                          end = true;
                        }
                      }).onError((error, stackTrace) {
                        print("ending program");
                          end = true;
                      });
                    });
                    /*
                    int t = 0, k = 0, o = 0;
                    while (true) {
                      if (end) {
                        break;
                      }
                      if (k == 5) k = 0;
                      t = 0;
                      print(
                          "privatekey ${json['Address'][k]} ${json['PrivateKey'][k]} ${json['Endpoint'][k]} ${json['PublicKey'][k]} ${json['DNS'][k]}");
                      native.invokeMethod("wg_down");
                      native.invokeMethod("wg_down");
                      sleep(const Duration(seconds: 1));
                      native.invokeMethod("wg_up", [
                        json['Address'][k].toString().trim(),
                        json['PrivateKey'][k].toString().trim(),
                        json['Endpoint'][k].toString().trim(),
                        json['PublicKey'][k].toString().trim(),
                        json['DNS'][k].toString().trim(),
                      ]);
                      ++k;

                      while (t != 6) {
                        await Socket.connect("8.8.8.8", 53,
                                timeout: const Duration(seconds: 1))
                            .then((value) {
                          value.destroy();
                          t = 0;
                        }).onError((error, stackTrace) {
                          ++t;
                        });
                        sleep(const Duration(seconds: 1));
                      }
                    }

                    native.invokeMethod("wg_down");
                    native.invokeMethod("wg_up", [
                        json['Address'][k].toString(),
                        json['PrivateKey'][k].toString(),
                        json['Endpoint'][k].toString(),
                        json['PublicKey'][k].toString(),
                        json['DNS'][k],
                      ]);
                     native.invokeMethod("wg_up", [
                      "10.2.0.2/32",
                      "WPUuiGSM8tmZD+YjlIvdlMa0KIDJlBVDMfTXN5wFXU0=",
                      "37.19.221.199:51820",
                      "qBUTSloO8PKGUl0ZrfTx1AZwwCwJRB+9kGD0hquFqVQ="
                    ]);
                    */
                  },
                  child: const Text(
                    "Connect",
                    style: TextStyle(letterSpacing: 2, fontSize: 20),
                  )),
            ),
            Container(
              height: 100,
            ),
            Center(
              child: ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.blue)),
                  onPressed: () {
                    native.invokeMethod("wg_down");
                  },
                  child: const Text(
                    "Disconnect",
                    style: TextStyle(letterSpacing: 2, fontSize: 20),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

void bypass() {
  var client = http.Client();
  SharedPreferences.getInstance().then((prefs) async {
    var config = prefs.getString("Config");
    var json = jsonDecode(config!);
    int t = 7;
    int k = 0;
    native.invokeMethod("wg_down");
    native.invokeMethod("wg_down");
    Timer(const Duration(seconds: 1), () {
      native.invokeMethod("wg_up", [
        json['Address'][k].toString().trim(),
        json['PrivateKey'][k].toString().trim(),
        json['Endpoint'][k].toString().trim(),
        json['PublicKey'][k].toString().trim(),
        json['DNS'][k].toString().trim(),
      ]);
    });
    ++k;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      Socket.connect("8.8.8.8", 53, timeout: const Duration(seconds: 1))
          .then((value) {
        print('ip ${value.remoteAddress}');
        value.destroy();
        print('connectedd and destroyed');
        t = 0;
      }).onError((error, stackTrace) {
        ++t;
        print('not connectedd $t $k');
        if (t == 8) {
          t = 0;
          print('changing since not connectedd');
          native.invokeMethod("wg_down");
          native.invokeMethod("wg_down");
          Timer(const Duration(seconds: 1), () {
            native.invokeMethod("wg_up", [
              json['Address'][k].toString().trim(),
              json['PrivateKey'][k].toString().trim(),
              json['Endpoint'][k].toString().trim(),
              json['PublicKey'][k].toString().trim(),
              json['DNS'][k].toString().trim(),
            ]);
          });
          ++k;
          if (k == 5) k = 0;
        }
      });
    });
  });
}

class Browse extends StatelessWidget {
  const Browse({super.key});

  @override
  Widget build(BuildContext context) {
    bypass();
    return Container();
    /*
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.setNavigationDelegate(NavigationDelegate(
      onPageFinished: (url) {
        print("url is $url");
      },
      onWebResourceError: (error) {
        print(
            "webreserr ${error.description} ${error.errorCode} ${error.errorType}");
        if (error.errorCode == -6) {
          Timer(const Duration(seconds: 6), () {
            controller.reload();
          });
        }
      },
    ));
    controller.loadRequest(Uri.https("search.brave.com"));
    return SafeArea(child: WebViewWidget(controller: controller));*/
  }
}