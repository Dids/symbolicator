/*

Created by Tomaz Kragelj on 10.06.2014.
Copyright (c) 2014 Gentle Bytes. All rights reserved.

*/

import Foundation

class ArchiveHandler {
    init(path: String, binaryPath: String, dsymPath: String) {
        print("ArchiveHandler init") // TODO: Remove
		self.dwarfPathsByIdentifiers = Dictionary()
		self.basePath = path
        self.binaryPath = binaryPath
        self.dsymPath = dsymPath
	}
    
    // TODO: If binaryPath and/or dsymPath are set, override them in the dwarf/archives scanning above
	
	/// Returns map where keys are names of binaries with corresponding full path to DWARF file.
	func dwarfPathWithIdentifier(_ identifier: String, version: String, build: String) -> String? {
        print("dwarfPathWithIdentifier begin") // TODO: Remove
		// If we don't have any dwarf files scanned, do so now.
		if self.dwarfPathsByIdentifiers.count == 0 {
			let manager = FileManager()
			let fullBasePath = (self.basePath as NSString).standardizingPath
            print("fullBasePath: \(fullBasePath)") // TODO: Remove
            
            // TODO: Added by Dids
            let basePathEnumerator:FileManager.DirectoryEnumerator = manager.enumerator(atPath: fullBasePath)!
            while let element = basePathEnumerator.nextObject() as? String {
                // Construct the full path.
                let fullElementPath = NSURL(fileURLWithPath: fullBasePath).appendingPathComponent(element)?.path
                
                print("fullElementPath: \(fullElementPath ?? "")") // TODO: Remove
                
                // Skip if the path is not a directory.
                if (!manager.isDirectoryAtPath(fullElementPath! as NSString)) { continue }
                
                print("fullElementPath is directory, continuing") // TODO: Remove
                
                // If there's no plist file at the given path, ignore it.
                let plistPath = (element as NSString).appendingPathComponent("Info.plist")
                if !manager.fileExists(atPath: plistPath) { continue }
                
                // Load plist into dictionary.
                let plistData = try! Data(contentsOf: URL(fileURLWithPath: plistPath), options: .uncached)
                let plistContents = try! PropertyListSerialization.propertyList(from: plistData, options: PropertyListSerialization.ReadOptions(rawValue: 0), format: nil)
                
                // Read application properties.
                let applicationInfo = self.applicationInformationWithInfoPlist(plistContents as! NSDictionary)
                
                // Scan for all subfolders of dSYMs folder.
                manager.enumerateDirectoriesAtPath("\(element)") { subpath in
                    print("subpath: \(subpath)") // TODO: Remove
                    //manager.enumerateDirectoriesAtPath("\(buildFolder)/dSYMs") { subpath in
                    // Delete .app.dSYM or .framework.dSYM and prepare path to contained DWARF file.
                    let binaryNameWithExtension = ((subpath as NSString).lastPathComponent as NSString).deletingPathExtension
                    let binaryName = (binaryNameWithExtension as NSString).deletingPathExtension
                    let dwarfPath = "\(subpath)/Contents/Resources/DWARF/\(binaryName)"
                    
                    // Add the key to DWARF file for this binary.
                    let dwarfKey = self.dwarfKeyWithIdentifier(binaryName, version: applicationInfo.version, build: applicationInfo.build)
                    self.dwarfPathsByIdentifiers[dwarfKey] = dwarfPath
                    
                    // If this is the main application binary, also create the key with bundle identifier.
                    if binaryNameWithExtension == applicationInfo.name {
                        let identifierKey = self.dwarfKeyWithIdentifier(applicationInfo.identifier, version: applicationInfo.version, build: applicationInfo.build)
                        self.dwarfPathsByIdentifiers[identifierKey] = dwarfPath
                    }
                }
            }
            
			/*manager.enumerateDirectoriesAtPath(fullBasePath) { dateFolder in
                print("dateFolder: \(dateFolder)") // TODO: Remove
				manager.enumerateDirectoriesAtPath(dateFolder) { buildFolder in
                    print("buildFolder: \(buildFolder)") // TODO: Remove
					// If there's no plist file at the given path, ignore it.
					let plistPath = (buildFolder as NSString).appendingPathComponent("Info.plist")
					if !manager.fileExists(atPath: plistPath) { return }
					
					// Load plist into dictionary.
					let plistData = try! Data(contentsOf: URL(fileURLWithPath: plistPath), options: .uncached)
					let plistContents = try! PropertyListSerialization.propertyList(from: plistData, options: PropertyListSerialization.ReadOptions(rawValue: 0), format: nil)
					
					// Read application properties.
					let applicationInfo = self.applicationInformationWithInfoPlist(plistContents as! NSDictionary)
					
					// Scan for all subfolders of dSYMs folder.
                    manager.enumerateDirectoriesAtPath("\(buildFolder)") { subpath in
                        print("subpath: \(subpath)") // TODO: Remove
					//manager.enumerateDirectoriesAtPath("\(buildFolder)/dSYMs") { subpath in
						// Delete .app.dSYM or .framework.dSYM and prepare path to contained DWARF file.
						let binaryNameWithExtension = ((subpath as NSString).lastPathComponent as NSString).deletingPathExtension
						let binaryName = (binaryNameWithExtension as NSString).deletingPathExtension
						let dwarfPath = "\(subpath)/Contents/Resources/DWARF/\(binaryName)"
						
						// Add the key to DWARF file for this binary.
						let dwarfKey = self.dwarfKeyWithIdentifier(binaryName, version: applicationInfo.version, build: applicationInfo.build)
						self.dwarfPathsByIdentifiers[dwarfKey] = dwarfPath
						
						// If this is the main application binary, also create the key with bundle identifier.
						if binaryNameWithExtension == applicationInfo.name {
							let identifierKey = self.dwarfKeyWithIdentifier(applicationInfo.identifier, version: applicationInfo.version, build: applicationInfo.build)
							self.dwarfPathsByIdentifiers[identifierKey] = dwarfPath
						}
					}
				}
			}*/
		}
            
        // TODO: Remove
        else {
            print("Skipping dwarf scan")
        }
        
        print("dwarfPathWithIdentifier end") // TODO: Remove
		
		// Try to get dwarf path using build number first. If found, use it.
		let archiveKey = self.dwarfKeyWithIdentifier(identifier, version: version, build: build)
		if let result = self.dwarfPathsByIdentifiers[archiveKey] {
			return result
		}
		
		// Try to use generic "any build" for given version (older versions of Xcode didn't save build number to archive plist). If found, use it.
		let genericArchiveKey = self.dwarfKeyWithIdentifier(identifier, version: version, build: "")
		if let result = self.dwarfPathsByIdentifiers[genericArchiveKey] {
			return result
		}
		
		// If there's no archive match, return nil
		return nil
	}
	
