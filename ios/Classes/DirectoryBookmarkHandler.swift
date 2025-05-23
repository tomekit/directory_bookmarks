// import Cocoa
import Flutter
import UIKit

class DirectoryBookmarkHandler: NSObject {
    static let shared = DirectoryBookmarkHandler()
//    private let bookmarkKey = "SavedDirectoryBookmark"
    private var currentAccessedURL: URL?
    
    deinit {
        stopAccessingCurrentURL()
    }
    
    private func stopAccessingCurrentURL() {
        if let url = currentAccessedURL {
            url.stopAccessingSecurityScopedResource()
            currentAccessedURL = nil
        }
    }
    
    func saveDirectoryBookmark(path: String) -> Bool {
        let url = URL(fileURLWithPath: path)
        
        // Verify directory exists and is accessible
        guard url.isDirectory else {
            print("Path is not a directory or is not accessible")
            return false
        }
        
        do {

            guard url.startAccessingSecurityScopedResource() else {
               print("Failed to save bookmark: Cannot access security-scoped resource")
               return false
            }

           defer { url.stopAccessingSecurityScopedResource() }


            // Create security-scoped bookmark
            let bookmarkData = try url.bookmarkData(
                options: [.minimalBookmark], // https://developer.apple.com/documentation/uikit/providing-access-to-directories#Save-the-URL-as-a-bookmark
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            
//            let saveUrl = URL(string: path)
//            try bookmarkData.write(to: saveUrl!)

            // Save bookmark data
            UserDefaults.standard.set(bookmarkData, forKey: path)
            return true
        } catch {
            print("Failed to create bookmark: \(error)")
            return false
        }
    }
    
    func resolveBookmark(path: String) -> URL? {
        // Stop accessing previous URL if any
//        stopAccessingCurrentURL()
        
        guard let bookmarkData = UserDefaults.standard.data(forKey: path) else {
            print("No bookmark data found")
            return nil
        }
        
        do {
//            let saveUrl = URL(string: path)
//            let bookmarkData = try Data(contentsOf: saveUrl!)
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
//                 options: [.minimalBookmark], // https://stackoverflow.com/a/77392449/29744315
//                 relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            
//            // Start accessing the security-scoped resource
//            if !url.startAccessingSecurityScopedResource() {
//                print("Failed to start accessing security-scoped resource")
//                return nil
//            }
//
//            // Store the current accessed URL
//            currentAccessedURL = url
            
            // Verify the URL still exists and is a directory
            guard url.isDirectory else {
                print("Bookmarked path no longer exists or is not a directory")
//                stopAccessingCurrentURL()
                return nil
            }
            
            if isStale {
                print("Bookmark is stale, attempting to recreate")
                if saveDirectoryBookmark(path: path) {
                    return url
                }
//                stopAccessingCurrentURL()
                return nil
            }
            
            return url
        } catch {
            print("Failed to resolve bookmark: \(error)")
            return nil
        }
    }
    
    func saveFile(fileName: String, data: FlutterStandardTypedData) -> Bool {
        guard let url = currentAccessedURL ?? resolveBookmark(path: "bookmark") else {
            print("No valid bookmark found")
            return false
        }
        
        do {
            let fileURL = url.appendingPathComponent(fileName)
            try data.data.write(to: fileURL)
            return true
        } catch {
            print("Failed to save file: \(error)")
            return false
        }
    }
    
    func readFile(fileName: String) -> FlutterStandardTypedData? {
        guard let url = currentAccessedURL ?? resolveBookmark(path: "bookmark") else {
            print("No valid bookmark found")
            return nil
        }
        
        do {
            let fileURL = url.appendingPathComponent(fileName)
            let data = try Data(contentsOf: fileURL)
            return FlutterStandardTypedData(bytes: data)
        } catch {
            print("Failed to read file: \(error)")
            return nil
        }
    }
    
    func listFiles(path: String) -> [String]? {
        guard let url = currentAccessedURL ?? resolveBookmark(path: path) else {
            print("No valid bookmark found")
            return nil
        }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )
            return contents
                .filter { (try? $0.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) ?? false }
                .map { $0.lastPathComponent }
        } catch {
            print("Failed to list files: \(error)")
            return nil
        }
    }
    
    func hasWritePermission(path: String) -> Bool {
        guard let url = currentAccessedURL ?? resolveBookmark(path: path) else {
            return false
        }
        
        return FileManager.default.isWritableFile(atPath: url.path)
    }
}

extension URL {
    var isDirectory: Bool {
        guard let resourceValues = try? resourceValues(forKeys: [.isDirectoryKey]),
              let isDirectory = resourceValues.isDirectory else {
            return false
        }
        return isDirectory
    }
}
