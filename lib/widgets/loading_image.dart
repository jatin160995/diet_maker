import 'package:cached_network_image/cached_network_image.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/globals.dart';
import 'package:flutter/material.dart';

class LoadingImage extends StatefulWidget {
  String imageUrl;
  LoadingImage(this.imageUrl);
  @override
  _LoadingImageState createState() => _LoadingImageState();
}

class _LoadingImageState extends State<LoadingImage> {
  @override
  Widget build(BuildContext context) {
    print("image_url_widget : " + widget.imageUrl);
    //print(widget.imageUrl);
    return /* Container(
      color: primaryColor,
      child: FadeInImage.assetNetwork(
          placeholder: loadImgPath,
          fit: BoxFit.cover,
          image: widget
              .imageUrl 
          ),
    )*/ Container(
      color: backgroundColor(),
      child: CachedNetworkImage(
        imageUrl: widget.imageUrl,
        fit: BoxFit.cover,
        progressIndicatorBuilder:
            (context, url, downloadProgress) =>
                Container(child: Image.asset(loadImgPath, fit: BoxFit.cover)),
        errorWidget: (context, url, error) => Image.asset(loadImgPath),
      ),
    );
  }
}
