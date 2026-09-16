import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_footer.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../data/repositories/discovery_repository.dart';
import '../../domain/models/place_activity.dart';
import '../widgets/place_activity_card.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({
    super.key,
    this.repository = const DiscoveryRepository(),
  });

  final DiscoveryRepository repository;

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

// Mapeia o valor técnico salvo/usado internamente (sem acento, sem espaço,
// igual ao nome da pasta em assets/Lugares/ e ao campo `cidade` do Firestore)
// para o nome bonito exibido pro usuário.
const Map<String, String> _cityDisplayNames = {
  'Americana': 'Americana',
  'Campinas': 'Campinas',
  'Limeira': 'Limeira',
  'SantaBarbara': 'Santa Bárbara',
  'Sumare': 'Sumaré',
};

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  List<PlaceActivity> _places = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategory;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_updateResults);
    _loadPlaces();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_updateResults)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadPlaces() async {
    try {
      final places = await widget.repository.getPlaces();

      if (!mounted) return;

      setState(() {
        _places = places;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      debugPrint('Erro ao carregar locais: $e');

      setState(() {
        _isLoading = false;
        _errorMessage = 'Não foi possível carregar os locais.';
      });
    }
  }

  void _updateResults() {
    setState(() {});
  }

  List<PlaceActivity> get _filteredPlaces {
    final query = _searchController.text.trim().toLowerCase();

    return _places.where((place) {
      final matchesQuery =
          query.isEmpty ||
          place.name.toLowerCase().contains(query) ||
          place.description.toLowerCase().contains(query) ||
          place.category.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory == null ||
          place.category == _selectedCategory;

      final matchesCity =
          _selectedCity == null ||
          place.city == _selectedCity;

      return matchesQuery && matchesCategory && matchesCity;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  24,
                  16,
                  8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSearchBar(
                      hintText: 'Pesquisar lugares',
                      controller: _searchController,
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildFilters(),

                    const SizedBox(height: 18),

                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_errorMessage != null)
                      _buildErrorState()
                    else ...[
                      ..._filteredPlaces.map(
                        (place) => PlaceActivityCard(
                          place: place,
                        ),
                      ),

                      if (_filteredPlaces.isEmpty)
                        _buildEmptyState(),
                    ],
                  ],
                ),
              ),
            ),

            const CustomFooter(
              currentIndex: 1,
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // FILTROS
  // ================================================================

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildAddFilterButton(),

          if (_selectedCategory != null) ...[
            const SizedBox(width: 8),
            _buildActiveFilterChip(
              label: _selectedCategory!,
              onRemove: () {
                setState(() {
                  _selectedCategory = null;
                });
              },
            ),
          ],

          if (_selectedCity != null) ...[
            const SizedBox(width: 8),
            _buildActiveFilterChip(
              label: _cityDisplayNames[_selectedCity] ?? _selectedCity!,
              onRemove: () {
                setState(() {
                  _selectedCity = null;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddFilterButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: _openFilterMenu,
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Text(
            'Filtrar',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF033B63),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF033B63),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF033B63),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // MENU DE FILTROS (BOTTOM SHEET)
  // ================================================================

  Future<void> _openFilterMenu() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 8,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Categorias',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF033B63),
                      ),
                    ),
                  ),

                  ListTile(
                    title: const Text(
                      'Cafeterias',
                      style: TextStyle(fontFamily: 'Raleway'),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Cafeterias';
                      });
                      Navigator.pop(context);
                    },
                  ),

                  ListTile(
                    title: const Text(
                      'Lazer',
                      style: TextStyle(fontFamily: 'Raleway'),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Lazer';
                      });
                      Navigator.pop(context);
                    },
                  ),

                  ListTile(
                    title: const Text(
                      'Restaurantes',
                      style: TextStyle(fontFamily: 'Raleway'),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Restaurantes';
                      });
                      Navigator.pop(context);
                    },
                  ),

                  const Divider(),

                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Cidade',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF033B63),
                      ),
                    ),
                  ),

                  ListTile(
                    title: const Text(
                      'Americana',
                      style: TextStyle(fontFamily: 'Raleway'),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCity = 'Americana';
                      });
                      Navigator.pop(context);
                    },
                  ),

                  ListTile(
                    title: const Text(
                      'Campinas',
                      style: TextStyle(fontFamily: 'Raleway'),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCity = 'Campinas';
                      });
                      Navigator.pop(context);
                    },
                  ),

                  ListTile(
                    title: const Text(
                      'Limeira',
                      style: TextStyle(fontFamily: 'Raleway'),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCity = 'Limeira';
                      });
                      Navigator.pop(context);
                    },
                  ),

                  ListTile(
                    title: const Text(
                      'Santa Bárbara',
                      style: TextStyle(fontFamily: 'Raleway'),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCity = 'SantaBarbara';
                      });
                      Navigator.pop(context);
                    },
                  ),

                  ListTile(
                    title: const Text(
                      'Sumaré',
                      style: TextStyle(fontFamily: 'Raleway'),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCity = 'Sumare';
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // ESTADOS VAZIOS E ERRO
  // ================================================================

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'Nenhum local encontrado.',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: 14,
            color: Color(0xFF033B63),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(
            fontFamily: 'Raleway',
            fontSize: 14,
            color: Color(0xFF033B63),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}