import 'dart:io';

import 'package:file_utils/file_utils.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'my_table';
  static final addtocart_table = 'cart';

  static final columnId = '_id';
  static final columnName = 'name';
  static final columnAge = 'age';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await ExistingDB();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {

    //getDatabasesPath
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // join(await getDatabasesPath(), 'doggie_database.db'),
    final dbFolder = await getDatabasesPath();
    print("dbfolder====${dbFolder}");

    String path = join(dbFolder, _databaseName);
    print("My database====${path}");




    return await openDatabase(path,version: _databaseVersion, onCreate: _onCreate);
  }

  ExistingDB()
  async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, _databaseName);
// delete existing if any
    await deleteDatabase(path);
// Make sure the parent directory exists
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

// Copy from asset
    ByteData data = await rootBundle.load(join("assets", "demo.db"));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await new File(path).writeAsBytes(bytes, flush: true);

// open the database
   // var db = await openDatabase(path, readOnly: true);

    return await openDatabase(path,version: _databaseVersion);
  }
  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnAge INTEGER NOT NULL
          )
          ''');
  }




  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryAllRowsNew() async {
    Database db = await instance.database;
    String sql="select * from ${table}";
    return await db.rawQuery(sql);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }
  Future<int> updateNew(String id, String name, int age) async {
    Database db = await instance.database;

    String sql="update ${table} set ${columnName}='${name}',${columnAge}='${age}' where ${columnId}='${int.parse(id)}'";
    return await db.rawUpdate(sql);
  }
  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
  Future<int> deleteNew(String id) async {
    Database db = await instance.database;
    String sql="delete from ${table}  where ${columnId}='${int.parse(id)}'";
    return await db.rawDelete(sql);
  }
// add notification

  Future<int> addtocart(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(addtocart_table, row);
  }

  Future<List<Map<String, dynamic>>> findcartItem(String pid,String size) async {
    Database db = await instance.database;
    String sql="select * from ${addtocart_table} where product_id='${pid}' and size='${size}'";
    return await db.rawQuery(sql);
  }

  /*Future<List<Map<String, dynamic>>> updatecart(String pid,String size) async {
    Database db = await instance.database;
    String sql="select * from ${addtocart_table} where product_id='${pid}' and size='${size}'";
    return await db.rawQuery(sql);
  }*/
  Future<int> updatecart(Map<String, dynamic> row) async {
    Database db = await instance.database;
    String sql="update ${addtocart_table} set qty='${row['qty']}',sub_total='${row['sub_total']}' where product_id='${row['product_id']}' and size='${row['size']}'";
    return await db.rawUpdate(sql);
  }

}