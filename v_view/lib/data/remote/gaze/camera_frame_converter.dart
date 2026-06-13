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
      final rotation = _rotationFromSensor(camera.sensorOrientation, camera.lensDirection);

      // ML Kit의 InputImage.fromByteArray()는 NV21/YV12만 지원하므로
      // 안드로이드 카메라가 주는 YUV_420_888을 NV21로 직접 변환해야 한다.
      if (Platform.isAndroid) {
        return InputImage.fromBytes(
          bytes: _yuv420ToNv21(image),
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.nv21,
            bytesPerRow: image.width,
          ),
        );
      }

      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }

      return InputImage.fromBytes(
        bytes: allBytes.done().buffer.asUint8List(),
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  // YUV_420_888의 Y/U/V 플레인을 row stride/pixel stride를 반영해
  // NV21(Y 전체 + 인터리브된 VU) 바이트 배열로 재배치한다.
  static Uint8List _yuv420ToNv21(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final uvWidth = width ~/ 2;
    final uvHeight = height ~/ 2;
    final nv21 = Uint8List(width * height + 2 * uvWidth * uvHeight);

    var index = 0;
    for (var row = 0; row < height; row++) {
      final rowStart = row * yPlane.bytesPerRow;
      nv21.setRange(index, index + width, yPlane.bytes, rowStart);
      index += width;
    }

    final uPixelStride = uPlane.bytesPerPixel ?? 1;
    final vPixelStride = vPlane.bytesPerPixel ?? 1;
    for (var row = 0; row < uvHeight; row++) {
      for (var col = 0; col < uvWidth; col++) {
        final uIndex = row * uPlane.bytesPerRow + col * uPixelStride;
        final vIndex = row * vPlane.bytesPerRow + col * vPixelStride;
        nv21[index++] = vPlane.bytes[vIndex];
        nv21[index++] = uPlane.bytes[uIndex];
      }
    }

    return nv21;
  }

  static InputImageRotation _rotationFromSensor(int sensorOrientation, CameraLensDirection lensDirection) {
    final compensated = lensDirection == CameraLensDirection.front
        ? (360 - sensorOrientation) % 360
        : sensorOrientation;
    return switch (compensated) {
      90  => InputImageRotation.rotation90deg,
      180 => InputImageRotation.rotation180deg,
      270 => InputImageRotation.rotation270deg,
      _   => InputImageRotation.rotation0deg,
    };
  }
}
