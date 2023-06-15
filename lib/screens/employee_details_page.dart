import 'package:flutter/material.dart';

class EmployeeDetailsDialog extends StatefulWidget {
  final String name;
  final String email;
  final String position;
  final String homeUnit;
  final String empNo;
  final String userType;
  final bool showUserType; // New parameter
  final Function(String) onUserTypeChanged;

  const EmployeeDetailsDialog({
    Key? key,
    required this.name,
    required this.email,
    required this.position,
    required this.homeUnit,
    required this.empNo,
    required this.userType,
    required this.showUserType, // Initialize the new parameter
    required this.onUserTypeChanged,
  }) : super(key: key);

  @override
  _EmployeeDetailsDialogState createState() => _EmployeeDetailsDialogState();
}

class _EmployeeDetailsDialogState extends State<EmployeeDetailsDialog> {
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
  leading: const Icon(Icons.work),
  title: const Text('Employee No'),
  subtitle: Text(widget.empNo),
),
ListTile(
  leading: const Icon(Icons.email),
  title: const Text('Email'),
  subtitle: Text(widget.email),
),
ListTile(
  leading: const Icon(Icons.work_outline),
  title: const Text('Position'),
  subtitle: Text(widget.position),
),
ListTile(
  leading: const Icon(Icons.home),
  title: const Text('Home Unit'),
  subtitle: Text(widget.homeUnit),
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