	fileprivate func applicationInformationWithInfoPlist(_ plistContents: NSDictionary) -> (name: String, identifier: String, version: String, build: String) {
		var applicationName = ""
		var applicationIdentifier = ""
		var applicationVersion = ""
		var applicationBuild = ""
		
		if let applicationProperties = plistContents.object(forKey: "ApplicationProperties") as? NSDictionary {
			if let path = applicationProperties.object(forKey: "ApplicationPath") as? String {
				applicationName = (path as NSString).lastPathComponent
			}
			if let identifier = applicationProperties.object(forKey: "CFBundleIdentifier") as? String {
				applicationIdentifier = identifier
			}
			if let version = applicationProperties.object(forKey: "CFBundleShortVersionString") as? String {
				applicationVersion = version
			}
			if let build = applicationProperties.object(forKey: "CFBundleVersion") as? String {
				applicationBuild = build
			}
		}
		
		return (applicationName, applicationIdentifier, applicationVersion, applicationBuild)
	}
	
	fileprivate func dwarfKeyWithIdentifier(_ identifier: String, version: String, build: String) -> String {
		if build.characters.count == 0 {
			return "\(identifier) \(version) ANYBUILD"
		}
		return "\(identifier) \(version) \(build)"
	}
	
	fileprivate let basePath: String
    fileprivate let binaryPath: String
    fileprivate let dsymPath: String
	fileprivate var dwarfPathsByIdentifiers: Dictionary<String, String>
}

extension FileManager {
	func enumerateDirectoriesAtPath(_ path: String, block: (_ path: String) -> Void) {
		let subpaths = try! self.contentsOfDirectory(atPath: path) as [String]
		for subpath in subpaths {
			let fullPath = (path as NSString).appendingPathComponent(subpath)
			if !self.isDirectoryAtPath(fullPath as NSString) { continue }
			block(fullPath)
		}
	}
	
	func isDirectoryAtPath(_ path: NSString) -> Bool {
		let attributes = try! self.attributesOfItem(atPath: path as String)
		if attributes[FileAttributeKey.type] as! FileAttributeType == FileAttributeType.typeDirectory {
			return true
		}
		return false
	}
}
