/*

Created by Tomaz Kragelj on 9.06.2014.
Copyright (c) 2014 Gentle Bytes. All rights reserved.

*/

class Settings: GBSettings {
	override init() {
		// First setup factory defaults.
		let defaults = Settings(name: "Factory Defaults")
		defaults.xcodeArchivesFolder = "~/Library/Developer/Xcode/Archives"
        defaults.applicationBinaryPath = ""
        defaults.applicationDsymPath = ""
		
		// Now return the settings using factory defaults as their parent
		super.init(name: "FactoryDefaults", parent: defaults)
	}
	
	fileprivate init(name: String) {
		super.init(name: name, parent: nil)
	}
	
	var xcodeArchivesFolder: String {
		get { return object(forKey: settingXcodeArchivesFolderKey) as! String }
		set { setObject(newValue, forKey: settingXcodeArchivesFolderKey) }
	}
    
    var applicationBinaryPath: String {
        get { return object(forKey: settingApplicationBinaryPathKey) as! String }
        set { setObject(newValue, forKey: settingApplicationBinaryPathKey) }
    }
    
    var applicationDsymPath: String {
        get { return object(forKey: settingApplicationDsymPathKey) as! String }
        set { setObject(newValue, forKey: settingApplicationDsymPathKey) }
    }
	
	var dryRun: Bool {
		get { return bool(forKey: settingsDryRunKey) }
		set { setBool(newValue, forKey: settingsDryRunKey) }
	}
	
	var printVerbose: Bool {
		get { return bool(forKey: settingsPrintVerboseKey) }
		set { setBool(newValue, forKey: settingsPrintVerboseKey) }
	}
	
	var printHelp: Bool {
		get { return bool(forKey: settingsPrintHelpKey) }
		set { setBool(newValue, forKey: settingsPrintHelpKey) }
	}
}

let settingXcodeArchivesFolderKey = "archives"
let settingApplicationBinaryPathKey = "binary"
let settingApplicationDsymPathKey = "dsym"
let settingsDryRunKey = "dryrun"
let settingsPrintVerboseKey = "verbose"
let settingsPrintHelpKey = "help"
