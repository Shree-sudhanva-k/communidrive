import 'dart:io';
import 'package:communidrive/src/homepage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_places_flutter/google_places_flutter.dart';
// import 'package:google_places_flutter/model/prediction.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class UserInputForm extends StatefulWidget {
  final String phoneNumber;
  const UserInputForm({super.key, required this.phoneNumber});

  @override
  State<UserInputForm> createState() => _UserInputFormState();
}

class _UserInputFormState extends State<UserInputForm> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  String _name = '';
  String _gender = 'Male';
  String _email = '';
  String _location = '';
  String _phoneno = '';
  String _profileURL = '';
  final TextEditingController searchController = TextEditingController();
  List<dynamic> locationlist = [];
  _UserInputFormState();

  @override
  void initState() {
    super.initState();
    _phoneno = widget.phoneNumber;
  }

  Future<void> addUser(String phoneNumber, String name, String gender,
      String email, String location, String profileURL) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return users
        .doc(phoneNumber)
        .set({
          'name': name,
          'gender': gender,
          'email': email,
          'location': location,
          'photo': profileURL,
        })
        .then((value) => print("User Added"))
        .catchError(
          (error) => print("Failed to add user: $error"),
        );
  }

  Future<void> uploadImgToFB() async {
    if (_image == null) return;
    Reference refDirImg =
        FirebaseStorage.instance.ref().child('images').child(_phoneno);
    try {
      await refDirImg.putFile(_image!);
      _profileURL = await refDirImg.getDownloadURL();
    } catch (error) {
      print("Error uploading image: $error");
    }
  }

  void showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Card(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 5.2,
            margin: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: 50,
                        ),
                        SizedBox(height: 12.0),
                        Text(
                          "Gallery",
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                    onTap: () {
                      _imageFromGallery();
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: InkWell(
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera,
                          size: 50,
                        ),
                        SizedBox(height: 12.0),
                        Text(
                          "Camera",
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                    onTap: () {
                      _imageFromCamera();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _cropImage(String imagePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: const Color.fromARGB(255, 255, 87, 52),
          toolbarWidgetColor: Colors.white,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        )
      ],
    );

    if (croppedFile != null) {
      imageCache.clear();
      setState(
        () {
          _image = File(croppedFile.path);
        },
      );
      uploadImgToFB();
    }
  }

  Future<void> _imageFromGallery() async {
    var storageStatus = await Permission.storage.status;
    print(storageStatus);
    if (!storageStatus.isGranted) {
      await Permission.storage.request(); // Re-check after request
    }

    if (!storageStatus.isGranted) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _cropImage(pickedFile.path);
      } else {
        print('No image selected.');
      }
    } else {
      print('Storage permission not granted.');
    }
  }

  Future<void> _imageFromCamera() async {
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
      if (cameraStatus.isGranted) {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.camera);
        if (pickedFile != null) {
          _cropImage(pickedFile.path);
        } else {
          print('No image selected.');
        }
      }
    } else {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        _cropImage(pickedFile.path);
      } else {
        print('No image selected.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Input Form'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showImagePicker(context);
                          },
                          child: _image == null
                              ? const CircleAvatar(
                                  radius: 65,
                                  backgroundImage: NetworkImage(
                                      'https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small/default-avatar-icon-of-social-media-user-vector.jpg'),
                                )
                              : CircleAvatar(
                                  radius: 65,
                                  backgroundImage: FileImage(_image!),
                                ),
                        ),
                        const Positioned(
                          bottom: 10,
                          right: 10,
                          child: Icon(Icons.add_a_photo),
                        ),
                      ],
                    ),
                  ),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  onSaved: (value) {
                    _name = value!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) {
                    _email = value!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Gender'),
                  value: _gender,
                  items: ['Male', 'Female', 'Other']
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
                TextFormField(
                  controller: searchController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  onSaved: (value) {
                    _location = value!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your location';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                Visibility(
                  visible: searchController.text.isEmpty,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.location_pin),
                    onPressed: () {},
                    label: const Text(
                      'Detect Current location',
                    ),
                  ),
                ),

                // placesAutoCompleteTextField(),
                Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Text(
                                'Name: $_name\nEmail: $_email\nGender: $_gender\nLocation: $_location'),
                          ),
                        );
                        addUser(_phoneno, _name, _gender, _email, _location,
                            _profileURL);
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  HomePage(phoneNumber: _phoneno)));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 87, 52),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

//   placesAutoCompleteTextField() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 20),
//       child: GooglePlaceAutoCompleteTextField(
//         textEditingController: searchController,
//         googleAPIKey: "AIzaSyD0luseLIsVhKYU1OfTS0UFlitl0-RRmEI",
//         inputDecoration: InputDecoration(
//           hintText: "Search your location",
//           border: InputBorder.none,
//           enabledBorder: InputBorder.none,
//         ),
//         debounceTime: 400,
//         countries: ["in", "fr"],
//         isLatLngRequired: true,
//         getPlaceDetailWithLatLng: (Prediction prediction) {
//           print("placeDetails" + prediction.lat.toString());
//         },

//         itemClick: (Prediction prediction) {
//           searchController.text = prediction.description ?? "";
//           searchController.selection = TextSelection.fromPosition(
//               TextPosition(offset: prediction.description?.length ?? 0));
//         },
//         seperatedBuilder: const Divider(),
//         containerHorizontalPadding: 10,

//         // OPTIONAL// If you want to customize list view item builder
//         itemBuilder: (context, index, Prediction prediction) {
//           return Container(
//             padding: const EdgeInsets.all(10),
//             child: Row(
//               children: [
//                 const Icon(Icons.location_on),
//                 const SizedBox(
//                   width: 7,
//                 ),
//                 Expanded(child: Text("${prediction.description ?? ""}"))
//               ],
//             ),
//           );
//         },

//         isCrossBtnShown: true,

//         // default 600 ms ,
//       ),
//     );
//   }
}
