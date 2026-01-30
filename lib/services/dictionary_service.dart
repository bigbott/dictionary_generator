import 'dart:io';

import 'package:dictionary_generator/config.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:dictionary_generator/ai/gemini.dart';

final class DictionaryService {
  DictionaryService._();
  static final _instance = DictionaryService._();
  factory DictionaryService() => _instance;

  static const geminiModelName = 'gemini-2.5-flash-lite';
  static const gemma27ModelName = 'gemma-3-27b-it';
  static const gemma12ModelName = 'gemma-3-12b-it';
  static const gemma4ModelName = 'gemma-3-4b-it';

  final model27 = Gemini().createModel(
    modelName: gemma27ModelName,
    // aiRules: 'You are translator from English to Russian',
    temperature: 0.5,
    topK: 20,
    topP: 0.8,
    maxOutputTokens: 1500,
  );

  final model12 = Gemini().createModel(
    modelName: gemma12ModelName,
    // aiRules: 'You are translator from English to Russian',
    temperature: 0.5,
    topK: 20,
    topP: 0.8,
    maxOutputTokens: 1500,
  );

  final model4 = Gemini().createModel(
    modelName: gemma4ModelName,
    // aiRules: 'You are translator from English to Russian',
    temperature: 0.5,
    topK: 20,
    topP: 0.8,
    maxOutputTokens: 1500,
  );

  static var currentModelName = 'gemma-3-27b-it';

  static const dictionaryEntryPrompt = '''
You are a dictionary compiler creating English-Russian dictionary entries in JSON format.

Given an English word, generate a complete dictionary entry following this exact structure:

1. Include the word, IPA pronunciation, and Cyrillic transliteration
2. List all parts of speech the word can function as (noun, verb, adjective, adverb, etc.)
3. For each part of speech, include:
   - If NOUN: singular and plural forms
   - If VERB: infinitive, present, third person present, past, and past_participle forms
   - If ADJECTIVE: comparative and superlative forms
4. Provide Russian translations with example sentences in both English and Russian

Output ONLY valid JSON with no additional text.

Example structure:
{
  "word": "light",
  "pronunciation": "/laɪt/",
  "transliteration": "лайт",
  "parts_of_speech": [
    {
      "pos": "noun",
      "forms": {
        "singular": "light",
        "plural": "lights"
      },
      "definitions": [
        {
          "meaning": "источник освещения, свет",
          "example": "Turn on the light",
          "example_ru": "Включи свет"
        }
      ]
    },
    {
      "pos": "verb",
      "forms": {
        "infinitive": "to light",
        "present": "light",
        "present_3p": "lights",
        "past": "lit",
        "past_participle": "lit"
      },
      "definitions": [
        {
          "meaning": "зажигать, освещать",
          "example": "Light the candles",
          "example_ru": "Зажги свечи"
        }
      ]
    },
    {
      "pos": "adjective",
      "forms": {
        "comparative": "lighter",
        "superlative": "lightest"
      },
      "definitions": [
        {
          "meaning": "светлый",
          "example": "Light colors",
          "example_ru": "Светлые цвета"
        }
      ]
    }
  ]
}

Now generate a dictionary entry for the word: {WORD}

                                        ''';

  Future<String> makeEntry(String word) async {
    var promptText = dictionaryEntryPrompt.replaceFirst('{WORD}', word);
    // print(promptText);

    var model = getModel(rotate: true);

    final response = await model.generateContent([Content.text(promptText)]);
    print(response.text);
    return response.text!;
  }

  void run() async {
    List<String> wordsWithFrequency = File(Config.words5k).readAsLinesSync();
    File progressFile = File(Config.progress);
    File failsFile = File(Config.fails);
    List<String> progress = progressFile.readAsLinesSync();
    List<String> fails = failsFile.readAsLinesSync();
    int failsNumber = 0;
    for (int i = 0; i < wordsWithFrequency.length; i++) {
      await Future.delayed(Duration(seconds: 2));
      List<String> wordData = wordsWithFrequency[i].split(' ');
      String word = wordData[0];
      if (progress.contains(word)) {
        continue;
      }
      String json;
      try {
        json = await makeEntry(word);
      } catch (e) {
        print(e);
        fails.add(word);
        failsFile.writeAsStringSync('$word\n', mode: FileMode.append);
        failsNumber++;
        if (failsNumber < 3) {
          i--;
        }
        continue;
      }
      failsNumber = 0;
      json = json.replaceFirst('json', '').replaceFirst('```', '').replaceFirst('```', '');

      String filename = '${word}_${wordData[1]}.txt';
      File file = File(Config.jsonDir + filename);
      file.writeAsStringSync(json);
      progress.add(word);
      progressFile.writeAsStringSync('$word\n', mode: FileMode.append);
      fails.removeWhere((element) => element == word);
      failsFile.writeAsStringSync(fails.join('\n'));
    }
  }

  GenerativeModel getModel({required bool rotate}) {
    if (rotate == false) {
      print(currentModelName);
      return model27;
    }
    if (currentModelName == gemma27ModelName) {
      currentModelName = gemma12ModelName;
      print(currentModelName);
      return model12;
    }
    currentModelName = gemma27ModelName;
    print(currentModelName);
    return model27;
  }
}

void main() async {
  //DictionaryService().makeEntry('exposed', );
  DictionaryService().run();
}
