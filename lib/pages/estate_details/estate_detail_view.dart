import 'package:flutter/material.dart';
import 'package:propertysmart2/export/file_exports.dart';
import 'package:propertysmart2/pages/estate_details/ContactAgentPage.dart';
import 'package:stacked/stacked.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class EstateDetailsView extends StatefulWidget {
  final EstateModel estate;
  const EstateDetailsView({Key? key, required this.estate}) : super(key: key);

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
          drawer:  CustomDrawer(), // Add the CustomDrawer here
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.4,
                flexibleSpace: FlexibleSpaceBar(
                  background: ClipPath(
                    clipper: UpwardArcClipper(),
                    child: Image.asset(
                      widget.estate.image, // Replace with Image.asset
                      fit: BoxFit.cover,
                    ),
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
                              'Bedrooms: ${widget.estate.availability['bedrooms']}',
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
                              'Bathrooms: ${widget.estate.availability['bathrooms']}',
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
                              'Wifi: ${widget.estate.availability['wifi'] ? 'Yes' : 'No'}',
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
                              'Swimming Pool: ${widget.estate.availability['swimmingPool'] ? 'Yes' : 'No'}',
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
                  height: 200, // Height for slider images
                  child: CarouselSlider.builder(
                    itemCount: widget.estate.roomImages.length,
                    itemBuilder: (context, index, realIndex) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullImageView(
                                imageUrl: widget.estate.roomImages[index],
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
                            child: Image.asset(
                              widget.estate.roomImages[index], // Replace with Image.asset
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: 200,
                              errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.error)),
                            ),
                          ),
                        ),
                      );
                    },
                    options: CarouselOptions(
                      height: 200,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: true,
                      viewportFraction: 0.8,
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
                    widget.estate.roomImages.length,
                        (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentRoomIndex == index ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.lightBlueAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Checkout',
                              style: TextStyle(
                                color: Colors.white, // Font color
                                fontWeight: FontWeight.w500,
                                fontSize: 18, // Font size
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ContactAgentPage()),
                            );
                          },
                          child: const Text(
                            'Contact Agent',
                            style: TextStyle(color:Colors.green),),
                        ),
                      ],
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

class UpwardArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    var controlPoint = Offset(size.width / 2, size.height);
    var endPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class FullImageView extends StatelessWidget {
  final String imageUrl;
  const FullImageView({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.asset(
          imageUrl, // Replace with Image.asset
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
