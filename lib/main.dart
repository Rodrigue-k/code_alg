import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/languages/dart.dart';
import 'package:dart_eval/dart_eval.dart'; 

void main() {
  runApp(const CodeEditorApp());
}

class CodeEditorApp extends StatelessWidget {
  const CodeEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CodeEditorScreen(),
    );
  }
}

class CodeEditorScreen extends StatefulWidget {
  const CodeEditorScreen({super.key});

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  late final CodeController _codeController;
  String _output = '';

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: '''void main() {
  // Welcome to the code editor!
  print("Hello, World!");
  
  for (var i = 0; i < 5; i++) {
    print("Counter: \$i");
  }
}''',
      language: dart,
      patternMap: {
        r'\b\d+\b': TextStyle(color: Colors.blue[300]),
      },
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// Exécute le code Dart en utilisant dart_eval.
  void _runCode() {
    try {
      // Compile le code saisi. Le paramètre 'uri' est requis pour identifier le module.
      final compiler = Compiler();
      final program = compiler.compile({
        'package:main/main.dart': {
          'main.dart': _codeController.text,
        }
      });
      // Crée le runtime en passant le bytecode du programme compilé.
      final runtime = Runtime.ofProgram(program);
      runtime.setup();
      // Exécute la fonction 'main' du module.
      final result = runtime.executeLib('package:main/main.dart', 'main', []);
      setState(() {
        _output = result.toString();
      });
    } catch (e, stack) {
      setState(() {
        _output = 'Erreur: $e\n$stack';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Code Editor"),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _codeController.clear();
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              final content = _codeController.text;
              Clipboard.setData(ClipboardData(text: content));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: CodeField(
                  controller: _codeController,
                  textStyle: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                  ),
                  wrap: false,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                border: Border(top: BorderSide(color: Colors.grey.shade800)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _runCode,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("Run Code"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  _output,
                  style: GoogleFonts.jetBrainsMono(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
