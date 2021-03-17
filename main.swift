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

final class UI {
    enum CurrentField {
        case LEFT
        case RIGHT
    }
    
    enum Banner {
        case WIN
        case LOST
        case START
        case MENU
        case HELP
    }
    
    static var inst:UI? = nil
    
    static func instance()->UI {
        if inst == nil {
            inst = UI()
        }
        return inst!
    }
    
    private init() {}

    private var buff:[[Character]] = Array(repeating: Array(repeating: ".", count: 60), count: 16)

    private func ResetBuff(leftField:[[Cell]], rightField:[[Cell]]) {
        let FIGURE: [Cell: Character] = [
            .NONE: " ",
            .SHIP: "#",
            .FIRE: "@",
            .DEAD: ".",
            .UPSS: "*",
            .STOP: "X"]
        buff[0] = Array("       ПОЛЕ ИГРОКА     │          │      ПОЛЕ ПРОТИВНИКА   │")
        buff[1] = Array("   a b c d e f g h i j │          │    a b c d e f g h i j │")
        for j in 2..<buff.count {
            for i in 0..<buff[j].count{
                if j < 12 {
                    switch(i) {
                    case 2...22 where i % 2 == 1:
                        buff[j][i] = FIGURE[leftField[j - 2][(i - 2) / 2]] ?? "?"
                    case 38...58 where i % 2 == 1:
                        buff[j][i] = FIGURE[rightField[j - 2][(i - 38) / 2]] ?? "?"
                    case 23, 34, 59:
                        buff[j][i] = "│"
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
            } else if j == 12 {
                for i in 0..<buff[j].count{
                    switch(i) {
                    case 23, 34:
                        buff[j][i] = "┴"
                    case 59:
                        buff[j][i] = "┘"
                    default:
                        buff[j][i] = "─"
                    }
                }
            }
        }
    }
    
    private func PrintBuff() {
        for j in 0..<buff.count {
            print(String(buff[j]))
        }
    }
    
    private func DrawTargetPoint(_ i:Int, _ j:Int){
        buff[j - 1][i + 0] = "│"
        buff[j + 0][i - 1] = "─"
        buff[j + 0][i + 1] = "─"
        buff[j + 1][i + 0] = "│"
    }
    
    private func DrawBalisticAttackToLeft(pos:Position, sym:Character, leftField:[[Cell]], rightField:[[Cell]]) {
        let deltaX = pos.x * 2 + 1
        let xDist = 46 - deltaX
        var half = xDist / 2
        let qHalf = half * half
        half += deltaX
        for i in stride(from:45, through:deltaX, by: -1) {
            ResetBuff(leftField:leftField, rightField:rightField)
            let h = i < half ? pos.y + 2 : 6
            let j = (i - half) * (i - half) * h / qHalf
            buff[j][i + 2] = sym
            DrawTargetPoint(pos.x * 2 + 3, pos.y + 2)
            PrintBuff()
            usleep(50000)
        }
    }

    private func DrawBalisticAttackToRight(pos:Position, sym:Character, leftField:[[Cell]], rightField:[[Cell]]) {
        let deltaX = (pos.x + 1) * 2
        let xDist = 27 + deltaX
        var half = xDist / 2
        let qHalf = half * half
        half += 11
        for i in stride(from:11, to:(xDist + 11), by: 1) {
            ResetBuff(leftField:leftField, rightField:rightField)
            let h = i < half ? 6 : pos.y + 2
            let j = (i - half) * (i - half) * h / qHalf
            buff[j][i] = sym
            DrawTargetPoint(pos.x * 2 + 39, pos.y + 2)
            PrintBuff()
            usleep(50000)
        }
    }

    func SetInfo(col:Int = 0, line:Int = 0, info:String) {
        let syms = Array(info)
        if (0..<4).contains(line) {
            let j = 13 + line
            for i in col..<60 {
                if (0..<60).contains(i) {
                    if (i - col) < syms.count {
                        buff[j][i] = syms[i - col]
                    } else {
                        buff[j][i] = " "
                    }
                }
            }
        }
    }
    
    func SetRandomInfo(col:Int = 0, line:Int = 0, start:Int = 0, info:[String]) {
        let index = Int.random(in: (start..<info.count))
        SetInfo(col:col, line:line, info:info[index])
    }
    
    func DrawBalisticAttack(pos:Position, to:CurrentField, leftField:[[Cell]], rightField:[[Cell]]) {
        if to == .RIGHT {
            DrawBalisticAttackToRight(pos:pos, sym:"O", leftField:leftField, rightField:rightField)
        } else {
            DrawBalisticAttackToLeft(pos:pos, sym:"O", leftField:leftField, rightField:rightField)
        }
    }

    func DrawWave(pos:Position, to:CurrentField, leftField:[[Cell]], rightField:[[Cell]]){
        let deltaX = to == .RIGHT ? 39 : 3
        for r in 0..<16 {
            ResetBuff(leftField:leftField, rightField:rightField)
            for j in (pos.y - r)...(pos.y + r) {
                if TABLE_RANGE.contains(j) {
                    for i in (pos.x - r)...(pos.x + r) {
                        if TABLE_RANGE.contains(i) {
                            let dx = pos.x - i
                            let dy = pos.y - j
                            let dist = Int(Float(dx * dx + dy * dy).squareRoot())
                            if dist == r {
                                buff[j + 2][i * 2 + deltaX] = "&"
                            }
                        }
                    }
                }
            }
            let sym:Character = r % 2 == 0 ? "#" : "@"
            buff[pos.y + 2][pos.x * 2 + deltaX] = sym
            PrintBuff()
            usleep(100000)
        }
    }

    func DrawUPSS(pos:Position, to:CurrentField, leftField:[[Cell]], rightField:[[Cell]]){
        let deltaX = to == .RIGHT ? 39 : 3
        for i in 0..<2 {
            ResetBuff(leftField:leftField, rightField:rightField)
            let sym:Character = i % 2 == 0 ? "*" : "X"
            buff[pos.y + 2][pos.x * 2 + deltaX] = sym
            PrintBuff()
            usleep(100000)
        }
    }

    func DrawFields(leftField:[[Cell]], rightField:[[Cell]]) {
        ResetBuff(leftField:leftField, rightField:rightField)
        PrintBuff()
    }

    func SetInfos(info:[String] = []) {
        switch info.count {
        case 0:
            SetInfo(col:0, line:0, info:"")
            SetInfo(col:0, line:1, info:"")
            SetInfo(col:0, line:2, info:"")
        case 1:
            SetInfo(col:0, line:0, info:"")
            SetInfo(col:0, line:1, info:"")
            SetInfo(col:0, line:2, info:info[0])
        case 2:
            SetInfo(col:0, line:0, info:"")
            SetInfo(col:0, line:1, info:info[0])
            SetInfo(col:0, line:2, info:info[1])
        default:
            SetInfo(col:0, line:0, info:info[0])
            SetInfo(col:0, line:1, info:info[1])
            SetInfo(col:0, line:2, info:info[2])
        }
    }
    
    func DrawBanner(leftField:[[Cell]], rightField:[[Cell]], line:Int, col:Int, banner:[String]) {
        if line < 0 || line > 10 || col < 0 || col > 57 {
            return
        }
        var max_val = 1
        let lastLine = min(12, banner.count + line + 1)  
        for i in 0..<banner.count{
            max_val = max(banner[i].count, max_val)
        }
        max_val = min(max_val + col + 1, 59)
        ResetBuff(leftField:leftField, rightField:rightField)
        buff[line][col] = "╔"
        buff[line][max_val] = "╗"
        buff[lastLine][col] = "╚"
        buff[lastLine][max_val] = "╝"
        for i in (col + 1)..<max_val {
            buff[line][i] = "═"
            buff[lastLine][i] = "═"
        }
        var j = line + 1
        for n in banner {
            buff[j][col] = "║"
            buff[j][max_val] = "║"
            var i = col + 1
            for l in n {
                if i < max_val {
                    buff[j][i] = l
                }
                i += 1
            }
            if i < max_val - 1 {
                for k in i..<max_val {
                    buff[j][k] = " "
                }
            }
            j += 1
            if j >= lastLine {
                break
            }
        }
    }

    func GetCell(leftField:[[Cell]], rightField:[[Cell]], request:[String] = [], exitWord:String, onError:String)->Position? {
        let Map:[Character:Int] = ["a":0, "b":1, "c":2, "d":3, "e":4, "f":5, "g":6, "h":7, "i":8, "j":9]
        var x:Int = -1
        var y:Int = -1
        var ySet:Bool = false
        var xSet:Bool = false
        while true {
            if request.count > 0 {
                SetInfos(info:request)
            }
            DrawFields(leftField:leftField, rightField:rightField)
            let k = readLine()!.lowercased()
            if k == exitWord {
                break
            }
            if (2...4).contains(k.count) {
                x = -1; y = -1
                xSet = false; ySet = false
                let l = Array(k)
                for i in 0..<l.count {
                    if ("a"..."j").contains(l[i]) {
                        if xSet == false {
                            x = Map[l[i]]!
                            xSet = true
                        } else {
                            xSet = false
                            break
                        }
                    } else if ("1"..."9").contains(l[i]) {
                        if ySet == false {
                            y = Int(String(l[i]))! - 1
                            ySet = true
                        } else {
                            ySet = false
                            break
                        }
                    } else if l[i] == "0" {
                        if i > 0 && l[i - 1] == "1" {
                            y = 9
                        } else {
                            ySet = false
                            break
                        }
                    } else if l[i] == " " {
                        if i > 0 && l[i - 1] == " " {
                            xSet = false
                            break
                        }
                    } else {
                        xSet = false
                        break
                    }
                }
                if (xSet == true) && (ySet == true) {
                    break
                }
            }
            SetInfo(line:0, info:onError)
            DrawFields(leftField:leftField, rightField:rightField)
        }
        let pos = Position(x:x, y:y)
        return pos
    }

    func GetPress(info:[String] = ["","","Press Enter..."]) {
        SetInfos(info:info)
        PrintBuff()
        _ = readLine()!
    }

    func GetNumber(info:[String], numbers:ClosedRange<Int>, onError:String)->Int {
        SetInfos(info:info)
        PrintBuff()
        while true {
            if let n:Int = Int(readLine()!) {
                if numbers.contains(n) {
                    return n
                }
            }
            SetInfos(info:info)
            SetInfo(info:onError)
            PrintBuff()
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
        
        var REVERSE:Direction {
            switch self {
                case .LEFT: return .RIGHT
                case .RIGHT: return .LEFT
                case .UP: return .DOWN
                case .DOWN: return .UP
            }
        }
        
        var CROSS:Direction {
            switch self {
                case .LEFT: return .UP
                case .RIGHT: return .DOWN
                case .UP: return .RIGHT
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
    private var oldGoodLastMove:Position? = nil
    private var curDirection = Direction.LEFT
    private var destroyShips = 0
    
    init() {
        randomSetShips()
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
    
    func deleteStop() {
        for j in TABLE_RANGE {
        for i in TABLE_RANGE {
           if selfField[j][i] == .STOP {
               selfField[j][i] = .NONE
           }
        }
        }
    }
    
    private func findToLeft(from field:[[Cell]], _ x:Int, _ y:Int, find:Cell, ignore:Cell = .FIRE)->Bool {
        if x >= 0 {
            if field[y][x] == find {return true}
            if field[y][x] == ignore {
                if x > 0 {
                    return findToLeft(from:field, x - 1, y, find:find, ignore:ignore)
                }
            }
        }
        return false
    }
    
    private func findToRight(from field:[[Cell]], _ x:Int, _ y:Int, find:Cell, ignore:Cell = .FIRE)->Bool {
        if x <= 9 {
            if field[y][x] == find {return true}
            if field[y][x] == ignore {
                if x < 9 {
                    return findToRight(from:field, x + 1, y, find:find, ignore:ignore)
                }
            }
        }
        return false
    }
    
    private func findToUp(from field:[[Cell]], _ x:Int, _ y:Int, find:Cell, ignore:Cell = .FIRE)->Bool {
        if y >= 0 {
            if field[y][x] == find {return true}
            if field[y][x] == ignore {
                if y > 0 {
                    return findToUp(from:field, x, y - 1, find:find, ignore:ignore)
                }
            }
        }
        return false
    }
    
    private func findToDown(from field:[[Cell]], _ x:Int, _ y:Int, find:Cell, ignore:Cell = .FIRE)->Bool {
        if y <= 9 {
            if field[y][x] == find {return true}
            if field[y][x] == ignore {
                if y < 9 {
                    return findToDown(from:field, x, y + 1, find:find, ignore:ignore)
                }
            }
        }
        return false
    }
    
    private func checkShip(pos:Position)->Bool {
        if findToLeft(from:selfField, pos.x, pos.y, find:.SHIP) ||
            findToRight(from:selfField, pos.x, pos.y, find:.SHIP) ||
            findToUp(from:selfField, pos.x, pos.y, find:.SHIP) ||
            findToDown(from:selfField, pos.x, pos.y, find:.SHIP) {return false}
        return true
    }
    
    private func setDeadShip(setField: inout [[Cell]], pos:Position) {
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
                        } else {
                            setField[y][x] = .DEAD
                        }
                    }
                }
            }
        }
    }
    
    private func emptyCellList(from field:[[Cell]])->[(Int, Int)] {
        var list:[(Int, Int)] = []
        for j in TABLE_RANGE {
            for i in TABLE_RANGE {
                if field[j][i] == .NONE {
                    list.append((i,j))
                }
            }
        }
        return list
    }
    
    func clean() {
        opponentField = Participan.CLEAN_FIELD
        shipsCount = Participan.SHIPS_COUNT
        selfField = Participan.CLEAN_FIELD
        lastMove = nil
        goodLastMove = nil
        curDirection = Direction.LEFT
        destroyShips = 0
    }

    func randomSetShips() {
        clean()
        while true {
            var index = 4
            shipsCount = Participan.SHIPS_COUNT
            selfField = Participan.CLEAN_FIELD
            for _ in 0...1000 {
                let list = emptyCellList(from:selfField)
                if shipsCount[index] == 0 {
                    index -= 1
                }
                if index == 0 {
                    deleteStop()
                    return
                }
                let ind:Int = Int.random(in: (0..<list.count))
                let size:Int = index
                let orient = Orient.allCases.randomElement()!
                let pos = Position(x:list[ind].0, y:list[ind].1)!
                let _ = addShip(pos:pos, size:size, orient:orient)
            }
        }
    }

    func randomMove()->Position?{
        let list = emptyCellList(from:opponentField)
        if list.isEmpty {
            return nil
        }
        let index = Int.random(in: (0..<list.count))
        let pos = Position(x:list[index].0, y:list[index].1)!
        goodLastMove = nil
        return pos
    }
    
    func checkEmptySelfField()->Bool{
        for j in TABLE_RANGE {
            for i in TABLE_RANGE {
                if selfField[j][i] == .NONE {
                    return false
                }
            }
        }
        return true
    }
    
    func addShip(pos:Position, size:Int, orient:Orient = .HORIZONTAL)-> Bool {
        if !Participan.SIZE_RANGE.contains(size) ||
            !TABLE_RANGE.contains(pos.x) ||
            !TABLE_RANGE.contains(pos.y) ||
            shipsCount[size] == 0 ||
            selfField[pos.y][pos.x] != .NONE ||
            (!checkStartPosition(pos.x, pos.y, size, orient)) {
                return false
        }
        switch (orient) {
        case .HORIZONTAL:
            for j in (pos.y - 1)...(pos.y + 1) {
                if !TABLE_RANGE.contains(j) { continue }
                for i in (pos.x - 1)...(pos.x + size) {
                    if !TABLE_RANGE.contains(i) { continue }
                    if j == pos.y && i >= pos.x && i < pos.x + size {
                        selfField[j][i] = Cell.SHIP
                    } else {
                        selfField[j][i] = Cell.STOP
                    }
                }
            }
            shipsCount[size] -= 1
            return true
        case .VERTICAL:
            for i in (pos.x - 1)...(pos.x + 1) {
                if !TABLE_RANGE.contains(i) { continue }
                for j in (pos.y - 1)...(pos.y + size) {
                    if !TABLE_RANGE.contains(j) { continue }
                    if i == pos.x && j >= pos.y && j < pos.y + size {
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
        } else {
            return false
        }
    }
    
    func checkAttack(pos:Position)->Cell {
        switch (selfField[pos.y][pos.x]) {
        case .SHIP:
            selfField[pos.y][pos.x] = .FIRE
            if checkShip(pos:pos) {
                setDeadShip(setField: &selfField, pos:pos)
                return .DEAD
            } else {
                return .FIRE
            }
        default:
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
                for x in stride(from:good.x - 1, to:good.x - 4, by:-1) {
                    if TABLE_RANGE.contains(x) {
                        if opponentField[good.y][x] == .NONE {
                            lastMove!.x = x
                            return lastMove
                        } else if opponentField[good.y][x] != .FIRE {
                            break
                        }
                    }
                }
            case .RIGHT:
                for x in stride(from:good.x + 1, to:good.x + 4, by:1) {
                    if TABLE_RANGE.contains(x) {
                        if opponentField[good.y][x] == .NONE {
                            lastMove!.x = x
                            return lastMove
                        } else if opponentField[good.y][x] != .FIRE {
                            break
                        }
                    }
                }
            case .UP:
                for y in stride(from:good.y - 1, to:good.y - 4, by:-1) {
                    if TABLE_RANGE.contains(y) {
                        if opponentField[y][good.x] == .NONE {
                            lastMove!.y = y
                            return lastMove
                        } else if opponentField[y][good.x] != .FIRE {
                            break
                        }
                    }
                }
            case .DOWN:
                for y in stride(from:good.y + 1, to:good.y + 4, by:1) {
                    if TABLE_RANGE.contains(y) {
                        if opponentField[y][good.x] == .NONE {
                            lastMove!.y = y
                            return lastMove
                        } else if opponentField[y][good.x] != .FIRE {
                            break
                        }
                    }
                }
            }
            if oldGoodLastMove == nil {
                curDirection = curDirection.NEXT
            } else {
                curDirection = curDirection.REVERSE
            }
        }
        }
        return randomMove()
    }

    func setResultAttack(pos:Position, res:Cell)->Bool {
        switch res {
        case.FIRE:
            opponentField[pos.y][pos.x] = .FIRE
            if goodLastMove == nil {
                oldGoodLastMove = nil
            } else {
                oldGoodLastMove = goodLastMove
            }
            goodLastMove = pos
            return true
        case .DEAD:
            opponentField[pos.y][pos.x] = .FIRE
            destroyShips += 1
            setDeadShip(setField: &opponentField, pos:pos)
            if goodLastMove == nil {
                oldGoodLastMove = nil
            } else {
                oldGoodLastMove = goodLastMove
            }
            goodLastMove = pos
            return true
        default:
            if opponentField[pos.y][pos.x] == .NONE {
                opponentField[pos.y][pos.x] = .UPSS
            }
            return false
        }
    }
    
    func getSelfField()->[[Cell]] {
        return selfField
    }
    
    func getOpponentField()->[[Cell]] {
        return opponentField
    }
    
    func getDestroyShips()->Int {
        return destroyShips
    }
}

class Game {
    let AVATAR:String = "🤴"
    let START_BANNER:[String] = [
        "  *** )─┼)***  ...o   . .      (┼─(",
        "   ** )─┼)*** ..     .   .  (┼─(┼─(┼─(",
        "╒══╕**)─┼) * .      .     . (┼─(┼─(┼ ╒══╕",
        "└─┐╘╦╬╦╦╬╦╦╬╦─>──  o    ──<─╦╬╦╦╬╦╦╬╦╛┌─┘",
        " ╭╯~ ~~ ~~ ~~/ ~~ ~v ~~ ~~ \\~~ ~~ ~ ~~╰╮",
        "-   ╔╦╗╔═╗╦═╗╔═╗╦╔═╔═╗╦║╔╗ ╦═╗╔═╗╦║╔╗   -",
        "--  ║║║║ ║╠═╝║  ╠╩╗║ ║║╔╝║ ╠═╗║ ║║╔╝║  --",
        "-   ╩ ╩╚═╝╩  ╚═╝╩ ╩╩═╝╚╝ ╩ ╩═╝╩═╝╚╝ ╩   -"]
    let WIN_BANNER:[String] = [
        "   ╔╦╗╦ ╦ ╔╗ ╦ ╦╦ ╔╗╦═╗╦═╗╔═╗ ╔╗ ┬ ┬ ┬   ",
        "    ║ ╠╗║ ╠╩╗╠╗║║╔╝║║  ╠═╝╠═╣╔╝║ │ │ │",
        "    ╩ ╚╝╩ ╚═╝╚╝╩╚╝ ╩╩  ╩  ╩ ╩╝ ╩ o o o",
        "    ╔═╗╔═╗╔═╗ ╔╗ ╦═╗╔═╗╔╗  ╔╗╔═╗╦╔═╗",
        "    ║ ║║ ║ ═║ ║║ ╠═╝╠═╣╠╩╗╔╝║╚╦╣╠╣ ║",
        "    ╩ ╩╚═╝╚═╝╔╩╩╗╩  ╩ ╩╚═╝╝ ╩═╝╩╩╚═╝"]
    let LOST_BANNER:[String] = [
        "  ╔╦╗╦ ╦ ╔═╗╦═╗╔═╗╦ ╔╗╦═╗╦═╗╔═╗ ╔╗ ┬ ┬ ┬",
        "   ║ ╠╗║ ║ ║╠═╝║ ║║╔╝║║  ╠═╝╠═╣╔╝║ │ │ │",
        "   ╩ ╚╝╩ ╩ ╩╩  ╚═╝╚╝ ╩╩  ╩  ╩ ╩╝ ╩ o o o",
        " ╔╦╗╦ ╦╔═╗ ╔═╗╦ ╦╔═╗╦ ╦╦   ═╗╦╔═╔═╗ ╔╗╦",
        " ║║║╠═╣║╣  ║ ║╚═╣║╣ ╠═╣╠═╗ ╔╩╬╩╗╠═╣╔╝║╠═╗",
        " ╩ ╩╩ ╩╚═╝ ╚═╝  ╩╚═╝╩ ╩╩═╝ ╩ ╩ ╩╩ ╩╝ ╩╩═╝"]
    let MENU_BANNER:[String] = [
        "               МЕНЮ ИГРЫ:",
        "",
        "   1 - НОВАЯ ИГРА",
        "   2 - РАССТАВИТЬ КОРАБЛИ ВРУЧНУЮ   ",
        "   3 - ПОКИНУТЬ ИГРУ",
        "   4 - СПРАВКА"]
    let MENU_SET_SHIP_BANNER:[String] = [
        " 1 - ВОЗВРАТ К УСТАНОВКЕ КОРАБЛЕЙ ",
        " 2 - ИЗМЕНИТЬ ПОВОРОТ",
        " 3 - ВЫХОД В МЕНЮ"]
    let HELP_BANNER:[String] = [
        "             СПРАВКА:",
        " ЧТОБЫ СДЕЛАТЬ  ХОД, НЕОБХОДИМО ВВЕСТИ БУКВУ",
        " СТОЛБЦА  И  НОМЕР СТРОКИ  В ЛЮБОМ ПОРЯДКЕ И",
        " ЛЮБОМ   РЕГИСТРЕ   В  АНГЛИЙСКОЙ  РАСКЛАДКЕ",
        " И НАЖАТЬ Enter.",
        " БУКВА  И  ЧИСЛО  МОГУТ БЫТЬ РАЗДЕЛЕНЫ ОДНИМ",
        " ПРОБЕЛОМ. ЧИСЛО 10 НЕ ДОЛЖНО БЫТЬ РАЗДЕЛЕНО.",
        " ДЛЯ  ПРЕКРАЩЕНИЯ  ИГРЫ  ИЛИ ВЫЗОВА МЕНЮ ДЛЯ",
        " НАСТРОЕК - ВВЕСТИ menu И НАЖАТЬ Enter."]
    
    enum GameStatus {
        case START
        case MENU
        case MANUAL_SET_SHIPS
        case GAME
        case FINISH
        case EXIT
    }
    
    enum Current:CaseIterable {
        case PLAYER
        case OPPONENT
    }
    
    
    let player: Participan
    let opponent: Participan
    let ui: UI
    var current:Current
    var win:Current?
    var status = GameStatus.START
    
    enum Theme {
        case GREETING
        case RESUME
        case SET_COORD
        case SELECT_MENU
        case ERR_COORD
        case ERR_MENU
        case SET_SHIP_MANUAL
        case SET_SHIP_MANUAL_ERR
        case SET_SHIP_MANUAL_INV
        case SET_SHIP_MANUAL_RESUME
        case FIRST_MOVE_PLAYER
        case FIRST_MOVE_OPPONENT
        case MOVE_PLAYER_GOOD
        case MOVE_PLAYER_BAD
        case MOVE_OPPONENT_GOOD
        case MOVE_OPPONENT_BAD
        case PLAYER_DESTROY_SHIP
        case PLAYER_LOST_SHIP
        case PLAYER_WIN
        case PLAYER_LOST
    }
    
    let phrases:[Theme:[String]]
    
    init(player:Participan, opponent:Participan) {
        self.player = player
        self.opponent = opponent
        ui = UI.instance()
        current = Current.allCases.randomElement()!
        status = GameStatus.START
        phrases = [
            .GREETING:["\(AVATAR) Приветствую тебя герой!","Пришла пора вступить в бой!","Нажми ENTER для продолжения..."],
            .RESUME:["\(AVATAR)","Прочти внимательно", "и нажми ENTER для продолжения..."],
            .SET_COORD:[AVATAR,"Укажи координаты для атаки?","(или menu для выхода в меню)"],
            .SELECT_MENU:[AVATAR,"Укажи номер пункта меню и нажми Enter",""],
            .ERR_COORD:["\(AVATAR) Ты ошибся! Будь внимательнее!"],
            .ERR_MENU:["\(AVATAR) Нет такого пункта! Будь внимательнее!"],
            .SET_SHIP_MANUAL:["\(AVATAR) Тебе необходимо умело расставить 10 кораблей",
                "\(AVATAR) осталось ещё немного","\(AVATAR) отлично продолжай в том же духе!","\(AVATAR) отлично!!!"],
            .SET_SHIP_MANUAL_ERR:["\(AVATAR) выбери другую клетку для этого корабля!"],
            .SET_SHIP_MANUAL_INV:["Укажи клетку для корабля (или menu - для вызова настроек)"],
            .SET_SHIP_MANUAL_RESUME:["\(AVATAR) Отлично! Все корабли на своих местах","Враг не должен догадаться.",
                "Пора приступать - жми ENTER для продолжения..."],
            .FIRST_MOVE_PLAYER:[AVATAR, "Право первого хода досталось тебе", "Битва началась! Жми Enter!"],
            .FIRST_MOVE_OPPONENT:[AVATAR, "Первым ходит противник", "Битва началась! Жми Enter!"],
            .MOVE_PLAYER_GOOD:["\(AVATAR) Отличный ход","\(AVATAR) Продолжай атаковать","\(AVATAR) Добей этот корабль"],
            .MOVE_PLAYER_BAD:["\(AVATAR) Ты промахнулся","\(AVATAR) Мимо...","\(AVATAR) Бей точнее"],
            .MOVE_OPPONENT_GOOD:["\(AVATAR) Он попал в наш корабль","\(AVATAR) Противник атакует"],
            .MOVE_OPPONENT_BAD:["\(AVATAR) Противник промахнулся","\(AVATAR) Сейчас наш ход"],
            .PLAYER_DESTROY_SHIP:["\(AVATAR) Корабль противника уничтожен!"],
            .PLAYER_LOST_SHIP:["\(AVATAR) Он уничтожил наш корабль!"],
            .PLAYER_WIN:[],
            .PLAYER_LOST:[]
        ]
    }
    
    private func start() {
        let lField = player.getOpponentField()
        let rField = opponent.getOpponentField()
        ui.DrawBanner(leftField:lField, rightField:rField, line:2, col:10, banner:START_BANNER)
        ui.GetPress(info:phrases[.GREETING]!)
        status = .MENU
    }
    
    private func menu() {
        let lField = player.getOpponentField()
        let rField = opponent.getOpponentField()
        ui.DrawBanner(leftField:lField, rightField:rField, line:2, col:10, banner:MENU_BANNER)
        let k = ui.GetNumber(info:phrases[.SELECT_MENU]!, numbers:1...4, onError:phrases[.ERR_MENU]![0])
        switch k {
        case 1:
            player.randomSetShips()
            opponent.randomSetShips()
            status = .GAME
        case 2:
            player.clean()
            opponent.randomSetShips()
            status = .MANUAL_SET_SHIPS
        case 3:
            status = .EXIT
        case 4:
            ui.DrawBanner(leftField:lField, rightField:rField, line:1, col:5, banner:HELP_BANNER)
            ui.GetPress(info:phrases[.RESUME]!)
        default:
            break
        }
    }
    
    private func manualSetShips() {
        var horizontalOrient = true
        ui.SetInfo(info:phrases[.SET_SHIP_MANUAL]![0])
        for size in stride(from:4, to:0, by:-1) {
            var count = 5 - size
            while count > 0 {
                var curOrient:String = ""
                if size > 1 {
                    curOrient = horizontalOrient ? " (поворот - горизонтально)" : " (поворот - вертикально)"
                }
                let suff = size > 1 ? "-х" : ""
                ui.SetInfo(line:1, info: "Установи \(size)\(suff) палубный корабль\(curOrient)")
                ui.SetInfo(line:2, info:phrases[.SET_SHIP_MANUAL_INV]![0])
                if let pos:Position = ui.GetCell(leftField:player.getSelfField(),
                        rightField:player.getOpponentField(),
                        request:[],
                        exitWord:"menu",
                        onError:phrases[.ERR_COORD]![0]) {
                    var res = true
                    if horizontalOrient {
                        if player.addShip(pos:pos, size:size, orient:.HORIZONTAL) {
                            count -= 1
                        } else {
                            res = false
                        }
                    } else {
                        if player.addShip(pos:pos, size:size, orient:.VERTICAL) {
                            count -= 1
                        } else {
                            res = false
                        }
                    }
                    if res == false {
                        ui.SetInfo(info:phrases[.SET_SHIP_MANUAL_ERR]![0])
                    } else {
                        ui.SetRandomInfo(start:1, info:phrases[.SET_SHIP_MANUAL]!)
                    }
                } else {
                    ui.DrawBanner(leftField:player.getSelfField(),
                    rightField:player.getOpponentField(),
                    line:2, col:24, 
                    banner:MENU_SET_SHIP_BANNER)
                    switch (ui.GetNumber(info:phrases[.SELECT_MENU]!, numbers:1...3, onError:phrases[.ERR_MENU]![0])) {
                    case 2:
                        horizontalOrient = !horizontalOrient
                    case 3:
                        status = .MENU
                        return
                    default:
                        break
                    }
                }
            }
        }
        player.deleteStop()
        ui.DrawFields(leftField:player.getSelfField(), rightField:player.getOpponentField())
        ui.GetPress(info:phrases[.SET_SHIP_MANUAL_RESUME]!)
        status = .GAME
    }
    
    private func game() {
        current = Current.allCases.randomElement()!
        switch current {
        case .PLAYER:
            ui.GetPress(info:phrases[.FIRST_MOVE_PLAYER]!)
        case .OPPONENT:
            ui.GetPress(info:phrases[.FIRST_MOVE_OPPONENT]!)
        }
        var lostShips = 0
        var destroyShips = 0
        ui.SetInfos(info:phrases[.SET_COORD]!)
        for n in 0...199 {
            let lField = player.getSelfField()
            let rField = player.getOpponentField()
            let curDestroyShips = player.getDestroyShips()
            let curLostShips = opponent.getDestroyShips()
            
            if curDestroyShips == 10 {
                win = .PLAYER
                status = .FINISH
                return
            } else if curLostShips == 10 {
                win = .OPPONENT
                status = .FINISH
                return
            } else if curDestroyShips > destroyShips {
                destroyShips = curDestroyShips
                ui.SetInfo(info:phrases[.PLAYER_DESTROY_SHIP]![0])
                ui.SetInfo(line:1, info:"Счёт: уничтожено:\(destroyShips) потеряно:\(lostShips)")
            } else if curLostShips > lostShips {
                lostShips = curLostShips
                ui.SetInfo(info:phrases[.PLAYER_LOST_SHIP]![0])
                ui.SetInfo(line:1, info:"Счёт: уничтожено:\(destroyShips) потеряно:\(lostShips)")
            }
            switch current {
            case .PLAYER:
                if let pos = ui.GetCell(leftField:lField,
                        rightField:rField,
                        exitWord:"menu",
                        onError:phrases[.ERR_COORD]![0]) {
                    if player.checkCell(pos:pos) == true {
                        ui.DrawBalisticAttack(pos:pos, to:.RIGHT, leftField:lField, rightField:rField)
                        if player.setResultAttack(pos:pos, res:opponent.checkAttack(pos:pos)) {
                            ui.SetInfos(info:phrases[.SET_COORD]!)
                            ui.SetRandomInfo(info:phrases[.MOVE_PLAYER_GOOD]!)
                            ui.DrawWave(pos:pos, to:.RIGHT, leftField:lField, rightField:rField)
                        } else {
                            ui.SetRandomInfo(info:phrases[.MOVE_PLAYER_BAD]!)
                            ui.DrawUPSS(pos:pos, to:.RIGHT, leftField:lField, rightField:rField)
                            current = .OPPONENT
                        }
                    } else {
                        if opponent.checkEmptySelfField() {
                            win = .PLAYER
                            status = .FINISH
                            print("Неожиданный выход 1 ходов=\(n)")
                            return
                        }
                        //let _ = player.randomMove()
                    }
                } else {
                    status = .FINISH
                    return
                }
            case .OPPONENT:
                if let pos = opponent.autoMove() {
                    if opponent.checkCell(pos:pos) == true {
                        ui.DrawBalisticAttack(pos:pos, to:.LEFT, leftField:lField, rightField:rField)
                        if opponent.setResultAttack(pos:pos, res:player.checkAttack(pos:pos)) {
                            ui.SetRandomInfo(info:phrases[.MOVE_OPPONENT_GOOD]!)
                            ui.DrawWave(pos:pos, to:.LEFT, leftField:lField, rightField:rField)
                        } else {
                            ui.SetInfos(info:phrases[.SET_COORD]!)
                            ui.SetRandomInfo(info:phrases[.MOVE_OPPONENT_BAD]!)
                            ui.DrawUPSS(pos:pos, to:.LEFT, leftField:lField, rightField:rField)
                            current = .PLAYER
                        }
                    } else {
                        if player.checkEmptySelfField() {
                            win = .OPPONENT
                            status = .FINISH
                            print("Неожиданный выход 2 ходов=\(n)")
                            return
                        }
                        let _ = opponent.randomMove()
                    }
                }
            }
            //ui.SetInfos(info:phrases[.SET_COORD]!)
        }
        status = .FINISH
    }
    
    private func finish() {
        let lField = player.getSelfField()
        let rField = opponent.getSelfField()
        if win == nil {
            print("НЕВЕРОЯТНО, НО НИЧЬЯ ???!!!")
        } else if win == .PLAYER {
            ui.DrawBanner(leftField:lField, rightField:rField, line:2, col:10, banner:WIN_BANNER)
        } else {
            ui.DrawBanner(leftField:lField, rightField:rField, line:2, col:10, banner:LOST_BANNER)
        }
        status = .MENU
    }
    
    func update() {
        while true {
            switch status {
            case .START: start()
            case .MENU: menu()
            case .MANUAL_SET_SHIPS: manualSetShips()
            case .GAME: game()
            case .FINISH: finish()
            case .EXIT: return
            }
        }
    }
}

let player = Participan()

let opponent = Participan()

let game = Game(player:player, opponent:opponent)

game.update()

