//
//  PlayerController.swift
//  SqLiteTest1
//
//  Created by Chuanxun on 16/2/24.
//  Copyright © 2016年 Leon. All rights reserved.
//

import Foundation
import UIKit

class PlayerController: UITableViewController {
    
    var db: COpaquePointer = nil
    var allPlayers:[Player] = [Player]()
    var availablePlayers:[[String]] = {
        var drogba = ["德罗巴","科特迪瓦🇨🇮","36"]
        var terry = ["特里","英格兰🇬🇧","36"]
        var messi = ["梅西","阿根廷🇦🇷","27"]
        var fabregas = ["法布雷加斯","西班牙🇪🇸","28"]
        var dc = ["迭戈科斯塔","西班牙🇪🇸","28"]
        var lampard = ["兰帕德","英格兰🇬🇧","37"]
        
        return [drogba,terry,messi,fabregas,dc,lampard]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftItem = UIBarButtonItem(title: "add", style: .Plain, target: self, action: "addNewPlayer")
        self.navigationItem.leftBarButtonItem = leftItem
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if  self.openDatabase("playerdb.db") == true {
            
            self.createTable()
        }
        
        self.loadDataFromDB()
    }
    
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPlayers.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:PlayerCell = tableView.dequeueReusableCellWithIdentifier("playerinfocell", forIndexPath: indexPath) as! PlayerCell
        
        let player = allPlayers[indexPath.row]
        cell.nameLabel.text = player.name
        cell.ageLabel.text = "\(player.age)"
        cell.countryLabel.text = player.country
        
        if indexPath.row % 2 == 0 {
            cell.contentView.backgroundColor = UIColor.yellowColor()
        }else {
            cell.contentView.backgroundColor = UIColor.greenColor()
        }
        
        return cell
        
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            let player = self.allPlayers[indexPath.row]
            self.allPlayers .removeAtIndex(indexPath.row)
            let sqlString = "delete from player where id = \(player.identifier);"
            if sqlite3_exec(db, sqlString.cStringUsingEncoding(NSUTF8StringEncoding)!, nil, nil, nil) == SQLITE_OK {
                NSLog("Delete OK")
                self.tableView.reloadData()
            }else{
                NSLog("Delete Failed")
            }
        case .Insert:
            NSLog("insert");
        default:
            NSLog("default")
        }
    }
    
    //滑动cell时，出现的按钮
    
//    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        let destrue = UITableViewRowAction(style: .Default, title: "Default") { (rowAction, inph) -> Void in
//            NSLog("default %d", inph.row)
//            self.allPlayers.removeAtIndex(indexPath.row)
//            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
//        }
//        let def = UITableViewRowAction(style: .Normal, title: "Normal") { (rowAction, inph) -> Void in
//            NSLog("normal %d", inph.row)
//            //self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .None)
//        }
//        if indexPath.row % 2 == 0 {
//            return [destrue,def]
//        }else {
//            return [def]
//        }
//    }

    //edit-button-item
//    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
//        return .Delete;
//    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func addNewPlayer() ->Bool {
        
        /*
        let arr = [1,2,4]
        // (((10+1) + 2) + 4)
        let brr = arr.reduce(10) { (preElement:Int, element:Int) -> Int in
            return preElement + element
        }
        
        print(brr)
        */
        
        if db != nil {
            let randomIndex = arc4random_uniform(UInt32(self.availablePlayers.count))
            let playerinfo:[String] = self.availablePlayers[Int(randomIndex)]
            let sqlString = "insert into player(name,country,age) values('\(playerinfo[0])','\(playerinfo[1])',\(playerinfo[2]));"
            
            if sqlite3_exec(db, sqlString.cStringUsingEncoding(NSUTF8StringEncoding)!, nil, nil, nil) == SQLITE_OK {
                print("add succeeded")
            }else {
                print("add failed")
            }
            
            self.loadDataFromDB()
            
            return true
            
        }
        
        return false
        
    }
    
    func loadDataFromDB() ->Void {
        
        if db != nil {
            
            allPlayers.removeAll()
            
            var stmt: COpaquePointer = nil
            let sqlString = "select name,country,age,id from player;"
            
            if sqlite3_prepare_v2(db, sqlString.cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &stmt, nil) == SQLITE_OK {
                while(sqlite3_step(stmt) == SQLITE_ROW) {
                    let nameChars = UnsafePointer<CChar>(sqlite3_column_text(stmt, 0))
                    let name = String(CString: nameChars, encoding: NSUTF8StringEncoding)!
                    let countryChars = UnsafePointer<CChar>(sqlite3_column_text(stmt, 1))
                    let country = String(CString: countryChars, encoding: NSUTF8StringEncoding)
                    let age = Int(sqlite3_column_int(stmt, 2))
                    let identifier = String(sqlite3_column_int(stmt, 3))
                    let player = Player(identifier: identifier,name: name, country: country!, age: age)
                    allPlayers .append(player)
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    func openDatabase(dbName:String) ->Bool {
        
        var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        path = (path as NSString).stringByAppendingPathComponent(dbName)
        
        let cpath = path.cStringUsingEncoding(NSUTF8StringEncoding)
        
        let error = sqlite3_open(cpath!,&db)
        
        if error != SQLITE_OK {
            print("failed to open db")
            sqlite3_close(db)
            return false
        }else {
            print("open db succeeded")
            return true
        }
        
    }
    
    func createTable() ->Bool {
        if db != nil {
            let sqlString = "create table if not exists player(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,name varchar(100),country varchar(100),age INTEGER);"
            
            return sqlite3_exec(db, sqlString.cStringUsingEncoding(NSUTF8StringEncoding)!, nil, nil, nil) == SQLITE_OK
            
        }
        
        return false
    }
    
    deinit{
        sqlite3_close(db)
    }
}
