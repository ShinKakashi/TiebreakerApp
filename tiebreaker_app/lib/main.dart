// ===== TIEBREAKER DECISION ASSISTANT APP =====
// Main entry point for the Flutter app
// Uses Google Gemini AI to analyze decisions with Pros/Cons, Comparison Table, and SWOT
// UI shows expandable sections for easy reading

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'services/gemini_services.dart';

void main() {
  runApp(const MyApp());
}

// ===== APP ROOT WIDGET =====
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiebreaker Decision Assistant', // App title
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // Purple theme
      ),
      home: const MyHomePage(title: 'Tiebreaker Decision Assistant'), // Main screen
    );
  }
}

// ===== MAIN UI SCREEN =====
// Stateful widget for decision input and AI analysis display
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _promptController = TextEditingController(); // Text input controller
  final GeminiService _geminiService = GeminiService(); // AI service instance
  String _result = '';
  String _prosCons = '';
  String _comparison = '';
  String _swot = '';
  bool _isLoading = false; // Loading state for UI

  // ===== GENERATE AI ANALYSIS =====
  // Calls Gemini to get structured decision analysis
  Future<void> _generateAnalysis() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final analysis = await _geminiService.generateDecisionAnalysis(_promptController.text);
      setState(() {
        _result = analysis;
        _parseSections(analysis); // Split into sections
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  // ===== PARSE AI RESPONSE INTO SECTIONS =====
  // Extracts Pros/Cons, Table, SWOT from Gemini response for tabbed display
  void _parseSections(String text) {
    int prosStart = text.indexOf('**Pros and Cons**');
    int compStart = text.indexOf('**Comparison Table**', prosStart + 1);
    int swotStart = text.indexOf('**SWOT Analysis**', compStart + 1);

    _prosCons = prosStart != -1 ? text.substring(prosStart, compStart != -1 ? compStart : swotStart != -1 ? swotStart : text.length) : '';
    _comparison = compStart != -1 ? text.substring(compStart, swotStart != -1 ? swotStart : text.length) : '';
    _swot = swotStart != -1 ? text.substring(swotStart) : '';

    // Clean headers for Markdown rendering
    if (_prosCons.isNotEmpty) _prosCons = _prosCons.replaceFirst('**Pros and Cons**', '**Pros and Cons**\\n\\n');
    if (_comparison.isNotEmpty) _comparison = _comparison.replaceFirst('**Comparison Table**', '**Comparison Table**\\n\\n');
    if (_swot.isNotEmpty) _swot = _swot.replaceFirst('**SWOT Analysis**', '**SWOT Analysis**\\n\\n');
  }

  @override
  void dispose() {
    _promptController.dispose(); // Clean up controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tiebreaker Decision Assistant'), // App title bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _promptController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Enter your decision prompt', // User inputs decision here
                hintText: 'e.g., Should I buy a house or rent?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateAnalysis, // Analyze button
              child: _isLoading 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2), // Loading spinner
                  )
                : const Text('Generate Analysis'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _result.isEmpty 
                ? const Center(
                    child: Text(
                      'Enter a decision prompt and tap Generate Analysis to get:\n\n1. Pros and Cons\n2. Comparison Table\n3. SWOT Analysis',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView(
                    children: [
                      // ===== PROS & CONS SECTION =====
                      if (_prosCons.isNotEmpty)
                        ExpansionTile(
                          title: const Text('1. Pros and Cons', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          initiallyExpanded: true,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: MarkdownBody(data: _prosCons), // Markdown rendered
                            ),
                          ],
                        ),
                      // ===== COMPARISON TABLE SECTION =====
                      if (_comparison.isNotEmpty)
                        ExpansionTile(
                          title: const Text('2. Comparison Table', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          initiallyExpanded: true,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: MarkdownBody(data: _comparison),
                            ),
                          ],
                        ),
                      // ===== SWOT ANALYSIS SECTION =====
                      if (_swot.isNotEmpty)
                        ExpansionTile(
                          title: const Text('3. SWOT Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                          initiallyExpanded: true,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: MarkdownBody(data: _swot),
                            ),
                          ],
                        ),
                      if (_prosCons.isEmpty && _comparison.isEmpty && _swot.isEmpty && _result.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: MarkdownBody(data: _result), // Fallback full response
                        ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

