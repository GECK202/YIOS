/**

                            Online Swift Compiler.
                Code, Compile, Run and Debug Swift script online.
Write your code in this editor and press "Run" button to execute it.

*/
import Foundation
let ship: Character = "⛴"
let fire: Character = "🔥"


var str  = " "+String(repeating: "🌊 ", count: 10)
var str1 = " "+String(repeating: "🌌 ", count: 10) 

//let chrs = [Character]("\u{1F30A}","\u{1F30A}","\u{1F30A}","\u{1F30A}","\u{1F30A}","\u{1F30A}","\u{1F30A}","\u{1F30A}","\u{1F30A}","\u{1F30A}")
//var str = " " + String(chrs) + " "

print("\u{001B}[0;0H\u{001B}[47;30m", "┏━━━┳━━━┳━━━┳━━━┳━━━┳━━━┳━━━┳━━━┳━━━┳━━━┳━━━┓"")
print("┃   ┃ a ┃ b ┃ c ┃ d ┃ e ┃ f ┃ g ┃ h ┃ i ┃ j ┃")
print("┣━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━┫")
for n in 1...10 {
    var str2 = n%2 == 0 ? str : str1
    if n == 9 {
        var strchars = [Character](str)    
        strchars[5] = ship
        str2 = String(strchars)
        ////str2.remove(at:str2.index(str2.startIndex, offsetBy: 11))
    }
    if n == 5 {
        var strchars = [Character](str)    
        strchars[5] = fire 
        str2 = String(strchars)
        
    }
    
    print("\u{001B}[47;30m", String(format: "%2d", n), "\u{001B}[46;37m", str2)
}
print("\u{001B}[0m")
//print("\u{001B}[5A")
//print("\u{001B}[0;0H\u{001B}[K\u{001B}[0;0H")
//print("\u{001B}[10;10H\u{001B}[43;31m\u{1F436}\u{001B}[0m")


//for _ in 1...10 {
//    let k = readLine()!
//    print(k)
//}
