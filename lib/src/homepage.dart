import 'package:communidrive/src/loginsignup.dart';

import 'package:communidrive/src/myrides.dart';
import 'package:communidrive/src/requests.dart';

import 'package:communidrive/src/schedulepg.dart';
import 'package:communidrive/src/sschedule.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final String phoneNumber;

  const HomePage({super.key, required this.phoneNumber});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController srcController = TextEditingController();
  TextEditingController destController = TextEditingController();
  String _phoneNo = '';
  String name = '';
  String profilePhotoURL = '';
  String source = '';
  String dest = '';

  static const LatLng _bmsClg = LatLng(12.9410, 77.5655);
  static const LatLng _pGooglePlex = LatLng(12.972442, 77.580643);
  @override
  void initState() {
    super.initState();
    _phoneNo = widget.phoneNumber;

    _getProfile(_phoneNo);
  }

  void _getProfile(String phoneNumber) async {
    try {
      DocumentSnapshot userdoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_phoneNo)
          .get();
      if (userdoc.exists) {
        Map<String, dynamic> userData = userdoc.data() as Map<String, dynamic>;
        setState(() {
          name = userData['name'];
          profilePhotoURL = userData['photo'];
        });
      } else {
        print('No such document!');
      }
    } catch (error) {
      print('Error retrieving user info: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('hello!'),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                icon: const Icon(
                  Icons.notification_important,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RRequests(
                        phonenumber: _phoneNo,
                      ),
                    ),
                  );
                },
              ))
        ],
      ),
      drawer: Drawer(
        width: 290,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.network(
                        profilePhotoURL,
                        fit: BoxFit.cover,
                        width: 72,
                        height: 72,
                      ),
                    ),
                  ),
                  const SizedBox(width: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _phoneNo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Friends'),
              leading: const Icon(Icons.people),
              onTap: () {},
            ),
            ListTile(
              title: const Text('community'),
              leading: const Icon(Icons.home),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Rides'),
              leading: const Icon(Icons.motorcycle),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Myrides(phoneNumber: _phoneNo),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('help and support'),
              leading: const Icon(Icons.help),
              onTap: () {},
            ),
            ListTile(
              title: const Text('settings'),
              leading: const Icon(Icons.settings),
              onTap: () {},
            ),
            Padding(
              padding: const EdgeInsets.only(top: 110),
              child: ListTile(
                title: const Text('logout'),
                leading: const Icon(Icons.logout_outlined),
                onTap: () async {
                  final SharedPreferences sharedPreference =
                      await SharedPreferences.getInstance();
                  sharedPreference.remove('PhoneNumber');

                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const PhoneNo()));
                  ;
                },
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _pGooglePlex,
              zoom: 13,
            ),
            markers: {
              const Marker(
                  markerId: MarkerId("_current location"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _bmsClg)
            },
          ),
          Positioned(
            bottom: 0,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              child: Container(
                color: const Color.fromARGB(255, 255, 255, 255),
                height: 250,
                padding: const EdgeInsets.all(7.5),
                child: Column(
                  children: [
                    const Center(
                      child: Text('Search a ride'),
                    ),
                    TextFormField(
                      controller: srcController,
                      decoration: const InputDecoration(labelText: 'From:'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your source';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: destController,
                      decoration: const InputDecoration(labelText: 'To:'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScheduledRidesScreen(
                              source: srcController.text.toUpperCase(),
                              destination: destController.text.toUpperCase(),
                              myphonenumber: _phoneNo,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                            255, 255, 87, 52), // Background color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Border radius
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12), // Button padding
                      ),
                      child: const Text(
                        'search',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 260,
            left: 20,
            child: ClipOval(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SchedulePage(phoneNumber: _phoneNo),
                    ),
                  );
                },
                child: Container(
                    height: 50,
                    width: 50,
                    color: const Color.fromARGB(255, 255, 87, 52),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }
}
