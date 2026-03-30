import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'gemini_services.dart';

class AIService {
  static final GeminiService _geminiService = GeminiService();
  static String? _activeModel;

  static Future<void> init() async {
    await dotenv.load();
    _activeModel = 'gemini-1.5-flash'; // Default active model
  }

  static String? getActiveModel() => _activeModel;

  static Future<String> analyzeDecision(String prompt) async {
    return await _geminiService.generateDecisionAnalysis(prompt);
  }
}

