/*

[Catindig-Cruz-Rada-Yncierto] 
UPLBeat: A Health Monitoring App
CMSC 23 Final Project 2S AY 22-23
[Section B-5L Sir Aldrin Hao] 

*/

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'add_entry_dialog.dart';
import 'preexisting_illness_dialog.dart';
import 'edit_entry_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'drawer.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  bool _isNewUser = false;

  @override
  void initState() {
    super.initState();
    _checkIsNewUser();
  }

  // future method that checks if user is new through bool
  Future<void> _checkIsNewUser() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.getCurrentUser();
    final currentUserDoc =
        FirebaseFirestore.instance.collection('client').doc(currentUser!.uid);

    try {
      final snapshot = await currentUserDoc.get();
      final data = snapshot.data();
      final isNewUser = data?['isNewUser'] as bool?;

      setState(() {
        _isNewUser =
            isNewUser ?? true; // Set _isNewUser to true if value is null
      });
    } catch (error) {
      print("Failed to fetch user data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {

    if (_isNewUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const PreexistingIllnessDialog();
          },
        );
      });
    }

    final String userType = "user";


    return Scaffold(
      appBar: AppBar(
        // leading: Padding(
        //   padding: const EdgeInsets.only(left: 16.0),
        //   child: Image.asset(
        //     'images/logo.png',
        //     fit: BoxFit.contain,
        //     width: 40,
        //     height: 40,
        //   ),
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5A0011), // Maroon
              Color(0xFFD4AF37), // Gold
              Color(0xFF228B22),
            ],
          ),
        ),
        child: ListView(
          children: [
            Column(
              children: [
                _buildProfileSection(),
                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
      // drawer: userType == "user" ? null : const createDrawer(),
      drawer: const createDrawer()
    );
  }

  // checks if two dates are of the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // method to formate date and time of entry
  String _formatDateTime(DateTime dateTime) {
    // list of months
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final month =
        monthNames[dateTime.month - 1]; // extract current month from date
    final day = dateTime.day.toString().padLeft(2, '0'); // extract day
    final year = dateTime.year.toString(); // extract year
    final hour = dateTime.hour == 0 // extract hour
        ? 12
        : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0'); // extract minute
    final period = dateTime.hour >= 12 ? 'pm' : 'am'; // extract period

    return '$month $day, $year at $hour:$minute $period';
  }

  // method to assign color to status
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Cleared':
        return Colors.green;
      case 'Under Monitoring':
        return Colors.orange;
      case 'Under Quarantine':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // widget to build profile section
  Widget _buildProfileSection() {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.getCurrentUser();
    final currentUserDoc =
        FirebaseFirestore.instance.collection('client').doc(currentUser!.uid);

    return StreamBuilder<DocumentSnapshot>(
      stream: currentUserDoc.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasData) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;

          if (data != null) {
            final entries = List.from(data['entries'] ?? []);
            final name = data['name'] as String?;
            // get today's date
            final today = DateTime.now();

            final todaysEntry = entries.firstWhere(
              (entry) => isSameDay(entry['Timestamp'].toDate(), DateTime.now()),
              orElse: () => null,
            );

            entries.sort((a, b) => b['Timestamp'].compareTo(a['Timestamp']));

            return Padding(
              padding: const EdgeInsets.fromLTRB(
                  16.0, 16.0, 16.0, 0.0), // Add margin on top
              child: Column(
                children: [
                  // Profile Container
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.account_circle,
                          size: 100,
                        ),
                        Text(
                          name!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        const Divider(), // Horizontal line
                        if (todaysEntry !=
                            null) // Check if there are entries for today
                          ..._buildStatusSection(
                              todaysEntry), // Build status section
                        Row(
                          children: [
                            if (todaysEntry == null)
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Add entry button callback
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const AddEntryDialog();
                                      },
                                    );
                                  },
                                  child: const Text('Add Entry'),
                                ),
                              ), // Add spacing between the buttons
                            if (todaysEntry != null &&
                                todaysEntry['Status'] == "Cleared")
                              Expanded(
                             child: ElevatedButton(
                                  onPressed: () async {

                                    final today = DateTime.now();
                                    final data = authProvider.getCurrentUser()!.uid;
                                    print(data);

                                    final image = await QrPainter(
                                      data: data,
                                      version: QrVersions.auto,
                                      gapless: false,
                                      color: Colors.black,
                                      emptyColor: Colors.white,
                                    ).toImage(300);
                                     
                                    final recorder = PictureRecorder();
                                    final canvas = Canvas(recorder);
                                    final canvasSize = Size(600, 600);


                                                                    // Fill the canvas with white background
                                    canvas.drawRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height), Paint()..color = Colors.white);

                                    // Calculate the coordinates to center the image
                                    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
                                    final imageRect = Alignment.center.inscribe(imageSize, Offset.zero & canvasSize);

                                    // Draw the image at the center of the canvas
                                    canvas.drawImageRect(image, Offset.zero & imageSize, imageRect, Paint());

                                   // Set up the text style
                                    final textStyle = TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    );

                                    // Calculate the position to insert the text
                                    final textSpan = TextSpan(
                                      text: 'Generated: $today\nStatus: Cleared',
                                      style: textStyle,
                                    );
                                    final textPainter = TextPainter(
                                      text: textSpan,
                                      textDirection: TextDirection.ltr,
                                      textAlign: TextAlign.center,
                                    );
                                    textPainter.layout(minWidth: 0, maxWidth: canvasSize.width);

                                    final textPosition = Offset(
                                      (canvasSize.width - textPainter.width) / 2,
                                      imageRect.bottom + 16, // Added vertical spacing below the image
                                    );

                                    // Draw the text onto the canvas
                                    textPainter.paint(canvas, textPosition);
                                    final picture = recorder.endRecording();
                                    final compositeImage = await picture.toImage(canvasSize.width.toInt(), canvasSize.height.toInt());

                                    // Save the composite image to the gallery
                                    final compositeByteData = await compositeImage.toByteData(format: ImageByteFormat.png);
                                    if (compositeByteData != null) {
                                      final compositeBytes = compositeByteData.buffer.asUint8List();
                                      await ImageGallerySaver.saveImage(compositeBytes);
                                    }

                                    // Assign the QR code image to the variable
                                    final qrCodeImage = QrImageView(
                                      data: '\n$today\nCleared',
                                      version: QrVersions.auto,
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                    );

                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text(
                                            'Scan Me!',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          content: SizedBox(
                                            width: 300,
                                            height: 300,
                                            child: qrCodeImage,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Close'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Save'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Text('Generate QR Code'),
                                ),

                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // Recent Entries Container
                  if (todaysEntry != null)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              "Today's Entry",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          const Divider(), // Horizontal line
                          Card(
                            child: ListTile(
                              title: Text(_formatDateTime(
                                  todaysEntry['Timestamp'].toDate())),
                              leading: Container(
                                width: 8,
                                color: _getStatusColor(todaysEntry['Status']),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _editEntry(todaysEntry);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      //_deleteEntry(todaysEntry);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10.0),

                  // All Entries Container
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'All Entries',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        const Divider(), // Horizontal line
                        if (entries
                            .isNotEmpty) // Show entries only if there are entries
                          Column(
                            children: entries.map((entry) {
                              final timestamp =
                                  entry['Timestamp'] as Timestamp?;
                              final dateTime = timestamp?.toDate();

                              return Card(
                                child: ListTile(
                                  title: Text(_formatDateTime(
                                      entry['Timestamp'].toDate())),
                                  leading: Container(
                                    width: 8,
                                    color: _getStatusColor(entry['Status']),
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        else
                          const Center(
                            child: Text('No entry yet'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  // build status section
  List _buildStatusSection(dynamic todaysEntry) {
    final timestamp = todaysEntry['Timestamp'].toDate() as DateTime?;
    final isTodayEntry = isSameDay(timestamp!, DateTime.now());
    final status = todaysEntry['Status'] as String?;

    if (isTodayEntry) {
      if (status == null) {
        return [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Text(
              'Status: No entry for today',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ];
      } else {
        return [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: status == 'Cleared'
                  ? Colors.green.withOpacity(0.2)
                  : status == 'Under Monitoring'
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: status == 'Cleared'
                        ? Colors.green
                        : status == 'Under Monitoring'
                            ? Colors.orange
                            : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ];
      }
    } else {
      return [];
    }
  }

  // method to show alert dialog for editing entry
  Future<void> _editEntry(Map<String, dynamic> entry) async {
    showDialog(
      context: context,
      builder: (context) {
        return EditEntryDialog(entry: entry);
      },
    );
  }

  // method to delete entry
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
}
