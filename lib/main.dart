import 'dart:core';
import 'dart:io';

import 'package:charset/charset.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> listTxt = [];
  @override
  void initState() {
    super.initState();
  }

  convertFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      print(cp866.decode(file.readAsBytesSync()));
    } else {
      // User canceled the picker
    }
    //cp866.decode(bytes)
  }

  getAllTxt() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      var dir = Directory(selectedDirectory);
      dir
          .list(recursive: true, followLinks: false)
          .listen((FileSystemEntity entity) {
        //print(entity.path);
        if (entity.path.contains('.txt')) {
          print(entity.path);
          listTxt.add(entity.path);
        }
        print('All done');
      });
    }
    print('DONE select');
    // setState(() {
    //   listTxt = list;
    // });
  }

  convertData() {
    List<String> data = [];
    for (var path in listTxt) {
      print('PATH: $path');
      File file = File(path);
      try {
        String text = cp866.decode(file.readAsBytesSync());
        // print(text);
        data.add(text);
      } catch (e) {
        print(e);
      }
    }
    for (var name in listTxt) {
      writeText(
          name: getName(name),
          data: data[listTxt.indexOf(name)],
          fileFrom: getFolderPath(name));
    }
    print('LIST DATA: $data');
    print('DONE');
  }

  getName(String file) {
    List<String> d = file.split('/');
    return d.last.toString();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String fPath, String fileFrom) async {
    final path = await _localPath;
    //print(path);
    return File('$fileFrom' + 'm$fPath');
    //return File('$path/$fPath');
  }

  Future<void> writeText(
      {required String fileFrom,
      required String name,
      required dynamic data}) async {
    print(data);
    final file = await _localFile(name, fileFrom);
    return file.writeAsStringSync('$data');
  }

  String getFolderPath(String path) {
    String p = '';
    List<String> list = path.split('/');
    list.removeLast();
    for (var item in list) {
      p += '$item/';
    }

    return p;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              'ку-ку',
              style: Theme.of(context).textTheme.headline4,
            ),
            ElevatedButton(
              onPressed: convertData,
              child: const Text('convert'),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getAllTxt,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
