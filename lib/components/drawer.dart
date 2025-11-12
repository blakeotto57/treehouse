import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:treehouse/models/category_model.dart';
import 'package:treehouse/pages/explore_page.dart';
import 'package:treehouse/pages/messages_page.dart';
import 'package:treehouse/pages/user_profile.dart';
import 'package:treehouse/models/user_post_page.dart';
import 'package:treehouse/theme/theme.dart';
import 'package:treehouse/theme/drawer_width_provider.dart';
import 'package:treehouse/router/app_router.dart';

Widget customDrawer(BuildContext context) {
  return Consumer<DrawerWidthProvider>(
    builder: (context, widthProvider, child) {
      return Drawer(
        elevation: 0,
        backgroundColor: Colors.transparent,
        width: widthProvider.drawerWidth,
        child: _TriagedDrawerContent(),
      );
    },
  );
}

class _TriagedDrawerContent extends StatefulWidget {
  @override
  State<_TriagedDrawerContent> createState() => _TriagedDrawerContentState();
}

class _TriagedDrawerContentState extends State<_TriagedDrawerContent> {
  // Map to track which categories are expanded
  final Map<String, bool> _expandedCategories = {};
  String? _selectedPostId;
  String? _selectedCategory;

  // Firestore collection mappings
  final Map<String, String> _categoryCollections = {
    'Personal Care': 'personal_care_posts',
    'Food': 'food_posts',
    'Photography': 'photography_posts',
    'Academics': 'academic_posts',
    'Technical': 'technical_posts',
    'Errands & Moving': 'errands_moving_posts',
    'Pet Care': 'pet_care_posts',
    'Cleaning': 'cleaning_posts',
  };

  @override
  void initState() {
    super.initState();
    // Initialize all categories as collapsed
    for (var category in CategoryModel.getCategories()) {
      final categoryName = _getCategoryName(category);
      _expandedCategories[categoryName] = false;
    }
  }

  String _getCategoryName(CategoryModel category) {
    // Map categories by their known names in order
    final knownCategories = [
      'Personal Care', 'Food', 'Photography', 'Academics', 
      'Technical', 'Errands & Moving', 'Pet Care', 'Cleaning'
    ];
    
    // Get the index of this category in the list
    final categories = CategoryModel.getCategories();
    final index = categories.indexOf(category);
    
    if (index >= 0 && index < knownCategories.length) {
      return knownCategories[index];
    }
    
    // Fallback: try to extract from Text widget
    try {
      final textData = category.name.data;
      if (textData != null && textData.isNotEmpty) {
        return textData;
      }
    } catch (e) {
      // Ignore
    }
    
    return 'Unknown';
  }

  void _toggleCategory(String categoryName) {
    setState(() {
      _expandedCategories[categoryName] = !(_expandedCategories[categoryName] ?? false);
    });
  }

  void _selectPost(String category, String postId, String firestoreCollection) {
    setState(() {
      _selectedCategory = category;
      _selectedPostId = postId;
    });
    // Navigate to the post page using go_router
    if (firestoreCollection == 'bulletin_posts') {
      context.go('/post/$postId');
    } else {
      final categoryRoute = AppRouter.getCategoryRouteName(firestoreCollection);
      context.go('/forum/$categoryRoute/$postId');
    }
  }

