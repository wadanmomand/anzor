import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

void main() {
  final cleanLogoPath = 'C:/Users/muham/.gemini/antigravity-ide/brain/ad510f56-c05f-46f8-8bff-234cc71c8cb5/media__1782458461509.jpg';
  final srcFile = File(cleanLogoPath);
  
  if (!srcFile.existsSync()) {
    print('ERROR: Clean master logo not found at: $cleanLogoPath');
    return;
  }
  
  final bytes = srcFile.readAsBytesSync();
  img.Image? src = img.decodeImage(bytes);
  if (src == null) {
    print('ERROR: Failed to decode clean master logo.');
    return;
  }
  print('Source decoded successfully: ${src.width} x ${src.height}');

  // Ensure source is square by cropping or padding if needed
  int srcSize = min(src.width, src.height);
  img.Image squareSrc = img.copyCrop(src, x: (src.width - srcSize) ~/ 2, y: (src.height - srcSize) ~/ 2, width: srcSize, height: srcSize);

  // ---------------------------------------------------------
  // 1. Generate Transparent Foreground Asset (60% safe zone size)
  // ---------------------------------------------------------
  const int canvasSize = 1024;
  const double foregroundScaleFraction = 0.60; // 60% of canvas size
  final int logoForegroundSize = (canvasSize * foregroundScaleFraction).round(); // ~614px

  print('Generating transparent adaptive foreground icon at ${logoForegroundSize}x${logoForegroundSize}...');
  img.Image logoResized = img.copyResize(squareSrc, width: logoForegroundSize, height: logoForegroundSize, interpolation: img.Interpolation.cubic);

  // Create transparent canvas
  img.Image foregroundCanvas = img.Image(width: canvasSize, height: canvasSize, numChannels: 4);
  img.fill(foregroundCanvas, color: img.ColorRgba8(0, 0, 0, 0));

  // Position logo in center
  int offsetForegroundX = (canvasSize - logoForegroundSize) ~/ 2;
  int offsetForegroundY = (canvasSize - logoForegroundSize) ~/ 2;

  // Key out the black background to create transparency with smooth alpha edges
  const int thresholdMin = 15;
  const int thresholdMax = 80;

  for (int y = 0; y < logoResized.height; y++) {
    for (int x = 0; x < logoResized.width; x++) {
      var pixel = logoResized.getPixel(x, y);
      int r = pixel.r.toInt();
      int g = pixel.g.toInt();
      int b = pixel.b.toInt();
      
      int val = [r, g, b].reduce(max);
      double alphaFraction = 1.0;
      
      if (val < thresholdMin) {
        alphaFraction = 0.0;
      } else if (val < thresholdMax) {
        alphaFraction = (val - thresholdMin) / (thresholdMax - thresholdMin);
      }
      
      int targetAlpha = (alphaFraction * 255).round();
      if (targetAlpha > 0) {
        // Draw the pixel onto the canvas at the offset coordinates
        foregroundCanvas.setPixel(
          offsetForegroundX + x,
          offsetForegroundY + y,
          img.ColorRgba8(r, g, b, targetAlpha),
        );
      }
    }
  }

  // Save the adaptive foreground PNG
  final foregroundFile = File('assets/app_icon_foreground.png');
  foregroundFile.writeAsBytesSync(img.encodePng(foregroundCanvas));
  print('SUCCESS: Saved assets/app_icon_foreground.png');

  // ---------------------------------------------------------
  // 2. Generate Legacy Icon Asset (with solid dark background, logo scaled to 72%)
  // ---------------------------------------------------------
  const double legacyScaleFraction = 0.72; // Legacy icon displays in a full square/circle, we want it a bit larger
  final int logoLegacySize = (canvasSize * legacyScaleFraction).round(); // ~737px

  print('Generating legacy app icon at ${logoLegacySize}x${logoLegacySize}...');
  img.Image logoLegacyResized = img.copyResize(squareSrc, width: logoLegacySize, height: logoLegacySize, interpolation: img.Interpolation.cubic);

  // Create legacy canvas filled with solid #090B14
  img.Image legacyCanvas = img.Image(width: canvasSize, height: canvasSize, numChannels: 4);
  img.fill(legacyCanvas, color: img.ColorRgba8(9, 11, 20, 255)); // 0x090B14 color

  // Position logo in center
  int offsetLegacyX = (canvasSize - logoLegacySize) ~/ 2;
  int offsetLegacyY = (canvasSize - logoLegacySize) ~/ 2;

  // Composite the logo onto the solid dark canvas using the same alpha keying
  for (int y = 0; y < logoLegacyResized.height; y++) {
    for (int x = 0; x < logoLegacyResized.width; x++) {
      var pixel = logoLegacyResized.getPixel(x, y);
      int r = pixel.r.toInt();
      int g = pixel.g.toInt();
      int b = pixel.b.toInt();
      
      int val = [r, g, b].reduce(max);
      double alphaFraction = 1.0;
      
      if (val < thresholdMin) {
        alphaFraction = 0.0;
      } else if (val < thresholdMax) {
        alphaFraction = (val - thresholdMin) / (thresholdMax - thresholdMin);
      }
      
      if (alphaFraction > 0.0) {
        // Blend pixel onto the dark background
        int destX = offsetLegacyX + x;
        int destY = offsetLegacyY + y;
        
        var destPixel = legacyCanvas.getPixel(destX, destY);
        int destR = destPixel.r.toInt();
        int destG = destPixel.g.toInt();
        int destB = destPixel.b.toInt();
        
        // Simple alpha blending
        int finalR = (r * alphaFraction + destR * (1.0 - alphaFraction)).round();
        int finalG = (g * alphaFraction + destG * (1.0 - alphaFraction)).round();
        int finalB = (b * alphaFraction + destB * (1.0 - alphaFraction)).round();
        
        legacyCanvas.setPixel(destX, destY, img.ColorRgba8(finalR, finalG, finalB, 255));
      }
    }
  }

  // Save the legacy app icon
  final legacyFile = File('assets/app_icon_legacy.png');
  legacyFile.writeAsBytesSync(img.encodePng(legacyCanvas));
  print('SUCCESS: Saved assets/app_icon_legacy.png');

  // Also replace app_logo.png (used by splash screen) with the legacy icon without guidelines
  final appLogoFile = File('assets/app_logo.png');
  appLogoFile.writeAsBytesSync(img.encodePng(legacyCanvas));
  print('SUCCESS: Replaced assets/app_logo.png with clean legacy icon');
  
  print('--- Asset Generation Complete ---');
}
