import Foundation

let NONE:Int = 0
let SHIP:Int = 1
let FIRE:Int = 2
let UPSS:Int = 3
let STOP:Int = 4

let HORZ:Int = 0
let VERT:Int = 1

let LEFT:Int = 0
let RIGHT:Int = 1
let UP:Int = 2
let DOWN:Int = 3

let DIR_RANGE = 0...3

let FIGURE: [Int: String] = [
NONE: ". ",
SHIP: "# ",
FIRE: "@ ",
UPSS: "X ",
STOP: ". "]

let CLEAN_FIELD = [
[0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0],]

let SHIPS_COUNT = [0,4,3,2,1]

let TABLE_RANGE = 0...9
let SIZE_RANGE = 1...4

struct Position {
    var x:Int = 0
    var y:Int = 0

    let LET_TO_INT = [
    "a":0, "A":0,
    "b":1, "B":1,
    "c":2, "C":2,
    "d":3, "D":3,
    "e":4, "E":4,
    "f":5, "F":5,
    "g":6, "G":6,
    "h":7, "H":7,
    "i":8, "I":8,
    "j":9, "J":9,]
    
    init?(_ figure1:Int, _ figure2:Int) {
        if !TABLE_RANGE.contains(figure1) || !TABLE_RANGE.contains(figure2) { return nil }
        x = figure1 - 1
        y = figure2 - 1
    }
    
    init?(figure:Int, letter:String) {
        if !TABLE_RANGE.contains(figure) ||
            letter.count != 1 { return nil}
        if let n:Int = LET_TO_INT[letter] {
            x = n
            y = figure - 1
        } else {return nil}
    }
}

let NOT_BULLET: [Character] = [" ", " ", " ", " ", " ", " ", " ", " "]
var bullet: [Character] = NOT_BULLET

func ShowField(_ player:ParticipanClass, fire:Int){
    let space = " |        | "
    var distance:String
    print("       ПОЛЕ ИГРОКА     \(space)     ПОЛЕ ПРОТИВНИКА")
    print("   a b c d e f g h i j \(space)   a b c d e f g h i j")
    for j in 0...9 {
        var slf = ""; var opp = ""
        for i in 0...9 {
            if let cfig:String = FIGURE[player.selfField[j][i]]{
                slf += cfig
            }
            else {
                slf += "?!"
            }
            if let cfig:String = FIGURE[player.opponentField[j][i]]{
                opp += cfig
            }
            else {
                opp += "?!"
            }
        }
        var number = String(j + 1)
        if number.count == 1 {
            number = " " + number
        }
        if j == fire {
            distance = " |" + String(bullet) + "| "
        } else { distance = space }
        print("\(number) \(slf)\(distance)\(number) \(opp)")
    }
}

class ParticipanClass {
    var selfField = CLEAN_FIELD
    var opponentField = CLEAN_FIELD
    var shipsCount = SHIPS_COUNT
    var lastMove:Position? = nil
    var goodLastMove:Position? = nil
    var curDirection:Int = Int.random(in: DIR_RANGE)
    
    init() {
        clean()
        randomSetShips()
    }
    
