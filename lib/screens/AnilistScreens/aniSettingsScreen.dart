import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isar/isar.dart';
import 'package:jellybook/models/anilist.dart';
import 'package:jellybook/providers/anilist.dart';

class AniSettingsScreen extends StatefulWidget {
  const AniSettingsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AniSettingsScreenState();
}

class _AniSettingsScreenState extends State<AniSettingsScreen> {
  late AnilistProvider? aniProvider;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anilist'),
      ),
      body: Container(
          padding: const EdgeInsets.all(10),
          child: (() {
            if (aniProvider == null || aniProvider!.token == '') {
              return loginWidget(context);
            } else {
              return loggedinWidget(context, aniProvider!);
            }
          }())),
    );
  }

  @override
  void initState() {
    aniProvider = null;
    loadToken();
    super.initState();
  }

  Future<void> loadToken() async {
    AnilistProvider anp = await AnilistProvider.getInstance();
    if (anp.token != '') {
      anp.viewer = await anp.getCurrentUserR();
    }
    setState(() {
      aniProvider = anp;
    });
  }
}

loginWidget(BuildContext context) => SizedBox(
      child: ElevatedButton(
        onPressed: () {
          AnilistProvider.openLoginPage();
        },
        child: Text(AppLocalizations.of(context)?.login ?? 'login'),
      ),
    );

loggedinWidget(BuildContext context, AnilistProvider provider) => ListView(
      children: [
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 80,
              color: provider.viewer?.profileColor,
            ),
            Container(
              margin: const EdgeInsets.only(top: 27),
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.only(right: 10),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(provider.viewer!.avatar),
                      radius: 50,
                    ),
                  ),
                  Text(
                    "${provider.viewer!.name}",
                    style: const TextStyle(fontSize: 30),
                  )
                ],
              ),
            )
          ],
        ),
        SizedBox(
          child: ElevatedButton(
            onPressed: () async {
              final isar = Isar.getInstance();
              await isar?.writeTxn(() async {
                await isar.anilists.clear();
              });
              await provider.setToken('');
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)?.logout ?? 'logout'),
          ),
        )
      ],
    );
