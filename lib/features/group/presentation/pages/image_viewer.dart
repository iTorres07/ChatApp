import 'package:flutter/material.dart';
import 'package:network_image/network_image.dart';

class ImageViewer extends StatefulWidget {
  final String imageUrl;
  const ImageViewer(this.imageUrl, {Key? key}) : super(key: key);

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String image = widget.imageUrl;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Image Viewer',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Center(
          child: NetworkImageWidget(
            borderRadiusNetworkImage: 0,
            imageFileBoxFit: BoxFit.cover,
            placeHolderBoxFit: BoxFit.cover,
            networkImageBoxFit: BoxFit.cover,
            imageUrl: image,
            progressIndicatorBuilder: const Center(
              child: CircularProgressIndicator(),
            ),
            placeHolder: "assets/profile_default.png",
          ),
        ),
      ),
    );
  }
}
