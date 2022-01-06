import 'package:ai_light/views/transferPage.dart';
import 'package:download_assets/download_assets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';

void main() {
  // if(!App.assetExists) sharedp();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

sharedp() async {
  await App.init();
  await App.downloadAssetsController.init();
  bool down = App.assetExists;
  if (!down) {
    await App.localStorage?.setBool("downloaded", false);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool downloaded = false;
  double progress = 0.0;
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future _init() async {
    await sharedp();
    await App.downloadAssetsController.init();
    downloaded = App.localStorage?.getBool("downloaded") ?? false;
    if (downloaded)
      setState(() {
        return;
      });
    try {
      await App.downloadAssetsController.startDownload(
        assetsUrl:
            "https://github.com/sidhunt/ai-light-asset/raw/master/model.zip",
        onProgress: (val) {
          setState(() {
            progress = val / 100;
          });
        },
      );
    } on DownloadAssetsException catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("AI Image Brightening App"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (downloaded)
                ? ClassifierPage()
                // Text("${App.downloadAssetsController.assetsDir}/")
                : Center(
                    child: Column(
                      children: [
                        const Text("Please wait while we initialize the AI"),
                        CircularProgressIndicator(
                          value: progress,
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
