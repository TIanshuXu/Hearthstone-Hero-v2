//
//  XMLHeroesParser.swift
//  Hearthstone Hero
//
//  Created by Tianshu Xu on 04/03/2019.
//  Copyright © 2019 Tianshu Xu. All rights reserved.
//

import Foundation

class XMLHeroesParser : NSObject, XMLParserDelegate{
    
    var name : String
    init(name:String) {self.name = name}
    
    // declaring vars to hold tag data
    var pName, pClassName, pHeroPower, pDeckType, pFlavorText, pImage, pUrl : String!
    
    // vars to spy during parsing
    var elementID = -1
    var passData = false
    
    // vars to manage the whole data
    var hero   = HeroClass()
    var heroes = [HeroClass]()
    // [Hero]() is a Hero array without element
    
    var parser = XMLParser()
    var tags = ["name", "className", "heroPower", "deckType", "flavorText", "image", "url"]
    
    // parser delegate methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
       
        // if elementName is in tages then spy
        if tags.contains(elementName){
            passData = true
            switch elementName{
                case "name"        : elementID = 0
                case "className"   : elementID = 1
                case "heroPower"   : elementID = 2
                case "deckType"    : elementID = 3
                case "flavorText"  : elementID = 4
                case "image"       : elementID = 5
                case "url"         : elementID = 6
                default            : break
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        // based on the spies grab some data into pVars
        if passData{
            switch elementID{
                case 0 : pName       = string
                case 1 : pClassName  = string
                case 2 : pHeroPower  = string
                case 3 : pDeckType   = string
                case 4 : pFlavorText = string
                case 5 : pImage      = string
                case 6 : pUrl        = string
                default: break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        // resetting the spies
        if tags.contains(elementName){
            passData  = false
            elementID = -1
        }
        
        // if elementName is hero then make a hero and append to heroes
        if elementName == "hero"{
            hero = HeroClass(name: pName, className: pClassName, heroPower: pHeroPower, deckType: pDeckType, flavorText: pFlavorText, image: pImage, url: pUrl)
            heroes.append(hero)
        }
    }
    
    func parsing() {
        
        // getting the path of the xml file
        let bundleUrl = Bundle.main.bundleURL
        let fileUrl   = URL(string: self.name, relativeTo: bundleUrl)
        
        // making a paser for this file
        parser = XMLParser(contentsOf: fileUrl!)!
        
        // giving the delegate and parsing
        parser.delegate = self
        parser.parse()
    }
}
