//
//  Heroes.swift
//  Hearthstone Hero
//
//  Created by Tianshu Xu on 04/03/2019.
//  Copyright © 2019 Tianshu Xu. All rights reserved.
//

import Foundation

class Heroes
{
    var heroesData : [HeroClass]
    
    init(fromContentOfXML : String) {
        // making an XMLHeroesParser
        let parser = XMLHeroesParser(name: fromContentOfXML)
        
        // parsing
        parser.parsing()
        
        // setting heroesData with what it comes from parsing
        heroesData = parser.heroes
    }
    func count()->Int {return heroesData.count}
    func heroData(index:Int)->HeroClass {return heroesData[index]}
}
