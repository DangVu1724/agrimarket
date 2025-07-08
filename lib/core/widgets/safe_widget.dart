import 'package:flutter/material.dart';

class SafeWidget extends StatelessWidget {
  final Widget child;
  final Widget Function(String error)? errorBuilder;
  final String? errorMessage;

  const SafeWidget({super.key, required this.child, this.errorBuilder, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(errorBuilder: errorBuilder, child: child);
  }
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(String error)? errorBuilder;

  const ErrorBoundary({super.key, required this.child, this.errorBuilder});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  String? _error;

  @override
  void initState() {
    super.initState();
    // Set up error handling for renderObject errors
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('renderObject')) {
        setState(() {
          _error = 'Lỗi hiển thị: ${details.exception}';
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ??
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Lỗi hiển thị', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(fontSize: 14), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                    });
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
    }

    return widget.child;
  }
}
