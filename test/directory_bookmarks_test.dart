import 'package:flutter_test/flutter_test.dart';
import 'package:directory_bookmarks/directory_bookmarks.dart';
import 'package:directory_bookmarks/directory_bookmarks_platform_interface.dart';
import 'package:directory_bookmarks/directory_bookmarks_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDirectoryBookmarksPlatform
    with MockPlatformInterfaceMixin
    implements DirectoryBookmarksPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DirectoryBookmarksPlatform initialPlatform = DirectoryBookmarksPlatform.instance;

  test('$MethodChannelDirectoryBookmarks is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDirectoryBookmarks>());
  });

  test('getPlatformVersion', () async {
    DirectoryBookmarks directoryBookmarksPlugin = DirectoryBookmarks();
    MockDirectoryBookmarksPlatform fakePlatform = MockDirectoryBookmarksPlatform();
    DirectoryBookmarksPlatform.instance = fakePlatform;

    expect(await directoryBookmarksPlugin.getPlatformVersion(), '42');
  });
}
