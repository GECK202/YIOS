/*
 Точка входа приложения
*/

import Foundation

let TABLE_RANGE = 0...9

enum Cell {
    case NONE
    case SHIP
    case FIRE
    case DEAD
    case UPSS
    case STOP
}

struct Position {
    var x:Int = 0
    var y:Int = 0

    init?(x:Int, y:Int) {
        if !TABLE_RANGE.contains(x) || !TABLE_RANGE.contains(y) { return nil }
        self.x = x
        self.y = y
    }
}


/*	
func fileWork(cnt1:Content) {
	
	let fileURL = try! FileManager.default
    	    .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    	    .appendingPathComponent("example.json")
	do {
    	try JSONEncoder().encode(cnt1)
    	    .write(to: fileURL)
    	    print("file=\(fileURL.path)")
	} catch {
    	print(error)
	}	
	do {
    let fileURL = try FileManager.default
        .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("example.json")

    let data = try Data(contentsOf: fileURL)
    let cnt = try JSONDecoder().decode(Content.self, from: data)
    
    print("cnt1 = \(cnt)")
    //let banners:[Banner] = foo.banners
    //let banner: Banner = banners[1]
    //print("line 1 = \(foo.banners[1].lines[1]) phrase=\(foo.phrase[.SET_COORD]![1])")
	} catch {
 	   print(error)
	}
}
*/

func readRes(fileURL:URL)->Content? {
	do {
    let data = try Data(contentsOf: fileURL)
    let cnt = try JSONDecoder().decode(Content.self, from: data)
    	return cnt
	} catch {
 	   print(error)
 	   return nil
	}
}

let ui = UI.instance()
let player = Participan()
let opponent = Participan()

let configURL = Bundle.module.url(forResource: "Content_en", withExtension: "json")
if let cnt = readRes(fileURL:configURL!) {
	let game = Game(player:player, opponent:opponent, content:cnt, ui:ui)
	game.update()
} //else {
	//let cont = getContent()
	//let game = Game(player:player, opponent:opponent, content:cont, ui:ui)
	//game.update()
//}



//print("path=\(configURL!)")

//print(NSHomeDirectory())
//fileWork(cnt1:cnt)
//readRes(fileURL:configURL!)

