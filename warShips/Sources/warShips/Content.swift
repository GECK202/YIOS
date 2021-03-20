/*
 Этот файл отвечает за загрузку контента
 Если контент не будет загружен по каким-то
 причинам, то будет возвращён зашитый в файле контент
*/

import Foundation

let AVATAR:String = "🤴"

struct Content: Codable{
	enum Theme: String, Codable {
		case GREETING
		case RESUME
		case SET_COORD
		case SET_COORD_NOT_EMPTY
		case SELECT_MENU
		case ERR_COORD
		case ERR_MENU
		case SET_SHIP_MANUAL
		case SET_SHIP_MANUAL_ERR
		case SET_SHIP_MANUAL_INV
		case SET_SHIP_MANUAL_RESUME
		case SET_SHIP_INFO
		case ORIENT
		case FIRST_MOVE_PLAYER
		case FIRST_MOVE_OPPONENT
		case MOVE_PLAYER_GOOD
		case MOVE_PLAYER_BAD
		case MOVE_OPPONENT_GOOD
		case MOVE_OPPONENT_BAD
		case SCORE
		case PLAYER_DESTROY_SHIP
		case PLAYER_LOST_SHIP
		case PLAYER_WIN
		case PLAYER_LOST
		case LEAVE_GAME
		case EXIT_GAME
	}	
	let START_BANNER:[String]
	let WIN_BANNER:[String]
	let LOST_BANNER:[String]
	let MENU_BANNER:[String]
	let LANGUAGE_BANNER:[String]
	let MENU_SET_SHIP_BANNER:[String]
	let HELP_BANNER:[String]
	let title:String
	let phrases:[Theme:[String]]
}

func readResources(language:LANGUAGE)->Content {
	let configURL = Bundle.module.url(forResource: "Content_\(language)", withExtension: "json")
	do {
    let data = try Data(contentsOf: configURL!)
    let cnt = try JSONDecoder().decode(Content.self, from: data)
    	return cnt
	} catch {
 	   let cnt = getContent()
 	   return cnt
	}
}

