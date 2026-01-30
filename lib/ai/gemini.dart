import 'package:dictionary_generator/secret_constants.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

final class Gemini {
  Gemini._();
  static final _instance = Gemini._();
  factory Gemini() => _instance;

  GenerativeModel createModel({
    required String modelName,
    String? aiRules,
    double? temperature,
    int? topK,
    double? topP,
    int? maxOutputTokens,
    String? responseMimeType,
  }) {
    final model = GenerativeModel(
      model: modelName,
      apiKey: SecretConstants.geminiApiKey,
      systemInstruction: aiRules != null ? Content.system(aiRules) : null,
      generationConfig: GenerationConfig(
        temperature: temperature ?? 0.7,
        topK: topK ?? 40,
        topP: topP ?? 0.95,
        maxOutputTokens: maxOutputTokens ?? 1024,
        responseMimeType: responseMimeType ?? 'text/plain',
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      ],
    );
    return model;
  }
}
