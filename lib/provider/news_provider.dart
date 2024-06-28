import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app/model/news_model.dart';

class NewsProvider with ChangeNotifier {
  List<NewsModel> _newsList = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<NewsModel> get newsList => _newsList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  NewsProvider() {
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('news').get();
      _newsList = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return NewsModel(
          title: data['title'] ?? 'No title',
          description: data['description'] ?? 'No description',
          imageUrl: (data['imageUrls'] as List<dynamic>?)
                  ?.map((url) => url.toString())
                  .toList() ??
              [],
        );
      }).toList();
      _isLoading = false;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Something went wrong';
      _isLoading = false;
    }
    notifyListeners();
  }
}
