import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String result;
  File? _image;
  InputImage? inputImage;
  List list = [];
  String path = "";
  String sin = "";
  String name = "";

  final picker = ImagePicker();
  @override
  void initState() {
    super.initState();
  }

  Future<void> pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        inputImage = InputImage.fromFilePath(pickedFile.path);
        path = pickedFile.path;
        if (inputImage != null) {
          imageToText(inputImage);
        } else {
          print('No image selected.');
        }
      }
    });
  }

  Future captureImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        inputImage = InputImage.fromFilePath(pickedFile.path);
        imageToText(inputImage);
      } else {
        print('No image selected.');
      }
    });
  }

  Future imageToText(inputImage) async {
    result = '';

    list = [];
    final textDetector = GoogleMlKit.vision.textDetector();
    final RecognisedText recognisedText =
        await textDetector.processImage(inputImage);

    setState(() {
      String text = recognisedText.text;
      for (TextBlock block in recognisedText.blocks) {
        //each block of text/section of text
        final String text = block.text;
        print("block of text: ");
        print(text);
        list.add(text);
        for (TextLine line in block.lines) {
          //each line within a text block
          for (TextElement element in line.elements) {
            //each word within a line
            result += element.text + " ";
          }
        }
      }
      var index = list.indexOf("SOCIAL");
      var count = 0;

      for (var li in list) {
        if (li.toString().contains("Social Insurance Number (SIN)")) {
          print("hurrey! this is Social Insurance Numbers");
          setState(() {
            sin = list[count + 1];
            name = list[count + 4] + ' ' + list[count + 5];
          });
          break;
        }
        if ((count + 4) < list.length) {
          if ((list[count] + ' ' + list[count + 2] + ' ' + list[count + 4]) ==
              "SOCIAL INSURANCE NUMBER") {
            print("hurrey! this is Social Insurance Number");
            setState(() {
              sin = list[count + 6];
              name = list[count + 7];
            });
            break;
          }
        }
        count++;
      }

      result += "\n\n";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Column(
            children: [
              Center(
                child: TextButton(
                    onPressed: () => {pickImageFromGallery()},
                    child: const Text("Select File")),
              ),
              const SizedBox(
                height: 20,
              ),
              if (path == "") ...[
                const Center(child: Text('No file selected')),
              ] else ...[
                Image.file(_image!),
              ],
              Text("Sin:" + sin),
              Text("Name:" + name),
            ],
          ),
        ),
      ),
    );
  }
}
