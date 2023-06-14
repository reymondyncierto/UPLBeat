import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class EmployeeInfoDialog extends StatefulWidget {
  const EmployeeInfoDialog({Key? key}) : super(key: key);

  @override
  State<EmployeeInfoDialog> createState() =>
      _EmployeeInfoDialogState();
}

class _EmployeeInfoDialogState extends State<EmployeeInfoDialog> {
  
  String? _empNo;
  String? _position;
  String? _homeUnit;

  String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<void> _saveEmployeeInfo(
      String? empNo, String? position, String? homeUnit) async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.getCurrentUser();
    final currentUserDoc =
        FirebaseFirestore.instance.collection('client').doc(currentUser!.uid);

    try {
      await currentUserDoc.update({
        // 'preExistingIllness': {
        //   'Hypertension': _selectedIllnessesMap['Hypertension'] ?? false,
        //   'Diabetes': _selectedIllnessesMap['Diabetes'] ?? false,
        //   'Tuberculosis': _selectedIllnessesMap['Tuberculosis'] ?? false,
        //   'Cancer': _selectedIllnessesMap['Cancer'] ?? false,
        //   'Kidney Disease': _selectedIllnessesMap['Kidney Disease'] ?? false,
        //   'Cardiac Disease': _selectedIllnessesMap['Cardiac Disease'] ?? false,
        //   'Autoimmune Disease':
        //       _selectedIllnessesMap['Autoimmune Disease'] ?? false,
        //   'Asthma': _selectedIllnessesMap['Asthma'] ?? false,
        //   'Allergies': _allergies,
        // },
        // 'isNewUser': false,
        'empNo': _empNo,
        'position': _position,
        'homeUnit': _homeUnit,
      });

      print("Employee information saved successfully!");
    } catch (error) {
      print("Failed to save employee information: $error");
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
            'Employee Information',
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
                  // for (int i = 0; i < _illnesses.length; i++)
                  //   if (_illnesses[i] == "Allergies")
                  //     _buildAllergiesTextField()
                  //   else
                  //     _buildIllnessSwitchListTile(_illnesses[i]),
                  
                  _buildEmpNoTextField(),
                  _buildPositionTextField(),
                  _buildHomeUnitTextField(),
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
            // List<String> selectedIllnesses = [];
            // _selectedIllnessesMap.forEach((illness, isSelected) {
            //   if (isSelected) {
            //     selectedIllnesses.add(illness);
            //   }
            // });

            // _saveIllnessesAndAllergies(selectedIllnesses);
            
_saveEmployeeInfo(_empNo, _position, _homeUnit);
            Navigator.pop(context);
          },
          child: const Text("Submit"),
        ))
      ],
    );
  }

  Widget _buildEmpNoTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
          labelText: "Employee No.",
        ),
        onChanged: (value) {
          setState(() {
            _empNo = value; 
          });
        },
      ),
    );
  }

  Widget _buildPositionTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
          labelText: "Position",
        ),
        onChanged: (value) {
          setState(() {
          //   _allergies =
          //       value.split(",").map((allergy) => allergy.trim()).toList();
              _position = value;
          });
        },
      ),
    );
  }

  Widget _buildHomeUnitTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
          labelText: "Home Unit",
        ),
        onChanged: (value) {
          setState(() {
            // _allergies =
            //     value.split(",").map((allergy) => allergy.trim()).toList();
            _homeUnit = value;
          });
        },
      ),
    );
  }
}