  Color _getCategoryColor(String categoryName) {
    final categories = CategoryModel.getCategories();
    for (var cat in categories) {
      if (_getCategoryName(cat) == categoryName) {
        return cat.boxColor;
      }
    }
    return AppColors.primaryGreen;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 16,
                  color: isDark 
                      ? AppColors.textSecondaryDark 
                      : AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 6),
                Text(
                  'CATEGORIES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark 
                        ? AppColors.textSecondaryDark 
                        : AppColors.textSecondaryLight,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Expandable Categories List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              itemCount: CategoryModel.getCategories().length,
              itemBuilder: (context, index) {
                final category = CategoryModel.getCategories()[index];
                final categoryName = _getCategoryName(category);
                final isExpanded = _expandedCategories[categoryName] ?? false;
                final firestoreCollection = _categoryCollections[categoryName] ?? '';
                final iconList = [
                  Icons.spa_rounded,
                  Icons.restaurant_rounded,
                  Icons.camera_alt_rounded,
                  Icons.menu_book_rounded,
                  Icons.build_rounded,
                  Icons.local_shipping_rounded,
                  Icons.pets_rounded,
                  Icons.cleaning_services_rounded,
                ];
                final iconColor = category.boxColor;

                return _ExpandableCategorySection(
                  categoryName: categoryName,
                  icon: iconList.length > index ? iconList[index] : category.icon,
                  iconColor: iconColor,
                  isExpanded: isExpanded,
                  isDark: isDark,
                  firestoreCollection: firestoreCollection,
                  selectedPostId: _selectedPostId,
                  selectedCategory: _selectedCategory,
                  onToggle: () => _toggleCategory(categoryName),
                  onPostSelected: (postId) => _selectPost(
                    categoryName,
                    postId,
                    firestoreCollection,
                  ),
                  onCategoryTap: () {
                    // Navigate to category page without closing drawer
                    category.onTap(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableCategorySection extends StatelessWidget {
  final String categoryName;
  final IconData icon;
  final Color iconColor;
  final bool isExpanded;
  final bool isDark;
  final String firestoreCollection;
  final String? selectedPostId;
  final String? selectedCategory;
  final VoidCallback onToggle;
  final Function(String) onPostSelected;
  final VoidCallback onCategoryTap;

  const _ExpandableCategorySection({
    required this.categoryName,
    required this.icon,
    required this.iconColor,
    required this.isExpanded,
    required this.isDark,
    required this.firestoreCollection,
    required this.selectedPostId,
    required this.selectedCategory,
    required this.onToggle,
    required this.onPostSelected,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Column(
        children: [
          // Category Header - Clickable to navigate to category page
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onCategoryTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isExpanded
                      ? (isDark 
                          ? AppColors.cardDark.withOpacity(0.5)
                          : AppColors.cardLight.withOpacity(0.5))
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    // Chevron Icon (for visual indication of expandable state)
                    AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        size: 18,
                        color: isDark 
                            ? AppColors.textSecondaryDark 
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Category Icon
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(
                        icon,
                        size: 14,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Category Name
                    Expanded(
                      child: Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark 
                              ? AppColors.textPrimaryDark 
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Expanded Posts List with Animation
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: firestoreCollection.isNotEmpty
                ? StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(firestoreCollection)
                        .orderBy('timestamp', descending: true)
                        .limit(10) // Limit to 10 most recent posts
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 32, top: 6, bottom: 6),
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 32, top: 6, bottom: 6),
                          child: Text(
                            'No posts yet',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark 
                                  ? AppColors.textSecondaryDark 
                                  : AppColors.textSecondaryLight,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      }

                      final posts = snapshot.data!.docs;

                      return Column(
                        children: [
                          ...posts.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final postId = doc.id;
                            final title = data['title'] ?? 'Untitled';
                            final comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);
                            final commentCount = comments.length;
                            final isSelected = selectedPostId == postId && selectedCategory == categoryName;

                            return _PostListItem(
                              title: title.toString(),
                              postId: postId,
                              commentCount: commentCount,
                              isSelected: isSelected,
                              isDark: isDark,
                              iconColor: iconColor,
                              onTap: () => onPostSelected(postId),
                            );
                          }).toList(),
                          // View all link at the bottom
                          Padding(
                            padding: const EdgeInsets.only(left: 32, top: 2, bottom: 6),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onCategoryTap,
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.list_outlined,
                                        size: 12,
                                        color: iconColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'View all posts',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: iconColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Icon(
                                        Icons.chevron_right,
                                        size: 12,
                                        color: iconColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : const SizedBox.shrink(),
            crossFadeState: isExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _PostListItem extends StatelessWidget {
  final String title;
  final String postId;
  final int commentCount;
  final bool isSelected;
  final bool isDark;
  final Color iconColor;
  final VoidCallback onTap;

  const _PostListItem({
    required this.title,
    required this.postId,
    required this.commentCount,
    required this.isSelected,
    required this.isDark,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = title.length > 20 ? '${title.substring(0, 20)}...' : title;
    
    return Material(
      color: Colors.transparent,
          child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Semantics(
          button: true,
          selected: isSelected,
          label: '$displayTitle${commentCount > 0 ? ", $commentCount comments" : ""}',
          child: Container(
            margin: const EdgeInsets.only(left: 32, right: 6, top: 1, bottom: 1),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: isSelected
                  ? (isDark 
                      ? AppColors.primaryGreenDark.withOpacity(0.3)
                      : AppColors.primaryGreenLight.withOpacity(0.2))
                  : Colors.transparent,
              border: isSelected
                  ? Border.all(
                      color: iconColor.withOpacity(0.4),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Document Icon
                Icon(
                  Icons.description_outlined,
                  size: 14,
                  color: isSelected 
                      ? iconColor 
                      : (isDark 
                          ? AppColors.textSecondaryDark 
                          : AppColors.textSecondaryLight),
                ),
                const SizedBox(width: 8),
                // Post Title
                Expanded(
                  child: Text(
                    displayTitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? (isDark 
                              ? AppColors.primaryGreenLight 
                              : AppColors.primaryGreenDark)
                          : (isDark 
                              ? AppColors.textPrimaryDark 
                              : AppColors.textPrimaryLight),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                // Comment Count Badge
                if (commentCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? AppColors.cardDark 
                          : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark 
                            ? AppColors.borderDark.withOpacity(0.3)
                            : AppColors.borderLight.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      commentCount > 99 ? '99+' : commentCount.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark 
                            ? AppColors.textSecondaryDark 
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Legacy function for backward compatibility
Widget customDrawerContent(BuildContext context) {
  return _TriagedDrawerContent();
}
