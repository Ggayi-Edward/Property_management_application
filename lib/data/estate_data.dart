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
      price: '12,000,000',
      title: 'Rehoboth Park And Gardens Phase 2 Extension 2',
      roomImages: [
        'assets/images/houses/rooms/livingroom1.jfif',
        'assets/images/houses/rooms/kitchen1.jfif',
        'assets/images/houses/rooms/bedroom1.jfif',
        'assets/images/houses/rooms/bathroom1.jfif',
      ],
    ),
    EstateModel(
      image: 'assets/images/houses/bukotohouse.jpeg',
      availability: {
        'wifi': true,
        'bedrooms': 3,
        'bathrooms': 2,
        'swimmingPool': false,
      },
      location: 'Bukoto, Kampala',
      price: '2,000,000',
      title: 'New York Park And Gardens',
      roomImages: [
        'assets/images/houses/rooms/livingroom2.jfif',
        'assets/images/houses/rooms/kitchen2.jfif',
        'assets/images/houses/rooms/bedroom2.jfif',
        'assets/images/houses/rooms/bathroom2.jfif',
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
      price: '3,000,000',
      title: 'Imperial Park And Gardens(The Sugarland Estate)',
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
      location: 'Munyonyo, Kampala',
      price: '2,000,000',
      title: 'Grandview Park & Gardens Phase 1 Extension',
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
      price: '3,000,000',
      title: 'West Park & Gardens Phase 1 Extension, Oleyo',
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
      price: '2,000,000',
      title: 'City Park & Gardens, Phase 2, Asejire',
      roomImages: [
        'assets/images/houses/rooms/livingroom1.jfif',
        'assets/images/houses/rooms/bathroom6.jfif',
        'assets/images/houses/rooms/swimmingpool3.jfif',
      ],
    ),
  ];
}
