import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jellybook/providers/anilist/User.dart';
import 'package:jellybook/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AnilistProvider {
  String token;
  static AnilistProvider? _instance;

  User? viewer;

  AnilistProvider({
    required this.token,
  }) {
    _instance = this;
  }

  Future<void> setToken(String token) async {
    this.token = token;
  }

  static Future<AnilistProvider> load() async {
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("aniToken");
    return AnilistProvider(token: token ?? '');
  }

  static Future<AnilistProvider> getInstance() async {
    return _instance ?? (await load());
  }

  static openLoginPage() {
    const String clientId = "12749";
    const String url = "https://anilist.co/api/v2/oauth/authorize?client_id=$clientId&response_type=token";
    logger.i('Opening anilist login url $url');
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<Response> makeRequest(String query, String vars) async {
    var headers = {'Authorization': 'Bearer $token', 'Accept': 'application/json', 'Content-Type': 'application/json'};
    var data = {'query': query, 'variables': vars};
    var dio = Dio();
    return dio.post('https://graphql.anilist.co', data: data, options: Options(headers: headers));
  }

  Future<User> getCurrentUserR() async {
    const query = """
      query AniChartUser {
        Viewer {
          id
          name
          about
          bannerImage
          avatar {
              large
          }
          options {
              profileColor
          }
        }
      }
    """;
    var req = await makeRequest(query, '[]');
    Map<String, dynamic> dec = (req.data as Map<String, dynamic>)['data']['Viewer'];
    return User(dec['id'], dec['name'], dec['about'] ?? '', dec['bannerImage'] ?? '', dec['avatar']['large'], parseColor(dec['options']['profileColor']));
  }

  Color parseColor(String color) {
    switch (color) {
      case 'blue':
        return const Color.fromRGBO(61, 180, 242, 1);
      case 'purple':
        return const Color.fromRGBO(192, 99, 255, 1);
      case 'pink':
        return const Color.fromRGBO(252, 157, 214, 1);
      case 'orange':
        return const Color.fromRGBO(239, 136, 26, 1);
      case 'red':
        return const Color.fromRGBO(225, 51, 51, 1);
      case 'green':
        return const Color.fromRGBO(76, 202, 81, 1);
      case 'gray':
        return const Color.fromRGBO(103, 123, 148, 1);
      default:
        return const Color.fromRGBO(0, 0, 0, 1);
    }
  }
}
