// ===== GEMINI AI SERVICE =====
// Handles Google Gemini API integration for decision analysis
// Generates structured response: Pros/Cons, Comparison Table, SWOT Analysis

import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // Gemini API configuration
  static const String _apiKey = 'AIzaSyBwiKmjcMdchVlDRNhpewaTdVYXmDEV7AQ'; // Your Gemini API key (get from makersuite.google.com)
  static const String _modelName = 'gemini-2.5-flash'; // Fast Gemini model for analysis

  late final GenerativeModel _model; // Initialized Gemini model instance

  GeminiService() {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7, // Creativity level (0-1)
        topP: 0.8, // Nucleus sampling
        topK: 40, // Top K sampling
        maxOutputTokens: 2048, // Max response length
      ),
    );
  }

  // ===== MAIN AI ANALYSIS METHOD =====
  // Input: User decision prompt (e.g., "Should I buy a car or lease?")
  // Output: Structured Markdown response with 3 sections
  Future<String> generateDecisionAnalysis(String decisionPrompt) async {
    // System prompt - defines response format
    final String systemPrompt = '''
You are an expert decision making assistant. The user is trying to make a decision: "$decisionPrompt".

ALWAYS provide ALL 3 sections, even if brief:

1. **Pros and Cons**
   Bullet list of pros (+) and cons (-) for the main decision/option.

2. **Comparison Table**
   Markdown table comparing 2-3 main alternatives/options. Columns: Aspect, Option1, Option2. Rows: 5-7 key factors. 
   If no clear alternatives, compare "Do it" vs "Don't do it".

3. **SWOT Analysis**
   **Strengths**, **Weaknesses**, **Opportunities**, **Threats** - bullet lists for the decision.

Use ## headers, bold subheaders, tables where applicable. Be comprehensive but concise.
'''; 

    try {
      final content = [Content.text(systemPrompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Error: No response generated.';
    } catch (e) {
      // Error handling for API issues
      return 'Error generating analysis: $e';
    }
  }
}

