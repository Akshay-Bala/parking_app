// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:parking_app/features/user/home/provider/booking_provider.dart';
// import 'package:provider/provider.dart';
//
// class SlotBooking extends StatefulWidget {
//   final List<Map<String, dynamic>> pricing;
//
//   const SlotBooking({super.key, required this.pricing});
//
//   @override
//   State<SlotBooking> createState() => _SlotBookingState();
// }
//
// class _SlotBookingState extends State<SlotBooking> {
//   double getDurationInHours() {
//     if (startTime == null || endTime == null) return 0;
//
//     final now = DateTime.now();
//
//     final start = DateTime(
//       now.year,
//       now.month,
//       now.day,
//       startTime!.hour,
//       startTime!.minute,
//     );
//
//     final end = DateTime(
//       now.year,
//       now.month,
//       now.day,
//       endTime!.hour,
//       endTime!.minute,
//     );
//
//     return end.difference(start).inMinutes / 60;
//   }
//
//   double calculateTotal() {
//     double total = 0;
//     double hours = getDurationInHours();
//
//     for (var v in vehicles) {
//       final type = v["type"];
//
//       final priceData = widget.pricing.firstWhere(
//         (e) => e['type'] == type,
//         orElse: () => {},
//       );
//
//       double pricePerHour = (priceData['hour'] ?? 0).toDouble();
//
//       total += pricePerHour * hours;
//     }
//
//     return total;
//   }
//
//   // ---------------- DATE PICKER ----------------
//   Future<void> pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//     );
//
//     if (picked != null) {
//       setState(() => selectedDate = picked);
//     }
//   }
//
//   // ---------------- TIME PICKER ----------------
//   Future<void> pickStartTime() async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//
//     if (picked != null) {
//       setState(() => startTime = picked);
//     }
//   }
//
//   Future<void> pickEndTime() async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//
//     if (picked != null) {
//       setState(() => endTime = picked);
//     }
//   }
//
//   void removeVehicle(int index) {
//     setState(() {
//       vehicles.removeAt(index);
//     });
//   }
//
//   // ---------------- BOOK SLOT ----------------
//   void bookSlot() {
//     if (startTime == null || endTime == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Select time")));
//       return;
//     }
//
//     for (var v in vehicles) {
//       if (v["numberController"].text.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Enter all vehicle numbers")),
//         );
//         return;
//       }
//     }
//
//     // 🔥 Ready for Firestore
//     print({
//       "date": selectedDate,
//       "startTime": startTime!.format(context),
//       "endTime": endTime!.format(context),
//       "vehicles": vehicles.map((v) {
//         return {"type": v["type"], "number": v["numberController"].text};
//       }).toList(),
//     });
//
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text("Booking Successful")));
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       Provider.of<BookingProvider>(
//         context,
//         listen: false,
//       ).setPricing(widget.pricing);
//     });
//   }
//
//   // ---------------- UI ----------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Book Parking Slot"),
//         backgroundColor: const Color(0xFF2563EB),
//       ),
//       backgroundColor: const Color(0xFFF5F7FA),
//
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             /// 📅 DATE
//             _card(
//               title: "Select Date",
//               child: ListTile(
//                 leading: const Icon(Icons.calendar_today),
//                 title: Consumer<BookingProvider>(
//                   builder: (context, provider, _) {
//                     return ListTile(
//                       title: Text(
//                         DateFormat('yyyy-MM-dd').format(provider.selectedDate),
//                       ),
//                       onTap: () async {
//                         final picked = await showDatePicker(
//                           context: context,
//                           initialDate: provider.selectedDate,
//                           firstDate: DateTime.now(),
//                           lastDate: DateTime(2100),
//                         );
//
//                         if (picked != null) {
//                           provider.setDate(picked);
//                         }
//                       },
//                     );
//                   },
//                 ),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: pickDate,
//               ),
//             ),
//
//             /// ⏰ TIME
//             _card(
//               title: "Select Time",
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: const Icon(Icons.login),
//                     title: Text(
//                       startTime == null
//                           ? "Start Time"
//                           : startTime!.format(context),
//                     ),
//                     onTap: pickStartTime,
//                   ),
//                   ListTile(
//                     leading: const Icon(Icons.logout),
//                     title: Text(
//                       endTime == null ? "End Time" : endTime!.format(context),
//                     ),
//                     onTap: pickEndTime,
//                   ),
//                 ],
//               ),
//             ),
//
//             /// 🚗 VEHICLES
//             _card(
//               title: "Select Time",
//               child: Consumer<BookingProvider>(
//                 builder: (context, provider, _) {
//                   return Column(
//                     children: [
//                       ListTile(
//                         leading: const Icon(Icons.login),
//                         title: Text(
//                           provider.startTime == null
//                               ? "Start Time"
//                               : provider.startTime!.format(context),
//                         ),
//                         onTap: () async {
//                           final picked = await showTimePicker(
//                             context: context,
//                             initialTime: TimeOfDay.now(),
//                           );
//                           if (picked != null) provider.setStartTime(picked);
//                         },
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.logout),
//                         title: Text(
//                           provider.endTime == null
//                               ? "End Time"
//                               : provider.endTime!.format(context),
//                         ),
//                         onTap: () async {
//                           final picked = await showTimePicker(
//                             context: context,
//                             initialTime: TimeOfDay.now(),
//                           );
//                           if (picked != null) provider.setEndTime(picked);
//                         },
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             Consumer<BookingProvider>(
//               builder: (context, provider, _) {
//                 return _card(
//                   title: "Booking Summary",
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Duration: ${provider.getDuration().toStringAsFixed(1)} hrs",
//                       ),
//
//                       const SizedBox(height: 10),
//
//                       Column(
//                         children: provider.vehicles.asMap().entries.map((
//                           entry,
//                         ) {
//                           int index = entry.key;
//                           var v = entry.value;
//
//                           final type = v["type"];
//                           final number = v["controller"].text;
//
//                           final priceData = provider.pricing.firstWhere(
//                             (e) => e['type'] == type,
//                             orElse: () => {},
//                           );
//
//                           double pricePerHour = (priceData['hour'] ?? 0)
//                               .toDouble();
//                           double vehicleTotal = provider.getVehicleAmount(type);
//
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 8),
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade100,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Vehicle ${index + 1}"),
//                                 Text("Type: $type"),
//                                 Text(
//                                   "Number: ${number.isEmpty ? '-' : number}",
//                                 ),
//                                 Text(
//                                   "Rate: ₹${pricePerHour.toStringAsFixed(0)}/hr",
//                                 ),
//                                 Text(
//                                   "Amount: ₹${vehicleTotal.toStringAsFixed(0)}",
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ),
//
//                       const Divider(),
//
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text("Total"),
//                           Text(
//                             "₹${provider.getTotalAmount().toStringAsFixed(0)}",
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//             Consumer<BookingProvider>(
//               builder: (context, provider, _) {
//                 return Column(
//                   children: [
//                     ListTile(
//                       title: Text(
//                         provider.startTime == null
//                             ? "Start Time"
//                             : provider.startTime!.format(context),
//                       ),
//                       onTap: () async {
//                         final picked = await showTimePicker(
//                           context: context,
//                           initialTime: TimeOfDay.now(),
//                         );
//                         if (picked != null) provider.setStartTime(picked);
//                       },
//                     ),
//                     ListTile(
//                       title: Text(
//                         provider.endTime == null
//                             ? "End Time"
//                             : provider.endTime!.format(context),
//                       ),
//                       onTap: () async {
//                         final picked = await showTimePicker(
//                           context: context,
//                           initialTime: TimeOfDay.now(),
//                         );
//                         if (picked != null) provider.setEndTime(picked);
//                       },
//                     ),
//                   ],
//                 );
//               },
//             ),
//             const SizedBox(height: 10),
//             SizedBox(
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: bookSlot,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2563EB),
//                 ),
//                 child: const Text(
//                   "Confirm Booking",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ---------------- CARD UI ----------------
//   Widget _card({required String title, required Widget child}) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//           ),
//           const SizedBox(height: 10),
//           child,
//         ],
//       ),
//     );
//   }
// }
