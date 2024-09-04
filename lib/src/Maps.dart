import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyMaps extends StatefulWidget {
  const MyMaps({super.key});

  @override
  State<MyMaps> createState() => _MyMapsState();
}

const LatLng _bmsClg = LatLng(12.9410, 77.5655);
const LatLng _pGooglePlex = LatLng(12.972442, 77.580643);

class _MyMapsState extends State<MyMaps> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("hello"),
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
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: Container(
                color: const Color.fromRGBO(246, 109, 36, 0.6),
                height: 200,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'This is a container above the map',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
