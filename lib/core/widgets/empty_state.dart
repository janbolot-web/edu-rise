import 'package:flutter/widgets.dart';

class EmptyState extends StatelessWidget {
  final String message;
  const EmptyState({super.key, this.message = 'Нет данных'});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}
