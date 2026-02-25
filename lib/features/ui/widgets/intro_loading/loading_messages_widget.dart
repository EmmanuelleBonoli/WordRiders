import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LoadingMessagesWidget extends StatefulWidget {
  const LoadingMessagesWidget({super.key});

  @override
  State<LoadingMessagesWidget> createState() => _LoadingMessagesWidgetState();
}

class _LoadingMessagesWidgetState extends State<LoadingMessagesWidget> {
  late List<String> _messages;
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messages = [
      context.tr('loading.messages.0'),
      context.tr('loading.messages.1'),
      context.tr('loading.messages.2'),
      context.tr('loading.messages.3'),
    ]..shuffle();
    
    _timer ??= Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _index = (_index + 1) % _messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Text(
            _messages.isNotEmpty ? _messages[_index] : context.tr('loading.title'),
            key: ValueKey(_index),
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}
