import 'package:flutter/material.dart';
import '../components/search_bar_component.dart';
import '../components/filter_tabs_component.dart';
import '../components/property_card_component.dart';
import '../components/trip_date_selector.dart';
import '../components/duration_selector.dart';

class TravelBookingScreen extends StatefulWidget {
  const TravelBookingScreen({Key? key}) : super(key: key);

  @override
  State<TravelBookingScreen> createState() => _TravelBookingScreenState();
}

class _TravelBookingScreenState extends State<TravelBookingScreen> {
  int selectedTabIndex = 0;
  bool showDateSelector = false;
  bool showDurationSelector = false;

  // Sample property data
  final List<PropertyData> properties = [
    PropertyData(
      imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-4.0.3',
      rating: 4.87,
      reviewCount: 71,
      location: 'Abiansernal, Indonesia',
      title: 'Villa with private swimming pool',
      bedInfo: '1 Queen Bed',
      distanceInfo: '1,620 kilometers',
      dateRange: 'Jun 01 - 01',
      price: 360,
      totalPrice: 348,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Search Bar
                SearchBarComponent(
                  hintText: 'Search destinations',
                  onClear: () {
                    // Handle clear action
                  },
                ),
                
                // Main Content
                Expanded(
                  child: ListView(
                    children: [
                      // Property Cards
                      ...properties.map((property) => PropertyCardComponent(
                        imageUrl: property.imageUrl,
                        rating: property.rating,
                        reviewCount: property.reviewCount,
                        location: property.location,
                        title: property.title,
                        bedInfo: property.bedInfo,
                        distanceInfo: property.distanceInfo,
                        dateRange: property.dateRange,
                        price: property.price,
                        totalPrice: property.totalPrice,
                        onTap: () {
                          setState(() {
                            showDateSelector = true;
                          });
                        },
                        onFavorite: () {
                          // Handle favorite action
                        },
                      )),
                      
                      const SizedBox(height: 100), // Space for bottom tabs
                    ],
                  ),
                ),
              ],
            ),
            
            // Bottom Filter Tabs
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FilterTabsComponent(
                selectedIndex: selectedTabIndex,
                onTabSelected: (index) {
                  setState(() {
                    selectedTabIndex = index;
                  });
                },
              ),
            ),
            
            // Date Selector Modal
            if (showDateSelector)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      showDateSelector = false;
                    });
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {}, // Prevent closing when tapping on modal
                          child: TripDateSelector(
                            onDatesSelected: (startDate, endDate) {
                              // Handle date selection
                              if (startDate != null && endDate != null) {
                                setState(() {
                                  showDateSelector = false;
                                  showDurationSelector = true;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            // Duration Selector Modal
            if (showDurationSelector)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      showDurationSelector = false;
                    });
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: GestureDetector(
                            onTap: () {}, // Prevent closing when tapping on modal
                            child: DurationSelector(
                              selectedDuration: 3,
                              onDurationChanged: (duration) {
                                // Handle duration change
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PropertyData {
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String location;
  final String title;
  final String bedInfo;
  final String distanceInfo;
  final String dateRange;
  final double price;
  final double totalPrice;

  PropertyData({
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.title,
    required this.bedInfo,
    required this.distanceInfo,
    required this.dateRange,
    required this.price,
    required this.totalPrice,
  });
}