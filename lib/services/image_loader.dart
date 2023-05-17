import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/painting.dart';

class ImageLoader {
  static Future<Image> loadImageFromUrl(String imageUrl) async {
    Completer<ImageInfo> completer = Completer();
    final networkImage = NetworkImage(imageUrl);
    networkImage.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool syncCall) {
        completer.complete(info);
      }),
    );
    ImageInfo imageInfo = await completer.future;

    return imageInfo.image;
  }

  static Future<Image> loadImageFromAsset(String assetName) async {
    Completer<ImageInfo> completer = Completer();
    final assetImage = AssetImage(assetName);
    assetImage.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool syncCall) {
        completer.complete(info);
      }),
    );
    ImageInfo imageInfo = await completer.future;

    return imageInfo.image;
  }

  static Future<Image> loadImageFromMemory(Uint8List bytesData) async {
    return await decodeImageFromList(bytesData);
    // Completer<ImageInfo> completer = Completer();
    // final memoryImage = MemoryImage(bytesData);
    // memoryImage.resolve(const ImageConfiguration()).addListener(
    //   ImageStreamListener((ImageInfo info, bool syncCall) {
    //     completer.complete(info);
    //   }),
    // );
    // ImageInfo imageInfo = await completer.future;
    //
    // return imageInfo.image;
  }
}
