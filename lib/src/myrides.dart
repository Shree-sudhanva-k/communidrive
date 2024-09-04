import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Myrides extends StatefulWidget {
  final String phoneNumber;
  const Myrides({super.key, required this.phoneNumber});

  @override
  State<Myrides> createState() => _ScheduledRidesScreenState();
}

class _ScheduledRidesScreenState extends State<Myrides> {
  String pno = '';
  List<Map<String, dynamic>> _scheduledRides = [];
  List<Map<String, dynamic>> _joinedRides = [];

  @override
  void initState() {
    pno = widget.phoneNumber;
    super.initState();
    _fetchRides();
    _fetchJoinedRides();
  }

  Future<void> _fetchRides() async {
    CollectionReference ridesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(pno)
        .collection('rides');

    QuerySnapshot querySnapshot = await ridesRef.get();

    List<Map<String, dynamic>> ridesWithPassengers = [];

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> rideData = doc.data() as Map<String, dynamic>;
      List<dynamic> passengers = rideData['accepted'] ?? [];

      // Fetch passenger details
      List<Map<String, dynamic>> passengerDetails =
          await _fetchPassengerDetails(passengers);

      rideData['passengerDetails'] = passengerDetails;
      ridesWithPassengers.add(rideData);
    }

    setState(() {
      _scheduledRides = ridesWithPassengers;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchPassengerDetails(
      List<dynamic> phoneNumbers) async {
    List<Map<String, dynamic>> passengers = [];

    for (var phone in phoneNumbers) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(phone).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        passengers.add({
          'name': userData['name'],
          'phone': phone,
        });
      }
    }

    return passengers;
  }

  Future<void> _fetchJoinedRides() async {
    try {
      CollectionReference joinedRidesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(pno)
          .collection('joinedRides');

      QuerySnapshot querySnapshot = await joinedRidesRef.get();

      List<Map<String, dynamic>> joinedRidesList = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> joinedRideData =
            doc.data() as Map<String, dynamic>;

        // Fetch the ride details from the original ride document
        DocumentSnapshot rideDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(joinedRideData['phonenumber'])
            .collection('rides')
            .doc(joinedRideData['rideid'])
            .get();

        if (rideDoc.exists) {
          Map<String, dynamic> rideData =
              rideDoc.data() as Map<String, dynamic>;
          joinedRidesList.add(rideData);
        }
      }

      setState(() {
        _joinedRides = joinedRidesList;
      });
    } catch (e) {
      print('Error fetching joined rides: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Scheduled Rides'),
      ),
      body: _scheduledRides.isEmpty && _joinedRides.isEmpty
          ? const Center(child: Text('No rides found.'))
          : Column(
              children: [
                const Text('Rides Scheduled by Me'),
                Expanded(
                  child: ListView.builder(
                    itemCount: _scheduledRides.length,
                    itemBuilder: (context, index) {
                      final ride = _scheduledRides[index];
                      return Card(
                        elevation: 4.0,
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        child: ListTile(
                          title: Text(
                              '${ride['source']} to ${ride['destination']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Date: ${ride['date']}'),
                              Text('Time: ${ride['time']}'),
                              Text('Passenger Count: ${ride['count']}'),
                              const SizedBox(height: 10),
                              Text('Accepted Passengers:'),
                              for (var passenger in ride['passengerDetails'])
                                Text(
                                    '${passenger['name']} (${passenger['phone']})'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Text('Joined Rides'),
                Expanded(
                  child: ListView.builder(
                    itemCount: _joinedRides.length,
                    itemBuilder: (context, index) {
                      final ride = _joinedRides[index];
                      return Card(
                        elevation: 4.0,
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        child: ListTile(
                          title: Text(
                              '${ride['source']} to ${ride['destination']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Date: ${ride['date']}'),
                              Text('Time: ${ride['time']}'),
                              Text('Passenger Count: ${ride['count']}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
