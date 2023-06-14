import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AddEntryDialog extends StatefulWidget {
  const AddEntryDialog({Key? key}) : super(key: key);

  @override
  State<AddEntryDialog> createState() => _AddEntryDialogState();
}

class _AddEntryDialogState extends State<AddEntryDialog> {
  bool _isFever = false;
  bool _isFeelingFeverish = false;
  bool _isMuscleJointPains = false;
  bool _isCough = false;
  bool _isColds = false;
  bool _isSoreThroat = false;
  bool _isDifficultyBreathing = false;
  bool _isDiarrhea = false;
  bool _isLossOfTaste = false;
  bool _isLossOfSmell = false;
  bool _encounter = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: const Center(
          child: Text(
            'Add Entry',
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
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildEntryCard('Fever (37.8°C and above)', _isFever, (value) {
                setState(() {
                  _isFever = value;
                });
              }),
              _buildEntryCard('Feeling Feverish', _isFeelingFeverish, (value) {
                setState(() {
                  _isFeelingFeverish = value;
                });
              }),
              _buildEntryCard('Muscle or Joint Pains', _isMuscleJointPains,
                  (value) {
                setState(() {
                  _isMuscleJointPains = value;
                });
              }),
              _buildEntryCard('Cough', _isCough, (value) {
                setState(() {
                  _isCough = value;
                });
              }),
              _buildEntryCard('Colds', _isColds, (value) {
                setState(() {
                  _isColds = value;
                });
              }),
              _buildEntryCard('Sore Throat', _isSoreThroat, (value) {
                setState(() {
                  _isSoreThroat = value;
                });
              }),
              _buildEntryCard('Difficulty of Breathing', _isDifficultyBreathing,
                  (value) {
                setState(() {
                  _isDifficultyBreathing = value;
                });
              }),
              _buildEntryCard('Diarrhea', _isDiarrhea, (value) {
                setState(() {
                  _isDiarrhea = value;
                });
              }),
              _buildEntryCard('Loss of Taste', _isLossOfTaste, (value) {
                setState(() {
                  _isLossOfTaste = value;
                });
              }),
              _buildEntryCard('Loss of Smell', _isLossOfSmell, (value) {
                setState(() {
                  _isLossOfSmell = value;
                });
              }),
              _buildEntryCard('Has Face-to-face Encounter', _encounter,
                  (value) {
                setState(() {
                  _encounter = value;
                });
              }),
            ],
          ),
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              _saveEntry();
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(String title, bool value, Function(bool) onChanged) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _saveEntry() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.getCurrentUser();
    final currentUserDoc =
        FirebaseFirestore.instance.collection('client').doc(currentUser!.uid);

    try {
      // Fetch the existing entries array
      final documentSnapshot = await currentUserDoc.get();
      final existingEntries =
          List.from(documentSnapshot.data()?['entries'] ?? []);

      final newEntry = {
        'Fever': _isFever,
        'Feeling Feverish': _isFeelingFeverish,
        'Muscle or Joint Pains': _isMuscleJointPains,
        'Cough': _isCough,
        'Colds': _isColds,
        'Sore Throat': _isSoreThroat,
        'Difficulty of Breathing': _isDifficultyBreathing,
        'Diarrhea': _isDiarrhea,
        'Loss of Taste': _isLossOfTaste,
        'Loss of Smell': _isLossOfSmell,
        'Has Face-to-face Encounter': _encounter,
        'Timestamp': DateTime.now(),
        'Status': ''
      };

      // Determine the status for the new entry
      String status = 'Cleared';
      String currentStatus = 'Cleared';
      if (_isFever ||
          _isFeelingFeverish ||
          _isMuscleJointPains ||
          _isCough ||
          _isColds ||
          _isSoreThroat ||
          _isDifficultyBreathing ||
          _isDiarrhea ||
          _isLossOfTaste ||
          _isLossOfSmell) {
        status = 'Under Quarantine';
        currentStatus = 'Under Quarantine';
      } else if (_encounter) {
        status = 'Under Monitoring';
        currentStatus = 'Under Monitoring';
      }

      // update status of newEntry
      newEntry['Status'] = status;

      existingEntries.add(newEntry);

      // Update the entries with the new entry
      await currentUserDoc.update({
        'entries': existingEntries,
        'isNewUser': false,
        'currentStatus': currentStatus
      });

      print("Entry saved successfully!");
    } catch (error) {
      print("Failed to save entry: $error");
    }
  }
}
