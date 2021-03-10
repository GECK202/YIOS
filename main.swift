import Foundation

let TABLE_RANGE = 0...9

enum Cell {
    case NONE
    case SHIP
    case FIRE
    case UPSS
    case STOP
}

enum Current:CaseIterable {
    case PLAYER
    case OPPONENT
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

final class UI {
    static var inst:UI? = nil
    
    static func instance(player:Participan)->UI {
        if inst == nil {
            inst = UI(player:player)
        }
        return inst!
    }
    
    private let player:Participan
    
    private init(player:Participan) {
        self.player = player
    }

    private var buff:[[Character]] = Array(repeating: Array(repeating: ".", count: 60), count: 15)

    func ResetBuff(player:Participan) {
        let FIGURE: [Cell: Character] = [
            .NONE: ".",
            .SHIP: "#",
            .FIRE: "@",
            .UPSS: "*",
            .STOP: "X"]
        buff[0] = Array("       ПОЛЕ ИГРОКА     |          |      ПОЛЕ ПРОТИВНИКА   ")
        buff[1] = Array("   a b c d e f g h i j |          |    a b c d e f g h i j ")
        for j in 2..<buff.count {
            for i in 0..<buff[j].count{
                if j < 12 {
                    switch(i) {
                    case 2...22 where i % 2 == 1:
                        buff[j][i] = FIGURE[player.getSelfCell(pos:Position(x:(i - 2) / 2, y:j - 2)!)] ?? "?"
                    case 38...58 where i % 2 == 1:
                        buff[j][i] = FIGURE[player.getOpponentCell(pos:Position(x:(i - 38) / 2, y:j - 2)!)] ?? "?"
                    case 23, 34:
                        buff[j][i] = "|"
                    default:
                        buff[j][i] = " "
                    }
                }
            }
            if j > 1 && j < 11 {
                let num = Array(String(j - 1))[0]
                buff[j][0] = " "
                buff[j][1] = num
                buff[j][36] = " "
                buff[j][37] = num
            } else if j == 11 {
                buff[j][0] = "1"
                buff[j][1] = "0"
                buff[j][36] = "1"
                buff[j][37] = "0"
            }
        }
    }
    
    func PrintBuff() {
        for j in 0..<buff.count {
            print(String(buff[j]))
        }
    }
    
    private func DrawFireFrom(pos:Position, sym:Character) {
        let deltaX = pos.x * 2 + 1
        let xDist = 46 - deltaX
        var half = xDist / 2
        let qHalf = half * half
        half += deltaX
        //let i = deltaX
        for i in stride(from:45, through:deltaX, by: -1) {
            ResetBuff(player:player)
            let h = i < half ? pos.y + 2 : 6
            let j = (i - half) * (i - half) * h / qHalf
            buff[j][i + 2] = sym
            PrintBuff()
            usleep(100000)
        }
    }

    private func DrawFireTo(pos:Position, sym:Character) {
        let deltaX = (pos.x + 1) * 2
        let xDist = 27 + deltaX
        var half = xDist / 2
        let qHalf = half * half
        half += 11
        //let i = xDist + 10
        for i in stride(from:11, to:(xDist + 11), by: 1) {
            ResetBuff(player:player)
            let h = i < half ? 6 : pos.y + 2
            let j = (i - half) * (i - half) * h / qHalf
            buff[j][i] = sym
            PrintBuff()
            usleep(100000)
        }
    }

    func DrawFire(pos:Position, cur:Current) {
        if cur == .PLAYER {
            DrawFireTo(pos:pos, sym:"O")
        } else {
            DrawFireFrom(pos:pos, sym:"O")
        }
    }

    func DrawWave(pos:Position, cur:Current){
        for r in 0..<16 {
            ResetBuff(player:player)
            for j in (pos.y - r)...(pos.y + r) {
                if TABLE_RANGE.contains(j) {
                    for i in (pos.x - r)...(pos.x + r) {
                        if TABLE_RANGE.contains(i) {
                            let dx = pos.x - i
                            let dy = pos.y - j
                            let dist = Int(Float(dx * dx + dy * dy).squareRoot())
                            let deltaX = cur == .PLAYER ? 39 : 3
                            if dist == r {
                                buff[j + 2][i * 2 + deltaX] = "&"
                            }
                        }
                    }
                }
            }
            PrintBuff()
            usleep(100000)
        }
    }    

