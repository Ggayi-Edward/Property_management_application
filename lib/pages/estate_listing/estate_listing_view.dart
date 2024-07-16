import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:propertysmart2/export/file_exports.dart';

class EstateCard extends StatelessWidget {
  final EstateModel estate;
  final double imageHeight;

  const EstateCard({
    super.key,
    required this.estate,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EstateDetailsView(estate: estate),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Image.asset(
                    estate.image,
                    fit: BoxFit.cover,
                    width: constraints.maxWidth,
                    height: imageHeight,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    estate.location,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    estate.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('\$${estate.price.toString()}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EstateListingView extends StatefulWidget {
  const EstateListingView({super.key});

  @override
  _EstateListingViewState createState() => _EstateListingViewState();
}

class _EstateListingViewState extends State<EstateListingView> {
  final TextEditingController _searchController = TextEditingController();
  final int gridCrossAxisCount = 2;
  final double cardImageHeight = 150;
  List<EstateModel> _filteredEstates = [];
  List<EstateModel> _estates = []; // Initialize with your estates data

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterEstates);
  }

  void _filterEstates() {
    setState(() {
      _filteredEstates = _estates
          .where((estate) =>
      estate.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          estate.location.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EstateListingViewModel>.reactive(
      viewModelBuilder: () => EstateListingViewModel(),
      onModelReady: (viewModel) {
        _estates = viewModel.estates;
        _filteredEstates = _estates;
      },
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true, // Show the back button
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF304FFE), Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Text(
                'PropertySmart',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          drawer: const CustomDrawer(), // Add the CustomDrawer here
          body: _buildEstateGrid(),
        );
      },
    );
  }

  Widget _buildEstateGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MasonryGridView.count(
        crossAxisCount: gridCrossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: _filteredEstates.length,
        itemBuilder: (context, index) {
          return EstateCard(
            estate: _filteredEstates[index],
            imageHeight: cardImageHeight,
          );
        },
      ),
    );
  }
}
