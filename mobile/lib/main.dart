import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// IMPORTANT: Change this based on your environment
// Android Emulator: 10.0.2.2
// iOS Simulator: 127.0.0.1
// Real Device: Your Computer's Local IP (e.g., 192.168.1.10)
const String apiUrl = "http://10.0.2.2:5000/api/process";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  String? _resultHtml;
  String? _filename;

  Future<void> _pickAndUpload() async {
    // 1. Pick File
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      await _uploadFile(file);
    }
  }

  Future<void> _uploadFile(File file) async {
    setState(() {
      _isLoading = true;
      _resultHtml = null;
    });

    try {
      // 2. Upload to Backend
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          _resultHtml = jsonResponse['html'];
          _filename = jsonResponse['filename'];
        });

        // Navigate to result screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              htmlContent: _resultHtml!,
              filename: _filename ?? "document",
            ),
          ),
        );
      } else {
        _showError("Upload failed: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI OCR Scanner"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Processing... This may take a minute."),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.document_scanner,
                    size: 100,
                    color: Colors.indigo.shade200,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Scan Handwritten PDFs & Tables",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _pickAndUpload,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Select PDF"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final String htmlContent;
  final String filename;

  const ResultScreen({
    super.key,
    required this.htmlContent,
    required this.filename,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Digitized Result"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // In a real app, this would call URL launcher to download the PDF
              // For now, allow viewing source or just a placeholder action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("PDF Download logic would go here."),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Html(
            data: htmlContent,
            style: {
              "table": Style(border: Border.all(color: Colors.grey)),
              "th": Style(
                padding: HtmlPaddings.all(5),
                backgroundColor: Colors.grey.shade200,
              ),
              "td": Style(
                padding: HtmlPaddings.all(5),
                border: Border.all(color: Colors.grey.shade300),
              ),
            },
          ),
        ),
      ),
    );
  }
}
