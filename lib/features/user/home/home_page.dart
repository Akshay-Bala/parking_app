// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:travel_guide_app/user/signup_files/login_page.dart';
//
// class HomePage extends StatefulWidget {
//   core HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   TextEditingController searchLocationController = TextEditingController();
//   String latitude = "";
//   String longitude = "";
//   String placeName = "";
//   String street = "";
//   String locality = "";
//   String postalCode = "";
//   String country = "";
//
//   signOut() async {
//     await FirebaseAuth.instance.signOut();
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (context) => core LoginPage()),
//       (route) => false,
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     getCurrentLocation();
//   }
//
//   Future<Position> _determinePosition() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       await Geolocator.openLocationSettings();
//       throw Exception("Location services disabled");
//     }
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//     if (permission == LocationPermission.deniedForever) {
//       throw Exception("Location permission permanently denied");
//     }
//     return await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//   }
//
//   /// Get Address from LatLng
//   Future<void> getCurrentLocation() async {
//     Position position = await _determinePosition();
//     latitude = position.latitude.toString();
//     longitude = position.longitude.toString();
//     List<Placemark> placemarks = await placemarkFromCoordinates(
//       position.latitude,
//       position.longitude,
//     );
//     Placemark place = placemarks[0];
//     setState(() {
//       // String fullAddress = place.name ?? "";
//       // List<String> parts = fullAddress.split(",");
//       // if (parts.length > 1) {
//       //   parts.removeAt(0);
//       // }
//       String fullAddress = place.name ?? "";
//       List<String> parts = fullAddress.split(",");
//       // placeName = parts[1].trim();
//
//       print(parts.toString());
//       print(parts[0]);
//       print(parts[1]);
//       print(parts[2]);
//
//       placeName = parts[1]; //place.name.toString(); // parts.join(",").trim();
//       latitude = position.latitude.toString();
//       longitude = position.longitude.toString();
//     });
//   }
//
//   Future<void> searchLocation() async {
//     String searchText = searchLocationController.text.trim();
//
//     if (searchText.isEmpty) {
//       await getCurrentLocation();
//       return;
//     }
//
//     try {
//       List<Location> locations = await locationFromAddress(searchText);
//       for (var loc in locations) {
//         setState(() {
//           latitude = loc.latitude.toString();
//           longitude = loc.longitude.toString();
//           placeName = searchText;
//         });
//         break;
//       }
//     } catch (e) {
//       print("Search error: $e");
//     }
//   }
//
//   String normalize(String text) {
//     return text.toLowerCase().replaceAll(" ", "");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         actions: [
//           ElevatedButton(
//             onPressed: () {
//               signOut();
//             },
//             child: Text("Logout"),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: core EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     controller: searchLocationController,
//                     onChanged: (value) {
//                       if (value.isEmpty) {
//                         getCurrentLocation(); // reload current location
//                       }
//                       setState(() {});
//                     },
//                     decoration: core InputDecoration(
//                       hintText: "Search location",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 core SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: () {
//                     searchLocation();
//                   },
//                   child: core Text("Search"),
//                 ),
//               ],
//             ),
//             core SizedBox(height: 20),
//             Row(
//               children: [
//                 Icon(Icons.location_on, color: Colors.red),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     "$placeName ($latitude, $longitude)",
//                     style: core TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ],
//             ),
//             core SizedBox(height: 10),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection("locations")
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   }
//                   if (!snapshot.hasData) {
//                     return Center(child: Text("No Locations Found"));
//                   }
//                   final docs = snapshot.data!.docs;
//                   final filterDocs = docs.where((doc) {
//                     String nearest = normalize(doc['nearestPlace']);
//                     String current = normalize(placeName);
//                     return current.contains(nearest) ||
//                         nearest.contains(current);
//                   }).toList();
//                   if (filterDocs.isEmpty) {
//                     return Center(child: Text("No Locations Found"));
//                   }
//                   return ListView.builder(
//                     itemCount: filterDocs.length,
//                     itemBuilder: (context, index) {
//                       var doc = filterDocs[index];
//                       return Container(
//                         margin: core EdgeInsets.only(bottom: 12),
//                         padding: core EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.white30,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 30,
//                               backgroundImage: NetworkImage(
//                                 doc['image'].toString(),
//                               ),
//                             ),
//                             core SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     doc['name'],
//                                     style: core TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   core SizedBox(height: 5),
//                                   Text(doc['description']),
//                                   core SizedBox(height: 5),
//                                   Text(
//                                     "Location: ${doc['locationName']}",
//                                     style: core TextStyle(
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   core SizedBox(height: 5),
//                                   Text(
//                                     "Lat: ${doc['latitude']}  |  Long: ${doc['longitude']}",
//                                   ),
//                                   core SizedBox(height: 5),
//                                   Text("Nearest Place: ${doc['nearestPlace']}"),
//                                   Text("Distance: ${doc['distance']} km"),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
