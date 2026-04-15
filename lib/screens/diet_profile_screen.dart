import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/diet_profile.dart';
import '../services/profile_service.dart';
import '../services/firestore_service.dart';
import 'home_screen.dart';

class DietProfileScreen extends StatefulWidget {
  final DietProfile? existingProfile;
  final bool isFirstSetup;

  const DietProfileScreen({
    super.key,
    this.existingProfile,
    this.isFirstSetup = false,
  });

  @override
  State<DietProfileScreen> createState() => _DietProfileScreenState();
}

class _DietProfileScreenState extends State<DietProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _profileService = ProfileService();

  String _selectedGoal = 'Eat healthier';
  final Set<String> _selectedRestrictions = {};

  static const List<String> _goals = [
    'Lose weight',
    'Gain muscle',
    'Maintain weight',
    'Eat healthier',
    'Manage diabetes',
    'Reduce cholesterol',
  ];

  static const List<String> _restrictionOptions = [
    'None',
    'Vegan',
    'Vegetarian',
    'Diabetic',
    'Gluten-free',
    'Dairy-free',
    'Nut allergy',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      _ageController.text = widget.existingProfile!.age.toString();
      _selectedGoal = widget.existingProfile!.goal;
      _selectedRestrictions.addAll(widget.existingProfile!.restrictions);
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final restrictions = _selectedRestrictions.isEmpty
        ? ['None']
        : _selectedRestrictions.toList();

    final profile = DietProfile(
      age: int.parse(_ageController.text.trim()),
      goal: _selectedGoal,
      restrictions: restrictions,
    );

    await _profileService.saveProfile(profile);

    // Also save to Firestore if user is logged in
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await FirestoreService().saveProfile(profile);
      } catch (_) {}
    }

    if (!mounted) return;
    if (widget.isFirstSetup) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(initialProfile: profile),
        ),
      );
    } else {
      Navigator.pop(context, profile);
    }
  }

  void _toggleRestriction(String value) {
    setState(() {
      if (value == 'None') {
        _selectedRestrictions.clear();
        _selectedRestrictions.add('None');
      } else {
        _selectedRestrictions.remove('None');
        if (_selectedRestrictions.contains(value)) {
          _selectedRestrictions.remove(value);
        } else {
          _selectedRestrictions.add(value);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: !widget.isFirstSetup,
        title: Row(
          children: [
            const Icon(Icons.person, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              widget.isFirstSetup
                  ? 'Set Up Your Diet Profile'
                  : 'Edit Diet Profile',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isFirstSetup) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tell us about yourself so we can give you personalized nutrition advice.',
                          style: TextStyle(
                              color: Colors.green.shade800, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              _sectionLabel('Your Age'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter your age',
                  prefixIcon: const Icon(Icons.cake_outlined),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 5 || age > 120) {
                    return 'Enter a valid age (5–120)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _sectionLabel('Health Goal'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGoal,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    items: _goals.map((goal) {
                      return DropdownMenuItem(value: goal, child: Text(goal));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedGoal = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _sectionLabel('Dietary Restrictions'),
              const SizedBox(height: 4),
              Text(
                'Select all that apply',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _restrictionOptions.map((option) {
                  final selected = _selectedRestrictions.contains(option);
                  return FilterChip(
                    label: Text(option),
                    selected: selected,
                    onSelected: (_) => _toggleRestriction(option),
                    selectedColor: Colors.green.shade100,
                    checkmarkColor: Colors.green.shade700,
                    labelStyle: TextStyle(
                      color: selected
                          ? Colors.green.shade800
                          : Colors.grey.shade700,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: selected
                          ? Colors.green.shade400
                          : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 36),
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
                    elevation: 2,
                  ),
                  onPressed: _saveProfile,
                  child: Text(
                    widget.isFirstSetup
                        ? 'Save & Start Chatting'
                        : 'Save Profile',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}