    func DrawInfo(x:Int, y:Int, info:String) {
        let syms = Array(info)
        if (0..<4).contains(y) {
            let j = 12 + y
            for i in 0..<syms.count {
                if (0..<60).contains(i + x) {
                    buff[j][i + x] = syms[i]
                }
            }
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
    
    enum Direction {
        case LEFT
        case RIGHT
        case UP
        case DOWN
        
        var NEXT:Direction {
            switch self {
                case .LEFT: return .RIGHT
                case .RIGHT: return .UP
                case .UP: return .DOWN
                case .DOWN: return .LEFT
            }
        }
    }
    
    enum Orient: CaseIterable {
        case HORIZONTAL
        case VERTICAL
    }
    
    private var selfField = Participan.CLEAN_FIELD
    private var opponentField = Participan.CLEAN_FIELD
    private var shipsCount = Participan.SHIPS_COUNT
    private var lastMove:Position? = nil
    private var goodLastMove:Position? = nil
    private var curDirection = Direction.LEFT
    private var destroyShips = 0
    
    init() {
        clean()
        randomSetShips()
        cleanStop()
    }
    
    private func checkStartPosition(_ x:Int, _ y:Int, _ size:Int, _ orient:Participan.Orient)-> Bool {
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
    
    private func clean() {
        opponentField = Participan.CLEAN_FIELD
        shipsCount = Participan.SHIPS_COUNT
        selfField = Participan.CLEAN_FIELD
        lastMove = nil
        goodLastMove = nil
        curDirection = Direction.LEFT
        destroyShips = 0
    }
    
    private func findToLeft(setField:inout[[Cell]], _ x:Int, _ y:Int, find:Cell, ignore:Cell = .FIRE)->Bool {
        if x >= 0 {
            if setField[y][x] == find {return true}
            if setField[y][x] == ignore {
                if x > 0 {
                    return findToLeft(setField:&setField, x - 1, y, find:find, ignore:ignore)
                }
            }
        }
        return false
    }
    
    private func findToRight(setField:inout[[Cell]], _ x:Int, _ y:Int, find:Cell, ignore:Cell = .FIRE)->Bool {
        if x <= 9 {
            if setField[y][x] == find {return true}
            if setField[y][x] == ignore {
                if x < 9 {
                    return findToRight(setField:&setField, x + 1, y, find:find, ignore:ignore)
                }
            }
        }
        return false
    }
    
    private func findToUp(setField:inout[[Cell]], _ x:Int, _ y:Int, find:Cell, ignore:Cell = .FIRE)->Bool {
        if y >= 0 {
            if setField[y][x] == find {return true}
            if setField[y][x] == ignore {
                if y > 0 {
                    return findToUp(setField:&setField, x, y - 1, find:find, ignore:ignore)
                }
            }
        }
        return false
    }
    
    private func findToDown(setField:inout[[Cell]], _ x:Int, _ y:Int, find:Cell, ignore:Cell = .FIRE)->Bool {
        if y <= 9 {
            if setField[y][x] == find {return true}
            if setField[y][x] == ignore {
                if y < 9 {
                    return findToDown(setField:&setField, x, y + 1, find:find, ignore:ignore)
                }
            }
        }
        return false
    }
    
    private func checkShip(pos:Position)->Bool {
        if findToLeft(setField:&selfField, pos.x, pos.y, find:.SHIP) ||
            findToRight(setField:&selfField, pos.x, pos.y, find:.SHIP) ||
            findToUp(setField:&selfField, pos.x, pos.y, find:.SHIP) ||
            findToDown(setField:&selfField, pos.x, pos.y, find:.SHIP) {return false}
        return true
    }
    
    private func setStopAroundShips(setField: inout [[Cell]], pos:Position) {
        var sizeX = 0
        var sizeY = 0
        var posStart = Position(x:pos.x, y:pos.y)!
        for x in stride(from:pos.x + 1, to:pos.x + 4, by:1) {
            if x > 9 { break }
            if setField[pos.y][x] == .FIRE {
                sizeX += 1
            } else { break }
            
        }
        for x in stride(from:pos.x - 1, to:pos.x - 4, by: -1) {
            if x < 0 { break }
            if setField[pos.y][x] == .FIRE {
                sizeX += 1
                posStart.x = x
            } else { break }
            
        }
        for y in stride(from:pos.y + 1, to:pos.y + 4, by:1) {
            if y > 9 { break }
            if setField[y][pos.x] == .FIRE {
                sizeY += 1
            } else { break }
            
        }
        for y in stride(from:pos.y - 1, to:pos.y - 4, by:-1) {
            if y < 0 { break }
            if setField[y][pos.x] == .FIRE {
                sizeY += 1
                posStart.y = y
            } else { break }
        }
        for y in (posStart.y - 1)...(posStart.y + sizeY + 1) {
            if TABLE_RANGE.contains(y) {
                for x in (posStart.x - 1)...(posStart.x + sizeX + 1) {
                    if TABLE_RANGE.contains(x) {
                        if x < posStart.x || x > posStart.x + sizeX || y < posStart.y || y > posStart.y + sizeY {
                            setField[y][x] = .STOP
                        }
                    }
                }
            } 
        }
    }
    
    private func randomMove()->Position? {
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

    func checkCell(pos:Position)->Bool {
        if opponentField[pos.y][pos.x] == .NONE {
            return true
        }
        return false
    }
    
    func checkAttack(pos:Position)->Cell {
        if selfField[pos.y][pos.x] == .SHIP {
            selfField[pos.y][pos.x] = .FIRE
            if checkShip(pos:pos) {
                setStopAroundShips(setField: &selfField, pos:pos)
                return .STOP
            } else {
                return .FIRE
            }
        } else {
            if selfField[pos.y][pos.x] == .NONE {
                selfField[pos.y][pos.x] = .UPSS
            } 
            return .UPSS
        }
    }

    func autoMove()->Position? {
        if goodLastMove == nil {
            return randomMove()
        } else {
        let good = goodLastMove!
        lastMove = good
        for _ in 0..<4 {
            switch curDirection {
                case .LEFT:
                if findToLeft(setField:&opponentField, good.x, good.y, find:.NONE) {
                    for x in stride(from:good.x - 1, to:good.x - 4, by:-1) {
                        if opponentField[good.y][x] == .NONE {
                            lastMove!.x = x
                            return lastMove
                        }
                    }
                }
                case .RIGHT:
                if findToRight(setField:&opponentField, good.x, good.y, find:.NONE) {
                    for x in good.x + 1...good.x + 3 {
                        if opponentField[good.y][x] == .NONE {
                            lastMove!.x = x
                            return lastMove
                        }
                    }
                }
                case .UP:
                if findToUp(setField:&opponentField, good.x, good.y, find:.NONE) {
                    for y in stride(from:good.y - 1, to:good.y - 4, by:-1) {
                        if opponentField[y][good.x] == .NONE {
                            lastMove!.y = y
                            return lastMove
                        } 
                    }
                }
                case .DOWN:
                if findToDown(setField:&opponentField, good.x, good.y, find:.NONE) {
                    for y in good.y + 1...good.y + 3 {
                        if opponentField[y][good.x] == .NONE {
                            lastMove!.y = y
                            return lastMove
                        } 
                    }
                }
            }
            curDirection = curDirection.NEXT
        }
        }
        return randomMove()
    }

    func setResultAttack(pos:Position, res:Cell)->Bool {
        if res == .FIRE {
            opponentField[pos.y][pos.x] = .FIRE
            goodLastMove = pos
            return true
        } else if res == .STOP {
            opponentField[pos.y][pos.x] = .FIRE
            destroyShips += 1
            setStopAroundShips(setField: &opponentField, pos:pos)
            goodLastMove = nil
            return true
        } else if opponentField[pos.y][pos.x] == .NONE {
            opponentField[pos.y][pos.x] = .UPSS
            curDirection = curDirection.NEXT
            return false
        }
        return false
    }
    
    func getSelfCell(pos:Position)->Cell {
        return selfField[pos.y][pos.x]
    }
    
    func getOpponentCell(pos:Position)->Cell {
        return opponentField[pos.y][pos.x]
    }
    
    func getDestroyShips()->Int {
        return destroyShips
    }
    
    func Test_setOpponentField(pos:Position, cell:Cell, cur:Current) {
        if cur == .PLAYER {
            opponentField[pos.y][pos.x] = cell
        } else {
            selfField[pos.y][pos.x] = cell
        }
    }
    
    func Test_getGoodLastMove()->String {
        var last:String = ""
        if lastMove == nil {
            last = "LAST=NIL"
        } else {
            last = "LAST x=\(lastMove!.x) y=\(lastMove!.y)"
        }
        if goodLastMove == nil {
            return "\(last) GOOD=NIL dir=\(curDirection)"
        } else {
            return "\(last) GOOD x=\(goodLastMove!.x) y=\(goodLastMove!.y) dir=\(curDirection)"
        }
    }
    
    func cleanStop() {
        for j in TABLE_RANGE {
        for i in TABLE_RANGE {
           if selfField[j][i] == .STOP {
               selfField[j][i] = .NONE
           }
        }
        }
    }
}

class Game {
    let player: Participan
    let opponent: Participan
    let ui: UI
    var current:Current
    var win:Current?
    
    init(player:Participan, opponent:Participan) {
        self.player = player
        self.opponent = opponent
        ui = UI.instance(player:player)
        current = Current.allCases.randomElement()!
    }
    
    func update() {
        while true {
            if player.getDestroyShips() == 10 {
                win = .PLAYER
                break
            }
            
            if opponent.getDestroyShips() == 10 {
                win = .OPPONENT
                break
            }
            
            if current == .PLAYER {
                if let pos = player.autoMove() {
                    if opponent.checkCell(pos:pos) {
                        ui.DrawFire(pos:pos, cur:current)
                        if player.setResultAttack(pos:pos, res:opponent.checkAttack(pos:pos)) {
                            ui.DrawWave(pos:pos, cur:current)
                        } else {
                            current = .OPPONENT
                        }
                    }
                }
            } else {
                if let pos = opponent.autoMove() {
                    if player.checkCell(pos:pos) {
                        ui.DrawFire(pos:pos, cur:current)
                            if opponent.setResultAttack(pos:pos, res:player.checkAttack(pos:pos)) {
                                ui.DrawWave(pos:pos, cur:current)
                            } else {
                                current = .PLAYER
                            }
                        }
                    }
                }
            }
         
        if win == .PLAYER {
            print ("ИГРОК ПОБЕДИЛ")
        } else {
            print("ИГРОК ПРОИГРАЛ")
        }
    }
}

let player = Participan()

let opponent = Participan()

let game = Game(player:player, opponent:opponent)

game.update()