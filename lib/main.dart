import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pagination_riverpod/post.dart';
import 'package:pagination_riverpod/post_provider.dart';

final keyProvider = StateProvider<String>((ref) {
  return '';
});

final postSearchProvider = StateProvider<List<Post>>(
  (ref) {
    final postState = ref.watch(postsProvider);
    final key = ref.watch(keyProvider);

    return postState.posts
        .where((element) =>
            element.body.contains(key) || element.title.contains(key))
        .toList();
  },
);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final ScrollController _controller = ScrollController();

  int oldLength = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() async {
      if (_controller.position.pixels >
          _controller.position.maxScrollExtent -
              MediaQuery.of(context).size.height) {
        if (oldLength == ref.read(postsProvider).posts.length) {
          ref.read(postsProvider.notifier).loadMorePost();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          decoration: const InputDecoration(
            hintText: 'Enter to search!',
            hintStyle: TextStyle(color: Colors.yellow),
          ),
          onChanged: (newValue) {
            ref.read(keyProvider.notifier).state = newValue;
          },
        ),
      ),
      body: Consumer(
        builder: (ctx, watch, child) {
          final isLoadMoreError = ref.watch(postsProvider).isLoadMoreError;
          final isLoadMoreDone = ref.watch(postsProvider).isLoadMoreDone;
          final isLoading = ref.watch(postsProvider).isLoading;
          final posts = ref.watch(postSearchProvider.notifier).state;

          oldLength = posts.length;
          // init data or error
          if (posts.isEmpty) {
            // error case
            if (isLoading == false) {
              return const Center(
                child: Text('error'),
              );
            }
            return const _Loading();
          }
          return RefreshIndicator(
            onRefresh: () {
              return ref.read(postsProvider.notifier).refresh();
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 20),
              controller: _controller,
              itemCount: posts.length + 1,
              itemBuilder: (ctx, index) {
                // last element (progress bar, error or 'Done!' if reached to the last element)
                if (index == posts.length) {
                  // load more and get error
                  if (isLoadMoreError) {
                    return const Center(
                      child: Text('Error'),
                    );
                  }
                  // load more but reached to the last element
                  if (isLoadMoreDone) {
                    return const Center(
                      child: Text(
                        'Done!',
                        style: TextStyle(color: Colors.green, fontSize: 20),
                      ),
                    );
                  }
                  return const LinearProgressIndicator();
                }
                return ListTile(
                  title: Text(posts[index].title),
                  subtitle: Text(posts[index].body),
                  trailing: Text(
                    posts[index].id.toString(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
