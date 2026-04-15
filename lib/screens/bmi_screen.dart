import 'package:flutter/material.dart';
import 'dart:math';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double? _bmi;
  String _category = '';
  Color _categoryColor = Colors.green;
  String _advice = '';

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final height = double.parse(_heightController.text.trim()) / 100;
    final weight = double.parse(_weightController.text.trim());
    final bmi = weight / pow(height, 2);

    String category;
    Color color;
    String advice;

    if (bmi < 18.5) {
      category = 'Underweight';
      color = Colors.blue.shade400;
      advice =
          'You are underweight. Focus on nutrient-rich foods like nuts, dairy, lean proteins, and whole grains to gain healthy weight.';
    } else if (bmi < 25) {
      category = 'Normal weight';
      color = Colors.green.shade500;
      advice =
          'Great! Your weight is healthy. Maintain a balanced diet with fruits, vegetables, lean proteins, and regular exercise.';
    } else if (bmi < 30) {
      category = 'Overweight';
      color = Colors.orange.shade500;
      advice =
          'You are slightly overweight. Reduce processed foods and sugary drinks. Focus on portion control and daily walks.';
    } else {
      category = 'Obese';
      color = Colors.red.shade400;
      advice =
          'Your BMI indicates obesity. Please consult a doctor or nutritionist. Focus on a calorie-controlled diet and regular physical activity.';
    }

    setState(() {
      _bmi = bmi;
      _category = category;
      _categoryColor = color;
      _advice = advice;
    });
  }

  void _reset() {
    _heightController.clear();
    _weightController.clear();
    setState(() => _bmi = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.monitor_weight_outlined, color: Colors.white),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BMI Calculator',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Body Mass Index',
                    style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BMI Scale card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('BMI Scale',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    _scaleRow(Colors.blue.shade400, 'Underweight', '< 18.5'),
                    _scaleRow(Colors.green.shade500, 'Normal', '18.5 – 24.9'),
                    _scaleRow(
                        Colors.orange.shade500, 'Overweight', '25 – 29.9'),
                    _scaleRow(Colors.red.shade400, 'Obese', '≥ 30'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Inputs
              const Text('Height (cm)',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 165',
                  prefixIcon: const Icon(Icons.height),
                  suffixText: 'cm',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter your height';
                  final h = double.tryParse(v);
                  if (h == null || h < 50 || h > 250) {
                    return 'Enter a valid height (50–250 cm)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Weight (kg)',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 65',
                  prefixIcon: const Icon(Icons.fitness_center),
                  suffixText: 'kg',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter your weight';
                  final w = double.tryParse(v);
                  if (w == null || w < 10 || w > 300) {
                    return 'Enter a valid weight (10–300 kg)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _calculate,
                  child: const Text('Calculate BMI',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              // Result
              if (_bmi != null) ...[
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _categoryColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: _categoryColor.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _bmi!.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: _categoryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: _categoryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _category,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _categoryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _advice,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _reset,
                        child: Text('Calculate Again',
                            style:
                                TextStyle(color: Colors.green.shade600)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _scaleRow(Color color, String label, String range) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(range,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
