import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RRequests extends StatefulWidget {
  final String phonenumber;
  RRequests({super.key, required this.phonenumber});

  @override
  State<RRequests> createState() => _RequestsState();
}

class _RequestsState extends State<RRequests> {
  String _phoneno = '';
  @override
  void initState() {
    super.initState();
    _phoneno = widget.phonenumber;
    print('Phone Number: $_phoneno');
  }

  Future<List<Map<String, dynamic>>> getAllData() async {
    List<Map<String, dynamic>> allData = [];

    try {
      // Get ride requests for the user
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_phoneno)
          .collection('request') // Ensure correct subcollection name
          .get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> rideData = doc.data() as Map<String, dynamic>;
        String? requestKey = doc.id;
        String? phoneNumber = rideData['rphonenumber'];
        String? rideId = rideData['rideid']; // Ensure correct field name

        if (phoneNumber != null && rideId != null) {
          // Fetch user data based on phone number
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(phoneNumber)
              .get();

          if (userSnapshot.exists) {
            Map<String, dynamic>? userData =
                userSnapshot.data() as Map<String, dynamic>?;

            // Fetch ride details from 'rides' subcollection
            DocumentSnapshot rideSnapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(_phoneno)
                .collection('rides')
                .doc(rideId)
                .get();

            if (rideSnapshot.exists) {
              Map<String, dynamic>? rideDetails =
                  rideSnapshot.data() as Map<String, dynamic>?;

              if (rideDetails != null) {
                allData.add({
                  'rideID': rideId,
                  'requestkey': requestKey,
                  'name': userData?['name'] ?? 'Unknown',
                  'profileURL': userData?['photo'] ?? '',
                  'date': rideDetails['date'] ?? 'N/A',
                  'time': rideDetails['time'] ?? 'N/A',
                  'phone': phoneNumber,
                  'count': rideDetails['count'] ?? 0,
                  'accepted': false,
                  'rejected': false,
                });
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }

    return allData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('requests'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getAllData(),
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
                      subtitle: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Date: ${data['date']}'),
                                // Text(' ${data['requestkey']}'),
                                Text('Time: ${data['time']}'),
                                Text('Phone: ${data['phone']}'),
                                Text('Passenger Count: ${data['count']}'),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      // Step 1: Update the 'accepted' array in the 'rides' collection
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(_phoneno)
                                          .collection('rides')
                                          .doc(data[
                                              'rideID']) // Assuming 'rideID' holds the document ID
                                          .update({
                                        'accepted': FieldValue.arrayUnion(
                                            [data['phone']]),
                                      });

                                      // Step 2: Delete the corresponding request document
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(_phoneno)
                                          .collection('request')
                                          .doc(data[
                                              'requestkey']) // Assuming 'requestkey' holds the document ID
                                          .delete();

                                      // Step 3: Add to the 'joinedRides' collection in the passenger's document
                                      await FirebaseFirestore.instance
                                          .collection(
                                              'users') // Corrected 'user' to 'users' if it's the right collection name
                                          .doc(data['phone'])
                                          .collection('joinedRides')
                                          .add({
                                        'phonenumber': _phoneno,
                                        'rideid': data['rideID'],
                                      });

                                      // Step 4: Update the UI by removing the processed item from 'allData'
                                      setState(() {
                                        allData.removeAt(
                                            index); // Assuming 'allData' is the list containing this item
                                      });

                                      print(
                                          'Passenger successfully accepted and data updated.');
                                    } catch (error) {
                                      print('Error processing request: $error');
                                    }
                                  },
                                  child: Text('Accept'),
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      // Delete the document from Firebase
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(_phoneno)
                                          .collection('request')
                                          .doc(data[
                                              'requestkey']) // Assuming 'requestKey' holds the document ID
                                          .delete()
                                          .then((_) {
                                        print('Document successfully deleted!');
                                      }).catchError((error) {
                                        print(
                                            'Error deleting document: $error');
                                      });

                                      // Remove the card from the screen
                                      setState(() {
                                        allData.removeAt(
                                            index); // Assuming 'allData' is the list containing this item
                                      });
                                    },
                                    child: Text('reject')),
                              ],
                            ),
                          ],
                        ),
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
