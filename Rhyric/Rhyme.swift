//
//  Rhyme.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/02/19.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit

class Rhyme: NSObject {
    
    class func toVowel(word:String) -> (String){
        let aGroup:Array<String> = ["あ", "か", "さ", "た", "な", "は", "ま", "や", "ら", "わ", "ア", "カ", "サ", "タ", "ナ", "ハ", "マ", "ヤ", "ラ", "ワ", "が", "ガ", "ざ", "ザ", "だ", "ダ", "ば", "バ", "ぱ", "パ"]
        let iGroup:Array<String> = ["い", "き", "し", "ち", "に", "ひ", "み", "り", "イ", "キ", "シ", "チ", "ニ", "ヒ", "ミ", "リ", "ぎ", "ギ", "じ", "ジ", "ぢ", "ヂ", "び", "ビ", "ぴ", "ピ"]
        let uGroup:Array<String> = ["う", "く", "す", "つ", "ぬ", "ふ", "む", "ゆ", "る", "ウ", "ク", "ス", "ツ", "ヌ", "フ", "ム", "ユ", "ル", "ぐ", "グ", "ず", "ズ", "づ", "ヅ", "ぶ", "ブ", "ぷ", "プ"]
        let eGroup:Array<String> = ["え", "け", "せ", "て", "ね", "へ", "め", "れ", "エ", "ケ", "セ", "テ", "ネ", "ヘ", "メ", "レ", "げ", "ゲ", "ぜ", "ゼ", "で", "デ", "べ", "ベ", "ぺ", "ペ"]
        let oGroup:Array<String> = ["お", "こ", "そ", "と", "の", "ほ", "も", "よ", "ろ", "を", "オ", "コ", "ソ", "ト", "ノ", "ホ", "モ", "ヨ", "ロ", "ヲ", "ご", "ゴ", "ぞ", "ゾ", "ど", "ド", "ぼ", "ボ", "ぽ", "ポ"]
        let nGroup:Array<String> = ["ん", "ン"]
        let shoumojiA = ["ゃ", "ャ", "ぁ", "ァ"]
        let shoumojiI = [ "ぃ", "ィ",]
        let shoumojiU = ["ゅ", "ュ", "ぅ", "ゥ"]
        let shoumojiE = ["ぇ", "ェ"]
        let shoumojiO = ["ょ", "ョ", "ぉ", "ォ"]

        
        var formerVowel:String = ""
        var yomiOuin1:String = ""
        var yomiOuin2:String = ""
        var yomiOuin3:String = ""
        
        //母音「お」の後の「う」は母音「お」に変換
        //母音に変換
        for element in word.characters {
            let letter = String(element)
            if letter == "う" && formerVowel == "お"{
                yomiOuin1 = yomiOuin1 + "お"
                formerVowel = "う"
            }else if aGroup.contains(letter){
                yomiOuin1 = yomiOuin1 + "あ"
                formerVowel = "あ"
            }else if iGroup.contains(letter){
                yomiOuin1 = yomiOuin1 + "い"
                formerVowel = "い"
            }else if uGroup.contains(letter){
                yomiOuin1 = yomiOuin1 + "う"
                let formerVowel = "う"
            }else if eGroup.contains(letter){
                yomiOuin1 = yomiOuin1 + "え"
                formerVowel = "え"
            }else if oGroup.contains(letter){
                yomiOuin1 = yomiOuin1 + "お"
                formerVowel = "お"
            }else if nGroup.contains(letter){
                yomiOuin1 = yomiOuin1 + "ん"
                formerVowel = "ん"
            }else if letter == "ッ"{
                yomiOuin1 = yomiOuin1 + "っ"
                formerVowel = "っ"
            }else {
                yomiOuin1 = yomiOuin1 + letter
                let formerVowel = ""
            }
        }
        //小文字は母音変換せずに消去
        for element in yomiOuin1.characters {
            let letter = String(element)
            if shoumojiA.contains(letter){
                yomiOuin2 = String(yomiOuin2.characters.dropLast(1))
                yomiOuin2 = yomiOuin2 + "あ"
            }else if shoumojiI.contains(letter){
                yomiOuin2 = String(yomiOuin2.characters.dropLast(1))
                yomiOuin2 = yomiOuin2 + "い"
            }else if shoumojiU.contains(letter){
                yomiOuin2 = String(yomiOuin2.characters.dropLast(1))
                yomiOuin2 = yomiOuin2 + "う"
            }else if shoumojiE.contains(letter){
                yomiOuin2 = String(yomiOuin2.characters.dropLast(1))
                yomiOuin2 = yomiOuin2 + "え"
            }else if shoumojiO.contains(letter){
                yomiOuin2 = String(yomiOuin2.characters.dropLast(1))
                yomiOuin2 = yomiOuin2 + "お"
            }else{
                yomiOuin2 = yomiOuin2 + letter
            }
        }
        //"ー"は１つ前の母音と同じにする
        var formerLetter:String = ""
        for element in yomiOuin2.characters {
            let letter = String(element)
            if letter == "ー" {
                yomiOuin3 = yomiOuin3 + formerLetter
                formerLetter = letter
            }else {
                yomiOuin3 = yomiOuin3 + letter
                formerLetter = letter
            }
        }
        return yomiOuin3
        
    }
    

}
