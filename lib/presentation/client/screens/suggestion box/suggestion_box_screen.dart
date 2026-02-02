import 'package:flutter/material.dart';
import 'package:prototipo1_app/presentation/client/Components/my_bottom_nav_bar.dart';
import 'package:prototipo1_app/presentation/client/screens/body/body_suggestion_screen.dart';

class SuggestionBoxScreen extends StatefulWidget {
  const SuggestionBoxScreen({super.key});

  @override
  State<SuggestionBoxScreen> createState() => _SuggestionBoxScreenState();
}

class _SuggestionBoxScreenState extends State<SuggestionBoxScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sugerencias y Reclamos')),
      body: BodySuggestionScreen(),
      bottomNavigationBar: MyBottomNavBar(),
    );
  }
}