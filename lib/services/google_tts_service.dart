import 'dart:convert';
import 'dart:io';

import 'package:dictionary_generator/config.dart';
import 'package:googleapis/texttospeech/v1.dart';
import 'package:googleapis/translate/v3.dart';
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

void synthesizeMp3ForAllJsons() {
  
}

void main() async {
  String text = 'I love you';
  List<int> ttsData = await GoogleTtsService().synthesizeText(text);
  GoogleTtsService().saveToFile(text, ttsData);
}
