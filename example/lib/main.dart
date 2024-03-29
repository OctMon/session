import 'dart:io';

import 'package:example/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:session/session.dart';

import 'data_model.dart';

void main() => runApp(MyApp());

Session session = Session(
  config: Config(
    baseUrl: 'https://api.tuchong.com/',
    // createHttpClient: () {
    //   // Don't trust any certificate just because their root cert is trusted.
    //   final client =
    //       HttpClient(context: SecurityContext(withTrustedRoots: false));
    //   // You can test the intermediate / root cert here. We just ignore it.
    //   client.badCertificateCallback = (cert, host, port) => true;
    //   // Config the client.
    //   client.findProxy = (uri) {
    //     // Forward all request to proxy "localhost:8888".
    //     // Be aware, the proxy should went through you running device,
    //     // not the host platform.
    //     return "PROXY localhost:8888";
    //   };
    //   // You can also create a new HttpClient for Dio instead of returning,
    //   // but a client must being returned here.
    //   return client;
    // },
    badCertificateCallback: (cert, String host, int port) {
      print("badCertificateCallback: $host");
      return true;
    },
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 5),
    code: 'result',
    list: 'feedList',
  ),
  onRequest: (options) {
    return options
      ..headers.addAll({
        'os': kIsWeb ? "web" : Platform.operatingSystem,
      });
  },
  onResult: (result) {
    return result
        .merge(Result(message: '永远都是成功', valid: result.code == 'SUCCESS'));
  },
);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title = ""}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    print("begin: ${DateTime.now()}");
    getAPI(path: "ip", connectTimeout: Duration(seconds: 20)).then((result) {
      print("end: ${DateTime.now()}");
      print("======");
      print(result.response?.statusCode);
      print(result.code);
      print(result.message);
      print(result.body);
      print(result.valid);
      print(result.error);
      print("======");
    });
    super.initState();
  }

  void _incrementCounter() async {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
    Result result = await session.request('feed-app',
        queryParameters: {'page': _counter}, connectTimeout: Duration(seconds: 60));
    if (result.valid) {
      // result.fillList(result.list.map((json) => FeedList.fromJson(json)).toList());
      // result.fillModels((json) => FeedList.fromJson(json));
      result.fillMap((json) => DataMode.fromJson(json), map: result.body);
      result.fillMap((json) => FeedList.fromJson(json), map: result.list);
      print(result.models.length);
      print(result.model);
    } else {
      print(result.error);
    }
    print('=====');
    print(result.response?.statusCode);
    print(result.response?.data);
    print(result.code);
    print(result.message);
    print(result.list);
    print(result.valid);
    print('=====');
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke 'debug painting' (press 'p' in the console, choose the
          // 'Toggle Debug Paint' action from the Flutter Inspector in Android
          // Studio, or the 'Toggle Debug Paint' command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
