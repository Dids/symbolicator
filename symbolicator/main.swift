//
//  main.swift
//  symbolicator
//
//  Created by Tomaz Kragelj on 9.06.14.
//  Copyright (c) 2014 Gentle Bytes. All rights reserved.
//

import Foundation

let settings = Settings()
let options = Options()
let commandLineParser = GBCommandLineParser()

func setup() {
	commandLineParser.registerOptions(options)
	commandLineParser.registerSettings(settings)
}

func run() {
	options.printVersion()
	println()
	
	if !commandLineParser.parseOptionsUsingDefaultArguments() {
		println()
		options.printHelp()
		return
	}

	if settings.printHelp {
		options.printHelp()
		return
	}
	
	if commandLineParser.arguments.count == 0 {
		println("At least one crashlog path is required!")
		println()
		options.printHelp()
		return
	}
	
	let symbolicator = Symbolicator()
	let crashLogs = settings.arguments as Array<String>;
	let archivesPath = settings.xcodeArchivesFolder;
	symbolicator.symbolicate(crashLogs, archivesPath: archivesPath)
}

setup()
run()
