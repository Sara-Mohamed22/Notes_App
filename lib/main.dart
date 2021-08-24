
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'modals/note.dart';
import 'util/date-time-manager.dart';

void main()
{

  return runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map> tasks = [];

  var namecontroller = TextEditingController();
  var notecontroller = TextEditingController();

  var keyform = GlobalKey<FormState>();

  var keyscafolf = GlobalKey<ScaffoldState>();

  var keyformdialog = GlobalKey<FormState>();

  String? name;

  Database? database;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CreateDb();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: keyscafolf,
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Center(child: Text('My Notes')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Write Note', style: TextStyle(color: Colors.pink),),
                Form(

                  key: keyform,
                  child: TextFormField(
                      controller: namecontroller,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Write Note ...';
                        }
                        else {
                          return null;
                        }
                      },

                      onTap: () {

                      },
                      cursorColor: Colors.pink,
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink),
                        ),
                      )


                  ),
                ),

                Container(
                  width: double.infinity,
                  child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                          primary: Colors.pink

                      ),
                      onPressed: () {
                        if (keyform.currentState!.validate()) {
                         // print('SoOOOOOOO');

                          setState(() {
                            name = namecontroller.value.text;
                            Note note = Note(
                                name: name, date: DateTimeManager.getTime());

                            InsertToDb(note) ;

                            namecontroller.text ="";


                          });
                        }
                      },
                      child: Text('Add Note')),
                ),


                 listDataView(tasks)


              ],
            ),
          ),
        ),
      ),
    );
  }


  void CreateDb() async
  {
    database = await openDatabase('task.db', version: 1,

        onCreate: (database, version) {
          print('db created');
          database.execute('create table todo'
              ' (id INTEGER PRIMARY KEY, name TEXT, date text)').
          then((value) {
            print('table created ');
          })
          ;
        },
        onOpen: (database) async {
          print('here');

          print('db opened!');
          getDb(database).then((value) {
            setState(() {
              tasks = value;

            });


            print('tasks : ${tasks}');
            print('Suger');
          }).catchError((error) => print('error in get ${error.toString() }'));
        });
  }


  Future InsertToDb(note) async
  {
    return await database!.transaction((txn) async {
      txn.rawInsert(
          'INSERT INTO todo(name, date) VALUES("${note.name}" ,"${note.date}")')
          .
      then((value) {
        print('insert done');
       // print(note);

        ShowNew();


      });
    });
  }

  listDataView( List<Map> models) {

    return Container(
      height:200
     ,
      child: ListView.builder(
        shrinkWrap: true ,
       //  physics: NeverScrollableScrollPhysics() ,
          itemCount: models.length , itemBuilder:
          (context, index) {
       var mod = models[index];
        return ListTile(
          title: Text('${mod['name']}'),
          subtitle: Text('${mod['date']}'),

          leading: Icon(Icons.note, color: Colors.pink,),
          trailing: Container(
            width: 100,
            // color: Colors.teal,
            margin: EdgeInsets.only(left: 20),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
              GestureDetector(
                onTap: (){
                  print('edit');

                  showUpdateDialog( tasks[index]);

                  },
                  child: Icon(Icons.edit , color: Colors.grey ,)),
               SizedBox(width: 8,),
              GestureDetector(
                  onTap: (){
                    print('delete');

                    setState(() {
                      Deletenote(tasks[index]);
                      ShowNew();

                    });
                    },
                  child: Icon(Icons.delete , color: Colors.grey ,))
            ],),
          ),
        );
      }),
    );

  }


  Future<List<Map>> getDb(database) async
  {
    return await database!.rawQuery('select * from todo');

    //print(tasks) ;
  }


  void ShowNew() {

    getDb(database).then((value) {
      setState(() {
        tasks = value;
      });
    });

  }

  void showUpdateDialog( Map task) {
    notecontroller.text = task['name'] ;
      showDialog(
          context: context,
          builder: (context){
         return SimpleDialog(
           children: [
             Form(
               key: keyformdialog ,
               child: Container(
                 width: 200,
                 height: 100,
                 margin: EdgeInsets.symmetric(horizontal: 8 , vertical: 5),
                 child: TextFormField(
                     controller: notecontroller,
                     validator: (value) {
                       if (value!.isEmpty) {
                         return 'Write Note ...';
                       }
                       else {
                         return null;
                       }
                     },

                     onTap: () {


                     },
                     cursorColor: Colors.pink,
                     decoration: InputDecoration(
                       labelText: 'Write Note',
                       labelStyle: TextStyle(color: Colors.pink ),
                       focusedBorder: UnderlineInputBorder(
                         borderSide: BorderSide(color: Colors.pink),
                       ),
                     )


                 ),
               ),
             ),

             Container(
               width: double.infinity,
               margin: EdgeInsets.symmetric(horizontal: 10),
               child: ElevatedButton(

                   style: ElevatedButton.styleFrom(
                       primary: Colors.pink

                   ),
                   onPressed: () {
                   //  print(notecontroller.text);

                     setState(() {
                       Updatenote(task , notecontroller);
                       ShowNew();
                       Navigator.pop(context);



                     });


                   },
                   child: Text('Update Note')),
             ),

           ],


         );
          } );
  }


  Future<int> Updatenote(Map task ,notecontroller )async
  {

      return  await database!.rawUpdate (
        'UPDATE todo SET name = ?  WHERE id =? ',
        [ '${notecontroller.text}' ,'${task['id']}' ] ).then((value)  {

          print(value);
          print('update Successfully !');
          return null! ;
        });

  }


  Future<int> Deletenote(Map task )async
 {
   await  database!.rawDelete('DELETE FROM todo WHERE id= ?', ['${task['id']}'] ).
   then((value) => print('delete Successfully!'));
   return null! ;
 }




}
