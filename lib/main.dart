import 'package:material_ui/material_ui.dart';
import 'package:nihongo_tap/screens/word_list_screen.dart';
import 'package:nihongo_tap/services/speech_service.dart';
import 'package:nihongo_tap/services/update_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NihongoTapApp());
}

/// Root application widget for Nihongo Tap.
class NihongoTapApp extends StatefulWidget {
  const NihongoTapApp({
    super.key,
    this.speechService,
    this.updateService,
  });

  final SpeechService? speechService;
  final UpdateService? updateService;

  @override
  State<NihongoTapApp> createState() => _NihongoTapAppState();
}

class _NihongoTapAppState extends State<NihongoTapApp> {
  late final SpeechService _speechService;
  late final UpdateService _updateService;
  late final bool _ownsSpeechService;

  @override
  void initState() {
    super.initState();
    _ownsSpeechService = widget.speechService == null;
    _speechService = widget.speechService ?? FlutterTtsSpeechService();
    _updateService = widget.updateService ?? GitHubUpdateService();
  }

  @override
  void dispose() {
    if (_ownsSpeechService) {
      _speechService.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nihongo Tap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2B3A67),
          surface: Colors.white,
        ),
      ),
      home: WordListScreen(
        speechService: _speechService,
        updateService: _updateService,
      ),
    );
  }
}
