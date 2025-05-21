import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../models/recipe.dart';
import '../widgets/custom_app_bar.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Quick', 'Popular', 'New'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomAppBar(title: 'Search: ${widget.query}'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterChips(),
                  const SizedBox(height: 16),
                  _buildSortButton(),
                ],
              ),
            ),
          ),
          Consumer<RecipeProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (provider.recipes.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recipes found',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _SearchResultCard(
                      recipe: provider.recipes[index],
                    ),
                    childCount: provider.recipes.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = filter == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortButton() {
    return OutlinedButton.icon(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => _buildSortOptions(),
        );
      },
      icon: const Icon(Icons.sort),
      label: const Text('Sort by'),
    );
  }

  Widget _buildSortOptions() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.trending_up),
            title: const Text('Most Popular'),
            onTap: () {
              // Sort by popularity
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Cooking Time'),
            onTap: () {
              // Sort by cooking time
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Rating'),
            onTap: () {
              // Sort by rating
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Recipe recipe;

  const _SearchResultCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navigate to recipe details
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Placeholder for recipe image
                  Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant, size: 48),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Recipe info
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.timer, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.cookingTime} min',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              recipe.rating?.toStringAsFixed(1) ?? '0.0',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 