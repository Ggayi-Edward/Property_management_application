import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:propertysmart2/export/file_exports.dart';


class EstateCard extends StatelessWidget {
  final EstateModel estate;
  final double imageHeight;

  const EstateCard({
    Key? key,
    required this.estate,
    required this.imageHeight,
  }) : super(key: key);

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
  const EstateListingView({Key? key}) : super(key: key);

  @override
  _EstateListingViewState createState() => _EstateListingViewState();
}

class _EstateListingViewState extends State<EstateListingView> {
  final TextEditingController _searchController = TextEditingController();
  final int gridCrossAxisCount = 2;
  final double cardImageHeight = 150;
  List<EstateModel> _filteredEstates = [];
  List<EstateModel> _estates = [];
  EstateData estateData = EstateData(); // Initialize EstateData

  String? _selectedPriceRange;
  int? _selectedBedrooms;
  int? _selectedBathrooms;
  bool? _selectedSwimmingPool;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterEstates);
  }

  void _filterEstates() {
    setState(() {
      _filteredEstates = estateData.filterEstates(
        priceRange: _selectedPriceRange,
        bedrooms: _selectedBedrooms,
        bathrooms: _selectedBathrooms,
        swimmingPool: _selectedSwimmingPool,
      ).where((estate) =>
      estate.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          estate.location.toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    });
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _selectedPriceRange = filters['priceRange'];
      _selectedBedrooms = filters['bedrooms'];
      _selectedBathrooms = filters['bathrooms'];
      _selectedSwimmingPool = filters['swimmingPool'];

      _filteredEstates = estateData.filterEstates(
        priceRange: _selectedPriceRange,
        bedrooms: _selectedBedrooms,
        bathrooms: _selectedBathrooms,
        swimmingPool: _selectedSwimmingPool,
      ).where((estate) =>
      estate.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          estate.location.toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ViewModelBuilder<EstateListingViewModel>.reactive(
      viewModelBuilder: () => EstateListingViewModel(),
      onViewModelReady: (viewModel) {
        _estates = viewModel.estates;
        _filteredEstates = _estates;
      },
      builder: (context, viewModel, child) {
        return Scaffold(
          drawer: CustomDrawer(
            onFilterApplied: _applyFilters,
            showFilters: true, // Show filters only on EstateListingView
          ),
          body: CustomScrollView(
            slivers: [
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
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!isCollapsed)
                            Text(
                              'Property Listing',
                              style: theme.textTheme.bodyMedium?.copyWith(
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
              SliverFillRemaining(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by location...',
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16, // Change font size here
                            ),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF0D47A1)),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterEstates();
                              },
                            )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) {
                            _filterEstates();
                          },
                        ),
                      ),
                    ),
                    Expanded(
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
