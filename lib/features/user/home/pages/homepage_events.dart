import 'package:flutter/material.dart';
import 'package:parking_app/features/user/home/pages/user_view_parking_detailed_page.dart';
import 'package:parking_app/features/user/home/provider/homepage_provider.dart';
import 'package:parking_app/features/user/profile/pages/profile_page.dart';
import 'package:provider/provider.dart';

class HomepageEvents extends StatefulWidget {
  final String? previousSearch;
  const HomepageEvents({super.key, this.previousSearch});

  @override
  State<HomepageEvents> createState() => _HomepageEventsState();
}

class _HomepageEventsState extends State<HomepageEvents> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomepageProvider>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
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
                  child: Consumer<HomepageProvider>(
                    builder: (context, provider, _) {
                      return Container(
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
                          controller: provider.searchController,
                          onChanged: (value) {
                            provider.setSearch(value);
                          },

                          decoration: InputDecoration(
                            hintText: "Search destination",
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                provider.searchController.clear();
                                provider.setSearch("");
                              },
                            ),

                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),
                Consumer<HomepageProvider>(
                  builder: (context, provider, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          final query = provider.searchController.text.trim();
                          Provider.of<HomepageProvider>(
                            context,
                            listen: false,
                          ).setSearch(query);
                        },
                        child: provider.isSearching
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Search",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: Consumer<HomepageProvider>(
                    builder: (context, provider, _) {
                      if (provider.isPageLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.error != null) {
                        return Center(child: Text(provider.error!));
                      }

                      if (provider.filteredParkings.isEmpty) {
                        return const Center(
                          child: Text("No nearby parking within 2 km"),
                        );
                      }

                      return ListView.builder(
                        itemCount: provider.filteredParkings.length,
                        itemBuilder: (context, index) {
                          final data = provider.filteredParkings[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                            child: ListTile(

                              leading: const Icon(
                                Icons.local_parking,
                                color: Color(0xFF2563EB),
                                size: 30,
                              ),

                              title: Text(
                                data['name'] ?? "",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['parking_name'] ?? "",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                   Text(
                                    data['address'] ?? "",
                                    
                                  ),
                                  const SizedBox(height: 4), Text(
                                    data['city'] ?? "",
                                  
                                  ),
                                  const SizedBox(height: 4),
                                  Text(data['locationName'] ?? ""),
                                  const SizedBox(height: 4),
                                  Text(
                                    "📍 ${data['distance'].toStringAsFixed(2)} km away",
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UserViewParkingDetailedPage(data: data),
                                  ),
                                );
                              },
                            ),
                          );
                        },
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
