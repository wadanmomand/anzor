import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  // Primary model configurations
  static const String _textModel = 'gemini-1.5-flash';
  static const String _visionModel = 'gemini-1.5-flash';

  // Direct prompt generator from user idea
  Future<Map<String, dynamic>> generatePrompt({
    required String rawIdea,
    required String apiKey,
    required String artStyle,
    required List<String> presets,
  }) async {
    if (apiKey.isEmpty) {
      // Mock Fallback when key is missing in offline mode
      await Future.delayed(const Duration(milliseconds: 1200));
      return _generateMockExpansion(rawIdea, artStyle, presets);
    }

    try {
      final model = GenerativeModel(
        model: _textModel,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.7,
        ),
      );

      final promptText = '''
You are a master Prompt Engineer specializing in generating detailed prompts for AI image generators (Midjourney, DALL-E, Stable Diffusion).
Expand the following raw idea: "$rawIdea" using the art style "$artStyle" and these quality accents: ${presets.join(', ')}.
Return your response in JSON format. The JSON schema must strictly be:
{
  "expandedPrompt": "The expanded descriptive prompt containing vivid sensory details, lighting, composition, and style accents, optimized for image generators",
  "revisedIdea": "A detailed explanation of the creative concept, mood, and atmosphere in 1-2 sentences",
  "keywordsExplanation": "A brief explanation of the key terms and modifiers added to enhance the visual outcome"
}''';

      final content = [Content.text(promptText)];
      final response = await model.generateContent(content);
      
      final text = response.text;
      if (text == null) {
        throw Exception('Gemini returned an empty response.');
      }

      return jsonDecode(text.trim()) as Map<String, dynamic>;
    } catch (e) {
      print('Direct Gemini API Error: $e');
      // If API fails (e.g. invalid key), fallback to mock with warning
      return {
        'error': 'API invocation failed: ${e.toString()}',
        ..._generateMockExpansion(rawIdea, artStyle, presets)
      };
    }
  }

  // Reverse engineer image (Vision analyze)
  Future<Map<String, dynamic>> analyzeImage({
    required Uint8List imageBytes,
    required String mimeType,
    required String apiKey,
  }) async {
    if (apiKey.isEmpty) {
      // Mock Fallback when key is missing in offline mode
      await Future.delayed(const Duration(milliseconds: 1500));
      return _generateMockVisionAnalysis();
    }

    try {
      final model = GenerativeModel(
        model: _visionModel,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.4,
        ),
      );

      const instruction = '''
Analyze this image and reverse-engineer it into a highly detailed text prompt that can reproduce its visual style, composition, subjects, color palette, lighting, and camera angle.
Return your response in JSON format. The JSON schema must strictly be:
{
  "prompt": "A highly detailed text prompt optimized for AI image generators that describes this image's content, composition, and lighting",
  "style": "The primary art style identified (e.g. Cinematic, Painterly, Anime & Manga, Digital Art, 3D Render, Watercolor, Cyberpunk, Vintage Film)",
  "composition": "Analysis of the layout, camera angle, and perspective of the image",
  "lighting": "Analysis of the lighting direction, quality, and atmosphere (e.g. golden hour, volumetric lighting, dramatic shadow)",
  "colors": "Description of the dominant color palette"
}''';

      final content = [
        Content.multi([
          TextPart(instruction),
          DataPart(mimeType, imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      final text = response.text;
      if (text == null) {
        throw Exception('Gemini Vision returned empty content.');
      }

      return jsonDecode(text.trim()) as Map<String, dynamic>;
    } catch (e) {
      print('Direct Gemini Vision API Error: $e');
      return {
        'error': 'Vision API invocation failed: ${e.toString()}',
        ..._generateMockVisionAnalysis()
      };
    }
  }

  // Helper: generates high quality mock responses for standalone mode
  Map<String, dynamic> _generateMockExpansion(String idea, String style, List<String> presets) {
    final styleDetails = {
      'Cinematic': 'volumetric lighting, atmospheric smoke, highly dramatic contrasts, shot on 35mm lens, depth of field, anamorphic style color grading',
      'Painterly': 'thick impasto brush textures, rich oil colors, classical Renaissance dynamic composition, visible canvas fibers, fine art styling',
      'Anime & Manga': 'crisp detailed line art, vibrant cel-shaded color scheme, key visual, action dynamic perspective, beautiful stylized particle effects',
      'Digital Art': 'intricate concept art, glowing neon accents, high fidelity render, trending on ArtStation, modern cyber-art aesthetic, clean vectors',
      '3D Render': 'octane render, subsurface scattering on materials, clay details, highly realistic displacement maps, raytraced reflection, Unreal Engine 5 style',
      'Watercolor': 'delicate ink splatters, wet-on-wet watercolor runs, soft bleeding edges, cold-press paper grain texture, soft hand-painted lines',
      'Cyberpunk': 'holographic advertising, rain-slicked neon street reflections, dark chrome, cyan and magenta color glows, robotic elements, futuristic city layout',
      'Vintage Film': 'analog silver-halide grain, chromatic aberrations, Polaroid border look, faded sepia shadows, light leak streaks, vintage camera lens, 1970s warm vibe',
    };

    final presetText = presets.isNotEmpty ? presets.join(', ') : 'exquisite details';
    final expandedPrompt = '$style style illustration of "$idea". ${styleDetails[style] ?? "detailed textures, fine composition"}. Enhanced with: $presetText. Masterpiece quality, highly detailed, photorealistic render.';
    
    return {
      'expandedPrompt': expandedPrompt,
      'revisedIdea': 'A premium re-imagining of "$idea" utilizing the core values of the $style aesthetic, with specific highlights on composition, lighting, and preset assets.',
      'keywordsExplanation': 'Established the "$style" aesthetic framework. Selected visual style parameters ("${styleDetails[style] ?? ''}") and quality enhancers [$presetText] to maximize fidelity and style accuracy.'
    };
  }

  Map<String, dynamic> _generateMockVisionAnalysis() {
    return {
      'prompt': 'A beautiful, highly detailed digital painting of an astronaut floating in a sea of glowing neon flowers, vibrant nebula clouds in the deep space background, purple and turquoise lighting, starry atmosphere, futuristic fantasy art style.',
      'style': 'Digital Art',
      'composition': 'Subject is centered, low angle shot looking up, dynamic rule of thirds with nebula curves',
      'lighting': 'Bioluminescent glow from flowers, dramatic backlighting from nebula stars, cyan/magenta highlights',
      'colors': 'Vibrant turquoise, neon purple, deep cosmic blue, golden starlight accents'
    };
  }
}
