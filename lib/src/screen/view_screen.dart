import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
class ViewScreen extends StatefulWidget {
  const ViewScreen({Key key}) : super(key: key);

  @override
  _ViewScreenState createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
   Box myBox;

  @override
  void initState() {
    super.initState();
    myBox=Hive.box("mydatabase");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Data"),
      ),
      body:  ListView.builder(
        itemCount:myBox.values.length,
        itemBuilder: (context, index) {
          print("length==${myBox.values.length}");
          var currentBox = myBox;
          var personData = currentBox.getAt(index);

          return InkWell(
            onTap: () {},
            child: ListTile(
              title: Text(personData.name),
              subtitle: Text(personData.mobile),
              trailing: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
