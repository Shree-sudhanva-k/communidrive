import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  final phoneNumber;
  const SchedulePage({super.key, required this.phoneNumber});

  @override
  SchedulePageState createState() => SchedulePageState();
}

class SchedulePageState extends State<SchedulePage> {
  final _formKey = GlobalKey<FormState>();
  String _phoneno = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String peoplecount = '';
  String _gender = '';
  String src = '';
  String dest = '';
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneno = widget.phoneNumber;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: selectedDate,
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = "${selectedDate.toLocal()}"
            .split(' ')[0]; // Format the date as needed
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay selectedTime = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        _timeController.text = selectedTime.format(context);
      });
    }
  }

  // DateTime _convertTimeOfDayToDateTime(DateTime date, TimeOfDay time) {
  //   return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  // }

  Future<void> addRide(String source, String destination, String gender,
      String count, String date, String time) async {
    // ignore: unused_local_variable
    String id;
    CollectionReference rides = FirebaseFirestore.instance
        .collection('users')
        .doc(_phoneno)
        .collection('rides');

    return rides.add(
      {
        'source': source,
        'destination': destination,
        'gender': gender,
        'count': count,
        'date': date,
        'time': time,
        'accepted': []
      },
    ).then(
      (value) {
        id = value.id;
        print("Ride Added with ID: ${value.id}");
        addSchedule(source, dest, id);
      },
    ).catchError(
      (error) {
        print("Failed to add ride: $error");
      },
    );
  }

  Future<void> addSchedule(String source, String destination, String id) {
    CollectionReference schedule =
        FirebaseFirestore.instance.collection('Schedules');
    return schedule
        .doc(id)
        .set({
          'source': source,
          'destination': destination,
          'phonenumber': _phoneno,
          'rideId': id,
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule a Ride'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Source'),
                onSaved: (value) {
                  src = value!.toUpperCase();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a source';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Destination'),
                onSaved: (value) {
                  dest = value!.toUpperCase();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a destination';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Number of People'),
                onSaved: (value) {
                  peoplecount = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of people';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Gender'),
                value: 'Any',
                items: ['Any', 'Male', 'Female']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today),
                  labelText: "Select Date",
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _timeController,
                readOnly: true,
                onTap: () => _selectTime(context),
                decoration: const InputDecoration(
                  icon: Icon(Icons.access_time),
                  labelText: "Select time",
                ),
              ),
              const SizedBox(
                height: 80,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    addRide(src, dest, _gender, peoplecount,
                        _dateController.text, _timeController.text);
                  }

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 255, 87, 52), // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Border radius
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12), // Button padding
                ),
                child: const Text('Schedule Ride',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
