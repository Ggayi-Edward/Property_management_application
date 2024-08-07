import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Import this to use kIsWeb
import 'package:propertysmart2/export/file_exports.dart';
import 'package:stacked/stacked.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EstateDetailsView extends StatefulWidget {
  final EstateModel estate;
  const EstateDetailsView({super.key, required this.estate});

  @override
  _EstateDetailsViewState createState() => _EstateDetailsViewState();
}

class _EstateDetailsViewState extends State<EstateDetailsView> {
  int _currentRoomIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EstateDetailsViewModel>.nonReactive(
      viewModelBuilder: () => EstateDetailsViewModel(),
      builder: (context, viewModel, _) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // SliverAppBar with title and subtitle
              SliverAppBar(
                expandedHeight: 150.0,
                pinned: true,
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    var isCollapsed = constraints.maxHeight <= kToolbarHeight + 20;
                    return FlexibleSpaceBar(
                      centerTitle: true,
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'PropertySmart',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!isCollapsed)
                            Text(
                              'House Details',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                      background: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Estate details image
              SliverToBoxAdapter(
                child: ClipPath(
                  clipper: UpwardArcClipper(),
                  child: widget.estate.image.isNotEmpty
                      ? Image.network(
                          widget.estate.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.3,
                          errorBuilder: (context, error, stackTrace) {
                            print('Image load error: $error');
                            return const Center(child: Icon(Icons.image_not_supported));
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: double.infinity,
                          child: const Center(child: Icon(Icons.image_not_supported)),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.estate.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.locationDot,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.estate.location,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.dollarSign,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Starting Price: \$${widget.estate.price}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.bed,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Bedrooms: ${widget.estate.availability?['bedrooms'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.bath,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Bathrooms: ${widget.estate.availability?['bathrooms'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.wifi,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Wifi: ${widget.estate.availability?['wifi'] == true ? 'Yes' : 'No'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.personSwimming,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Swimming Pool: ${widget.estate.availability?['swimmingPool'] == true ? 'Yes' : 'No'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: CarouselSlider.builder(
                    itemCount: widget.estate.roomImages?.length ?? 0,
                    itemBuilder: (context, index, realIndex) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullImageView(
                                imageUrl: widget.estate.roomImages![index],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.network(
                              widget.estate.roomImages![index],
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: 200,
                              errorBuilder: (context, error, stackTrace) {
                                print('Carousel image load error: $error');
                                return const Center(child: Icon(Icons.image_not_supported));
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentRoomIndex = index;
                        });
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.estate.roomImages?.length ?? 0,
                    (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentRoomIndex = index;
                        });
                      },
                      child: Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentRoomIndex == index
                              ? const Color.fromRGBO(0, 0, 0, 0.9)
                              : const Color.fromRGBO(0, 0, 0, 0.4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your checkout logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Define FullImageView
class FullImageView extends StatelessWidget {
  final String imageUrl;

  const FullImageView({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Image View'),
      ),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}

// Define UpwardArcClipper
class UpwardArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.arcToPoint(Offset(size.width / 2, size.height / 2),
        radius: Radius.circular(20));
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
