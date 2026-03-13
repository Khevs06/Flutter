import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/ai_provider.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Load some initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().searchRecipes('chicken');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<RecipeProvider>().searchRecipes(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReciFinder', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.chat_bubble_outline),
        tooltip: 'Ask the AI assistant',
        onPressed: () => _showAiDialog(context),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.primary.withAlpha(20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for meals...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          Consumer<RecipeProvider>(
            builder: (context, provider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cuisine Area:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: provider.selectedArea,
                          icon: const Icon(Icons.arrow_drop_down),
                          isDense: true,
                          items: <String>[
                            'All', 'Filipino', 'American', 'British', 'Canadian', 
                            'Chinese', 'French', 'Indian', 'Italian', 'Japanese', 'Mexican'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null && newValue != provider.selectedArea) {
                               // Clear search box to avoid confusion
                               _searchController.clear();
                               context.read<RecipeProvider>().filterByArea(newValue);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // always show ingredient/category chips below the area selector
              _buildIngredientChips(context, provider),
            ],
          );
        },
          ),
          Expanded(
            child: Consumer<RecipeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _performSearch,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (provider.searchResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No recipes found.\nTry a different search term.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _performSearch();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: provider.searchResults.length,
                    itemBuilder: (context, index) {
                      final meal = provider.searchResults[index];
                      return RecipeCard(
                        meal: meal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailScreen(mealId: meal.idMeal),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientChips(BuildContext context, RecipeProvider provider) {
    // a basic hardcoded list of common ingredient filters
    final filters = <Map<String, dynamic>>[
      {'label': 'Chicken', 'query': 'chicken', 'isIngredient': true},
      {'label': 'Pork', 'query': 'pork', 'isIngredient': true},
      {'label': 'Beef', 'query': 'beef', 'isIngredient': true},
      {'label': 'Seafood', 'query': 'Seafood', 'isIngredient': false},
      {'label': 'Vegetables', 'query': 'eggplant', 'isIngredient': true},
    ];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final f = filters[index];
          return _buildChip(
            context,
            provider,
            f['label'] as String,
            f['query'] as String,
            f['isIngredient'] as bool,
          );
        },
      ),
    );
  }

  void _showAiDialog(BuildContext context) {
    final TextEditingController _aiController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recipe Assistant'),
          content: Consumer<AiProvider>(
            builder: (context, ai, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _aiController,
                    decoration: const InputDecoration(
                      hintText: 'Ask something like "Suggest a pasta recipe"',
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) {
                      if (_aiController.text.trim().isNotEmpty) {
                        ai.ask(_aiController.text.trim());
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  if (ai.isLoading)
                    const CircularProgressIndicator()
                  else if (ai.response != null)
                    SingleChildScrollView(
                      child: Text(ai.response!),
                    )
                  else if (ai.error != null)
                    Text(
                      ai.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Provider.of<AiProvider>(context, listen: false).clear();
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChip(
    BuildContext context, 
    RecipeProvider provider, 
    String label, 
    String endpointQuery, 
    bool isIngredient
  ) {
    final isSelected = provider.selectedCategory == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          provider.filterByCategory(label, endpointQuery, isIngredient);
        } else {
          // If deselected, fetch the full Filipino area again 
          provider.filterByArea('Filipino');
        }
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected 
          ? Theme.of(context).colorScheme.onPrimaryContainer 
          : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
