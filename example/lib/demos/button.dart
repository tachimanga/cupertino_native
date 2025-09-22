import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class ButtonDemoPage extends StatefulWidget {
  const ButtonDemoPage({super.key});

  @override
  State<ButtonDemoPage> createState() => _ButtonDemoPageState();
}

class _ButtonDemoPageState extends State<ButtonDemoPage> {
  String _last = 'None';

  void _set(String what) => setState(() => _last = what);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Button')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Text buttons'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                CNButton(
                  label: 'Plain',
                  style: CNButtonStyle.plain,
                  onPressed: () => _set('Plain'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Gray',
                  style: CNButtonStyle.gray,
                  onPressed: () => _set('Gray'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Tinted',
                  style: CNButtonStyle.tinted,
                  onPressed: () => _set('Tinted'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Bordered',
                  style: CNButtonStyle.bordered,
                  onPressed: () => _set('Bordered'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'BorderedProminent',
                  style: CNButtonStyle.borderedProminent,
                  onPressed: () => _set('BorderedProminent'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Filled',
                  style: CNButtonStyle.filled,
                  onPressed: () => _set('Filled'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Glass',
                  style: CNButtonStyle.glass,
                  onPressed: () => _set('Glass'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'ProminentGlass',
                  style: CNButtonStyle.prominentGlass,
                  onPressed: () => _set('ProminentGlass'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Disabled',
                  style: CNButtonStyle.bordered,
                  onPressed: null,
                  shrinkWrap: true,
                ),
              ],
            ),
            const SizedBox(height: 48),
            const Text('Icon buttons'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.plain,
                  onPressed: () => _set('Icon Plain'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.gray,
                  onPressed: () => _set('Icon Gray'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.tinted,
                  onPressed: () => _set('Icon Tinted'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.bordered,
                  onPressed: () => _set('Icon Bordered'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.borderedProminent,
                  onPressed: () => _set('Icon BorderedProminent'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.filled,
                  onPressed: () => _set('Icon Filled'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.glass,
                  onPressed: () => _set('Icon Glass'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.prominentGlass,
                  onPressed: () => _set('Icon ProminentGlass'),
                ),
              ],
            ),
            const SizedBox(height: 48),
            const Text('Child widget buttons'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                CNButton.child(
                  style: CNButtonStyle.borderedProminent,
                  onPressed: () => _set('Child Button'),
                  shrinkWrap: true,
                  child: const Text('Custom Child'),
                ),
                SizedBox(
                  height: 70,
                  child: CNButton.child(
                    style: CNButtonStyle.prominentGlass,
                    onPressed: () => _set('Child with Icon Prominent Glass'),
                    shrinkWrap: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.heart_fill,
                            size: 30,
                            color: CupertinoColors.white,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Title',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 24,
                                  ),
                                ),
                                Text(
                                  'Child with Icon Prominent Glass',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                CNButton.child(
                  style: CNButtonStyle.tinted,
                  onPressed: null,
                  shrinkWrap: true,
                  child: const Text('Disabled'),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Center(child: Text('Last pressed: $_last')),
          ],
        ),
      ),
    );
  }
}
