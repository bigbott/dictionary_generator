import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dictionary_generator/config.dart';
import 'package:dictionary_generator/models/dictionary/entry.dart';
import 'package:googleapis/texttospeech/v1.dart';
import 'package:googleapis_auth/auth_io.dart';

final class GoogleTtsService {
  static final _instance = GoogleTtsService._();
  factory GoogleTtsService() => _instance;
  GoogleTtsService._();

  AuthClient? _authClient;
  TexttospeechApi? _ttsApi;

  Future<AuthClient> _getAuthClient() async {
    if (_authClient != null) return _authClient!;

    String jsonString = File('messenger-007.json').readAsStringSync();

    final accountCredentials = ServiceAccountCredentials.fromJson(jsonDecode(jsonString));
    final scopes = [TexttospeechApi.cloudPlatformScope];

    _authClient = await clientViaServiceAccount(accountCredentials, scopes);
    return _authClient!;
  }

  Future<TexttospeechApi> _getTextToSpeechApi() async {
    if (_ttsApi != null) return _ttsApi!;
    final client = await _getAuthClient();
    _ttsApi = TexttospeechApi(client);
    return _ttsApi!;
  }

  Future<List<int>> synthesizeText(
    String text, {
    String languageCode = 'en-US',
    String voiceName = 'en-US-Standard-A',
  }) async {
    final ttsApi = await _getTextToSpeechApi();

    final synthesisInput = SynthesisInput(text: text);
    final voiceSelectionParams = VoiceSelectionParams(
      languageCode: languageCode,
      name: voiceName,
    );
    final audioConfig = AudioConfig(audioEncoding: 'MP3');

    final synthesizeSpeechRequest = SynthesizeSpeechRequest(
      input: synthesisInput,
      voice: voiceSelectionParams,
      audioConfig: audioConfig,
    );

    final response = await ttsApi.text.synthesize(synthesizeSpeechRequest);

    // The API returns base64-encoded string, decode it to bytes
    final base64String = response.audioContent as String;
    return base64.decode(base64String);
  }

  void saveToFile(String text, List<int> ttsData) {
    String filename = text.replaceAll(RegExp(r'[^\w\s\-]'), '');
    filename = '${filename.toLowerCase().replaceAll(' ', '_').
                                         replaceAll('-', '_')}.mp3';

    String pathToFile = Config.mp3Dir + filename;

    final file = File(pathToFile);
    file.createSync(recursive: true);

    file.writeAsBytesSync(ttsData);
    print('file saved');
  }

  void dispose() {
    _authClient?.close();
  }
}

void synthesizeMp3ForAllJsons() async {
  final jsonDir = Directory(Config.jsonDir);
  if (!jsonDir.existsSync()) {
    print('JSON directory does not exist: ${Config.jsonDir}');
    return;
  }

  final mp3Dir = Directory(Config.mp3Dir);
  if (!mp3Dir.existsSync()) {
    mp3Dir.createSync(recursive: true);
  }

  final jsonFiles = jsonDir.listSync().where((file) => file.path.endsWith('.txt')).toList();
  print('Found ${jsonFiles.length} JSON files');

  final voiceNames = [
    Config.voiceName1, Config.voiceName2, Config.voiceName3, Config.voiceName4,
    Config.voiceName5, Config.voiceName6, Config.voiceName7, Config.voiceName8,
    Config.voiceName9, Config.voiceName10
  ];

  final random = Random();

  File progressFile = File(Config.ttsProgress);
  List<String> progress = progressFile.readAsLinesSync();
  File invalidFile = File(Config.invalid);
  List<String> invalid = invalidFile.readAsLinesSync();
  File failsFile = File(Config.ttsFails);

  for (final file in jsonFiles) {
    
    try {
      final jsonString = File(file.path).readAsStringSync();
      final entry = Entry.fromJson(jsonString);
      
      print('Processing: ${entry.word} ${DateTime.now().millisecondsSinceEpoch}');
       
      if (progress.contains(entry.word.trim())){
        print('${entry.word} is in progress');
        continue;
      }
      if (invalid.contains(entry.word.trim())){
        print('${entry.word} is invalid');
        continue;
      }
      
      sleep(Duration(milliseconds: 400));
      // Synthesize main word using Config.voiceName8
      try {
        final wordTtsData = await GoogleTtsService().synthesizeText(
          entry.word.trim(),
          languageCode: Config.languageCode,
          voiceName: Config.voiceName6,
        );
        GoogleTtsService().saveToFile(entry.word.trim(), wordTtsData);
      } catch (e) {
        print('Error synthesizing main word "${entry.word}": $e');
      }

      // Synthesize forms using random voices
      for (final partOfSpeech in entry.partsOfSpeech) {
        sleep(Duration(milliseconds: 100));
        if (partOfSpeech.forms != null) {
          for (final formEntry in partOfSpeech.forms!.entries) {
            final formText = formEntry.value;
            final randomVoice = voiceNames[random.nextInt(voiceNames.length)];
            
            try {
              final formTtsData = await GoogleTtsService().synthesizeText(
                formText.trim(),
                languageCode: Config.languageCode,
                voiceName: randomVoice,
              );
              GoogleTtsService().saveToFile(formText.trim(), formTtsData);
            } catch (e) {
              print('Error synthesizing form "$formText" for "${entry.word}": $e');
            }
          }
        }

        // Synthesize English examples using random voices
        for (final definition in partOfSpeech.definitions) {
          sleep(Duration(milliseconds: 100));
          if (definition.example.isNotEmpty) {
            final randomVoice = voiceNames[random.nextInt(voiceNames.length)];
            
            try {
              final exampleTtsData = await GoogleTtsService().synthesizeText(
                definition.example.trim(),
                languageCode: Config.languageCode,
                voiceName: randomVoice,
              );
              // Create a safe filename from the example
             GoogleTtsService().saveToFile(definition.example.trim(), exampleTtsData);
            } catch (e) {
              print('Error synthesizing example "${definition.example}" for "${entry.word}": $e');
            }
          }
        }
      }
      progressFile.writeAsStringSync('${entry.word}\n', mode: FileMode.append);
      print('Completed: ${entry.word} ${DateTime.now().millisecondsSinceEpoch}');
    } catch (e) {
      print('Error processing file ${file.path}: $e');
    }
  }
  
  print('All JSON files processed');
}

void main() async {
  // String text = 'I love you';
  // List<int> ttsData = await GoogleTtsService().synthesizeText(text);
  // GoogleTtsService().saveToFile(text, ttsData);
  // Test the synthesizeMp3ForAllJsons function
  print('Testing synthesizeMp3ForAllJsons function...');
   synthesizeMp3ForAllJsons();
}
