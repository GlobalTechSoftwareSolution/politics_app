import 'package:flutter/material.dart';

mixin SearchMixin<T extends StatefulWidget> on State<T> {
  bool _isSearching = false;
  String _searchQuery = '';

  // Methods to be implemented by the implementing class
  void performSearch(String query);
  Widget buildSearchBar();
  Widget buildSearchResults();

  void toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
      }
    });
  }

  void updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
    performSearch(query);
  }

  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  Widget buildSearchAppBar(AppBar originalAppBar) {
    return AppBar(
      title: originalAppBar.title,
      backgroundColor: originalAppBar.backgroundColor,
      foregroundColor: originalAppBar.foregroundColor,
      elevation: originalAppBar.elevation,
      actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: toggleSearch),
        if (originalAppBar.actions != null)
          ...originalAppBar.actions!.where(
            (action) =>
                action is! IconButton ||
                (action as IconButton).onPressed != toggleSearch,
          ),
      ],
    );
  }

  Widget buildSearchBody(Widget originalBody) {
    return Column(
      children: [
        if (_isSearching) buildSearchBar(),
        Expanded(child: originalBody),
      ],
    );
  }
}
