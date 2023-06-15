import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class EmployeeInfoDialog extends StatefulWidget {
  const EmployeeInfoDialog({Key? key}) : super(key: key);

  @override
  State<EmployeeInfoDialog> createState() => _EmployeeInfoDialogState();
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
  String? empNo,
  String? position,
  String? homeUnit,
) async {
  final authProvider = context.read<AuthProvider>();
  final currentUser = authProvider.getCurrentUser();
  final currentUserDoc =
      FirebaseFirestore.instance.collection('client').doc(currentUser!.uid);

  try {
    await currentUserDoc.update({
      'empNo': _empNo,
      'position': _position,
      'homeUnit': _homeUnit,
    });

    if (mounted) {
      setState(() {
        _empNo = null;
        _position = null;
        _homeUnit = null;
      });
    }

    print("Employee information saved successfully!");
  } catch (error) {
    print("Failed to save employee information: $error");
    // Handle the error scenario accordingly
  }
}



  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Employee Information',
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.zero,
      buttonPadding: EdgeInsets.zero,
      content: Container(
        width: MediaQuery.of(context).size.width - 100,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTextField(
                  labelText: 'Employee No.',
                  onChanged: (value) {
                    setState(() {
                      _empNo = value;
                    });
                  },
                  errorText: validateName(_empNo, 'Employee No.'),
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  labelText: 'Position',
                  onChanged: (value) {
                    setState(() {
                      _position = value;
                    });
                  },
                  errorText: validateName(_position, 'Position'),
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  labelText: 'Home Unit',
                  onChanged: (value) {
                    setState(() {
                      _homeUnit = value;
                    });
                  },
                  errorText: validateName(_homeUnit, 'Home Unit'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              _saveEmployeeInfo(_empNo, _position, _homeUnit);
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String labelText,
    required ValueChanged<String> onChanged,
    String? errorText,
  }) {
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        errorText: errorText,
      ),
      onChanged: onChanged,
    );
  }
}
