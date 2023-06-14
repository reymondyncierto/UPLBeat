import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class EditEntryDialog extends StatefulWidget {
  final Map<String, dynamic> entry;
//  final Function(Map<String, dynamic>) onUpdate;

  const EditEntryDialog({super.key, required this.entry});

  @override
  _EditEntryDialogState createState() => _EditEntryDialogState();
}

class _EditEntryDialogState extends State<EditEntryDialog> {
  // hardcoded admin ID to ask permission for editing and deleting
  final adminID = 'mFtrE9FVg0TpWoNKQwVGzq2w7Wv1';

  late bool _isFever;
  late bool _isFeelingFeverish;
  late bool _isMuscleJointPains;
  late bool _isCough;
  late bool _isColds;
  late bool _isSoreThroat;
  late bool _isDifficultyBreathing;
  late bool _isDiarrhea;
  late bool _isLossOfTaste;
  late bool _isLossOfSmell;
  late bool _hasEncounter;

  @override
  void initState() {
    super.initState();

    // Initialize the switch values with the values from the entry
    _isFever = widget.entry['Fever'] ?? false;
    _isFeelingFeverish = widget.entry['Feeling Feverish'] ?? false;
    _isMuscleJointPains = widget.entry['Muscle or Joint Pains'] ?? false;
    _isCough = widget.entry['Cough'] ?? false;
    _isColds = widget.entry['Colds'] ?? false;
    _isSoreThroat = widget.entry['Sore Throat'] ?? false;
    _isDifficultyBreathing = widget.entry['Difficulty of Breathing'] ?? false;
    _isDiarrhea = widget.entry['Diarrhea'] ?? false;
    _isLossOfTaste = widget.entry['Loss of Taste'] ?? false;
    _isLossOfSmell = widget.entry['Loss of Smell'] ?? false;
    _hasEncounter = widget.entry['Has Face-to-face Encounter'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: const Center(
          child: Text(
            'Edit Entry',
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
              _buildEntryCard('Has Face-to-face Encounter', _hasEncounter,
                  (value) {
                setState(() {
                  _hasEncounter = value;
                });
              }),
            ],
          ),
        ),
      ),
      actions: [
        ButtonBar(
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedEntry = {
                  'Timestamp':
                      widget.entry['Timestamp'], // Keep the original timestamp
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
                  'Has Face-to-face Encounter': _hasEncounter,
                  'Status': '',
                };

                // Determine the status for the new entry
                String status = 'Cleared';
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
                } else if (_hasEncounter) {
                  status = 'Under Monitoring';
                }

                // Update the status of updatedEntry
                updatedEntry['Status'] = status;

                // Ask Permission from Admin to Edit Entry
                _sendRequestToAdmin(updatedEntry, status, 'edit');
                Navigator.pop(context);
              },
              child: const Text('Request Permission to Edit'),
            ),
          ],
        ),
      ],
    );
  }

  void _sendRequestToAdmin(Map<dynamic, dynamic> editedEntry, String status,
      String requestType) async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.getCurrentUser();
    final admin = FirebaseFirestore.instance.collection('client').doc(adminID);

    try {
      // Fetch the existing requests array from Admin
      final documentSnapshot = await admin.get();
      final existingRequests =
          List.from(documentSnapshot.data()?['requests'] ?? []);
      final newRequest = {
        'userid': currentUser!.uid,
        'editedEntry': editedEntry,
        'currentStatus': status,
        'requestType': requestType
      };

      existingRequests.add(newRequest);

      // Update the requests with the new entry
      await admin.update({'requests': existingRequests});

      print("Request sent to Admin successfully!");
    } catch (error) {
      print("Failed to Send Request: $error");
    }
  }

  void _updateEntry(Map<String, dynamic>? data, Map<String, dynamic> entry,
      Map<String, dynamic> updatedEntry) {
    if (data != null) {
      final entries = List.from(data['entries'] ?? []);
      final index = entries.indexOf(entry);
      if (index != -1) {
        entries[index] = updatedEntry;
        data['entries'] = entries;

        final currentUser = FirebaseAuth.instance.currentUser;
        final currentUserDoc = FirebaseFirestore.instance
            .collection('client')
            .doc(currentUser!.uid);
        currentUserDoc.update(data);
      }
    }
  }

  void _deleteEntry(Map<String, dynamic>? data, Map<String, dynamic> entry) {
    if (data != null) {
      final entries = List.from(data['entries'] ?? []);
      entries.remove(entry);
      data['entries'] = entries;

      final currentUser = FirebaseAuth.instance.currentUser;
      final currentUserDoc =
          FirebaseFirestore.instance.collection('client').doc(currentUser!.uid);
      currentUserDoc.update(data);
    }
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
}
