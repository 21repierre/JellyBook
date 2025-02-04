// The purpose of this file is to create a list of entries from a selected folder

// import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar/isar.dart';
import 'package:isar_flutter_libs/isar_flutter_libs.dart';
import 'package:jellybook/models/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_star/flutter_star.dart';
import 'package:jellybook/models/folder.dart';
import 'package:jellybook/screens/infoScreen.dart';
import 'package:jellybook/providers/fixRichText.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jellybook/variables.dart';

class collectionScreen extends StatelessWidget {
  final String folderId;
  final String name;
  final String image;
  final List<String> bookIds;

  collectionScreen({
    required this.folderId,
    required this.name,
    required this.image,
    required this.bookIds,
  });

  final isar = Isar.getInstance();
  // make a list of entries from the the list of bookIds
  Future<List<Map<String, dynamic>>> getEntries() async {
    // final isar = Isar.openSync([EntrySchema]);
    List<Map<String, dynamic>> entries = [];
    // get the entries from the database
    final entryList = await isar!.entrys.where().findAll();
    // var entryList = box.values.toList();
    logger.d("bookIds: ${bookIds.length}");
    for (int i = 0; i < bookIds.length; i++) {
      // get the first entry that matches the bookId
      var entry = entryList.firstWhere((element) => element.id == bookIds[i]);
      entries.add({
        'id': entry.id,
        'title': entry.title,
        'imagePath': entry.imagePath != '' ? entry.imagePath : 'Asset',
        'rating': entry.rating,
        'description': entry.description,
        'path': entry.path,
        'year': entry.releaseDate,
        'type': entry.type.toString(),
        'tags': entry.tags,
        'url': entry.url,
        'isFavorited': entry.isFavorited,
        'isDownloaded': entry.downloaded,
      });
    }
    return entries;
    // checkeach field of the entry to make sure it is not null
  }

  // getter for the list of entries calling getEntries()
  Future<List<Map<String, dynamic>>> get entries async {
    return await getEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: FutureBuilder(
        future: entries,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData &&
              snapshot.data.length > 0 &&
              snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  onTap: () {
                    if (snapshot.data[index]['type'] != "EntryType.folder") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InfoScreen(
                            comicId: snapshot.data[index]['id'],
                            title: snapshot.data[index]['title'],
                            imageUrl: snapshot.data[index]['imagePath'],
                            stars: snapshot.data[index]['rating'],
                            description: snapshot.data[index]['description'],
                            path: snapshot.data[index]['type'],
                            year: snapshot.data[index]['year'],
                            url: snapshot.data[index]['url'],
                            tags: snapshot.data[index]['tags'],
                            isLiked: snapshot.data[index]['isFavorited'],
                            isDownloaded: false,
                          ),
                        ),
                      );
                    } else if (snapshot.data[index]['type'] ==
                        "EntryType.folder") {
                      logger.d("Tapped: ${snapshot.data[index].toString()}");
                      var folder = isar!.folders
                          .where()
                          .filter()
                          .idEqualTo(snapshot.data[index]['id'])
                          .findFirstSync();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => collectionScreen(
                            folderId: folder!.id,
                            name: folder.name,
                            image: folder.image,
                            bookIds: folder.bookIds,
                          ),
                        ),
                      );
                    }
                  },
                  title: Text(snapshot.data[index]['title']),
                  leading: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.5),
                          // color: Colors.black.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: snapshot.data[index]['imagePath'] != "Asset"
                          ? FancyShimmerImage(
                              imageUrl: snapshot.data[index]['imagePath'],
                              errorWidget: Image.asset(
                                'assets/images/NoCoverArt.png',
                                fit: BoxFit.cover,
                              ),
                              boxFit: BoxFit.fitWidth,
                              width: MediaQuery.of(context).size.width * 0.1,
                            )
                          : Image.asset(
                              'assets/images/NoCoverArt.png',
                              width: MediaQuery.of(context).size.width * 0.1,
                              fit: BoxFit.fitWidth,
                            ),
                    ),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (snapshot.data[index]['rating'] >= 0)
                        IgnorePointer(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: CustomRating(
                                  max: 5,
                                  score: snapshot.data[index]['rating'] / 2,
                                  star: Star(
                                    fillColor: Color.lerp(
                                        Colors.red,
                                        Colors.yellow,
                                        snapshot.data[index]['rating'] / 10)!,
                                    emptyColor: Colors.grey.withOpacity(0.5),
                                  ),
                                  onRating: (double score) {},
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                child: Text(
                                  "${(snapshot.data[index]['rating'] / 2).toStringAsFixed(2)} / 5.00",
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (snapshot.data[index]['rating'] < 0 &&
                          snapshot.data[index]['description'] != '')
                        Flexible(
                          child: RichText(
                            text: TextSpan(
                              text: fixRichText(
                                  snapshot.data[index]['description']),
                              // prevent overflow
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasData &&
              snapshot.data.length == 0 &&
              snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)?.noResultsFound ??
                        'No results found in this folder',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Icon(Icons.sentiment_dissatisfied, size: 100),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)?.unknownError ??
                        "An unknown error has occured.",
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Icon(Icons.sentiment_dissatisfied, size: 100),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
