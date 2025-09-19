import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class PopupMenuButtonDemoPage extends StatefulWidget {
  const PopupMenuButtonDemoPage({super.key});

  @override
  State<PopupMenuButtonDemoPage> createState() =>
      _PopupMenuButtonDemoPageState();
}

class _PopupMenuButtonDemoPageState extends State<PopupMenuButtonDemoPage> {
  int? _lastSelected;
  String? _lastSelectedLabel;

  @override
  Widget build(BuildContext context) {
    final items = [
      const CNPopupMenuItem(label: 'New File', icon: CNSymbol('doc', size: 18)),
      const CNPopupMenuItem(
        label: 'New Folder',
        icon: CNSymbol('folder', size: 18),
      ),
      const CNPopupMenuDivider(),
      const CNPopupMenuItem(
        label: 'Rename',
        icon: CNSymbol('rectangle.and.pencil.and.ellipsis', size: 18),
      ),
      const CNPopupMenuItem(
        label: 'Delete',
        icon: CNSymbol('trash', size: 18),
        enabled: false,
      ),
    ];

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Popup Menu Button'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Text button'),
                Spacer(),
                CNPopupMenuButton(
                  buttonLabel: 'Actions',
                  items: items,
                  onSelected: (index, entry) {
                    setState(() {
                      _lastSelected = index;
                      _lastSelectedLabel = entry.label;
                    });
                  },
                  buttonStyle: CNButtonStyle.plain,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Icon button'),
                Spacer(),
                CNPopupMenuButton.icon(
                  buttonIcon: const CNSymbol('ellipsis', size: 18),
                  size: 44,
                  items: items,
                  onSelected: (index, entry) {
                    setState(() {
                      _lastSelected = index;
                      _lastSelectedLabel = entry.label;
                    });
                  },
                  buttonStyle: CNButtonStyle.glass,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_lastSelected != null) ...[
              Center(child: Text('Selected index: $_lastSelected')),
              const SizedBox(height: 8),
              Center(child: Text('Selected label: $_lastSelectedLabel')),
            ],
          ],
        ),
      ),
    );
  }
}
