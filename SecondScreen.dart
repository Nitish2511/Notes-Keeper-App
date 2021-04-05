import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guide/Models/Note.dart';
import 'package:flutter_guide/Utils/Database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget{

  final String appBarTitle;
  final Note note;

  NoteDetail(this.note,this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NoteDetailState(this.note,this.appBarTitle);
  }
}

class _NoteDetailState extends State<NoteDetail>{


  String appBarTitle;
  Note note;

  DatabaseHelper helper = DatabaseHelper();

  _NoteDetailState(this.note,this.appBarTitle);

  static var _priorities = ['High','Low'];

  TextEditingController titleController = TextEditingController();
  TextEditingController discriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    TextStyle textStyle = Theme.of(context).textTheme.title;
    // TODO: implement build

    titleController.text = note.title;
    discriptionController.text = note.discription;

    return WillPopScope(

      onWillPop: (){
        moveToLastScreen();
      },

      child: Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: IconButton(icon: Icon(Icons.arrow_back),onPressed: (){
          moveToLastScreen();
        },),
      ),

      body: Padding(
        padding: EdgeInsets.only(top: 15.0,left: 10.0,right: 10.0),
        child: ListView(
          children: [
            ListTile(
              title: DropdownButton(
                items: _priorities.map((String dropDownStringItem){
                  return DropdownMenuItem<String>(
                    value: dropDownStringItem,
                    child: Text(dropDownStringItem),
                  );
                }).toList(),

                style: textStyle,

                value: getPriorityAsString(note.priority),

                onChanged: (valueSelectedByUser){
                  setState(() {
                    debugPrint('User Selected $valueSelectedByUser');
                    updatepriorityAsInt(valueSelectedByUser);
                  });
                }
              )
            ),

            Padding(
              padding: EdgeInsets.only(top: 10.0,bottom: 10.0),
              child: TextField(
                controller: titleController,
                style: textStyle,
                onChanged: (value){
                  debugPrint('Something changed in title textfield');
                  updateTitle();
                },
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  )

                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0,bottom: 10.0),
              child: TextField(
                controller: discriptionController,
                style: textStyle,
                onChanged: (value){
                  debugPrint('Something changed in discription textfield');
                  updateDiscription();
                },
                decoration: InputDecoration(
                    labelText: 'Discription',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )

                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0,bottom: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text('Save',textScaleFactor: 1.5,),
                      onPressed: (){
                        setState(() {
                          debugPrint('Save Button Clicked');
                          _save();
                        });
                      },
                    )
                  ),

                  Container(
                    width: 5.0,
                  ),

                  Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text('Delete',textScaleFactor: 1.5,),
                        onPressed: (){
                          setState(() {
                            debugPrint('Delete Button Clicked');
                            _delete();
                          });
                        },
                      )
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }

  void moveToLastScreen(){
    Navigator.pop(context,true);
  }

  void updatepriorityAsInt(String value){
    switch(value){
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }
  String getPriorityAsString(int value){
    String priority;
    switch(value){
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  void updateTitle(){
    note.title = titleController.text;
  }
  void updateDiscription(){
    note.discription = discriptionController.text;
  }

  void _save() async {

    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if(note.id != null){
      result = await helper.updateNote(note);
    }else{
      result = await helper.insertNote(note);
    }

    if(result != 0){
      _showAlertDialog('Status','Note Saved Successfully');
    }else{
      _showAlertDialog('Status','Problem Saving Note');
    }
  }

  void _delete() async {

    moveToLastScreen();
    if(note.id == null){
      _showAlertDialog('Status','No Note Was Deleted');
      return;
    }

    int result = await helper.deleteNote(note.id);
    if(result != 0){
      _showAlertDialog('Status', 'Note Deleted Successfully');
    }else{
      _showAlertDialog('Status', 'Error occured in deleting note');
    }
  }

  void _showAlertDialog(String title,String message){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context: context,
      builder: (_) => alertDialog
    );
  }
}