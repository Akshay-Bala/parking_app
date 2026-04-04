import 'package:flutter/material.dart';
import 'package:parking_app/features/admin/parkings/models/model_vehicle_price.dart';
import 'package:parking_app/features/admin/parkings/provider/parking_provider.dart';

class AddVehicleDialog extends StatefulWidget {
  final ParkingProvider provider;

  const AddVehicleDialog({super.key, required this.provider});

  @override
  State<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> {
  String selectedType = "Two Wheeler";

  TextEditingController hour = TextEditingController();
  TextEditingController day = TextEditingController();
  TextEditingController month = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Vehicle Type"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedType,
            items: [
              "Two Wheeler",
              "Four Wheeler",
              "EV",
              "Other Heavy Vehicles",
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) {
              setState(() {
                selectedType = val!;
              });
            },
          ),

          const SizedBox(height: 10),

          TextField(
            controller: hour,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Per Hour"),
          ),
          TextField(
            controller: day,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Per Day"),
          ),
          TextField(
            controller: month,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Per Month"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (hour.text.trim().isEmpty ||
                day.text.trim().isEmpty ||
                month.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("⚠️ Please fill all pricing fields"),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            widget.provider.addVehicle(
              VehiclePricing(
                type: selectedType,
                hour: double.tryParse(hour.text) ?? 0,
                day: double.tryParse(day.text) ?? 0,
                month: double.tryParse(month.text) ?? 0,
              ),
            );

            hour.clear();
            day.clear();
            month.clear();

            Navigator.pop(context);
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
