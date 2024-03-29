/*
	В этом классе описана основная логика игры
*/

class Game {
    enum GameStatus {
        case START
        case MENU
        case LANGUAGE
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
    var language = LANGUAGE.ru
    
    init(player:Participan, opponent:Participan, ui:UI, language:LANGUAGE) {
        self.player = player
        self.opponent = opponent
        self.ui = ui
        self.language = language
        current = Current.allCases.randomElement()!
        status = GameStatus.START
    }
    
    private func start() {
        let lField = player.getSelfField()
        let rField = player.getOpponentField()
        ui.DrawBanner(leftField:lField, rightField:rField, line:2, col:10, banner:CNT.START_BANNER)
        ui.GetPress(info:CNT.phrases[.GREETING]!)
        status = .MENU
    }
    
    private func menu() {
        let lField = player.getSelfField()
        let rField = player.getOpponentField()
        ui.DrawBanner(leftField:lField, rightField:rField, line:2, col:10, banner:CNT.MENU_BANNER)
        let k = ui.GetNumber(info:CNT.phrases[.SELECT_MENU]!, numbers:1...5, onError:CNT.phrases[.ERR_MENU]![0])
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
        	status = .LANGUAGE
        case 4:
            status = .EXIT
        case 5:
            ui.DrawBanner(leftField:lField, rightField:rField, line:3, col:5, banner:CNT.HELP_BANNER)
            ui.GetPress(info:CNT.phrases[.RESUME]!)
        default:
            break
        }
    }
    
    private func changeLanguage() {
    	let lField = player.getSelfField()
        let rField = player.getOpponentField()
        ui.DrawBanner(leftField:lField, rightField:rField, line:3, col:13, banner:CNT.LANGUAGE_BANNER)
        let k = ui.GetNumber(info:CNT.phrases[.SELECT_MENU]!, numbers:1...2, onError:CNT.phrases[.ERR_MENU]![0])
        switch k {
        case 1:
            if language == .en {
            	language = .ru
            	CNT = readResources(language:language)
            }
        case 2:
            if language == .ru {
            	language = .en
            	CNT = readResources(language:language)
            }
        default:
            break
        }
        status = .MENU
    }
    
