import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'directory_bookmarks_method_channel.dart';

abstract class DirectoryBookmarksPlatform extends PlatformInterface {
  /// Constructs a DirectoryBookmarksPlatform.
  DirectoryBookmarksPlatform() : super(token: _token);

  static final Object _token = Object();

  static DirectoryBookmarksPlatform _instance = MethodChannelDirectoryBookmarks();

  /// The default instance of [DirectoryBookmarksPlatform] to use.
  ///
  /// Defaults to [MethodChannelDirectoryBookmarks].
  static DirectoryBookmarksPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DirectoryBookmarksPlatform] when
  /// they register themselves.
  static set instance(DirectoryBookmarksPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