private func getContent()->Content {
	let content:Content = Content(
		START_BANNER:[
        "  *** )─┼)***  ...o   . .      (┼─(",
        "   ** )─┼)*** ..     .   .  (┼─(┼─(┼─(",
        "╒══╕**)─┼) * .      .     . (┼─(┼─(┼ ╒══╕",
        "└─┐╘╦╬╦╦╬╦╦╬╦─>──  o    ──<─╦╬╦╦╬╦╦╬╦╛┌─┘",
        " ╭╯~ ~~ ~~ ~~/ ~~ ~v ~~ ~~ \\~~ ~~ ~ ~~╰╮",
        "-   ╔╦╗╔═╗╦═╗╔═╗╦╔═╔═╗╦║╔╗ ╦═╗╔═╗╦║╔╗   -",
        "--  ║║║║ ║╠═╝║  ╠╩╗║ ║║╔╝║ ╠═╗║ ║║╔╝║  --",
        "-   ╩ ╩╚═╝╩  ╚═╝╩ ╩╩═╝╚╝ ╩ ╩═╝╩═╝╚╝ ╩   -"],
    	WIN_BANNER:[
        "   ╔╦╗╦ ╦ ╔╗ ╦ ╦╦ ╔╗╦═╗╦═╗╔═╗ ╔╗ ┬ ┬ ┬   ",
        "    ║ ╠╗║ ╠╩╗╠╗║║╔╝║║  ╠═╝╠═╣╔╝║ │ │ │",
        "    ╩ ╚╝╩ ╚═╝╚╝╩╚╝ ╩╩  ╩  ╩ ╩╝ ╩ o o o",
        "    ╔═╗╔═╗╔═╗ ╔╗ ╦═╗╔═╗╔╗  ╔╗╔═╗╦╔═╗",
        "    ║ ║║ ║ ═║ ║║ ╠═╝╠═╣╠╩╗╔╝║╚╦╣╠╣ ║",
        "    ╩ ╩╚═╝╚═╝╔╩╩╗╩  ╩ ╩╚═╝╝ ╩═╝╩╩╚═╝"],
    	LOST_BANNER:[
        "  ╔╦╗╦ ╦ ╔═╗╦═╗╔═╗╦ ╔╗╦═╗╦═╗╔═╗ ╔╗ ┬ ┬ ┬",
        "   ║ ╠╗║ ║ ║╠═╝║ ║║╔╝║║  ╠═╝╠═╣╔╝║ │ │ │",
        "   ╩ ╚╝╩ ╩ ╩╩  ╚═╝╚╝ ╩╩  ╩  ╩ ╩╝ ╩ o o o",
        " ╔╦╗╦ ╦╔═╗ ╔═╗╦ ╦╔═╗╦ ╦╦   ═╗╦╔═╔═╗ ╔╗╦",
        " ║║║╠═╣║╣  ║ ║╚═╣║╣ ╠═╣╠═╗ ╔╩╬╩╗╠═╣╔╝║╠═╗",
        " ╩ ╩╩ ╩╚═╝ ╚═╝  ╩╚═╝╩ ╩╩═╝ ╩ ╩ ╩╩ ╩╝ ╩╩═╝"],
        MENU_BANNER:[
        "               МЕНЮ ИГРЫ:",
        "",
        "   1 - НОВАЯ ИГРА",
        "   2 - РАССТАВИТЬ КОРАБЛИ ВРУЧНУЮ   ",
        "   3 - ВЫБРАТЬ ЯЗЫК",
        "   4 - ВЫХОД",
        "   5 - СПРАВКА"],
        LANGUAGE_BANNER:[
        "  ВЫБРАТЬ ЯЗЫК: ",
        " 1 - РУССКИЙ ",
        " 2 - АНГЛИЙСКИЙ"
        ],
    	MENU_SET_SHIP_BANNER:[
        " 1 - ВОЗВРАТ К УСТАНОВКЕ КОРАБЛЕЙ ",
        " 2 - ИЗМЕНИТЬ ПОВОРОТ",
        " 3 - ВЫХОД В МЕНЮ"],
    	HELP_BANNER:[
        "             СПРАВКА:",
        " ЧТОБЫ СДЕЛАТЬ ХОД, НЕОБХОДИМО ВВЕСТИ БУКВУ ",
        " СТОЛБЦА  И  НОМЕР СТРОКИ В ЛЮБОМ ПОРЯДКЕ И",
        " ЛЮБОМ   РЕГИСТРЕ   В АНГЛИЙСКОЙ  РАСКЛАДКЕ",
        " И НАЖАТЬ Enter.",
        " БУКВА  И  ЧИСЛО МОГУТ БЫТЬ РАЗДЕЛЕНЫ ОДНИМ",
        " ПРОБЕЛОМ."],
        title:"       ПОЛЕ ИГРОКА     │          │      ПОЛЕ ПРОТИВНИКА   │",
        phrases:[
            .GREETING:["\(AVATAR) Приветствую тебя герой!","Пришла пора вступить в бой!",
            	"Нажми ENTER для продолжения..."],
            .RESUME:["\(AVATAR)","Прочти внимательно", "и нажми ENTER для продолжения..."],
            .SET_COORD:[AVATAR,"","Укажи координаты для атаки (или exit для выхода)"],
            .SET_COORD_NOT_EMPTY:["\(AVATAR) атака в эту клетку невозможна! Укажи другую!"],
            .SELECT_MENU:[AVATAR,"Укажи номер пункта меню и нажми Enter",""],
            .ERR_COORD:["\(AVATAR) Ты ошибся! Будь внимательнее!"],
            .ERR_MENU:["\(AVATAR) Нет такого пункта! Будь внимательнее!"],
            .SET_SHIP_MANUAL:["\(AVATAR) Тебе необходимо умело расставить 10 кораблей",
                "\(AVATAR) осталось ещё немного","\(AVATAR) отлично продолжай в том же духе!","\(AVATAR) отлично!!!"],
            .SET_SHIP_MANUAL_ERR:["\(AVATAR) выбери другую клетку для этого корабля!"],
            .SET_SHIP_MANUAL_INV:["Укажи клетку для корабля (или menu - для вызова настроек)"],
            .SET_SHIP_MANUAL_RESUME:["\(AVATAR) Отлично! Все корабли на своих местах","Враг не должен догадаться.",
                "Пора приступать - жми ENTER для продолжения..."],
            .SET_SHIP_INFO:["Установи ","-палубный корабль"],
            .ORIENT:[" (поворот - горизонтально)", " (поворот - вертикально)"],
            .FIRST_MOVE_PLAYER:[AVATAR, "Право первого хода досталось тебе", "Битва началась! Жми Enter!"],
            .FIRST_MOVE_OPPONENT:[AVATAR, "Первым ходит противник", "Битва началась! Жми Enter!"],
            .MOVE_PLAYER_GOOD:["\(AVATAR) Отличный ход","\(AVATAR) Продолжай атаковать","\(AVATAR) Добей этот корабль"],
            .MOVE_PLAYER_BAD:["\(AVATAR) Ты промахнулся","\(AVATAR) Мимо...","\(AVATAR) Бей точнее"],
            .MOVE_OPPONENT_GOOD:["\(AVATAR) Он попал в наш корабль","\(AVATAR) Противник атакует"],
            .MOVE_OPPONENT_BAD:["\(AVATAR) Противник промахнулся","\(AVATAR) Сейчас наш ход"],
            .SCORE:["Счёт: уничтожено кораблей:"," потеряно кораблей:"],
            .PLAYER_DESTROY_SHIP:["\(AVATAR) Корабль противника уничтожен!"],
            .PLAYER_LOST_SHIP:["\(AVATAR) Он уничтожил наш корабль!"],
            .PLAYER_WIN:["\(AVATAR) противник разгромлен!","Это заслуженная победа!", "Нажми ENTER для продолжения..."],
            .PLAYER_LOST:["\(AVATAR) Не отчаивайся,повезёт в другой раз!",
            	"Ты проиграл битву, но не проиграл войну!","Нажми ENTER для продолжения..."],
            .LEAVE_GAME:["\(AVATAR) Ты покинул битву","Вовзращайся, когда будешь готов",
            	"Нажми ENTER для продолжения..."],
            .EXIT_GAME:["\(AVATAR)","До новых встреч герой",""]
        ]
	)
	return content
}

