//
//  Player.swift
//  SqLiteTest1
//
//  Created by Chuanxun on 16/2/24.
//  Copyright © 2016年 Leon. All rights reserved.
//

import Foundation


class Player {
    var identifier:String
    var name:String
    var country:String
    var age:Int
    
    init(identifier:String,name:String,country:String,age:Int) {
        self.identifier = identifier
        self.name = name
        self.country = country
        self.age = age
    }
}