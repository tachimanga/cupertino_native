import 'package:cupertino_native/components/alert_dialog.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlertDialogDemoPage extends StatefulWidget {
  const AlertDialogDemoPage({super.key});

  @override
  State<AlertDialogDemoPage> createState() => _AlertDialogDemoPageState();
}

class _AlertDialogDemoPageState extends State<AlertDialogDemoPage> {
  String? _lastAction;

  void _showSimpleAlert() {
    CNAlertDialog.show(
      context: context,
      title: 'Simple Alert',
      message: 'This is a simple alert with liquid glass design.',
      actions: [
        CNAlertAction(
          title: 'OK',
          onPressed: () {
            setState(() => _lastAction = 'OK pressed');
          },
        ),
      ],
      style: CNButtonStyle.glass,
    );
  }

  void _showConfirmationAlert() {
    CNAlertDialog.show(
      context: context,
      title: 'Delete Item',
      message:
          'Are you sure you want to delete this item? This action cannot be undone.',
      actions: [
        CNAlertAction(
          title: 'Cancel',
          style: CNAlertActionStyle.cancel,
          onPressed: () {
            setState(() => _lastAction = 'Cancel pressed');
          },
        ),
        CNAlertAction(
          title: 'Delete',
          style: CNAlertActionStyle.destructive,
          onPressed: () {
            setState(() => _lastAction = 'Delete pressed');
          },
        ),
      ],
      icon: const CNSymbol('trash', size: 24, color: CupertinoColors.systemRed),
      style: CNButtonStyle.prominentGlass,
    );
  }

  void _showMultipleActionsAlert() {
    CNAlertDialog.show(
      context: context,
      title: 'Choose Action',
      message: 'What would you like to do with this file?',
      actions: [
        CNAlertAction(
          title: 'Save',
          onPressed: () {
            setState(() => _lastAction = 'Save pressed');
          },
        ),
        CNAlertAction(
          title: 'Save As...',
          onPressed: () {
            setState(() => _lastAction = 'Save As pressed');
          },
        ),
        CNAlertAction(
          title: 'Cancel',
          style: CNAlertActionStyle.cancel,
          onPressed: () {
            setState(() => _lastAction = 'Cancel pressed');
          },
        ),
      ],
      icon: const CNSymbol('doc.fill', size: 24),
      style: CNButtonStyle.glass,
    );
  }

  void _showWarningAlert() {
    CNAlertDialog.show(
      context: context,

      title: 'Network Error',
      message:
          'Unable to connect to the server. Please check your internet connection and try again.',
      actions: [
        CNAlertAction(
          title: 'Retry',
          style: CNAlertActionStyle.defaultAction,
          onPressed: () {
            setState(() => _lastAction = 'Retry pressed');
          },
        ),
        CNAlertAction(
          title: 'Cancel',
          style: CNAlertActionStyle.cancel,
          onPressed: () {
            print("object");
            setState(() => _lastAction = 'Cancel pressed');
          },
        ),
      ],
      icon: const CNSymbol(
        'wifi.exclamationmark',
        size: 24,
        color: CupertinoColors.systemOrange,
      ),
      style: CNButtonStyle.bordered,
    );
  }

  void _showSuccessAlert() {
    CNAlertDialog.show(
      context: context,
      title: 'Success',
      message: 'Your file has been saved successfully.',
      actions: [
        CNAlertAction(
          title: 'Great!',
          style: CNAlertActionStyle.primary,
          onPressed: () {
            setState(() => _lastAction = 'Great pressed');
          },
        ),
      ],
      icon: const CNSymbol(
        'checkmark.circle.fill',
        size: 24,
        color: CupertinoColors.systemGreen,
      ),
      style: CNButtonStyle.bordered,
    );
  }

  void _showActionStylesAlert() {
    CNAlertDialog.show(
      context: context,
      title: 'Action Styles Demo',
      message: 'This alert demonstrates different action button styles.',
      actions: [
        CNAlertAction(
          title: 'Primary',
          style: CNAlertActionStyle.primary,
          onPressed: () {
            setState(() => _lastAction = 'Primary pressed');
          },
        ),
        CNAlertAction(
          title: 'Success',
          style: CNAlertActionStyle.success,
          onPressed: () {
            setState(() => _lastAction = 'Success pressed');
          },
        ),
        CNAlertAction(
          title: 'Warning',
          style: CNAlertActionStyle.warning,
          onPressed: () {
            setState(() => _lastAction = 'Warning pressed');
          },
        ),
        CNAlertAction(
          title: 'Info',
          style: CNAlertActionStyle.info,
          onPressed: () {
            setState(() => _lastAction = 'Info pressed');
          },
        ),
        CNAlertAction(
          title: 'Secondary',
          style: CNAlertActionStyle.secondary,
          onPressed: () {
            setState(() => _lastAction = 'Secondary pressed');
          },
        ),
        CNAlertAction(
          title: 'Cancel',
          style: CNAlertActionStyle.cancel,
          onPressed: () {
            // setState(() => _lastAction = 'Cancel pressed');
          },
        ),
      ],
      icon: const CNSymbol(
        'paintbrush.fill',
        size: 24,
        color: CupertinoColors.systemBlue,
      ),
      style: CNButtonStyle.bordered,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Alert Dialog'),
        backgroundColor: CupertinoColors.systemGroupedBackground,
        border: null,
      ),
      child: ListView(
        children: [
          CupertinoListSection.insetGrouped(
            header: Text('Alert Dialog Examples'),
            children: [
              CupertinoListTile(
                title: Text('Simple Alert'),
                leading: const Icon(CupertinoIcons.exclamationmark_circle),
                subtitle: Text('Basic alert with glass effect'),
                onTap: _showSimpleAlert,
              ),

              CupertinoListTile(
                title: Text('Confirmation Alert'),
                leading: const Icon(CupertinoIcons.trash),
                subtitle: Text('Delete confirmation with destructive action'),
                onTap: _showConfirmationAlert,
              ),

              CupertinoListTile(
                title: Text('Multiple Actions'),
                leading: const Icon(CupertinoIcons.ellipsis),
                subtitle: Text('Alert with multiple choice actions'),
                onTap: _showMultipleActionsAlert,
              ),

              CupertinoListTile(
                title: Text('Warning Alert'),
                leading: const Icon(CupertinoIcons.exclamationmark_triangle),
                subtitle: Text('Network error with retry option'),
                onTap: _showWarningAlert,
              ),

              CupertinoListTile(
                title: Text('Success Alert'),
                leading: const Icon(CupertinoIcons.checkmark_circle),
                subtitle: Text('Success message with checkmark'),
                onTap: _showSuccessAlert,
              ),

              CupertinoListTile(
                title: Text('Action Styles'),
                leading: const Icon(CupertinoIcons.paintbrush),
                subtitle: Text('Different button styles showcase'),
                onTap: _showActionStylesAlert,
              ),
            ],
          ),

          const SizedBox(height: 32),

          if (_lastAction != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Last Action',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(_lastAction!),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDemoButton({
    required String title,
    required String description,
    required VoidCallback onPressed,
  }) {
    return CupertinoListTile(
      title: Text(title),
      onTap: onPressed,
      subtitle: Text(description),
    );
  }
}
