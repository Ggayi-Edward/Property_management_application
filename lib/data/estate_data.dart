import 'package:propertysmart2/export/file_exports.dart';

class EstateData {
  List<EstateModel> estates = [
    EstateModel(
      image: 'assets/images/houses/bugolobihouse.jpeg',
      availability: {
        'wifi': true,
        'bedrooms': 4,
        'bathrooms': 3,
        'swimmingPool': false,
      },
      location: 'Bugolobi, Kampala',
      price: 1200.0,
      title: 'Bugolobi Apartments',
      roomImages: [
        'assets/images/houses/rooms/livingroom1.jfif',
        'assets/images/houses/rooms/kitchen1.jfif',
        'assets/images/houses/rooms/bedroom1.jfif',
        'assets/images/houses/rooms/bathroom1.jfif',
      ],
    ),
    EstateModel(
      image: 'assets/images/houses/bugolobihouse.jpeg',
      availability: {
        'wifi': true,
        'bedrooms': 1,
        'bathrooms': 1,
        'swimmingPool': false,
      },
      location: 'Nakasero, Kampala',
      price: 2000.0,
      title: 'Prince Charles Drive Cottages',
      roomImages: [
        'assets/images/houses/rooms/livingroom1.jfif',
        'assets/images/houses/rooms/kitchen1.jfif',
        'assets/images/houses/rooms/bedroom1.jfif',
        'assets/images/houses/rooms/bathroom1.jfif',
      ],
    ),
    EstateModel(
      image: 'assets/images/houses/bugolobihouse.jpeg',
      availability: {
        'wifi': true,
        'bedrooms': 4,
        'bathrooms': 3,
        'swimmingPool': false,
      },
      location: 'Bugolobi, Kampala',
      price: 2500.0,
      title: 'Pathway Residences',
      roomImages: [
        'assets/images/houses/rooms/livingroom1.jfif',
        'assets/images/houses/rooms/kitchen1.jfif',
        'assets/images/houses/rooms/bedroom1.jfif',
        'assets/images/houses/rooms/bathroom1.jfif',
      ],
    ),
    EstateModel(
      image: 'assets/images/houses/entebbe.jpeg',
      availability: {
        'wifi': true,
        'bedrooms': 5,
        'bathrooms': 4,
        'swimmingPool': true,
      },
      location: 'Entebbe, Wakiso',
      price: 5000.0,
      title: 'Imperial Park And Gardens Estate',
      roomImages: [
        'assets/images/houses/rooms/livingroom3.jfif',
        'assets/images/houses/rooms/kitchen3.jfif',
        'assets/images/houses/rooms/bedroom3.jfif',
        'assets/images/houses/rooms/bathroom3.jfif',
      ],
    ),
    EstateModel(
      image: 'assets/images/houses/makindyehouse.jpeg',
      availability: {
        'wifi': true,
        'bedrooms': 4,
        'bathrooms': 3,
        'swimmingPool': true,
      },
      location: 'Makindye, Kampala',
      price: 2300.0,
      title: 'Grandview Apartments',
      roomImages: [
        'assets/images/houses/rooms/bathroom4.jfif',
        'assets/images/houses/rooms/bedroom4.jfif',
        'assets/images/houses/rooms/kitchen4.jfif',
        'assets/images/houses/rooms/livingroom4.jfif',
        'assets/images/houses/rooms/swimmingpool1.jfif',
      ],
    ),
    EstateModel(
      image: 'assets/images/houses/kyabanyorohouse.jpeg',
      availability: {
        'wifi': true,
        'bedrooms': 3,
        'bathrooms': 2,
        'swimmingPool': true,
      },
      location: 'Kabanyolo, Mbarara',
      price: 1000.0,
      title: 'West Gate Cottages',
      roomImages: [
        'assets/images/houses/rooms/bathroom5.jfif',
        'assets/images/houses/rooms/kitchen5.jfif',
        'assets/images/houses/rooms/livingroom5.jfif',
        'assets/images/houses/rooms/swimmingpool2.jfif',
      ],
    ),
    EstateModel(
      image: 'assets/images/houses/kyabanyorohouse.jpeg',
      availability: {
        'wifi': false,
        'bedrooms': 4,
        'bathrooms': 3,
        'swimmingPool': false,
      },
      location: 'Mbuya, Kampala',
      price: 1800.0,
      title: 'Elizabeth Apartments',
      roomImages: [
        'assets/images/houses/rooms/bathroom5.jfif',
        'assets/images/houses/rooms/kitchen5.jfif',
        'assets/images/houses/rooms/livingroom5.jfif',
        'assets/images/houses/rooms/swimmingpool2.jfif',
      ],
    ),
    EstateModel(
      image: 'assets/images/houses/makindyehouse.jpeg',
      availability: {
        'wifi': true,
        'bedrooms': 2,
        'bathrooms': 1,
        'swimmingPool': true,
      },
      location: 'Makindye, Kampala',
      price: 2000.0,
      title: 'City View Villa',
      roomImages: [
        'assets/images/houses/rooms/livingroom1.jfif',
        'assets/images/houses/rooms/bathroom6.jfif',
        'assets/images/houses/rooms/swimmingpool3.jfif',
      ],
    ),
  ];

  List<EstateModel> filterEstates({
    String? priceRange,
    int? bedrooms,
    int? bathrooms,
    bool? swimmingPool,
  }) {
    return estates.where((estate) {
      bool matches = true;

      // Price Range Filtering
      if (priceRange != null) {
        matches = _filterByPriceRange(estate, priceRange);
      }

      // Bedrooms Filtering
      if (bedrooms != null) {
        matches = matches && estate.availability['bedrooms'] == bedrooms;
      }

      // Bathrooms Filtering
      if (bathrooms != null) {
        matches = matches && estate.availability['bathrooms'] == bathrooms;
      }

      // Swimming Pool Filtering
      if (swimmingPool != null) {
        matches = matches && estate.availability['swimmingPool'] == swimmingPool;
      }

      return matches;
    }).toList();
  }

  bool _filterByPriceRange(EstateModel estate, String priceRange) {
    final price = estate.price;
    switch (priceRange) {
      case 'Below \$100k':
        return price < 100000;
      case '\$100k - \$500k':
        return price >= 100000 && price <= 500000;
      case 'Above \$500k':
        return price > 500000;
      default:
        return true;
    }
  }
}
