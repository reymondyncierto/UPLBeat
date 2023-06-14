import 'package:flutter/material.dart';

class UserDetailsDialog extends StatefulWidget {
  final String name;
  final String email;
  final String college;
  final String course;
  final String studentNo;
  final String userType;
  final bool showUserType; // New parameter
  final Function(String) onUserTypeChanged;

  const UserDetailsDialog({
    Key? key,
    required this.name,
    required this.email,
    required this.college,
    required this.course,
    required this.studentNo,
    required this.userType,
    required this.showUserType, // Initialize the new parameter
    required this.onUserTypeChanged,
  }) : super(key: key);

  @override
  _UserDetailsDialogState createState() => _UserDetailsDialogState();
}

class _UserDetailsDialogState extends State<UserDetailsDialog> {
  late String selectedUserType;

  @override
  void initState() {
    super.initState();
    selectedUserType = widget.userType;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(
                  Icons.person,
                  size: 80,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (widget.showUserType) // Conditionally display the section
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Change User Type: "),
                      const SizedBox(width: 10.0),
                      DropdownButton<String>(
                        value: selectedUserType,
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
                          if (newValue != null) {
                            setState(() {
                              selectedUserType = newValue;
                            });
                            widget.onUserTypeChanged(selectedUserType);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              const Divider(),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Student No'),
                subtitle: Text(widget.studentNo),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(widget.email),
              ),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('Course'),
                subtitle: Text(widget.course),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance),
                title: const Text('College'),
                subtitle: Text(widget.college),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
