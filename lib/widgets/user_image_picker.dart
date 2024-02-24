import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:streak_meter/theme/colors.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File pickedImage) onPickImage;

  const UserImagePicker({
    Key? key,
    required this.onPickImage,
  }) : super(key: key);

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage == null) return;

    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    widget.onPickImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _pickImage,
      splashColor: Colors.transparent,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 75,
            backgroundColor: Colors.grey,
            foregroundImage: _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Icon(
              Icons.add_rounded,
              size: 50,
              color: kWhite.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
