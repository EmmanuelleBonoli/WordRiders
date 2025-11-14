import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool musicOn = true;
  bool sfxOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('settings.title'))),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          Text(
            tr('settings.language'),
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 8),
          DropdownButton<Locale>(
            value: context.locale,
            dropdownColor: Colors.grey[900],
            items: const [
              DropdownMenuItem(value: Locale('en'), child: Text('English')),
              DropdownMenuItem(value: Locale('fr'), child: Text('Français')),
            ],
            onChanged: (newLocale) {
              if (newLocale != null) context.setLocale(newLocale);
            },
          ),
          const Divider(color: Colors.white24),
          SwitchListTile(
            title: Text(
              tr('settings.enableMusic'),
              style: const TextStyle(color: Colors.white),
            ),
            value: musicOn,
            onChanged: (val) => setState(() => musicOn = val),
          ),
          SwitchListTile(
            title: Text(
              tr('settings.enableSounds'),
              style: const TextStyle(color: Colors.white),
            ),
            value: sfxOn,
            onChanged: (val) => setState(() => sfxOn = val),
          ),
          const Divider(color: Colors.white24),
          ListTile(
            title: Text(
              tr('settings.resetCampaign'),
              style: const TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              // TODO: show confirmation dialog + reset save
            },
          ),
        ],
      ),
    );
  }
}
