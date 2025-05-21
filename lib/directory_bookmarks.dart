
import 'directory_bookmarks_platform_interface.dart';

class DirectoryBookmarks {
  Future<String?> getPlatformVersion() {
    return DirectoryBookmarksPlatform.instance.getPlatformVersion();
  }
}
