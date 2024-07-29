import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:gratitude_diary/services/isar/isar_collections.dart';
import 'package:gratitude_diary/services/isar/isar_db.dart';

abstract class GratitudeViewState {}

class GratitudeViewInitial extends GratitudeViewState {}

class GratitudeViewLoading extends GratitudeViewState {}

class GratitudeViewLoaded extends GratitudeViewState {
  final GratitudeEntry entry;
  final String? emoji;
  GratitudeViewLoaded({this.emoji, required this.entry});
}

class GratitudeViewError extends GratitudeViewState {
  final String message;
  GratitudeViewError({required this.message});
}

class GratitudeViewNotifiers extends StateNotifier<GratitudeViewState> {
  GratitudeViewNotifiers() : super(GratitudeViewInitial()) {
    _isarDbService = GetIt.I.get<IsarDbService>();
    getRandomGratitudeEntry();
  }

  late IsarDbService _isarDbService;

  final String gratitudeHeader = 'Today I am grateful for ';
  final String aiPrompt =
      "I will give you a paragraph where a user input what he is grateful for. Analyze the text and reply me with three emojis with single spce between them that best represents the text. Here is the text:";

  void getRandomGratitudeEntry() async {
    state = GratitudeViewLoading();
    try {
      final entry = _isarDbService.getRandomEntry();
      state = GratitudeViewLoaded(entry: entry, emoji: null);

      final apiKey = dotenv.env['GOOGLE_AI_KEY'];
      if (apiKey == null) {
        throw Exception('API key not found');
      }

      final googleAiModel =
          GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final content = [Content.text("$aiPrompt'${entry.text!}'")];
      final response = await googleAiModel.generateContent(content);
      state = GratitudeViewLoaded(entry: entry, emoji: response.text);
    } catch (e) {
      state = GratitudeViewError(message: e.toString());
    }
  }
}

final gratitudeViewNotifierProvider =
    StateNotifierProvider<GratitudeViewNotifiers, GratitudeViewState>(
        (ref) => GratitudeViewNotifiers());
