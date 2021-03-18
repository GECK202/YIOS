/*
 В этом классе описываются функции, отвечающие за поведение игроков
 и для управления человеком и для управления AI
	-функция randomSetShips отвечает за автоматическую расстановку кораблей на старте
	-функция autoMove отвечает за принятие решения AI
*/

import Foundation

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

