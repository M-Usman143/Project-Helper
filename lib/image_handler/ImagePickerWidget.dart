import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'PermissionHandlerService.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(List<File>) onImagesSelected;

  ImagePickerWidget({required this.onImagesSelected});

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _openImageUploadScreen() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.camera),
            title: Text('Take Photo'),
            onTap: () async {
              Navigator.pop(context);
              bool isCameraGranted = await PermissionHandlerService.requestCameraPermission();
              if (isCameraGranted) {
                await _pickSingleImage(fromCamera: true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Camera permission required!")),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.image),
            title: Text('Choose from Gallery'),

            onTap: () async {
              Navigator.pop(context);
              bool isStorageGranted = await PermissionHandlerService.requestStoragePermission();
              if (isStorageGranted) {
                await _pickMultipleImages();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Storage permission required!")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickSingleImage({bool fromCamera = false}) async {
    final pickedFile = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickedFile != null) {
      File? compressedImage = await _compressImage(File(pickedFile.path));
      if (compressedImage != null) {
        setState(() {
          _selectedImages.add(compressedImage);
        });
        widget.onImagesSelected(_selectedImages);
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      if (pickedFiles.length < 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Please select at least 5 images!"),
              backgroundColor: Colors.red),
        );
      } else {
        List<File> compressedImages = [];
        for (var file in pickedFiles) {
          File? compressedImage = await _compressImage(File(file.path));
          if (compressedImage != null) {
            compressedImages.add(compressedImage);
          }
        }
        setState(() {
          _selectedImages.addAll(compressedImages);
        });
        widget.onImagesSelected(_selectedImages);
      }
    }
  }

  Future<File?> _compressImage(File file) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf('.');
    final outPath = filePath.substring(0, lastIndex) + '_compressed.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: 70,
    );

    return compressedFile != null ? File(compressedFile.path) : null;
  }

  Widget _buildImagePickerContainer() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _selectedImages.isEmpty
          ? GestureDetector(
        onTap: _openImageUploadScreen,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, color: Colors.blue, size: 50),
            SizedBox(height: 8),
            Text("Add images", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("5MB max, formats: jpg, png, gif",
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
          ],
        ),
      )
          : GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(_selectedImages[index], fit: BoxFit.cover),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImages.removeAt(index);
                    });
                    widget.onImagesSelected(_selectedImages);
                  },
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildImagePickerContainer();
  }
}
