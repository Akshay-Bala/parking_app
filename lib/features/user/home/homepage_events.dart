import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/core/widgets_scaffold_messenger.dart';
import 'package:parking_app/features/user/profile/profile_page.dart';

class HomepageEvents extends StatefulWidget {
  final String? previousSearch;
  const HomepageEvents({super.key, this.previousSearch});

  @override
  State<HomepageEvents> createState() => _HomepageEventsState();
}

class _HomepageEventsState extends State<HomepageEvents> {
  String? place = "";
  String email = "";
  String latitude = "";
  String longitude = "";

  bool isLoading = true;

  final double defaultPrice = 12;

  Map<String, dynamic> selectedFilters = {"rating": "", "amount": ""};

  TextEditingController searchController = TextEditingController();

  List<dynamic> eventDetails = [];

  void applyFilter(Map<String, dynamic> filters) {
    List<dynamic> tempList = List.from(eventDetails);

    tempList.sort((a, b) {
      double priceA = a['extracted_price'] != null
          ? (a['extracted_price']).toDouble()
          : defaultPrice;

      double priceB = b['extracted_price'] != null
          ? (b['extracted_price']).toDouble()
          : defaultPrice;

      double ratingA = double.tryParse(a["rating"]?.toString() ?? "0") ?? 0;
      double ratingB = double.tryParse(b["rating"]?.toString() ?? "0") ?? 0;

      if (filters["rating"] == "rating_low_high") {
        return ratingA.compareTo(ratingB);
      } else if (filters["rating"] == "rating_high_low") {
        return ratingB.compareTo(ratingA);
      }

      if (filters["amount"] == "amount_low_high") {
        return priceA.compareTo(priceB);
      } else if (filters["amount"] == "amount_high_low") {
        return priceB.compareTo(priceA);
      }

      return 0;
    });

    setState(() {
      eventDetails = tempList;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.previousSearch != null && widget.previousSearch!.isNotEmpty) {
      searchController.text = widget.previousSearch!;
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),

          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: "ai_chat",
                backgroundColor: Colors.deepPurple,
                onPressed: () {},
                child: const Icon(Icons.smart_toy, color: Colors.white),
              ),

              const SizedBox(height: 10),

              FloatingActionButton(
                heroTag: "admin_chat",
                backgroundColor: const Color(0xFF2563EB),
                onPressed: () async {
                  try {} catch (e) {
                    CustomSnackBar.show(
                      context: context,
                      message: "Error loading admin",
                      type: SnackBarType.error,
                    );
                  }
                },
                child: const Icon(Icons.chat, color: Colors.white),
              ),
            ],
          ),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              "Explore",
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                  child: const CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=3',
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search destination",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () async {
                          // final filters = await showModalBottomSheet(
                          //   context: context,
                          //   isScrollControlled: true,
                          //   builder: (_) => FilterBottomSheetPage(
                          //     selectedRating: selectedFilters["rating"],
                          //     selectedAmount: selectedFilters["amount"],
                          //   ),
                          // );
                          //
                          // if (filters != null) {
                          //   setState(() {
                          //     selectedFilters = filters;
                          //   });
                          //
                          //   if (filters["rating"] == "" &&
                          //       filters["amount"] == "") {
                          //     getEventWithDynamicFallback([place ?? ""]);
                          //   } else {
                          //     applyFilter(filters);
                          //   }
                          // }
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      var city = searchController.text.trim();
                      if (city.isNotEmpty) {}
                    },
                    child: const Text(
                      "Search",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 18),
                    const SizedBox(width: 5),
                    Text(
                      place ?? "",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : eventDetails.isEmpty
                      ? const Center(child: Text("No data found"))
                      : ListView.builder(
                          itemCount: eventDetails.length,
                          itemBuilder: (context, index) {
                            var event = eventDetails[index];

                            final imageUrl = event['thumbnail'] ?? '';
                            final title = event['title'] ?? 'No Title';
                            final description = event['description'] ?? '';
                            final rating = event["rating"]?.toString() ?? "0";
                            final reviews = event['reviews']?.toString() ?? "0";

                            final price = event['extracted_price'] != null
                                ? (event['extracted_price']).toDouble()
                                : defaultPrice;

                            return GestureDetector(
                              onTap: () async {},
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                            left: Radius.circular(14),
                                          ),
                                      child: Image.network(
                                        imageUrl,
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 110,
                                          height: 110,
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),

                                            const SizedBox(height: 5),

                                            if (description.isNotEmpty)
                                              Text(
                                                description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),

                                            const SizedBox(height: 6),

                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 16,
                                                ),
                                                Text(" $rating"),
                                                Text(
                                                  " ($reviews)",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 6),

                                            Text(
                                              "₹ $price",
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
