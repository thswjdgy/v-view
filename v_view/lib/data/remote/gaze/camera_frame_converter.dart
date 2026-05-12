import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraFrameConverter {
  static InputImage? convert({
    required CameraImage image,
    required CameraDescription camera,
  }) {
    try {
      final format = Platform.isAndroid
          ? InputImageFormat.yuv_420_888
          : InputImageFormat.bgra8888;

      final rotation = _rotationFromSensor(camera.sensorOrientation);

      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }

      return InputImage.fromBytes(
        bytes: allBytes.done().buffer.asUint8List(),
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  static InputImageRotation _rotationFromSensor(int sensorOrientation) {
    return switch (sensorOrientation) {
      90  => InputImageRotation.rotation90deg,
      180 => InputImageRotation.rotation180deg,
      270 => InputImageRotation.rotation270deg,
      _   => InputImageRotation.rotation0deg,
    };
  }
}
