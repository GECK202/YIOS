/*
 Класс одиночка отвечает за взаимодействие с пользователем через терминал
*/

import Foundation

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

	private func ResetBuff2(leftField:[[Cell]], rightField:[[Cell]]) {
        buff[0] = Array(CONTENT.title)
        buff[1] = Array("   a b c d e f g h i j │          │    a b c d e f g h i j │")
        for j in 2..<buff.count {
            for i in 0..<buff[j].count{
                if j < 12 {
                    switch(i) {
                    case 2...22 where i % 2 == 1:
                    	let sym = Array(FIGURE[leftField[j - 2][(i - 2) / 2]] ?? "? ")
                        buff[j][i] = sym[0]
                        if sym.count > 1 {
                        	buff[j][i + 1] = sym[1]
                        }
                    case 38...58 where i % 2 == 1:
                    	let sym = Array(FIGURE[rightField[j - 2][(i - 38) / 2]] ?? "? ")
                        buff[j][i] = sym[0]
                        if sym.count > 1 {
                        	buff[j][i + 1] = sym[1]
                        }
                    case 23, 34, 59:
                        buff[j][i] = "│"
                    case 24...33, 2,35,38:
                    	buff[j][i] = " "
                    default:
                        break
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

    private func ResetBuff(leftField:[[Cell]], rightField:[[Cell]]) {
        buff[0] = Array(CONTENT.title)
        buff[1] = Array("   a b c d e f g h i j │          │    a b c d e f g h i j │")
        for j in 2..<buff.count {
        	if j < 12 {
        		var line = ""
        		let number = String(format: "%2d", j - 1)
        		line = number + " "
        		for i in 0..<leftField.count{
        			line += FIGURE[leftField[j - 2][i]] ?? "? "
        		}
        		line += "│          │ " + number + " "
        		for i in 0..<rightField.count{
        			line += FIGURE[rightField[j - 2][i]] ?? "? "
        		}
        		line += "│"
        		buff[j] = Array(line)
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
    
    func DrawAttack(pos:Position, to:CurrentField, leftField:[[Cell]], rightField:[[Cell]]) {
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

	func Update() {
		PrintBuff()
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
        let _ = readLine()!
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

