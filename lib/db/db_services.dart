import 'package:getlocation/model/contactsm.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseHelper
{
  String contactTable = 'contact_table';
  String colId = 'id';
  String colContactName = 'name';
  String colContactNumber = 'number';

  DataBaseHelper._createInstance();
  static DataBaseHelper ? _dataBaseHelper;
  factory DataBaseHelper(){
    if(_dataBaseHelper == null){
      _dataBaseHelper = DataBaseHelper._createInstance();
    }
    return _dataBaseHelper!;
  }
  static Database? _database;
  Future<Database> get database async{
    if(_database == null){
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase()async{
    String dirPath = await getDatabasesPath();
    String dbLocation = dirPath + 'contact.db';
    var contactDatabase = await openDatabase(dbLocation,version: 1,onCreate: _createDbTable);
    return contactDatabase;
  }
  void _createDbTable(Database db,int newVersion)async{
    await db.execute(
      'CREATE TABLE $contactTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colContactName TEXT, $colContactNumber TEXT)'
    );
  }

  Future<List<Map<String, dynamic>>> getContactMapList() async{
    Database db = await this.database;
    List<Map<String,dynamic>> result =
        await db.rawQuery('SELECT * FROM $contactTable order by $colId ASC');
    return result;
  }
  Future<int> updateContact(TContact contact) async{
    Database db = await this.database;
    var result = await db.update(contactTable,contact.toMap(),where: '$colId = ?',whereArgs:[contact.id] );
    return result;
  }
  Future<int> insertContact(TContact contact) async{
    Database db = await this.database;
    var result = await db.insert(contactTable,contact.toMap());
    return result;
  }
  Future<int> deleteContact(int id) async {
    Database db = await this.database;
    int result =
    await db.rawDelete('DELETE FROM $contactTable WHERE $colId = $id');
    // print(await db.query(contactTable));
    return result;
  }

  //get number of contact objects
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $contactTable');
    int result = Sqflite.firstIntValue(x)!;
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Contact List' [ List<Contact> ]
  Future<List<TContact>> getContactList() async {
    var contactMapList =
    await getContactMapList(); // Get 'Map List' from database
    int count =
        contactMapList.length; // Count the number of map entries in db table

    List<TContact> contactList = <TContact>[];
    // For loop to create a 'Contact List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      contactList.add(TContact.fromMapObject(contactMapList[i]));
    }

    return contactList;
  }
}