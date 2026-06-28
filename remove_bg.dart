import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File('1000296482.png');
  if (!file.existsSync()) {
    print('Error: 1000296482.png not found.');
    return;
  }
  
  print('Loading 1000296482.png...');
  final bytes = file.readAsBytesSync();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    print('Error: failed to decode image.');
    return;
  }

  print('Processing pixels...');
  // Modify image to set background pixels to transparent white
  for (final pixel in decoded) {
    final r = pixel.r;
    final g = pixel.g;
    final b = pixel.b;
    if (r < 25 && g < 25 && b < 25) {
      pixel.setRgba(255, 255, 255, 0);
    }
  }

  print('Encoding transparent PNG...');
  final pngBytes = img.encodePng(decoded);
  
  final outputDir = Directory('assets');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }
  
  final outputFile = File('assets/anzor_ai_transparent.png');
  outputFile.writeAsBytesSync(pngBytes);
  print('Successfully saved to assets/anzor_ai_transparent.png');
}
