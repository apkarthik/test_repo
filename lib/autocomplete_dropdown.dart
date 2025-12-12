import 'dart:async';
import 'package:flutter/material.dart';

/// Minimal, reusable autocomplete dropdown that shows suggestions
/// when the user types 3 or more characters.
///
/// Usage:
/// AutocompleteDropdown(
///   hintText: 'Search...',
///   fetchSuggestions: (q) async => yourAsyncLookup(q),
///   onSelected: (s) => print('selected: $s'),
/// )
class AutocompleteDropdown extends StatefulWidget {
  final Future<List<String>> Function(String) fetchSuggestions;
  final void Function(String)? onSelected;
  final String? hintText;

  const AutocompleteDropdown({
    Key? key,
    required this.fetchSuggestions,
    this.onSelected,
    this.hintText,
  }) : super(key: key);

  @override
  _AutocompleteDropdownState createState() => _AutocompleteDropdownState();
}

class _AutocompleteDropdownState extends State<AutocompleteDropdown> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _textFieldKey = GlobalKey();

  OverlayEntry? _overlayEntry;
  List<String> _suggestions = [];
  Timer? _debounce;

  // Controls minimum chars to start suggesting
  static const int _minChars = 3;
  // Debounce duration to avoid too many calls
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    } else {
      // If focused and current text qualifies, show overlay
      if (_controller.text.trim().length >= _minChars && _suggestions.isNotEmpty) {
        _showOverlay();
      }
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    setState(() {}); // Trigger rebuild to update clear button visibility
    _debounce = Timer(_debounceDuration, () async {
      final q = value.trim();
      if (q.length >= _minChars) {
        final results = await widget.fetchSuggestions(q);
        if (mounted) {
          setState(() => _suggestions = results);
          if (_suggestions.isNotEmpty && _focusNode.hasFocus) {
            _showOverlay();
          } else {
            _removeOverlay();
          }
        }
      } else {
        setState(() => _suggestions = []);
        _removeOverlay();
      }
    });
  }

  void _showOverlay() {
    _overlayEntry ??= _createOverlayEntry();
    Overlay.of(context)?.insert(_overlayEntry!);
    // If overlay already exists, rebuild it to update suggestions
    _overlayEntry!.markNeedsBuild();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(builder: (context) {
      // Find width of the field using the stored key
      RenderBox? renderBox = _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
      final width = renderBox?.size.width ?? 300.0;
      return Positioned(
        // Use CompositedTransformFollower for accurate placement
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0.0, 8.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(6.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 240,
                minWidth: width,
                maxWidth: width,
              ),
              child: _suggestions.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final s = _suggestions[index];
                        return ListTile(
                          title: Text(s),
                          onTap: () {
                            _controller.text = s;
                            _controller.selection = TextSelection.collapsed(offset: s.length);
                            widget.onSelected?.call(s);
                            _removeOverlay();
                            _focusNode.unfocus();
                          },
                        );
                      },
                    ),
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        key: _textFieldKey,
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Type to search...',
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    _onChanged('');
                  },
                )
              : null,
        ),
        onChanged: _onChanged,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _removeOverlay(),
      ),
    );
  }
}

/// Example usage: a small page demonstrating the widget
class AutocompleteExamplePage extends StatelessWidget {
  const AutocompleteExamplePage({Key? key}) : super(key: key);

  // Example local data source (could be remote)
  final List<String> _allItems = const [
    'apple', 'apricot', 'banana', 'blackberry', 'blueberry', 'cantaloupe', 'cherry',
    'date', 'dragonfruit', 'fig', 'grape', 'grapefruit', 'kiwi', 'lemon', 'lime',
    'mango', 'nectarine', 'orange', 'papaya', 'peach', 'pear', 'pineapple', 'plum',
    'raspberry', 'strawberry', 'watermelon'
  ];

  Future<List<String>> _fetchSuggestions(String query) async {
    // simulate network latency
    await Future.delayed(const Duration(milliseconds: 200));
    final q = query.toLowerCase();
    return _allItems.where((s) => s.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Autocomplete dropdown example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AutocompleteDropdown(
              hintText: 'Type 3+ chars to search fruits...',
              fetchSuggestions: _fetchSuggestions,
              onSelected: (s) => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Selected: $s'))),
            ),
            const SizedBox(height: 24),
            const Text('Other content below...'),
          ],
        ),
      ),
    );
  }
}
