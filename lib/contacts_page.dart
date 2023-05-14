import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getlocation/db/db_services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

import 'model/contactsm.dart';

class ContactsPage extends StatefulWidget{
  const ContactsPage({Key?key}):super(key : key);
  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage>
{
  List<Contact> contacts = [];
  List<Contact> contactsfiltered = [];
  DataBaseHelper _dataBaseHelper = DataBaseHelper();
  TextEditingController searchController = TextEditingController();
  @override
  void initState(){
    super.initState();
    askPermissions();
  }
  String flattenPhoneNumber(String phoneStr){
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }
  filterContacts(){
    List<Contact> lcontacts = [];
    lcontacts.addAll(contacts);
    if(searchController.text.isNotEmpty){
      lcontacts.retainWhere((element){
        String searchterm = searchController.text.toLowerCase();
        String searchtermflatten = flattenPhoneNumber(searchterm);
        String contactname=element.displayName!.toLowerCase();
        bool nameMatch = contactname.contains(searchterm);
        if(nameMatch == true){
          return true;
        }
        if(searchtermflatten.isEmpty){
          return false;
        }
        var phone=element.phones!.firstWhere((p) {
          String phnFlattened = flattenPhoneNumber(p.value!);
          return phnFlattened.contains(searchtermflatten);
        });
        return phone.value!=null;
      });
    }
    setState(() {
      contactsfiltered = lcontacts;
    });
  }
  Future<void> askPermissions() async{
    PermissionStatus permissionStatus = await getContactsPermission();
    if(permissionStatus==PermissionStatus.granted){
        getAllContacts();
        searchController.addListener(() {
          filterContacts();
        });
    }else{
      handleInvalidPermission(permissionStatus);
    }
  }
  handleInvalidPermission(PermissionStatus permissionStatus){
    if(permissionStatus == PermissionStatus.denied){
      //Display toast that access to contacts denied by user
    }else if(permissionStatus == PermissionStatus.permanentlyDenied){
      //Display toast message that contact access is permanently denied
    }
  }
  Future<PermissionStatus> getContactsPermission() async
  {
    PermissionStatus permission = await Permission.contacts.status;
    if(permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied){
      PermissionStatus permissionstatus = await Permission.contacts.request();
      return permissionstatus;
    }else{
      return permission;
    }
  }
  getAllContacts()async{
    List<Contact> lcontacts = await ContactsService.getContacts(withThumbnails: false);
    setState((){
      contacts = lcontacts;
        });
  }
  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    bool listItemExist=(contactsfiltered.length>0 || contacts.length>0);
    return Scaffold(
        body:contacts.length==0
            ?Center(child: CircularProgressIndicator())
        : SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  autofocus: true,
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: "Search Contacts",
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              listItemExist==true ?
              Expanded(
                child: ListView.builder(
                    itemCount: isSearching == true? contactsfiltered.length : contacts.length,
                    itemBuilder: (BuildContext context ,int index){
                      Contact contact = isSearching == true ? contactsfiltered[index] : contacts[index];
                      return ListTile(
                          onTap: (){
                            if(contact.phones!.length > 0){
                              final String phoneNum = contact.phones!.elementAt(0).value!;
                              final String name=contact.displayName!;
                              addContact(TContact(phoneNum, name));
                            }else{
                                Fluttertoast.showToast(msg: "Oops! Phone number of this contact does not exist");
                            }
                            Navigator.of(context).pop();
                          },
                          title:Text(contact.displayName!),
                        leading: contact.avatar != null && contact.avatar!.length > 0?
                            CircleAvatar(backgroundImage: MemoryImage(contact.avatar!),
                            ):CircleAvatar(
                          child:Text(contact.initials()),
                        )
                      );
                    }),
              ):Container(
                child: Text("Searching"),
              ),
            ],
          ),
        )
    );
  }
  void addContact(TContact newContact) async{
    int result = await _dataBaseHelper.insertContact(newContact);
    if(result !=0){
      Fluttertoast.showToast(msg: "Contact added successfully");
    }else{
      Fluttertoast.showToast(msg: "Problem occured in adding this contact");
    }
    Navigator.of(context).pop(true);
  }
}

