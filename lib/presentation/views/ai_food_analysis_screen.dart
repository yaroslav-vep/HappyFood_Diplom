import 'package:flutter/material.dart';

class AIFoodAnalysisScreen extends StatefulWidget {
  const AIFoodAnalysisScreen({super.key});

  @override
  State<AIFoodAnalysisScreen> createState() => _AIFoodAnalysisScreenState();
}

class _AIFoodAnalysisScreenState extends State<AIFoodAnalysisScreen> {
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;

  void _simulateAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    // Simulate Network/Processing Delay
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _analysisResult = {
          'name': 'Grilled Chicken Salad',
          'calories': 350,
          'protein': 30,
          'fats': 12,
          'carbs': 10,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Food Analysis')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey),
              ),
              child: Center(
                child: _isAnalyzing
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Analyzing Food...'),
                        ],
                      )
                    : _analysisResult != null
                    ? Image.network(
                        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                        fit: BoxFit.cover,
                      )
                    : Icon(Icons.camera_alt, size: 64, color: Colors.grey[400]),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _simulateAnalysis,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload / Take Photo'),
            ),
            if (_analysisResult != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detected: ${_analysisResult!['name']}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNutrientInfo(
                            'Calories',
                            '${_analysisResult!['calories']}',
                          ),
                          _buildNutrientInfo(
                            'Protein',
                            '${_analysisResult!['protein']}g',
                          ),
                          _buildNutrientInfo(
                            'Fats',
                            '${_analysisResult!['fats']}g',
                          ),
                          _buildNutrientInfo(
                            'Carbs',
                            '${_analysisResult!['carbs']}g',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Added to your daily intake!'),
                              ),
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Add to Intake'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
