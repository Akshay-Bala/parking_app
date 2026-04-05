import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:parking_app/features/admin/parkings/models/model_vehicle_price.dart';
import 'package:parking_app/features/admin/parkings/widgets/map_picker.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/features/admin/parkings/provider/parking_provider.dart';

class AddParkingPage extends StatelessWidget {
  const AddParkingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ParkingProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 90),
                Text(
                  "Add New Parking",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Fill all details to create parking spot",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: Form(
              key: provider.formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildField(provider.name, "Parking Name"),
                      _buildField(provider.description, "Description"),
                      _buildField(provider.address, "Address"),
                      _buildField(provider.city, "City"),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                          ),
                          onPressed: () async {
                            bool serviceEnabled =
                                await Geolocator.isLocationServiceEnabled();

                            if (!serviceEnabled) {
                              await Geolocator.openLocationSettings();
                              return;
                            }

                            LocationPermission permission =
                                await Geolocator.checkPermission();

                            if (permission == LocationPermission.denied) {
                              permission = await Geolocator.requestPermission();
                            }

                            if (permission == LocationPermission.denied ||
                                permission ==
                                    LocationPermission.deniedForever) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Location permission required"),
                                ),
                              );
                              return;
                            }

                            Position position =
                                await Geolocator.getCurrentPosition();

                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MapPickerPage(
                                  initialLat: position.latitude,
                                  initialLng: position.longitude,
                                ),
                              ),
                            );

                            if (result != null) {
                              await provider.setLocation(
                                result.latitude,
                                result.longitude,
                              );
                            }
                          },
                          icon: const Icon(Icons.map, color: Colors.white),
                          label: const Text(
                            "Select Location from Map",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      if (provider.latitude != null &&
                          provider.longitude != null)
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (provider.latitude != null &&
                                  provider.longitude != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (provider.locationName != null)
                                        Text(
                                          "📍 ${provider.locationName}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      const SizedBox(height: 5),
                                      Text("Latitude: ${provider.latitude}"),
                                      Text("Longitude: ${provider.longitude}"),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      const SizedBox(height: 15),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Vehicles",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      provider.addEmptyVehicle(context),
                                  icon: const Icon(
                                    Icons.add_circle,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            if (provider.vehicles.isEmpty)
                              const Text("No vehicle types added yet."),

                            ...provider.vehicles.asMap().entries.map((entry) {
                              final index = entry.key;
                              final v = entry.value;

                              return Card(
                                color: Colors.white,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child:
                                                DropdownButtonFormField<String>(
                                                  value: v.type,
                                                  items: const [
                                                    DropdownMenuItem(
                                                      value: 'Two Wheeler',
                                                      child: Text(
                                                        'Two Wheeler',
                                                      ),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 'Four Wheeler',
                                                      child: Text(
                                                        'Four Wheeler',
                                                      ),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 'Other',
                                                      child: Text('Other'),
                                                    ),
                                                  ],
                                                  onChanged: (val) {
                                                    if (val == null) return;
                                                    provider.updateVehicleAt(
                                                      index,
                                                      VehiclePricing(
                                                        type: val,
                                                        slots: v.slots,
                                                        balanceSlots:
                                                            v.balanceSlots,
                                                        hour: v.hour,
                                                        day: v.day,
                                                        month: v.month,
                                                      ),
                                                    );
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText:
                                                            'Vehicle Type',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              provider.removeVehicleAt(index);
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              initialValue: v.slots.toString(),
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: 'Slots',
                                                border: OutlineInputBorder(),
                                              ),
                                              validator: (val) {
                                                if (val == null || val.isEmpty)
                                                  return 'Required';
                                                if (int.tryParse(val) == null)
                                                  return 'Enter valid number';
                                                return null;
                                              },
                                              onChanged: (val) {
                                                final s =
                                                    int.tryParse(val) ?? 0;
                                                provider.updateVehicleAt(
                                                  index,
                                                  VehiclePricing(
                                                    balanceSlots: s,
                                                    type: v.type,
                                                    slots: s,
                                                    hour: v.hour,
                                                    day: v.day,
                                                    month: v.month,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextFormField(
                                              initialValue: v.hour.toString(),
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9.]'),
                                                ),
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: 'Rate / Hr',
                                                border: OutlineInputBorder(),
                                              ),
                                              validator: (val) {
                                                if (val == null || val.isEmpty)
                                                  return 'Required';
                                                if (double.tryParse(val) ==
                                                    null)
                                                  return 'Enter valid number';
                                                return null;
                                              },
                                              onChanged: (val) {
                                                final numVal =
                                                    double.tryParse(val) ?? 0;
                                                provider.updateVehicleAt(
                                                  index,
                                                  VehiclePricing(
                                                    balanceSlots:
                                                        v.balanceSlots,
                                                    type: v.type,
                                                    slots: v.slots,
                                                    hour: numVal,
                                                    day: v.day,
                                                    month: v.month,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              initialValue: v.day.toString(),
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9.]'),
                                                ),
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: 'Rate / Day',
                                                border: OutlineInputBorder(),
                                              ),
                                              validator: (val) {
                                                if (val == null || val.isEmpty)
                                                  return 'Required';
                                                if (double.tryParse(val) ==
                                                    null)
                                                  return 'Enter valid number';
                                                return null;
                                              },
                                              onChanged: (val) {
                                                final numVal =
                                                    double.tryParse(val) ?? 0;
                                                provider.updateVehicleAt(
                                                  index,
                                                  VehiclePricing(
                                                    balanceSlots:
                                                        v.balanceSlots,
                                                    type: v.type,
                                                    slots: v.slots,
                                                    hour: v.hour,
                                                    day: numVal,
                                                    month: v.month,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextFormField(
                                              initialValue: v.month.toString(),
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9.]'),
                                                ),
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: 'Rate / Month',
                                                border: OutlineInputBorder(),
                                              ),
                                              validator: (val) {
                                                if (val == null || val.isEmpty)
                                                  return 'Required';
                                                if (double.tryParse(val) ==
                                                    null)
                                                  return 'Enter valid number';
                                                return null;
                                              },
                                              onChanged: (val) {
                                                final numVal =
                                                    double.tryParse(val) ?? 0;
                                                provider.updateVehicleAt(
                                                  index,
                                                  VehiclePricing(
                                                    balanceSlots:
                                                        v.balanceSlots,
                                                    type: v.type,
                                                    slots: v.slots,
                                                    hour: v.hour,
                                                    day: v.day,
                                                    month: numVal,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildField(
                        provider.contact,
                        "Contact Number",
                        isNumber: true,
                      ),

                      const SizedBox(height: 10),

                      SwitchListTile(
                        inactiveTrackColor: Colors.white,
                        inactiveThumbColor: Colors.black,
                        activeColor: const Color(0xFF2563EB),
                        title: const Text("24 Hours"),
                        value: provider.is24Hours,
                        onChanged: (val) {
                          provider.is24Hours = val;
                          provider.notifyListen();
                        },
                      ),
                      if (!provider.is24Hours) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (picked != null) {
                                    provider.startTime = picked;
                                    provider.notifyListen();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(
                                  provider.startTime == null
                                      ? "Start Time"
                                      : provider.formatTime(
                                          provider.startTime!,
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (picked != null) {
                                    provider.endTime = picked;
                                    provider.notifyListen();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(
                                  provider.endTime == null
                                      ? "End Time"
                                      : provider.formatTime(provider.endTime!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 15),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select Days",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        children: provider.days.map((day) {
                          final isSelected = provider.selectedDays.contains(
                            day,
                          );

                          return ChoiceChip(
                            backgroundColor: Colors.white,
                            label: Text(day),
                            selected: isSelected,
                            selectedColor: const Color(0xFF2563EB),
                            onSelected: (_) => provider.toggleDay(day),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          );
                        }).toList(),
                      ),
                      if (provider.selectedDays.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            "📅 ${provider.displayDays}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      CheckboxListTile(
                        activeColor: const Color(0xFF2563EB),
                        title: const Text("CCTV"),
                        value: provider.cctv,
                        onChanged: (val) {
                          provider.cctv = val!;
                          provider.notifyListen();
                        },
                      ),
                      Consumer<ParkingProvider>(
                        builder: (context, provider, _) {
                          return Column(
                            children: [
                              CheckboxListTile(
                                title: const Text("Security"),
                                value: provider.security,
                                onChanged: (val) {
                                  provider.security = val ?? false;
                                  provider.notifyListen();
                                },
                              ),

                              CheckboxListTile(
                                title: const Text("Covered Parking"),
                                value: provider.covered,
                                onChanged: (val) {
                                  provider.covered = val ?? false;
                                  provider.notifyListen();
                                },
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      provider.isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  bool success = await provider.addParking(
                                    context,
                                  );

                                  if (success) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text(
                                  "Add Parking",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Field is required";

          if (label == "Contact Number") {
            if (value.length < 10) return "Enter valid number";
          }

          return null;
        },
      ),
    );
  }
}
