// lib/views/crop_health_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/gemini_service.dart';

class CropHealthScreen extends StatefulWidget {
  const CropHealthScreen({super.key});

  @override
  State<CropHealthScreen> createState() => _CropHealthScreenState();
}

class _CropHealthScreenState extends State<CropHealthScreen> {
  XFile? _selectedImage;
  String _diagnosis = '';
  bool _isAnalyzing = false;

  Future<void> _chooseImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _selectedImage = picked;
        _diagnosis = '';
      });
    }
  }

  Future<void> _analyzeImage(String languageCode) async {
    if (_selectedImage == null) {
      return;
    }
    setState(() {
      _isAnalyzing = true;
      _diagnosis = '';
    });
    final service = GeminiService();
    final response = await service.diagnoseCropImage(_selectedImage!, languageCode);
    setState(() {
      _diagnosis = response;
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    final languageCode = context.watch<LanguageProvider>().languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(strings.cropHealth)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(strings.selectImage, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _chooseImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: Text(strings.takePhoto),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _chooseImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: Text(strings.chooseFromGallery),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Card(
            child: SizedBox(
              width: double.infinity,
              height: 220,
              child: _selectedImage == null
                  ? Center(child: Text(strings.noImageSelected))
                  : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _selectedImage == null || _isAnalyzing
                ? null
                : () => _analyzeImage(languageCode),
            child: Text(strings.analyzeCropHealth),
          ),
          const SizedBox(height: 20),
          if (_isAnalyzing)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  const SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
                  const SizedBox(width: 16),
                  Text(strings.analyzing),
                ]),
              ),
            ),
          if (_diagnosis.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(strings.diagnosis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Text(_diagnosis, style: const TextStyle(fontSize: 15, height: 1.5)),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}
