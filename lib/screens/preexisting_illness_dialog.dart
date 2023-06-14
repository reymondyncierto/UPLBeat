import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class PreexistingIllnessDialog extends StatefulWidget {
  const PreexistingIllnessDialog({Key? key}) : super(key: key);

  @override
  State<PreexistingIllnessDialog> createState() =>
      _PreexistingIllnessDialogState();
}

class _PreexistingIllnessDialogState extends State<PreexistingIllnessDialog> {
  final List<String> _illnesses = [
    "Hypertension",
    "Diabetes",
    "Tuberculosis",
    "Cancer",
    "Kidney Disease",
    "Cardiac Disease",
    "Autoimmune Disease",
    "Asthma",
    "Allergies",
  ];
  List<String> _allergies = [];
  final Map<String, bool> _selectedIllnessesMap = {};

  Future<void> _saveIllnessesAndAllergies(
      List<String> selectedIllnesses) async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.getCurrentUser();
    final currentUserDoc =
        FirebaseFirestore.instance.collection('client').doc(currentUser!.uid);

    try {
      await currentUserDoc.update({
        'preExistingIllness': {
          'Hypertension': _selectedIllnessesMap['Hypertension'] ?? false,
          'Diabetes': _selectedIllnessesMap['Diabetes'] ?? false,
          'Tuberculosis': _selectedIllnessesMap['Tuberculosis'] ?? false,
          'Cancer': _selectedIllnessesMap['Cancer'] ?? false,
          'Kidney Disease': _selectedIllnessesMap['Kidney Disease'] ?? false,
          'Cardiac Disease': _selectedIllnessesMap['Cardiac Disease'] ?? false,
          'Autoimmune Disease':
              _selectedIllnessesMap['Autoimmune Disease'] ?? false,
          'Asthma': _selectedIllnessesMap['Asthma'] ?? false,
          'Allergies': _allergies,
        },
        'isNewUser': false,
      });

      print("Illnesses and allergies saved successfully!");
    } catch (error) {
      print("Failed to save illnesses and allergies: $error");
      // Handle the error scenario accordingly
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        margin: const EdgeInsets.only(bottom: 5.0),
        child: const Center(
          child: Text(
            'Pre-existing Illnesses',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.zero,
      buttonPadding: EdgeInsets.zero,
      content: Container(
        width: MediaQuery.of(context).size.width - 100,
        height: MediaQuery.of(context).size.height - 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              Column(
                children: [
                  for (int i = 0; i < _illnesses.length; i++)
                    if (_illnesses[i] == "Allergies")
                      _buildAllergiesTextField()
                    else
                      _buildIllnessSwitchListTile(_illnesses[i]),
                ],
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
      actions: [
        Center(
            child: ElevatedButton(
          onPressed: () {
            List<String> selectedIllnesses = [];
            _selectedIllnessesMap.forEach((illness, isSelected) {
              if (isSelected) {
                selectedIllnesses.add(illness);
              }
            });

            _saveIllnessesAndAllergies(selectedIllnesses);

            Navigator.pop(context);
          },
          child: const Text("Submit"),
        ))
      ],
    );
  }

  Widget _buildAllergiesTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
          labelText: "Allergies (comma-separated)",
        ),
        onChanged: (value) {
          setState(() {
            _allergies =
                value.split(",").map((allergy) => allergy.trim()).toList();
          });
        },
      ),
    );
  }

  Widget _buildIllnessSwitchListTile(String illness) {
    return Card(
      child: SwitchListTile(
        title: Text(illness),
        value: _selectedIllnessesMap[illness] ?? false,
        onChanged: (bool value) {
          setState(() {
            _selectedIllnessesMap[illness] = value;
          });
        },
      ),
    );
  }
}