    func checkStartPosition(_ x:Int, _ y:Int, _ size:Int, _ orient:Int)-> Bool {
        if orient == HORZ {
            if x + size > 10 {
                return false
            }
            for i in x...(x + size - 1) {
                if selfField[y][i] != NONE {
                    return false
                }
            }
            return true
        }
        else if orient == VERT {
            if y + size > 10 {
                return false
            }
            for i in y...(y + size - 1) {
                if selfField[i][x] != NONE {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    func addShip(_ x:Int, _ y:Int, _ size:Int, _ orient:Int = HORZ)-> Bool {
        if !TABLE_RANGE.contains(size) ||
            !TABLE_RANGE.contains(x) ||
            !TABLE_RANGE.contains(y) ||
            shipsCount[size] == 0 ||
            selfField[y][x] != NONE ||
            (!checkStartPosition(x, y, size, orient)) {
                return false
        }
        if orient == HORZ {
            for j in (y - 1)...(y + 1) {
                if !TABLE_RANGE.contains(j) { continue }
                for i in (x - 1)...(x + size) {
                    if !TABLE_RANGE.contains(i) { continue }
                    if j == y && i >= x && i < x + size {
                        selfField[j][i] = SHIP
                    } else {
                        selfField[j][i] = STOP
                    }
                }
            }
            shipsCount[size] -= 1
            return true
        }
        else if orient == VERT {
            for i in (x - 1)...(x + 1) {
                if !TABLE_RANGE.contains(i) { continue }
                for j in (y - 1)...(y + size) {
                    if !TABLE_RANGE.contains(j) { continue }
                    if i == x && j >= y && j < y + size {
                        selfField[j][i] = SHIP
                    } else {
                        selfField[j][i] = STOP
                    }
                }
            }
            shipsCount[size] -= 1
            return true
        }
        return false
    }
    
    func clean() {
        opponentField = CLEAN_FIELD
        shipsCount = SHIPS_COUNT
        selfField = CLEAN_FIELD
        lastMove = nil
        goodLastMove = nil
        curDirection = Int.random(in: DIR_RANGE)
    }
    
    func randomSetShips() {
        while (true){
            var index = 4
            shipsCount = SHIPS_COUNT
            selfField = CLEAN_FIELD
            for _ in 0...1000 {
                let x:Int = Int.random(in: TABLE_RANGE)
                let y:Int = Int.random(in: TABLE_RANGE)
                let size:Int = Int.random(in: SIZE_RANGE)
                let orient:Int = Int.random(in: 0...1)
                let _ = addShip(x, y, size, orient)
                if shipsCount[index] == 0 {
                    index -= 1
                }
                if index == 0 {
                    return
                }
            }
        }
    }
    
    func autoMove()->Position? {
        if lastMove == nil {
            for _ in 0...1000 {
                let x:Int = Int.random(in: TABLE_RANGE)
                let y:Int = Int.random(in: TABLE_RANGE)
                lastMove = Position(x, y)
                if lastMove != nil {
                    if opponentField[lastMove!.y][lastMove!.x] == NONE {
                        return lastMove
                    }
                }
            }
            return nil
        }
        switch curDirection {
            case LEFT:
            if lastMove!.x > 1 && opponentField[lastMove!.y][lastMove!.x - 1] == NONE {
                lastMove!.x += 1
                return lastMove
            }
            default: break
        }
        return lastMove
    }
}

let player = ParticipanClass()
player.randomSetShips()
//ShowField(player)
//print()
//ShowField(player)
/*
let msg1 = "Введите позицию в английской раскладке через пробел (например 'b 1' или 'D 2'):"
var msg = msg1
while (true) {
    ShowField(player)
    print (msg)
    let str = String(readLine()!)
    if str == "exit" { break }
    let line = str.split(separator: " ")
    if line.count != 2 {
        msg = "Вы ошиблись! Будьте внимательнее!\n" + msg
    }
    else {
        msg = msg1
        let letter = line[0]
        let figure = Int(line[1])!
        print("x = \(letter) y = \(figure)")
    //    let pos = Position(letter: line[0], figure: Int(line[1]))
    //    if pos != nil {
    //        print(pos)
    //    }
    }
}
*/
/*
var posBullet = 0
var delta = 1
var fire = 0
var deltaFire = 1
for _ in 0...300 {
    bullet = NOT_BULLET
    bullet[posBullet] = "*"
    ShowField(player, fire:fire)
    print()
    posBullet += delta
    if posBullet == 7 || posBullet == 0 {
        delta = 0 - delta
        fire  += deltaFire
        if fire == 9 || fire == 0 {
            deltaFire = 0 - deltaFire
        }
    }
    usleep(500000)
}
*/
//let d=0
var y = 5
for i in 0...9 {
    let dj = Int(4 * sin(Double.pi * Double(i) / 8))
    player.opponentField[y - dj][i] = SHIP
    ShowField(player, fire: 9)
    usleep(800000)
}
//let line = "BLANCHE:   I don't want realism. I want magic!"
//print(line.split(separator: " "))