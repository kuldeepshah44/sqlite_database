import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sqflite/src/database_helper.dart';
import 'package:flutter_sqflite/src/model/data.dart';
import 'package:flutter_sqflite/src/model/person_model.dart';
import 'package:flutter_sqflite/src/person_adapter.dart';
import 'package:flutter_sqflite/src/screen/view_screen.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:hive_flutter/hive_flutter.dart';
Future<void> main() async {

await Hive.initFlutter();
final appDocumentDirectory = await getApplicationDocumentsDirectory();
print("appDocumentDirectory.path======${appDocumentDirectory.path}");
 Hive..init(appDocumentDirectory.path)..registerAdapter(PersonAdapter());

//Hive.registerAdapter(PersonAdapter());
await Hive.openBox('mydatabase');

  runApp(MaterialApp(
    home: SplashScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
class SplashScreen extends StatefulWidget {

  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  final dbHelper = DatabaseHelper.instance;
  void initState() {
    super.initState();
    getDb();
  }
var message="";

  Future<void> getDb()
  async {
//   await dbHelper.copyDatabase();
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sqflite'),
      ),
      body: Center(
        child: ListView.builder(
        itemCount: 1,
         itemBuilder: (BuildContext ctx,int index){
           return Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: <Widget>[



               Text(message),
               SizedBox(height: 10,),
               RaisedButton(
                 child: Text('insert', style: TextStyle(fontSize: 20),),
                 onPressed: _insert,
               ),

               RaisedButton(
                 child: Text('Add to Cart', style: TextStyle(fontSize: 20),),
                 onPressed: addtocart,
               ),

               RaisedButton(
                 child: Text('query', style: TextStyle(fontSize: 20),),
                 onPressed: _query,
               ),
               RaisedButton(
                 child: Text('update', style: TextStyle(fontSize: 20),),
                 onPressed: updateNew,
               ),
               RaisedButton(
                 child: Text('delete', style: TextStyle(fontSize: 20),),
                 onPressed: deleteNew,
               ),
               RaisedButton(
                 onPressed: () async {
                   var dbFolder = await getDatabasesPath();
                   File source1 = File('${dbFolder}/MyDatabase.db');

                     if ((await source1.exists())) {
                       print("exits file");
                     }
                     else
                       {
                         print("not exits file");
                       }
                   var basNameWithExtension = path.basename(source1.path);
                   Directory copyTo = Directory("/storage/emulated/0/local");
                   if ((await copyTo.exists())) {
                     print("Path exist");
                     var status = await Permission.storage.status;
                     if (!status.isGranted) {
                       await Permission.storage.request();
                     }
                   } else {
                     print("not exist");
                     if (await Permission.storage.request().isGranted) {
                       // Either the permission was already granted before or the user just granted it.
                       await copyTo.create();
                     } else {
                       print('Please give permission');
                     }
                   }
                   String newPath = "${copyTo.path}/${basNameWithExtension}";
                   await source1.copy(newPath);
                   setState(() {
                     message = 'Successfully Copied DB';
                     print("Ok...");
                   });
                 },
                 child: const Text('Copy DB'),
               ),

               RaisedButton(
                 child: Text('Hive Data', style: TextStyle(fontSize: 20),),
                 onPressed: hiveData,
               ),

               RaisedButton(
                 child: Text('Hive Data', style: TextStyle(fontSize: 20),),
                 onPressed: gethiveData,
               ),
                RaisedButton(
                 child: Text('Hive insert', style: TextStyle(fontSize: 20),),
                 onPressed: insertHive,
               ),

               RaisedButton(
                 child: Text('ViewScreen', style: TextStyle(fontSize: 20),),
                 onPressed: (){

                   Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewScreen()));
                 },
               ),


               /* RaisedButton(
                onPressed: () async {
                  var databasesPath = await getDatabasesPath();
                  var dbPath = join(databasesPath, 'doggie_database.db');

                  FilePickerResult result =
                  await FilePicker.platform.pickFiles();

                  if (result != null) {
                    File source = File(result.files.single.path);
                    await source.copy(dbPath);
                    setState(() {
                      message = 'Successfully Restored DB';
                    });
                  } else {
                    // User canceled the picker

                  }
                },
                child: const Text('Restore DB'),
              ),*/

             ],
           );
         },
        ),
      ),
    );
  }

  Future<void> hiveData()
  async {
    var path=Directory.current.path;
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
   // Hive..init(appDocumentDirectory.path)..registerAdapter(Person());

    //print("path=====${appDocumentDirectory.path}");

    //Hive..init(path)..registerAdapter();
  var box=await Hive.openBox("database");
    box.put('name', 'proto coders point');
    box.put('myname', 'Rajat palankar');

   var newbox = Hive.box('mydatabase');
    var person=Person();
        person=new Person(name: "Kuldeep",mobile: "7405050870",address: "surat");
    newbox.add(person);
        person=new Person(name: "ashis",mobile: "9876543210",address: "surat");
    newbox.add(person);
        person=new Person(name: "mehul",mobile: "7779049787",address: "surat");
    newbox.add(person);
    print('Info added to box!');

int a=0;
newbox.values.forEach((element) {
  a++;
  print("id=${a}==Name==${element.name.toString()},Mobile==${element.mobile.toString()}");
});
    var personData = newbox.getAt(9);
  print("print=====${newbox.values.toList()}");
  print("print=====${personData.name}");

  print("Get Data=====${box.get("name")}");
  }

  Future<void> insertHive()
  async {
    var box = Hive.box('mydatabase');
    await box.delete('data');
    box.put('data', dataToInsert);
    print("insert");

    List<Map<dynamic, dynamic>> data = box.get('data');
    print(data);
    print("data===${data[1]}");
  }

  Future<void> gethiveData()
  async {
    var newbox = Hive.box('mydatabase');
    int a=0;
    newbox.values.forEach((element) {
      a++;
      print("id=${a}==Name==${element.name.toString()},Mobile==${element.mobile.toString()}");
    });


    var personData = newbox.getAt(9);
    print("print=====${newbox.values.toList()}");
    print("print=====${personData.name}");

    print("Get Data=====${newbox.values.length}");
  }

  Future<File> moveFile(File sourceFile, String newPath) async {
    try {
      /// prefer using rename as it is probably faster
      /// if same directory path
      return await sourceFile.rename(newPath);
    } catch (e) {
      /// if rename fails, copy the source file
      final newFile = await sourceFile.copy(newPath);
      return newFile;
    }
  }

  void _insert() async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName : 'Bob',
      DatabaseHelper.columnAge  : 23
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
  }

  void addtocart() async {
    // row to insert
    Map<String, dynamic> map =new Map();
    map['product_id']='12';
    map['product_name']='test';
    map['product_image']='http://demo.com/test.jpg';
    map['product_price']='499';
    map['mrp_price']='799';
    map['sell_price']='499';
    map['gst']='5';
    map['weight']='1';
    map['qty']='1';
    map['size']='M';
    map['sub_total']='499';


    List<Map<String,dynamic>> list = await dbHelper.findcartItem(map['product_id'], map['size']);
    if(list.length > 0)
    {
      map['qty']='2';
      map['sub_total']='1500';
      final id = await dbHelper.updatecart(map);
      print('update table');
    }
    else {
      final id = await dbHelper.addtocart(map);
      print('inserted row id: $id');
    }
  }

  void _query() async {
    List<Map<String,dynamic>> allRows = await dbHelper.queryAllRowsNew();
    print('query all rows:');
    allRows.forEach(print);
    message=allRows.toString();

    allRows.forEach((element) {
      print("record =${element}");
      print("id =${element['_id']}");
      print("name =${element['name']}");
      print("Bob =${element['age']}");

    });
    setState(() {

    });
  }

  Future<void> updateNew()
  async {
    final rowsAffected = await dbHelper.updateNew("2","kuldeep",30);
    print('updated $rowsAffected row(s)');
    setState(() {
message="updated $rowsAffected row(s)";
    });
  }

  void _update() async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnId   : 1,
      DatabaseHelper.columnName : 'Mary',
      DatabaseHelper.columnAge  : 32
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
  }

  void _delete() async {
    // Assuming that the number of rows is the id for the last row.
    final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id);
    print('deleted $rowsDeleted row(s): row $id');
  }

  Future<void> deleteNew()
  async {
    final rowsDeleted = await dbHelper.deleteNew("2");
    print('deleted $rowsDeleted row(s): row ');
    setState(() {
      message="deleted $rowsDeleted row(s)";
    });
  }
}