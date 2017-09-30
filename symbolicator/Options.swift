/*

Created by Tomaz Kragelj on 11.06.2014.
Copyright (c) 2014 Gentle Bytes. All rights reserved.

*/

import Foundation

class Options: GBOptionsHelper {
	override init() {
		super.init()
		
		applicationVersion = { "1.0" }
		applicationBuild = { "100" }
		printHelpHeader = { "Usage: %APPNAME [OPTIONS] <crash log paths separated by space>\nExample: %APPNAME crashlog1.crash \"~/Downloads/some other crash.txt\"" }
		
		registerSeparator("OPTIONS")
		registerOption(0, long: settingXcodeArchivesFolderKey, description: "Xcode archives location", flags: GBOptionFlags())
        registerOption(0, long: settingApplicationBinaryPathKey, description: "Application binary location (.app)", flags: GBOptionFlags())
        registerOption(0, long: settingApplicationDsymPathKey, description: "Application dSYM location (.app.dSYM)", flags: GBOptionFlags())
		registerOption(0, long: settingsDryRunKey, description: "Dry run, do not overwrite input", flags: .noValue)
		registerOption(0, long: settingsPrintVerboseKey, description: "Print verbose output", flags: .noValue)
		registerOption(0, long: settingsPrintHelpKey, description: "Print this help and exit", flags: .noValue)
	}
}
