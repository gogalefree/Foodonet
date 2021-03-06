#!/usr/bin/env xcrun swift -sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk
//
//  PreBuildScript.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 18/02/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

// chmod +rx       adds read and execute for everyone
import Foundation

println(">>>> Start Script")

let filemgr = NSFileManager.defaultManager()
let projectPath = filemgr.currentDirectoryPath


//println(${SRCROOT})
// BaseURL.plist dictionary values, key and path
let kProdURLVal = "https://fd-server.herokuapp.com/" //prod-
let kDevURLVal  = "https://fd-server.herokuapp.com/"
let kBetaURLVal = "https://fd-server.herokuapp.com/" //test-
let kDictKey    = "Server URL"
let pathToBaseURLPlist = projectPath + "/FoodCollector/BaseURL.plist"
// "/Users/Guy/ios projects/foodCollector4/FoodCollector/FoodCollector/Info.plist"


// Info.plist dictionary values, keys and path
let kBundleIDKey          = "CFBundleIdentifier"
let kBundleIDProdVal      = "com.gogalefree.$(PRODUCT_NAME:rfc1034identifier)"
let kBundleIDDevVal       = "com.gogalefree.$(PRODUCT_NAME:rfc1034identifier).dev"
let kBundleIDBetaVal      = "com.gogalefree.$(PRODUCT_NAME:rfc1034identifier).beta"
let kBundleNameKey        = "CFBundleName"
let kBundleNameProdVal    = "$(PRODUCT_NAME)"
let kBundleNameDevVal     = "dev.$(PRODUCT_NAME)" 
let kBundleNameBetaVal    = "beta.$(PRODUCT_NAME)"
let kBundleDispNameKey    = "CFBundleDisplayName"
let kBundleDispNameDevVal = "Foodonet Dev"
let kBundleDispNameBetaVal = "Foodonet Beta"
let kBundleDispNameProdVal = "Foodonet"

let pathToInfoPlist = projectPath + "/FoodCollector/Info.plist"
//"/Users/Guy/ios projects/foodCollector4/FoodCollector/FoodCollector/BaseURL.plist"

let args = Process.arguments
var argValue = "dev"
if args.count > 1 {
    argValue = args[1]
}

println(argValue)

// START Changes to BaseURL.plist
var plistDict = NSMutableDictionary(contentsOfFile: pathToBaseURLPlist)
println("before changing \(plistDict)")

// Change BaseURL.plist dictionary values based on argument value
switch argValue {
case "prod": // Production URL
    plistDict!.setObject(kProdURLVal, forKey: kDictKey)
case "beta": // Beta URL
    plistDict!.setObject(kBetaURLVal, forKey: kDictKey)
default: // Dev URL
    plistDict!.setObject(kDevURLVal,  forKey: kDictKey)
}

println("after changing \(plistDict)")

plistDict!.writeToFile(pathToBaseURLPlist, atomically: false)

// END Changes to BaseURL.plist

// START Changes to Info.plist
plistDict = NSMutableDictionary(contentsOfFile: pathToInfoPlist)
println("before changing \(plistDict)")
println("arg value \(argValue)")

// Change Info.plist dictionary values based on argument value
switch argValue {
case "prod": // Production URL
    plistDict!.setObject(kBundleIDProdVal,         forKey: kBundleIDKey)
    plistDict!.setObject(kBundleNameProdVal,       forKey: kBundleNameKey)
    plistDict!.setObject(kBundleDispNameProdVal,    forKey: kBundleDispNameKey)

case "beta": // Beta URL
    plistDict!.setObject(kBundleIDBetaVal,         forKey: kBundleIDKey)
    plistDict!.setObject(kBundleNameBetaVal,       forKey: kBundleNameKey)
    plistDict!.setObject(kBundleDispNameBetaVal,    forKey: kBundleDispNameKey)

default: // Dev URL
    plistDict!.setObject(kBundleIDDevVal,          forKey: kBundleIDKey)
    plistDict!.setObject(kBundleNameDevVal,        forKey: kBundleNameKey)
    plistDict!.setObject(kBundleDispNameDevVal,    forKey: kBundleDispNameKey)
}
println("after changing \(plistDict)")
println("arg value \(argValue)")


if plistDict!.writeToFile(pathToInfoPlist, atomically: true) {

    println("path saved: \(pathToInfoPlist)")
    println("plist saved")
}

// End Changes to Info.plist

println(">>>> End Script")


