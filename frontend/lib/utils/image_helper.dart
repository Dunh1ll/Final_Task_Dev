import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// ImageHelper is a centralized utility for building ImageProviders.
///
/// Every screen and widget that displays an image should use this class.
/// It handles all possible image sources in priority order:
///   1. Uint8List bytes  — photo just uploaded this session (fastest)
///   2. Base64 data URI  — photo saved to DB as base64 string
///   3. HTTP/HTTPS URL   — photo hosted on a server
///   4. assets/ path     — local bundled Flutter asset
///   5. Default asset    — fallback, never crashes
class ImageHelper {
  /// Build the correct [ImageProvider] from any image source.
  ///
  /// Parameters:
  /// - [imagePath] — string path/URL/base64 from the database or model
  /// - [defaultAsset] — asset path to use when everything else fails
  /// - [bytes] — optional raw bytes from a recent upload (highest priority)
  static ImageProvider buildProvider(
    String? imagePath,
    String defaultAsset, {
    Uint8List? bytes,
  }) {
    // ── Priority 1: Raw bytes ──────────────────────────────────────
    // Used when the user just uploaded a photo this session.
    // Bytes are stored in UserBase.profilePictureBytes / coverPhotoBytes.
    // This is the fastest because no decoding is needed.
    if (bytes != null) {
      return MemoryImage(bytes);
    }

    // ── Priority 2: Base64 data URI ───────────────────────────────
    // When a photo is uploaded and saved to the backend, it is stored
    // as a base64 string in the database profile_picture_url column.
    // Format: "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
    // We split on "," to get just the base64 part after the header.
    if (imagePath != null && imagePath.startsWith('data:image')) {
      try {
        final base64Str = imagePath.split(',').last.trim();
        final decoded = base64Decode(base64Str);
        return MemoryImage(decoded);
      } catch (_) {
        // Corrupted or invalid base64 — fall through to next option
      }
    }

    // ── Priority 3: Network URL ───────────────────────────────────
    // For images hosted on a remote server (future feature).
    // Currently the backend stores base64, but this handles future
    // cases where images are stored on cloud storage with HTTP URLs.
    if (imagePath != null &&
        imagePath.isNotEmpty &&
        (imagePath.startsWith('http://') || imagePath.startsWith('https://'))) {
      return NetworkImage(imagePath);
    }

    // ── Priority 4: Local asset path ─────────────────────────────
    // For images bundled inside the Flutter app under assets/.
    // Example: "assets/images/default_avatar.png"
    if (imagePath != null &&
        imagePath.isNotEmpty &&
        imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    }

    // ── Priority 5: Default asset (always safe) ───────────────────
    // If nothing else works, return the default placeholder image.
    // This prevents blank white boxes or crashes.
    return AssetImage(defaultAsset);
  }
}
