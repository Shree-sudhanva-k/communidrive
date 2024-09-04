import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduledRidesScreen extends StatefulWidget {
  final String source;
  final String destination;
  final String myphonenumber;

  const ScheduledRidesScreen({
    super.key,
    required this.source,
    required this.destination,
    required this.myphonenumber,
  });

  @override
  State<ScheduledRidesScreen> createState() => _ScheduledRidesScreenState();
}

class _ScheduledRidesScreenState extends State<ScheduledRidesScreen> {
  Future<List<Map<String, dynamic>>> getAllData(
      String source, String destination, String _mynumber) async {
    List<Map<String, dynamic>> allData = [];

    try {
      // Get ride schedules
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Schedules')
          .where('source', isEqualTo: source)
          .where('destination', isEqualTo: destination)
          // .where('phonenumber', isNotEqualTo: _mynumber)
          .get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> rideData = doc.data() as Map<String, dynamic>;
        String phoneNumber = rideData['phonenumber'];
        String rideId = rideData['rideId'];

        // Fetch user data based on phone number
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(phoneNumber)
            .get();

        if (userSnapshot.exists) {
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;

          // Fetch ride details from 'rides' subcollection
          DocumentSnapshot rideSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(phoneNumber)
              .collection('rides')
              .doc(rideId)
              .get();

          if (rideSnapshot.exists) {
            Map<String, dynamic> ridedetails =
                rideSnapshot.data() as Map<String, dynamic>;
            allData.add({
              'rideID': rideId,
              'name': userData['name'],
              'profileURL': userData['photo'],
              'date': ridedetails['date'],
              'time': ridedetails['time'],
              'phone': phoneNumber,
              'count': ridedetails['count'],
              'requested': false, // Initialize requested state
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }

    return allData;
  }

  Future<void> request(String phoneno, String rID) async {
    try {
      CollectionReference requests = FirebaseFirestore.instance
          .collection('users')
          .doc(phoneno)
          .collection('request');

      await requests.add({
        'rphonenumber': widget.myphonenumber,
        'rideid': rID,
      });

      print("Ride Added with ID: $rID");
    } catch (error) {
      print("Failed to add ride: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Rides'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getAllData(
              widget.source, widget.destination, widget.myphonenumber),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No scheduled rides found.'));
            } else {
              List<Map<String, dynamic>> allData = snapshot.data!;
              return ListView.builder(
                itemCount: allData.length,
                itemBuilder: (context, index) {
                  var data = allData[index];

                  return Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: data['profileURL'] != null &&
                                data['profileURL'].isNotEmpty
                            ? NetworkImage(data['profileURL']) as ImageProvider
                            : const AssetImage('assets/images/null.png'),
                        radius: 30.0,
                        onBackgroundImageError: (_, __) {
                          // In case of an error, you can set a fallback image here
                        },
                      ),
                      title: Text(data['name'] ?? 'No Name'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Date: ${data['date']}'),
                          Text('Time: ${data['time']}'),
                          Text('Passenger Count: ${data['count']}'),
                        ],
                      ),
                      trailing: OneTimePressButton(
                        initialText: 'Request',
                        pressedText: 'Requested',
                        onPressed: () {
                          request(data['phone'], data['rideID']);
                        },
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class OneTimePressButton extends StatefulWidget {
  final String initialText;
  final String pressedText;
  final VoidCallback onPressed;

  const OneTimePressButton({
    super.key,
    required this.initialText,
    required this.pressedText,
    required this.onPressed,
  });

  @override
  _OneTimePressButtonState createState() => _OneTimePressButtonState();
}

class _OneTimePressButtonState extends State<OneTimePressButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isPressed
          ? null
          : () {
              setState(() {
                _isPressed = true;
              });
              widget.onPressed();
            },
      child: Text(_isPressed ? widget.pressedText : widget.initialText),
    );
  }
}
