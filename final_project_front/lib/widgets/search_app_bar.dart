import 'package:flutter/material.dart';

class SearchAppBar extends StatefulWidget {
  const SearchAppBar({
    super.key,
    required this.hintLabel,
    required this.onSubmitted,
    this.clearSearch,
  });

  final String hintLabel;
  final Function(String) onSubmitted;
  final Function(String)? clearSearch;

  @override
  State<StatefulWidget> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  final TextEditingController _controller = TextEditingController();

  void _clearSearch() {
    _controller.clear();
    widget.clearSearch?.call(''); // Invoke the clear search callback
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 50),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 40,
        padding: const EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hintLabel,
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            icon: const Icon(Icons.search, size: 18),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearSearch,
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() => _controller.text = value);
          },
          onSubmitted: widget.onSubmitted,
        ),
      ),
    );
  }
}
