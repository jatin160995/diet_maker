import 'dart:convert';
import 'dart:io';
import 'package:diet_maker/Models/dietary_preference.dart';
import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/Models/user_profile.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class UploadPhotoScreen extends StatefulWidget {
  const UploadPhotoScreen({super.key});

  @override
  State<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await showDialog<XFile>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Image'),
          children: [
            SimpleDialogOption(
              onPressed: () async {
                // Navigator.pop(
                //   context,
                //   await _picker.pickImage(
                //     source: ImageSource.camera,
                //     imageQuality: 20,
                //     maxWidth: 1024,
                //     maxHeight: 1024,
                //   ),
                // );
                final XFile? photo = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 20,
                  maxWidth: 1024,
                  maxHeight: 1024,
                );

                if (photo != null) {
                  setState(() {
                    _imageFile = File(photo.path);
                    // showToast(photo.path);
                    //Navigator.pop(context);
                  });
                }
              },
              child: const Text('Camera'),
            ),
            SimpleDialogOption(
              onPressed: () async {
                // Navigator.pop(
                //   context,
                //   await _picker.pickImage(
                //     source: ImageSource.gallery,
                //     imageQuality: 20,
                //   ),
                // );
                final XFile? photo = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 20,
                  // maxWidth: 1024,
                  // maxHeight: 1024,
                );

                if (photo != null) {
                  setState(() {
                    _imageFile = File(photo.path);
                    // showToast(photo.path);
                    Navigator.pop(context);
                  });
                }
              },
              child: const Text('Gallery'),
            ),
          ],
        );
      },
    );

    // if (pickedFile != null) {
    //   File imageFile = File(pickedFile.path);
    //   final mimeType = lookupMimeType(imageFile.path) ?? '';

    //   // iOS Camera Fix: convert HEIC/HEIF → JPEG
    //   if (mimeType.contains('heic') || mimeType.contains('heif')) {
    //     final bytes = await imageFile.readAsBytes();
    //     final decoded = img.decodeImage(bytes);
    //     if (decoded != null) {
    //       final jpgBytes = img.encodeJpg(decoded);
    //       final newPath = path.join(
    //         (await Directory.systemTemp.createTemp()).path,
    //         '${DateTime.now().millisecondsSinceEpoch}.jpg',
    //       );
    //       imageFile = await File(newPath).writeAsBytes(jpgBytes);
    //     }
    //   } else {
    //     // Copy temp file to a safe local directory
    //     final newPath = path.join(
    //       (await Directory.systemTemp.createTemp()).path,
    //       path.basename(imageFile.path),
    //     );
    //     imageFile = await imageFile.copy(newPath);
    //   }

    //   setState(() {
    //     _imageFile = imageFile;
    //   });

    //   debugPrint("Picked file: ${imageFile.path}");
    //   debugPrint("Mime type: $mimeType");
    // }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() => _isUploading = true);

    final uri = Uri.parse('$baseUrl$uploadPhoto');
    final request = http.MultipartRequest('POST', uri);

    final loginData = await StorageService.getLoginData();
    final token = loginData?.accessToken;

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(
      await http.MultipartFile.fromPath('photo', _imageFile!.path),
    );

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint("Upload response: $responseBody");

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);

        final newResponse = LoginResponse(
          profile: UserProfile.fromJson(data['profile']),
          dietaryPreference: DietaryPreference.fromJson(
            data['dietary_preference'],
          ),
          accessToken: data['access_token'],
        );

        await StorageService.saveLoginData(newResponse);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Upload successful')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Upload failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor(),
        title: heading('Upload Photo'),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_imageFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _imageFile!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                )
              else
                GestureDetector(
                  onTap: _pickImage,
                  child: const Icon(Icons.image, size: 150, color: Colors.grey),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_a_photo, color: primaryColor),
                label: const Text(
                  "Choose Image",
                  style: TextStyle(color: primaryColor),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width - 50,
                decoration: borderRadius(primaryColor, 20),
                child: TextButton(
                  onPressed: _isUploading ? null : _uploadImage,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isUploading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.cloud_upload, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        _isUploading ? "Uploading..." : "Upload Image",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
