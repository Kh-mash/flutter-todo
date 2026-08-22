import 'package:flutter/material.dart';

class QuickAddField extends StatefulWidget {
  const QuickAddField({super.key, required this.onSubmitted});
  final ValueChanged<String> onSubmitted;

  @override
  State<QuickAddField> createState() => _QuickAddFieldState();
}

class _QuickAddFieldState extends State<QuickAddField> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _hasText = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Add a task',
          prefixIcon: const Icon(Icons.add),
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    widget.onSubmitted(_controller.text);
                    _controller.clear();
                  },
                )
              : null,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            widget.onSubmitted(value);
            _controller.clear();
          }
        },
      ),
    );
  }
}
