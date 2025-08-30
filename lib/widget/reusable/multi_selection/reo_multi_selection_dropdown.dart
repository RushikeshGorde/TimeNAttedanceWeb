import 'package:flutter/material.dart';

class MultiSelectDropdown<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T) getDisplayName;
  final String Function(T) getItemId;
  final Function(List<T>) onSelectionChanged;
  final bool selectAll;
  final Function(bool) onSelectAllChanged;
  final double? height;
  final String? hintText;

  const MultiSelectDropdown({
    Key? key,
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.getDisplayName,
    required this.getItemId,
    required this.onSelectionChanged,
    required this.selectAll,
    required this.onSelectAllChanged,
    this.height = 400,
    this.hintText,
  }) : super(key: key);

  @override
  State<MultiSelectDropdown<T>> createState() => _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T> extends State<MultiSelectDropdown<T>> {
  void _openSelectionDialog() {
    showDialog<List<T>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _MultiSelectDialog<T>(
          title: widget.title,
          items: widget.items,
          selectedItems: widget.selectedItems,
          getDisplayName: widget.getDisplayName,
          getItemId: widget.getItemId,
          selectAll: widget.selectAll,
          height: widget.height,
        );
      },
    ).then((result) {
      if (result != null) {
        final isAllSelected = result.length == widget.items.length;
        widget.onSelectionChanged(result);
        widget.onSelectAllChanged(isAllSelected);
      }
    });
  }

  String _getDisplayText() {
    if (widget.selectAll && widget.selectedItems.length == widget.items.length) {
      return 'All ${widget.title} Selected (${widget.items.length})';
    } else if (widget.selectedItems.isEmpty) {
      return widget.hintText ?? 'Select ${widget.title}';
    } else if (widget.selectedItems.length == 1) {
      return widget.getDisplayName(widget.selectedItems.first);
    } else {
      return '${widget.selectedItems.length} ${widget.title} Selected';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openSelectionDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _getDisplayText(),
                style: TextStyle(
                  fontSize: 13,
                  color: widget.selectedItems.isEmpty && !widget.selectAll
                      ? Colors.grey[600]
                      : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _MultiSelectDialog<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T) getDisplayName;
  final String Function(T) getItemId;
  final bool selectAll;
  final double? height;

  const _MultiSelectDialog({
    Key? key,
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.getDisplayName,
    required this.getItemId,
    required this.selectAll,
    this.height,
  }) : super(key: key);

  @override
  State<_MultiSelectDialog<T>> createState() => _MultiSelectDialogState<T>();
}

class _MultiSelectDialogState<T> extends State<_MultiSelectDialog<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];
  List<T> _tempSelectedItems = [];
  bool _tempSelectAll = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _tempSelectedItems = List.from(widget.selectedItems);
    _tempSelectAll = widget.selectAll;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => widget
                .getDisplayName(item)
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _tempSelectAll = value ?? false;
      if (_tempSelectAll) {
        _tempSelectedItems = List.from(widget.items);
      } else {
        _tempSelectedItems.clear();
      }
    });
  }

  void _toggleItemSelection(T item, bool? value) {
    setState(() {
      if (value == true) {
        if (!_tempSelectedItems.any((selectedItem) =>
            widget.getItemId(selectedItem) == widget.getItemId(item))) {
          _tempSelectedItems.add(item);
        }
      } else {
        _tempSelectedItems.removeWhere((selectedItem) =>
            widget.getItemId(selectedItem) == widget.getItemId(item));
      }
      _tempSelectAll = _tempSelectedItems.length == widget.items.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select ${widget.title}'),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: double.maxFinite,
        height: widget.height ?? 400,
        child: Column(
          children: [
            // Search field
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ),

            // Selected items count and controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Selected: ${_tempSelectedItems.length} of ${widget.items.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _toggleSelectAll(true),
                    child: const Text('Select All', style: TextStyle(fontSize: 11)),
                  ),
                  TextButton(
                    onPressed: () => _toggleSelectAll(false),
                    child: const Text('Clear All', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),

            // Select All checkbox
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _tempSelectAll,
                    onChanged: _toggleSelectAll,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Text(
                    'Select All',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            // Items list
            Expanded(
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = _tempSelectedItems.any(
                    (selectedItem) =>
                        widget.getItemId(selectedItem) == widget.getItemId(item),
                  );

                  return CheckboxListTile(
                    title: Text(
                      widget.getDisplayName(item),
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: isSelected,
                    onChanged: (value) => _toggleItemSelection(item, value),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  );
                },
              ),
            ),

            // Selected items preview (scrollable)
            if (_tempSelectedItems.isNotEmpty)
              Container(
                height: 80,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Items:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children: _tempSelectedItems.map((item) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.getDisplayName(item),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(List<T>.from(_tempSelectedItems));
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}