import Foundation

let TABLE_RANGE = 0...9

enum Cell {
    case NONE
    case SHIP
    case FIRE
    case UPSS
    case STOP
}

struct Position {
    var x:Int = 0
    var y:Int = 0

    init?(x:Int, y:Int) {
        if !TABLE_RANGE.contains(x) || !TABLE_RANGE.contains(y) { return nil }
        self.x = x - 1
        self.y = y - 1
    }
}

final class UI {
    static let instance:UI = {
        let inst = UI()
        return inst
    }()
    private init() {}

    let NOT_BULLET: [Character] = [" ", " ", " ", " ", " ", " ", " ", " "]

    let FIGURE: [Cell: String] = [
        .NONE: ". ",
        .SHIP: "# ",
        .FIRE: "@ ",
        .UPSS: "X ",
        .STOP: ". "]

    var bullet: [Character] = [" ", " ", " ", " ", " ", " ", " ", " "]
    
    var screenBuffer: [String] = [""]

    private func Waves() {
        
    }

    func ShowField(_ player:Participan, fire:Int){
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
}

extension UI: NSCopying {

    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}

class Participan {
    static let CLEAN_FIELD: [[Cell]] = [
        [.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE],
        [.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE],
        [.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE],
        [.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE],
        [.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE],
        [.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE],
        [.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE],
        [.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE],
        [.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE],
        [.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE,.NONE]]
    
    static let SHIPS_COUNT = [0,4,3,2,1]
    
 
    static let SIZE_RANGE = 1...4
    
    enum Direction: CaseIterable {
        case LEFT
        case RIGHT
        case UP
        case DOWN
    }
    
    enum Orient: CaseIterable {
        case HORIZONTAL
        case VERTICAL
    }
    
    var selfField = Participan.CLEAN_FIELD
    var opponentField = Participan.CLEAN_FIELD
    var shipsCount = Participan.SHIPS_COUNT
    var lastMove:Position? = nil
    var goodLastMove:Position? = nil
    var curDirection = Direction.allCases.randomElement()!
    
    init() {
        clean()
        randomSetShips()
    }
    
    func checkStartPosition(_ x:Int, _ y:Int, _ size:Int, _ orient:Participan.Orient)-> Bool {
        switch (orient) { 
            case .HORIZONTAL:
                if x + size > 10 {
                    return false
                }
                for i in x...(x + size - 1) {
                    if selfField[y][i] != Cell.NONE {
                     return false
                    }
                }
                return true
            case .VERTICAL:
                if y + size > 10 {
                    return false
                }
                for i in y...(y + size - 1) {
                    if selfField[i][x] != Cell.NONE {
                        return false
                    }
                }
                return true
        }
    }
    
    func addShip(_ x:Int, _ y:Int, _ size:Int, _ orient:Orient = .HORIZONTAL)-> Bool {
        if !Participan.SIZE_RANGE.contains(size) ||
            !TABLE_RANGE.contains(x) ||
            !TABLE_RANGE.contains(y) ||
            shipsCount[size] == 0 ||
            selfField[y][x] != .NONE ||
            (!checkStartPosition(x, y, size, orient)) {
                return false
        }
        switch (orient) { 
            case .HORIZONTAL:
                for j in (y - 1)...(y + 1) {
                    if !TABLE_RANGE.contains(j) { continue }
                    for i in (x - 1)...(x + size) {
                        if !TABLE_RANGE.contains(i) { continue }
                        if j == y && i >= x && i < x + size {
                            selfField[j][i] = Cell.SHIP
                        } else {
                            selfField[j][i] = Cell.STOP
                        }
                    }
                }
                shipsCount[size] -= 1
                return true
            case .VERTICAL:
                for i in (x - 1)...(x + 1) {
                    if !TABLE_RANGE.contains(i) { continue }
                    for j in (y - 1)...(y + size) {
                        if !TABLE_RANGE.contains(j) { continue }
                        if i == x && j >= y && j < y + size {
                            selfField[j][i] = Cell.SHIP
                        } else {
                            selfField[j][i] = Cell.STOP
                        }
                    }
                }
                shipsCount[size] -= 1
                return true
        }
    }
    
    func clean() {
        opponentField = Participan.CLEAN_FIELD
        shipsCount = Participan.SHIPS_COUNT
        selfField = Participan.CLEAN_FIELD
        lastMove = nil
        goodLastMove = nil
        curDirection = Direction.allCases.randomElement()!
    }
    
    func randomSetShips() {
        while (true){
            var index = 4
            shipsCount = Participan.SHIPS_COUNT
            selfField = Participan.CLEAN_FIELD
            for _ in 0...1000 {
                let x:Int = Int.random(in: TABLE_RANGE)
                let y:Int = Int.random(in: TABLE_RANGE)
                let size:Int = Int.random(in: Participan.SIZE_RANGE)
                let orient = Orient.allCases.randomElement()!
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
                lastMove = Position(x:x, y:y)
                if lastMove != nil {
                    if opponentField[lastMove!.y][lastMove!.x] == .NONE {
                        return lastMove
                    }
                }
            }
            return nil
        }
        switch curDirection {
            case .LEFT:
            if lastMove!.x > 1 && opponentField[lastMove!.y][lastMove!.x - 1] == .NONE {
                lastMove!.x += 1
                return lastMove
            }
            default: break
        }
        return lastMove
    }
}

class Game {
    enum Step:CaseIterable {
        case player
        case opponent
    }
    
    let player: Participan
    let opponent: Participan
    var currentStep: Step
    
    init(player:Participan, opponent:Participan) {
        self.player = player
        self.opponent = opponent
        currentStep = Step.allCases.randomElement()!
    }
}

let player = Participan()
player.randomSetShips()

let opponent = Participan()
opponent.randomSetShips()

let game = Game(player:player, opponent:opponent)
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
let ui = UI.instance
var y = 5
for i in 0...9 {
    let dj = Int(4 * sin(Double.pi * Double(i) / 8))
    player.opponentField[y - dj][i] = .SHIP
    ui.ShowField(player, fire: 9)
    //usleep(200000)
}

var buff=[[Character]]()

for _ in 0...9 {
    var tmp=[Character]()
    for _ in 0...9 {
       tmp.append(".")
       tmp.append(" ")
    }
    buff.append(tmp)
}

for k in 0...9 {
    buff[k][4] = "8"
    for j in 0...9 {
        print(String(buff[j]))
    }
    print()
    usleep(200000)
}