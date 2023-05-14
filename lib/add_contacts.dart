import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getlocation/contacts_page.dart';
import 'package:getlocation/db/db_services.dart';
import 'package:sqflite/sqflite.dart';

import 'model/contactsm.dart';

class AddContactsPage extends StatefulWidget {
  const AddContactsPage({super.key});
  @override
  State<AddContactsPage> createState()=> _AddContactsPageState();
}
class _AddContactsPageState extends State<AddContactsPage>{
  DataBaseHelper databasehelper = DataBaseHelper();
  List<TContact> contactList = [];
  int count = 0;
  void showList(){
    Future<Database>dbFuture=databasehelper.initializeDatabase();
    dbFuture.then((database){
      Future<List<TContact>>contactlistfuture = databasehelper.getContactList();
      contactlistfuture.then((value){
        setState(() {
          this.contactList = value;
          this.count = value.length;
        });
      });
    });
  }
  void deleteContact(TContact contact)async{
    int result = await databasehelper.deleteContact(contact.id);
    if(result != 0){
      Fluttertoast.showToast(msg: "Contact removed successfully!");
      showList();
    }
  }
  @override
  void initState()
  {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { showList();});
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
            padding:EdgeInsets.all(12),
            child:Column (
              children: [
                TextButton(onPressed: () async {
                 bool result = await Navigator.push(context,MaterialPageRoute(builder: (context)=>ContactsPage()));
                 if(result==true){
                   showList();
                 }
                },
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.orange),
                    ),
                    child: Text("Add Trusted Contacts")),
                  SingleChildScrollView(
                    child: ListView.builder(
                    shrinkWrap: true,
                      itemCount: count,
                      itemBuilder:(BuildContext context, int index){
                        return Card(
                          child:
                            ListTile(
                              title: Text(contactList![index].name),
                              trailing:IconButton(
                                onPressed: (){
                                  deleteContact(contactList[index]);
                                },
                                icon:Icon(Icons.delete,color: Colors.red,)
                              ),
                            ),

                        );
                      }),
                )
              ],
            )
        ),
      ),
    );
  }
}
