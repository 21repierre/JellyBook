import 'package:isar/isar.dart';

part 'anilist.g.dart';

@Collection()
class Anilist {
  Id isarId = Isar.autoIncrement;

  @Index()
  String token;

  Anilist({
    required this.token,
  });
}
