import 'package:flutter/material.dart';

class FilterBottomSheetPage extends StatefulWidget {
  final String selectedRating;
  final String selectedAmount;
  const FilterBottomSheetPage({
    super.key,
    required this.selectedRating,
    required this.selectedAmount,
  });

  @override
  State<FilterBottomSheetPage> createState() => _FilterBottomSheetPageState();
}

class _FilterBottomSheetPageState extends State<FilterBottomSheetPage> {
  late String selectedRating;
  late String selectedAmount;

  @override
  void initState() {
    super.initState();
    selectedRating = widget.selectedRating;
    selectedAmount = widget.selectedAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            "Filters",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Rating",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 10),

          _buildOption(
            title: "Low to High",
            value: "rating_low_high",
            groupValue: selectedRating,
            onChanged: (val) => setState(() => selectedRating = val),
          ),

          _buildOption(
            title: "High to Low",
            value: "rating_high_low",
            groupValue: selectedRating,
            onChanged: (val) => setState(() => selectedRating = val),
          ),

          const SizedBox(height: 20),
          const Text(
            "Price",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 10),

          _buildOption(
            title: "Low to High",
            value: "amount_low_high",
            groupValue: selectedAmount,
            onChanged: (val) => setState(() => selectedAmount = val),
          ),

          _buildOption(
            title: "High to Low",
            value: "amount_high_low",
            groupValue: selectedAmount,
            onChanged: (val) => setState(() => selectedAmount = val),
          ),

          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF2563EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedRating = "";
                      selectedAmount = "";
                    });

                    Navigator.pop(context, {"rating": "", "amount": ""});
                  },
                  child: const Text("Clear"),
                ),
              ),

              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, {
                      "rating": selectedRating,
                      "amount": selectedAmount,
                    });
                  },
                  child: Text("Apply", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

Widget _buildOption({
  required String title,
  required String value,
  required String groupValue,
  required Function(String) onChanged,
}) {
  final bool isSelected = groupValue == value;

  return GestureDetector(
    onTap: () => onChanged(value),
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF2563EB).withOpacity(0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? const Color(0xFF2563EB) : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isSelected ? const Color(0xFF2563EB) : Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}
