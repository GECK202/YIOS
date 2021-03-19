/*
 Точка входа приложения
 В этом файле определены константы
 и функции, отвечающие за загрузку и сохранение
 выбранного языка приложения
 Создаются экземпляры и запускается функция game.update()
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

enum LANGUAGE:String, Codable {
	case ru
	case en
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

let FIGURE:[Cell:String] = [
	.NONE: "  ",
	.SHIP: "# ",
	.FIRE: "@ ",
	.DEAD: ". ",
	.UPSS: "* ",
	.STOP: "X "]

func loadSetLanguage()->LANGUAGE {
	do {
    	let fileURL = try FileManager.default
    	    .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    	    .appendingPathComponent("warShipsSettings")
	    let data = try Data(contentsOf: fileURL)
	    let language = try JSONDecoder().decode(LANGUAGE.self, from: data)
	    return language
    } catch {
 		return .ru
	}
}

func saveSetLanguage(language:LANGUAGE) {
	let fileURL = try! FileManager.default
    	    .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    	    .appendingPathComponent("warShipsSettings")
	do {
    	try JSONEncoder().encode(language)
    	    .write(to: fileURL)
	} catch {
		return
	}
}

let lang = loadSetLanguage()
var CNT = readResources(language:lang)
let ui = UI.instance()
let player = Participan()
let opponent = Participan()
let game = Game(player:player, opponent:opponent, ui:ui, language:lang)

game.update()


