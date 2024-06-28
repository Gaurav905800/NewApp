import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

class AddNews extends StatefulWidget {
  static const routeName = '/add-news';

  const AddNews({super.key});

  @override
  State<AddNews> createState() => _AddNewsState();
}

class _AddNewsState extends State<AddNews> with WidgetsBindingObserver {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<File> _images = [];
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isKeyboardVisible = false;
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _titleFocusNode.addListener(_onFocusChange);
    _descriptionFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _titleFocusNode.removeListener(_onFocusChange);
    _descriptionFocusNode.removeListener(_onFocusChange);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isKeyboardVisible =
          _titleFocusNode.hasFocus || _descriptionFocusNode.hasFocus;
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // ignore: deprecated_member_use
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {
      _isKeyboardVisible = bottomInset > 0.0;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    if (_images.length >= 5) {
      return;
    }

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      bool isDuplicate = _images.any((image) => image.path == pickedFile.path);

      if (isDuplicate) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This image is already selected')),
        );
        return;
      }

      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _addNews() async {
    if (_formKey.currentState?.validate() ?? false) {
      String title = _titleController.text;
      String description = _descriptionController.text;

      setState(() {
        _isSubmitting = true;
      });
      DocumentReference newsDoc =
          await FirebaseFirestore.instance.collection('news').add({
        'title': title,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
      });

      List<String> imageUrls = [];
      for (var image in _images) {
        String imageName =
            '${newsDoc.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        TaskSnapshot uploadTask = await FirebaseStorage.instance
            .ref('news_images/$imageName')
            .putFile(image);
        String imageUrl = await uploadTask.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      await newsDoc.update({'imageUrls': imageUrls});

      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _images.clear();
        _isSubmitting = false;
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('News added successfully')),
      );

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  void _cancel() {
    _titleController.clear();
    _descriptionController.clear();
    Navigator.pop(context);
    setState(() {
      _images.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    double formPadding = isPortrait ? screenWidth * 0.05 : screenWidth * 0.02;
    double imagePadding = isPortrait ? screenWidth * 0.01 : screenWidth * 0.005;
    double fontSize = isPortrait ? screenWidth * 0.04 : screenWidth * 0.03;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add News',
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: _isSubmitting
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: formPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: GoogleFonts.poppins(fontSize: fontSize),
                      ),
                      style: GoogleFonts.poppins(fontSize: fontSize),
                      maxLines: 1,
                      maxLength: 100,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      focusNode: _descriptionFocusNode,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: GoogleFonts.poppins(fontSize: fontSize),
                      ),
                      style: GoogleFonts.poppins(fontSize: fontSize),
                      maxLines: 2,
                      maxLength: 500,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Pick Images',
                          style: GoogleFonts.poppins(fontSize: fontSize)),
                    ),
                    SizedBox(
                      height: _isKeyboardVisible
                          ? screenHeight * 0.05
                          : screenHeight * 0.4,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _images.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isPortrait ? 3 : 5,
                          crossAxisSpacing: imagePadding,
                          mainAxisSpacing: imagePadding,
                        ),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(imagePadding),
                                child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 18, 17, 17),
                                      ),
                                    ),
                                    child: Image.file(_images[index])),
                              ),
                              Positioned(
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteImage(index),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _addNews,
                          child: Text('Add News',
                              style: GoogleFonts.poppins(fontSize: fontSize)),
                        ),
                        ElevatedButton(
                          onPressed: _cancel,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontSize: fontSize,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
    );
  }
}
