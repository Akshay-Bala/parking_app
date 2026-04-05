import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parking_app/features/user/home/provider/booking_provider.dart';
import 'package:provider/provider.dart';

class SlotBooking extends StatefulWidget {
  final List<Map<String, dynamic>> pricing;

  const SlotBooking({super.key, required this.pricing});

  @override
  State<SlotBooking> createState() => _SlotBookingState();
}

class _SlotBookingState extends State<SlotBooking> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<BookingProvider>(
        context,
        listen: false,
      ).setPricing(widget.pricing);
    });
  }

  void bookSlot() {
    final provider = Provider.of<BookingProvider>(context, listen: false);

    final error = provider.validate();

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final data = provider.getBookingData(context);

    print(data);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Booking Successful")));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Parking Slot"),
        backgroundColor: const Color(0xFF2563EB),
      ),
      backgroundColor: const Color(0xFFF5F7FA),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _card(
              title: "Select Date",
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  DateFormat('yyyy-MM-dd').format(provider.selectedDate),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: provider.selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (picked != null) {
                    provider.setDate(picked);
                  }
                },
              ),
            ),

            _card(
              title: "Select Time",
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: Text(
                      provider.startTime == null
                          ? "Start Time"
                          : provider.startTime!.format(context),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (picked != null) {
                        provider.setStartTime(picked);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text(
                      provider.endTime == null
                          ? "End Time"
                          : provider.endTime!.format(context),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (picked != null) {
                        provider.setEndTime(picked);
                      }
                    },
                  ),
                ],
              ),
            ),

            _card(
              title: "Vehicle Details",
              child: Column(
                children: [
                  ...provider.vehicles.asMap().entries.map((entry) {
                    int index = entry.key;
                    var v = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: v["type"],
                            items: provider.pricing
                                .map<DropdownMenuItem<String>>((p) {
                                  return DropdownMenuItem<String>(
                                    value: p['type'],
                                    child: Text(p['type']),
                                  );
                                })
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                provider.updateVehicleType(index, val);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: "Vehicle Type",
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextField(
                            controller: v["controller"],
                            decoration: const InputDecoration(
                              hintText: "Enter Vehicle Number",
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => provider.removeVehicle(index),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  ElevatedButton.icon(
                    onPressed: provider.addVehicle,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Vehicle"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _card(
              title: "Booking Summary",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Duration: ${provider.getDuration().toStringAsFixed(1)} hrs",
                  ),

                  const SizedBox(height: 10),

                  Column(
                    children: provider.vehicles.map((v) {
                      final type = v["type"];
                      final number = v["controller"].text;

                      final priceData = provider.pricing.firstWhere(
                        (e) => e['type'] == type,
                        orElse: () => {},
                      );

                      double pricePerHour = (priceData['rate_per_hour'] ?? 0)
                          .toDouble();

                      double amount = provider.getVehicleAmount(type);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Type: $type"),
                            Text("Number: ${number.isEmpty ? '-' : number}"),
                            Text("Rate: ₹$pricePerHour/hr"),
                            Text(
                              "Amount: ₹${amount.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const Divider(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total"),
                      Text("₹${provider.getTotalAmount().toStringAsFixed(0)}"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: bookSlot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                ),
                child: const Text(
                  "Confirm Booking",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
