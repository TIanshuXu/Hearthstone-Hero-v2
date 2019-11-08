//
//  HeroClass.swift
//  HearthStone Hero2.0
//
//  Created by jiajia shi on 02/04/2019.
//  Copyright © 2019 Tianshu Xu. All rights reserved.
//

import Foundation

class HeroClass
{
    var name       : String
    var className  : String
    var heroPower  : String
    var deckType   : String
    var flavorText : String
    var image      : String
    var url        : String
    
    init() {
        self.name       = "Jaina Proudmoore"
        self.className  = "Mage"
        self.heroPower  = "Fireblast"
        self.deckType   = "Secret, Elemental, Big Spell"
        self.flavorText = "The Kirin Tor’s leader is a powerful sorceress. She used to be a lot nicer before the Theramore thing."
        self.image      = "game.jpg"
        self.url        = "https://wow.gamepedia.com/Jaina_Proudmoore"
    }
    
    init(name:String,className:String,heroPower:String,deckType:String,flavorText:String,image:String,url:String) {
        self.name = name
        self.className = className
        self.heroPower = heroPower
        self.deckType = deckType
        self.flavorText = flavorText
        self.image = image
        self.url = url
    }
}
