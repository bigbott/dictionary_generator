abstract final class Config {
  static const workingDir = 'F:/ADICTIONARIES/english/';
  static const jsonDir = '${workingDir}jsons/';
  static const mp3Dir = '${workingDir}mp3s/';
  static const words5k = '${workingDir}words5k.txt';
  static const words50k = '${workingDir}words50k.txt';
  static const progress = '${workingDir}dic_progress.txt';
  static const fails = '${workingDir}fails.txt';
  static const dbProgress = '${workingDir}db_progress.txt';
  static const dbFails = '${workingDir}db_fails.txt';
  static const dbDif = '${workingDir}dif.txt';

  static const languageCode = 'en-US';
  static const voiceName1 = 'en-GB-Wavenet-B'; //uk male
  static const voiceName2 = 'en-GB-Wavenet-C';  //uk female
  static const voiceName3 = 'en-GB-Wavenet-D';  //uk male
  static const voiceName4 = 'en-GB-Wavenet-F'; //uk female

  static const voiceName5 = 'en-US-Wavenet-A'; //us male
  static const voiceName6 = 'en-US-Wavenet-C';  //us female
  static const voiceName7 = 'en-US-Wavenet-B';  //us male
  static const voiceName8 = 'en-US-Wavenet-F'; //us female
}
