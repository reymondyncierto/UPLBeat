import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'drawer.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  bool isPaused = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const createDrawer(),
      appBar: AppBar(title: const Text('Scanning QR'), actions: <Widget>[
        IconButton(
          onPressed: () async {
            await controller?.toggleFlash();
            setState(() {});
          },
          icon: FutureBuilder<bool?>(
            future: controller?.getFlashStatus(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Icon(
                  snapshot.data! ? Icons.flash_on : Icons.flash_off,
                  size: 24,
                );
              } else {
                return const Icon(
                  Icons.flash_off,
                  size: 24,
                );
              }
            },
          ),
        ),
        IconButton(
          onPressed: () async {
            await controller?.flipCamera();
            setState(() {});
          },
          icon: const Icon(
            Icons.flip_camera_ios_sharp,
            size: 24,
          ),
        ),
      ]),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result == null) const Text('Scan a QR code'),
                  if (result != null) ...[
                    FutureBuilder<Map<String, dynamic>?>(
                      future: _getUserInfo(result!.code!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasData) {
                          final userInfo = snapshot.data!;
                          final studno = userInfo['studno'];
                          final currentStatus = userInfo['currentStatus'];
                          print(userInfo);
                          print('User Status: $currentStatus');
                          print('User studno: $studno');
                          if (currentStatus == 'Cleared') {
                            _saveStudentLog(
                                result!.code!, studno, currentStatus);
                          }
                          return Column(
                            children: [
                              Text(
                                'Student Number: $studno',
                              ),
                              Text(
                                'Status: $currentStatus',
                              ),
                            ],
                          );
                        } else {
                          return const Text(
                              'Failed to fetch user information.');
                        }
                      },
                    ),
                  ],
                  Container(
                    margin: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (isPaused) {
                          await controller?.resumeCamera();
                          isPaused = false;
                          setState(() {
                            result = null; // Reset result field to null
                          });
                        } else {
                          await controller?.pauseCamera();
                          isPaused = true;
                        }
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 18),
                        backgroundColor: isPaused
                            ? const Color(0xFF228B22)
                            : const Color(0xFF5A0011),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        isPaused ? 'Resume' : 'Pause',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _saveStudentLog(String uid, String studno, String currentStatus) async {
    final currentUserDoc =
        FirebaseFirestore.instance.collection('client').doc(uid);

    try {
      // Fetch the existing entries array
      final documentSnapshot = await currentUserDoc.get();

      final existingLogs =
          List.from(documentSnapshot.data()?['student_logs'] ?? []);

      final newLog = {
        'location': 'ICS',
        'studno': studno,
        'status': currentStatus,
        'dateTime': DateTime.now(),
      };

      existingLogs.add(newLog);

      await currentUserDoc.update({
        'student_logs': existingLogs,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student log saved.')),
      );

      print("Log saved successfully!");
    } catch (error) {
      print("Failed to save entry: $error");
    }
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 500.0; // Increase the scan area size here
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }


  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      if (isPaused) {
        return;
      }
      setState(() {
        result = scanData;
      });

      if (scanData.code != null) {
        final uid = scanData.code;
        final userInfo = await _getUserInfo(uid!);

        if (userInfo != null) {
          final studno = userInfo['studentNumber'];
          final currentStatus = userInfo['currentStatus'];

          print('User studno: $studno');
          print('User Status: $currentStatus');
        }
      }
      await controller.pauseCamera();
      setState(() {
        isPaused = true;
      });
    });
  }

  Future<Map<String, String>?> _getUserInfo(String uid) async {
    final currentUserDoc =
        FirebaseFirestore.instance.collection('client').doc(uid);

    final snapshot = await currentUserDoc.get();
    final data = snapshot.data();
    if (data != null) {
      final studno = data['studentNumber'] as String?;
      final currentStatus = data['currentStatus'] as String?;
      return {
        'studno': studno ?? 'name not found',
        'currentStatus': currentStatus ?? 'status not found',
      };
    }
    return null;
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
