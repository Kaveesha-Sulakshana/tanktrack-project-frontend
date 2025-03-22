import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/emergency_service.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  List<EmergencyService> emergencyServices = [];
  bool isLoading = true;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    fetchEmergencyServices();
  }

  Future<void> fetchEmergencyServices() async {
    final url = Uri.parse("http://10.0.2.2:8080/api/services");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          emergencyServices =
              data.map((json) => EmergencyService.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        print("Failed to load data: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else if (index == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        color: const Color.fromARGB(255, 50, 45, 85),
        child:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: emergencyServices.length,
                  itemBuilder: (context, index) {
                    final service = emergencyServices[index];
                    return Card(
                      color: const Color.fromARGB(84, 240, 194, 142),
                      margin: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: _buildServiceLogo(service),
                        title: Text(
                          service.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 📍 Location with Icon
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 18,
                                ), // Location icon
                                SizedBox(width: 5), // Small space
                                Expanded(
                                  child: Text(
                                    service.address,
                                    style: TextStyle(color: Colors.white70),
                                    overflow:
                                        TextOverflow
                                            .ellipsis, // Prevents long text overflow
                                  ),
                                ),
                              ],
                            ),

                            // 📞 Phone Number with Icon
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Colors.green,
                                  size: 18,
                                ), // Phone icon
                                SizedBox(width: 5),
                                Text(
                                  service.phoneNumber,
                                  style: TextStyle(color: Colors.blueAccent),
                                ),
                              ],
                            ),

                            const SizedBox(height: 5), // Space before stars
                            //  Display Stars Below the Phone Number
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < service.rating.round()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                );
                              }),
                            ),

                            // Show Numeric Rating Below Stars
                            Text(
                              "Rating: ${service.rating.toString()}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // 🔹 App Bar with Logo
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color.fromARGB(255, 72, 66, 109),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/logomark.png', height: 40),
          const Text(
            "Tank Cleaning Services",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Icon(Icons.notifications, color: Colors.white),
        ],
      ),
    );
  }

  // 🔹 Circular Service Logo Function
  Widget _buildServiceLogo(EmergencyService service) {
    if (service.logoUrl != null && service.logoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 25,
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(service.logoUrl!), //  Load online logo
        onBackgroundImageError: (_, __) {
          print("Error loading image for: ${service.name}");
        },
      );
    } else {
      return CircleAvatar(
        radius: 25,
        backgroundColor: Colors.white,
        backgroundImage: AssetImage(
          _getLocalLogo(service.name),
        ), //  Load mapped local image
      );
    }
  }

  // Function to map service names to local logo filenames
  String _getLocalLogo(String serviceName) {
    Map<String, String> logoMap = {
      "CleanTech (PVT) LTD": "assets/service1.png",
      "Tanclean Lanka": "assets/service2.png",
      "Cleanplus (Pvt) Ltd": "assets/service3.png",
      "Carekleen (Pvt) Ltd": "assets/service4.png",
    };

    return logoMap.containsKey(serviceName)
        ? logoMap[serviceName]!
        : "assets/logo.png";
  }

  // 🔹 Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Container(
      color: const Color.fromARGB(255, 50, 45, 85), // Updated solid background
      child: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 50, 45, 85),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(247, 240, 194, 142),
        unselectedItemColor: Colors.white54,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        iconSize: 30,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emergency, color: Colors.white, size: 28),
            ),
            label: "",
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.settings), label: ""),
        ],
      ),
    );
  }
}
