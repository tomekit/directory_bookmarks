import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'directory_bookmarks_platform_interface.dart';

/// An implementation of [DirectoryBookmarksPlatform] that uses method channels.
class MethodChannelDirectoryBookmarks extends DirectoryBookmarksPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('directory_bookmarks');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
