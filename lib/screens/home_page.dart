import 'package:flutter/material.dart';
import 'package:news_app/provider/news_provider.dart';
import 'package:provider/provider.dart';
import 'package:news_app/screens/add_news.dart';
import 'package:news_app/screens/detail_screen.dart';
import 'package:news_app/widgets/card_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    newsProvider.fetchNews();
  }

  Future<void> _refreshNews() async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    await newsProvider.fetchNews();
    await newsProvider.fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home Page',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNews,
        child: _buildBody(newsProvider),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNews(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(NewsProvider newsProvider) {
    if (newsProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (newsProvider.newsList.isEmpty) {
      return const Center(
        child: Text('Nothing here, add some news!'),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: newsProvider.newsList.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    data: newsProvider.newsList[index],
                  ),
                ),
              );
            },
            splashColor: Colors.black.withOpacity(0.5),
            child: CardItem(data: newsProvider.newsList[index]),
          );
        },
      );
    }
  }
}
