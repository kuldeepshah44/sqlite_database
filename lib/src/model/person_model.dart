import 'package:hive/hive.dart';
@HiveType(typeId: 1)
class Person {


  @HiveField(0)
  String name;

  @HiveField(1)
  String mobile;

  @HiveField(2)
  String address;

  Person({this.name, this.mobile, this.address});

}