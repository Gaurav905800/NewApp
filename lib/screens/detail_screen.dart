import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news_app/model/news_model.dart';

class DetailScreen extends StatefulWidget {
  final NewsModel data;

  const DetailScreen({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.data.title,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.data.imageUrl.isNotEmpty)
              Column(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 200.0,
                      enableInfiniteScroll: true,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      },
                    ),
                    items: widget.data.imageUrl.map((imageUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey,
                                child: Center(
                                  child: Text(
                                    'Invalid image URL',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }).toList(),
                  ),
                  CarouselIndicator(
                    count: widget.data.imageUrl.length,
                    index: _current,
                    activeColor: Theme.of(context).primaryColor,
                    color: Colors.grey,
                  ),
                ],
              )
            else
              Container(
                height: 200.0,
                color: Colors.grey,
                child: Center(
                    child: Image.network(
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTw_HeSzHfBorKS4muw4IIeVvvRgnhyO8Gn8w&s",
                  height: 200.0,
                  fit: BoxFit.cover,
                )),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data.title,
                    style: Theme.of(context).textTheme.headlineSmall?.merge(
                          GoogleFonts.poppins(),
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.data.description,
                    style: Theme.of(context).textTheme.bodyLarge?.merge(
                          GoogleFonts.poppins(),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
