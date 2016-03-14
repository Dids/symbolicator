/*

Created by Tomaz Kragelj on 9.06.2014.
Copyright (c) 2014 Gentle Bytes. All rights reserved.

*/

class Settings: GBSettings {
	override init() {
		// First setup factory defaults.
		let defaults = Settings(name: "Factory Defaults")
		defaults.xcodeArchivesFolder = "~/Library/Developer/Xcode/Archives"
		
		// Now return the settings using factory defaults as their parent
		super.init(name: "FactoryDefaults", parent: defaults)
	}
	
	private init(name: String) {
		super.init(name: name, parent: nil)
	}
	
	var xcodeArchivesFolder: String {
		get { return objectForKey(settingXcodeArchivesKey) as! String }
		set { setObject(newValue, forKey: settingXcodeArchivesKey) }
	}
	
	var dryRun: Bool {
		get { return boolForKey(settingsDryRunKey) }
		set { setBool(newValue, forKey: settingsDryRunKey) }
	}
	
	var printVerbose: Bool {
		get { return boolForKey(settingsPrintVerboseKey) }
		set { setBool(newValue, forKey: settingsPrintVerboseKey) }
	}
	
	var printHelp: Bool {
		get { return boolForKey(settingsPrintHelpKey) }
		set { setBool(newValue, forKey: settingsPrintHelpKey) }
	}
}

let settingXcodeArchivesKey = "archives"
let settingsDryRunKey = "dryrun"
let settingsPrintVerboseKey = "verbose"
let settingsPrintHelpKey = "help"
