import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pagination_riverpod/post.dart';

Future<List<Post>> getPosts(int page) async {
  try {
    final response = await http.get(
      Uri.parse(
        'https://jsonplaceholder.typicode.com/posts?_page=$page&_limit=10',
      ),
    );
    final List<Post> posts = (jsonDecode(response.body) as List)
        .map((e) => Post.fromJsonMap(e))
        .toList();
    return posts;
  } catch (ex, st) {
    print(ex);
    print(st);
    return [];
  }
}
