import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:telephony/telephony.dart';
import 'package:getlocation/NavBar.dart';
import 'package:permission_handler/permission_handler.dart';

import 'db/db_services.dart';
import 'model/contactsm.dart';

void main() => runApp(MyApp());

// Custom Methods Start

String createLocationLink(double lat, double lon) {
  String link = "https://www.google.com/maps/search/?api=1&query=$lat%2C$lon";
  return link;
}

void SMS(String message) async {
  final Telephony telephony = Telephony.instance;
  List<TContact> savedcontacts = await DataBaseHelper().getContactList();
  List numbers = [];
  if (savedcontacts.length == 0) {
    Fluttertoast.showToast(msg: "No contacts");
  } else {
    Fluttertoast.showToast(msg: "Sending SOS...");
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted == true) {
      for (var nums in savedcontacts) {
        numbers.add(nums.number.substring(nums.number.length - 10));
      }
      print(numbers);
      for (var rec in numbers) {
        await telephony.sendSms(to: rec, message: message);
      }
    }
  }
}

// Custom Methods End

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ask For Help',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Homepage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TipsPage extends StatelessWidget {
  final List<String> texts = [
    'Do not over share on social media',
    'Trust your instincts – if you think something is wrong then act on it',
    'Have your keys available when you reach your home or car..',
    'Try to stay in well-lit areas',
    'Leave venues with friends wherever possible.',
    'Display confidence',
  ];
  String getRandomText() {
    Random random = Random();
    int RandomNumber = random.nextInt(texts.length);
    return texts[RandomNumber];
  }

  TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _showDialogBox(context),
      builder: (context, snapshot) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          leading: Icon(Icons.tips_and_updates),
          centerTitle: true,
          title: const Text("Tips"),
        ),
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
            Image.asset(
              "assets/bgimage.jpg",
              fit: BoxFit.cover,
            ),
            Container(
              height: 60,
              width: 320,
              color: Colors.blue,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              child: const Text(
                "1. Do not over share on social media",
                style: TextStyle(
                    fontSize: 17,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              height: 100,
              width: 320,
              color: Colors.blue,
              padding: const EdgeInsets.all(20),
              child: const Text(
                "2. Trust your instincts – if you think something is wrong then act on it.",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Container(
              height: 90,
              width: 320,
              color: Colors.blue,
              padding: const EdgeInsets.all(20),
              child: const Text(
                "3. Have your keys available when you reach your home or car..",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 25),
            Container(
              height: 70,
              width: 320,
              color: Colors.blue,
              padding: const EdgeInsets.all(20),
              child: const Text(
                "4. Try to stay in well-lit areas",
                style: TextStyle(
                    fontSize: 19,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 25),
            Container(
              height: 90,
              width: 320,
              color: Colors.blue,
              padding: const EdgeInsets.all(20),
              child: const Text(
                "5. Leave venues with friends wherever possible.",
                style: TextStyle(
                    fontSize: 19,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 25),
            Container(
                height: 65,
                width: 320,
                color: Colors.blue,
                padding: const EdgeInsets.all(20),
                child: const Text(
                  "6. Display confidence",
                  style: TextStyle(
                      fontSize: 19,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold),
                )),
            const SizedBox(height: 25),
            Container(
                height: 85,
                width: 320,
                color: Colors.blue,
                padding: const EdgeInsets.all(20),
                child: const Text(
                  "7.  Maintain regular contact with friends or family members",
                  style: TextStyle(
                      fontSize: 19,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold),
                )),
            const SizedBox(height: 25),
            Container(
                height: 85,
                width: 320,
                color: Colors.blue,
                padding: const EdgeInsets.all(20),
                child: const Text(
                  "8.  Stay vigilant and alert to what's happening around you.",
                  style: TextStyle(
                      fontSize: 19,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold),
                )),
          ]),
        ),
      ),
    );
  }

  Future<void> _showDialogBox(BuildContext context) async {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.tips_and_updates_rounded),
                    SizedBox(width: 10),
                    Text("Quick tip:"),
                  ],
                ),
                content: Text(getRandomText()),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got It!'))
                ],
              ));
    });
  }
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String location = 'Link will appear here';
  String Address = 'Address will appear here';
  bool isLoading = true;

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    // Placemark place = placemarks[0];
    // Address =
    //     '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: NavBar(),
      appBar: AppBar(
        title: const Text('Security App'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(100),
                    backgroundColor: Colors.red,
                    side: const BorderSide(color: Colors.yellow, width: 6)),
                onPressed: () async {
                  Position position = await _getGeoLocationPosition();
                  location =
                      createLocationLink(position.latitude, position.longitude);
                  GetAddressFromLatLong(position);
                  String msg =
                      "Test Message. Ignore It $location"; //TODO: Change the message
                  SMS(msg);
                },
                child: const Text(
                  'Send SOS',
                  style: TextStyle(fontSize: 30),
                ))
          ],
        ),
      ),
    );
  }
}
