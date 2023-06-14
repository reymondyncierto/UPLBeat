import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminEditsUser extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> userData;
  // final Function(Map<String, dynamic>) onUpdate;

  const AdminEditsUser({super.key, required this.userData});
  //const AdminEditsUser({required this.userData, required this.onUpdate});
  @override
  _AdminEditsUserState createState() => _AdminEditsUserState();
}

class _AdminEditsUserState extends State<AdminEditsUser> {
  late bool isFever = false;
  late bool isFeelingFeverish = false;
  late bool isMuscleJointPains = false;
  late bool isCough = false;
  late bool isColds = false;
  late bool isSoreThroat = false;
  late bool isDifficultyBreathing = false;
  late bool isDiarrhea = false;
  late bool isLossOfTaste = false;
  late bool isLossOfSmell = false;
  late bool hasEncounter = false;

  late final name;
  //late final lastName;
  late final currentStatus;
  late final docID;
  late String userType;
  late List<dynamic> entries = [];
  late Map<dynamic, dynamic> lastEntry = {};

  // late final dropdownValue = 'User';

  @override
  void initState() {
    super.initState();

    docID = widget.userData.id;
    print(docID.toString());

    name = widget.userData['name'];
    // lastName = widget.userData['lastName'];
    userType = widget.userData['userType'];
    currentStatus = widget.userData['currentStatus'];
    entries = widget.userData['entries'] ?? [];
    // print(entries);

    if (entries.isNotEmpty) {
      lastEntry = entries.last ?? {};
      //print(lastEntry);

      isFever = lastEntry['Fever'] ?? false;
      isFeelingFeverish = lastEntry['Feeling Feverish'] ?? false;
      isMuscleJointPains = lastEntry['Muscle or Joint Pains'] ?? false;
      isCough = lastEntry['Cough'] ?? false;
      isColds = lastEntry['Colds'] ?? false;
      isSoreThroat = lastEntry['Sore Throat'] ?? false;
      isDifficultyBreathing = lastEntry['Difficulty of Breathing'] ?? false;
      isDiarrhea = lastEntry['Diarrhea'] ?? false;
      isLossOfTaste = lastEntry['Loss of Taste'] ?? false;
      isLossOfSmell = lastEntry['Loss of Smell'] ?? false;
      hasEncounter = lastEntry['Has Face-to-face Encounter'] ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('$name'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(),
            Center(
                child: Row(children: [
              const Text("User Type"),
              const SizedBox(width: 10.0),
              DropdownButton<String>(
                value: userType,
                items: <String>['user', 'admin', 'em']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 15),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    userType = newValue!;
                  });
                },
              )
            ])),
            Text("Status: $currentStatus",
                style: TextStyle(
                  color: currentStatus == 'Cleared'
                      ? Colors.green.withOpacity(0.8)
                      : currentStatus == 'Under Monitoring'
                          ? Colors.orange.withOpacity(0.8)
                          : Colors.red.withOpacity(0.8),
                )),
            symptoms()
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final currUser =
                FirebaseFirestore.instance.collection('client').doc(docID);

            if (entries.isNotEmpty) {
              currUser.get().then((DocumentSnapshot snapshot) {
                if (snapshot.exists) {
                  final data = snapshot.data() as Map<String, dynamic>;
                  final dataArray = List.from(data['entries']);
                  final timestamp =
                      dataArray[dataArray.length - 1]['Timestamp'];

                  String currStatus = '';
                  String status = '';

                  if (isFever ||
                      isFeelingFeverish ||
                      isMuscleJointPains ||
                      isCough ||
                      isColds ||
                      isSoreThroat ||
                      isDifficultyBreathing ||
                      isDiarrhea ||
                      isLossOfTaste ||
                      isLossOfSmell) {
                    currStatus = 'Under Quarantine';
                    status = 'Under Quarantine';
                  } else if (hasEncounter) {
                    currStatus = 'Under Monitoring';
                    status = 'Under Monitoring';
                  } else {
                    currStatus = 'Cleared';
                    status = 'Cleared';
                  }

                  final updatedEntry = {
                    'Fever': isFever,
                    'Feeling Feverish': isFeelingFeverish,
                    'Muscle or Joint Pains': isMuscleJointPains,
                    'Cough': isCough,
                    'Colds': isColds,
                    'Sore Throat': isSoreThroat,
                    'Difficulty of Breathing': isDifficultyBreathing,
                    'Diarrhea': isDiarrhea,
                    'Loss of Taste': isLossOfTaste,
                    'Loss of Smell': isLossOfSmell,
                    'Has Face-to-face Encounter': hasEncounter,
                    'Timestamp': timestamp,
                    'status': status
                  };

                  dataArray[dataArray.length - 1] = updatedEntry;

                  currUser.update({
                    'entries': dataArray,
                    'userType': userType,
                    'currentStatus': currStatus
                  });
                } else {
                  print('Document does not exist.');
                }
              }).catchError((error) {
                print('Error getting document: $error');
              });
            }

            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  // widget for symptoms (only built when user's entries array is non-empty)
  Widget symptoms() {
    if (entries.isNotEmpty) {
      return (Column(children: [
        _buildEntrySwitchListTile(
          'Fever (37.8°C and above)',
          isFever,
          (value) {
            setState(() {
              isFever = value;
            });
          },
        ),
        _buildEntrySwitchListTile(
          'Feeling Feverish',
          isFeelingFeverish,
          (value) {
            setState(() {
              isFeelingFeverish = value;
            });
          },
        ),
        _buildEntrySwitchListTile('Muscle or Joint Pains', isMuscleJointPains,
            (value) {
          setState(() {
            isMuscleJointPains = value;
          });
        }),
        _buildEntrySwitchListTile('Cough', isCough, (value) {
          setState(() {
            isCough = value;
          });
        }),
        _buildEntrySwitchListTile('Colds', isColds, (value) {
          setState(() {
            isColds = value;
          });
        }),
        _buildEntrySwitchListTile('Sore Throat', isSoreThroat, (value) {
          setState(() {
            isSoreThroat = value;
          });
        }),
        _buildEntrySwitchListTile(
            'Difficulty of Breathing', isDifficultyBreathing, (value) {
          setState(() {
            isDifficultyBreathing = value;
          });
        }),
        _buildEntrySwitchListTile('Diarrhea', isDiarrhea, (value) {
          setState(() {
            isDiarrhea = value;
          });
        }),
        _buildEntrySwitchListTile('Loss of Taste', isLossOfTaste, (value) {
          setState(() {
            isLossOfTaste = value;
          });
        }),
        _buildEntrySwitchListTile('Loss of Smell', isLossOfSmell, (value) {
          setState(() {
            isLossOfSmell = value;
          });
        }),
        _buildEntrySwitchListTile('Has Face-to-face Encounter', hasEncounter,
            (value) {
          setState(() {
            hasEncounter = value;
          });
        })
      ]));
    } else {
      return (const SizedBox.shrink());
    }
  }

  Widget _buildEntrySwitchListTile(
      String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  //     void _editUser(QueryDocumentSnapshot<Map<String, dynamic>> userData, Map<String, dynamic> entry, String userType) {
  //  //  if (userData != null) {
  //     final entries = List.from(data['entries'] ?? []);
  //     final index = entries.indexOf(entry);
  //     if (index != -1) {
  //       entries[index] = updatedEntry;
  //       data['entries'] = entries;

  //       final currentUser = FirebaseAuth.instance.currentUser;
  //       final currentUserDoc = FirebaseFirestore.instance
  //           .collection('client')
  //           .doc(currentUser!.uid);
  //       currentUserDoc.update(data);
  //     }
  // //  }
  // }

  //   void _updateEntry(Map<String, dynamic>? data, Map<String, dynamic> entry,
  //     Map<String, dynamic> updatedEntry) {
  //   if (data != null) {
  //     final entries = List.from(data['entries'] ?? []);
  //     final index = entries.indexOf(entry);
  //     if (index != -1) {
  //       entries[index] = updatedEntry;
  //       data['entries'] = entries;

  //       final currentUser = FirebaseAuth.instance.currentUser;
  //       final currentUserDoc = FirebaseFirestore.instance
  //           .collection('client')
  //           .doc(currentUser!.uid);
  //       currentUserDoc.update(data);
  //     }
  //   }
  // }
}