    private func manualSetShips() {
        var horizontalOrient = true
        ui.SetInfo(info:CNT.phrases[.SET_SHIP_MANUAL]![0])
        for size in stride(from:4, to:0, by:-1) {
            var count = 5 - size
            while count > 0 {
                var curOrient:String = ""
                if size > 1 {
                    curOrient = horizontalOrient ? CNT.phrases[.ORIENT]![0] : CNT.phrases[.ORIENT]![1] 
                }
                ui.SetInfo(line:1,
                	info: "\(CNT.phrases[.SET_SHIP_INFO]![0])\(size)\(CNT.phrases[.SET_SHIP_INFO]![1])\(curOrient)")
                ui.SetInfo(line:2, info:CNT.phrases[.SET_SHIP_MANUAL_INV]![0])
                if let pos:Position = ui.GetCell(leftField:player.getSelfField(),
                        rightField:player.getOpponentField(),
                        request:[],
                        exitWord:"menu",
                        onError:CNT.phrases[.ERR_COORD]![0]) {
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
                        ui.SetInfo(info:CNT.phrases[.SET_SHIP_MANUAL_ERR]![0])
                    } else {
                        ui.SetRandomInfo(start:1, info:CNT.phrases[.SET_SHIP_MANUAL]!)
                    }
                } else {
                    ui.DrawBanner(leftField:player.getSelfField(),
                    rightField:player.getOpponentField(),
                    line:2, col:24, 
                    banner:CNT.MENU_SET_SHIP_BANNER)
                    switch (ui.GetNumber(info:CNT.phrases[.SELECT_MENU]!, numbers:1...3,
                    	onError:CNT.phrases[.ERR_MENU]![0])) {
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
        ui.GetPress(info:CNT.phrases[.SET_SHIP_MANUAL_RESUME]!)
        status = .GAME
    }
    
    private func game() {
        current = Current.allCases.randomElement()!
        ui.DrawFields(leftField:player.getSelfField(), rightField:player.getOpponentField())
        switch current {
        case .PLAYER:
            ui.GetPress(info:CNT.phrases[.FIRST_MOVE_PLAYER]!)
        case .OPPONENT:
            ui.GetPress(info:CNT.phrases[.FIRST_MOVE_OPPONENT]!)
        }
        var lostShips = 0
        var destroyShips = 0
        ui.SetInfos(info:CNT.phrases[.SET_COORD]!)
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
                ui.SetInfo(info:CNT.phrases[.PLAYER_DESTROY_SHIP]![0])
                ui.SetInfo(line:1,
                	info:"\(CNT.phrases[.SCORE]![0])\(destroyShips)\(CNT.phrases[.SCORE]![1])\(lostShips)")
            } else if curLostShips > lostShips {
                lostShips = curLostShips
                ui.SetInfo(info:CNT.phrases[.PLAYER_LOST_SHIP]![0])
                ui.SetInfo(line:1,
                	info:"\(CNT.phrases[.SCORE]![0])\(destroyShips)\(CNT.phrases[.SCORE]![1])\(lostShips)")
            }
            switch current {
            case .PLAYER:
                if let pos = ui.GetCell(leftField:lField,
                        rightField:rField,
                        exitWord:"exit",
                        onError:CNT.phrases[.ERR_COORD]![0]) {
                    if player.checkCell(pos:pos) == true {
                        ui.DrawAttack(pos:pos, to:.RIGHT, leftField:lField, rightField:rField)
                        if player.setResultAttack(pos:pos, res:opponent.checkAttack(pos:pos)) {
                            ui.SetInfos(info:CNT.phrases[.SET_COORD]!)
                            ui.SetRandomInfo(info:CNT.phrases[.MOVE_PLAYER_GOOD]!)
                            ui.DrawWave(pos:pos, to:.RIGHT, leftField:lField, rightField:rField)
                        } else {
                            ui.SetRandomInfo(info:CNT.phrases[.MOVE_PLAYER_BAD]!)
                            ui.DrawUPSS(pos:pos, to:.RIGHT, leftField:lField, rightField:rField)
                            current = .OPPONENT
                        }
                    } else {
                    	ui.SetInfo(info:CNT.phrases[.SET_COORD_NOT_EMPTY]![0])
                        if opponent.checkEmptySelfField() {
                            win = .PLAYER
                            status = .FINISH
                            print("Неожиданный выход 1 ходов=\(n)")
                            return
                        }
                    }
                } else {
                    status = .FINISH
                    return
                }
            case .OPPONENT:
                if let pos = opponent.autoMove() {
                    if opponent.checkCell(pos:pos) == true {
                        ui.DrawAttack(pos:pos, to:.LEFT, leftField:lField, rightField:rField)
                        if opponent.setResultAttack(pos:pos, res:player.checkAttack(pos:pos)) {
                            ui.SetRandomInfo(info:CNT.phrases[.MOVE_OPPONENT_GOOD]!)
                            ui.DrawWave(pos:pos, to:.LEFT, leftField:lField, rightField:rField)
                        } else {
                            ui.SetInfos(info:CNT.phrases[.SET_COORD]!)
                            ui.SetRandomInfo(info:CNT.phrases[.MOVE_OPPONENT_BAD]!)
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
        }
        status = .FINISH
    }
    
    private func finish() {
        let lField = player.getSelfField()
        let rField = player.getOpponentField()
        if win == nil {
            ui.GetPress(info:CNT.phrases[.LEAVE_GAME]!)
        } else if win == .PLAYER {
            ui.DrawBanner(leftField:lField, rightField:rField, line:2, col:10, banner:CNT.WIN_BANNER)
            ui.GetPress(info:CNT.phrases[.PLAYER_WIN]!)
        } else {
            ui.DrawBanner(leftField:lField, rightField:rField, line:2, col:10, banner:CNT.LOST_BANNER)
            ui.GetPress(info:CNT.phrases[.PLAYER_LOST]!)
        }
        status = .MENU
    }
    
    func update() {
        while true {
            switch status {
            case .START: start()
            case .MENU: menu()
            case .LANGUAGE: changeLanguage()
            case .MANUAL_SET_SHIPS: manualSetShips()
            case .GAME: game()
            case .FINISH: finish()
            case .EXIT:
            	let lField = player.getSelfField()
            	let rField = player.getOpponentField()
            	ui.SetInfos(info:CNT.phrases[.EXIT_GAME]!)
            	ui.DrawBanner(leftField:lField,	rightField:rField, line:2, col:10, banner:CNT.START_BANNER)
				ui.Update()
				saveSetLanguage(language:language)
            	return
            }
        }
    }
}

