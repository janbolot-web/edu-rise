import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';

class MarketplaceSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final String? initialValue;

  const MarketplaceSearchBar({
    super.key,
    required this.onSearchChanged,
    this.initialValue,
  });

  @override
  State<MarketplaceSearchBar> createState() => _MarketplaceSearchBarState();
}

class _MarketplaceSearchBarState extends State<MarketplaceSearchBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appPrimary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Поиск материалов, авторов, предметов...',
          hintStyle: GoogleFonts.montserrat(
            color: appSecondary.withOpacity(0.6),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: appSecondary.withOpacity(0.6),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _controller.clear();
                    widget.onSearchChanged('');
                  },
                  icon: Icon(
                    Icons.clear,
                    color: appSecondary.withOpacity(0.6),
                  ),
                )
              : IconButton(
                  onPressed: () {
                    // TODO: Open advanced search
                  },
                  icon: Icon(
                    Icons.tune,
                    color: appSecondary.withOpacity(0.6),
                  ),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        style: GoogleFonts.montserrat(
          fontSize: 16,
          color: appPrimary,
        ),
      ),
    );
  }
}
