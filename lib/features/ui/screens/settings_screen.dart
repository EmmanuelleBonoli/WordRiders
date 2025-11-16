import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_train/features/gameplay/services/player_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool musicOn = true;
  bool sfxOn = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    musicOn = await PlayerProgress.isMusicEnabled();
    sfxOn = await PlayerProgress.isSfxEnabled();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: Text(tr('settings.title'))),
      backgroundColor: Colors.black,
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(50),
          children: [
            const SizedBox(height: 20),

            ListTile(
              title: Text(
                tr('settings.language'),
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              trailing: DropdownButton<Locale>(
                value: context.locale,
                dropdownColor: Colors.grey[900],
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(
                    value: Locale('fr'),
                    child: Text('Français'),
                  ),
                ],
                onChanged: (newLocale) async {
                  if (newLocale != null) {
                    context.setLocale(newLocale);
                  }
                },
              ),
            ),
            const Divider(color: Colors.white24),

            SwitchListTile(
              title: Text(
                tr('settings.enableMusic'),
                style: const TextStyle(color: Colors.white),
              ),
              value: musicOn,
              onChanged: (val) async {
                setState(() => musicOn = val);
                await PlayerProgress.setMusicEnabled(val);
              },
            ),

            SwitchListTile(
              title: Text(
                tr('settings.enableSounds'),
                style: const TextStyle(color: Colors.white),
              ),
              value: sfxOn,
              onChanged: (val) async {
                setState(() => sfxOn = val);
                await PlayerProgress.setSfxEnabled(val);
              },
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
      ),
    );
  }
}
