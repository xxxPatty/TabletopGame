//
//  Card.swift
//  TabletopGame
//
//  Created by 林湘羚 on 2021/3/10.
//

import Foundation
import AVFoundation

struct Card{
    let rank:String //點數
    let suit:String //花色
}

class CardDeck{ //公牌
    let ranks=["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
    let suits=["♣","♦","♥","♠"]
    var cards=[Card]()
    var discard=[Card]()
    init(){
        for suit in suits {
            for rank in ranks {
                cards.append(Card(rank:rank, suit:suit))
            }
        }
    }
    func Draw()->Card{   //被抽走或發出去，要加進玩家手牌！！！！
        if cards.count<=0 {
            self.Complement()
        }
        let index=Int.random(in:0..<cards.count)
        let temp=cards[index]
        //discard.append(temp)
        cards.remove(at: index)
        return temp
    }
    func Complement()->Void{  //補充公牌
        discard.shuffle()
        playSound(sound: "shuffle", type: "mp3")
        cards=discard
        discard=[]
    }
    func AddToDiscard(card:Card)->Void{
        discard.append(card)
    }
}

class Player:ObservableObject{   //玩家
    @Published var handCards=[Card]()
    func PlayACard()->Card{ //隨機出牌，要丟到棄牌區！！！！
        let index=Int.random(in:0..<handCards.count)
        let temp=handCards[index]
        handCards.remove(at: index)
        return temp
    }
    func RemoveFromHandCards(card:Card)->Void{
        for i in 0..<handCards.count {
            if handCards[i].rank==card.rank && handCards[i].suit==card.suit {
                handCards.remove(at: i)
                break
            }
        }
    }
    func AddToHandCards(card:Card)->Void{
        handCards.append(card)
    }
}

class Game:ObservableObject{
    var cardDeck=CardDeck()
    @Published var player=Player()
    var npc=[Player]()
    var totalscores=0
    var turn=0  //0為自己，1為電腦
    var direction=true  //true->順時針，false->逆時針
    var npcNum=1
    init(){
        //洗牌
        cardDeck.cards.shuffle()
        playSound(sound: "shuffle", type: "mp3")
        for _ in 0..<npcNum {
            npc.append(Player())
        }
        //先各發五張牌
        for _ in 0..<5 {
            player.handCards.append(cardDeck.Draw())
            for i in 0..<npcNum {
                npc[i].handCards.append(cardDeck.Draw())
            }
            
        }
    }
    func SetScores(scores:Int)->Bool{
        totalscores=scores
        if totalscores>99 {
            return false    //遊戲結束
        }else{
            return true     //遊戲繼續
        }
    }
    func PlayAgain(){
        cardDeck=CardDeck()
        player=Player()
        npc=[Player]()
        totalscores=0
        turn=0
        direction=true
        //洗牌
        cardDeck.cards.shuffle()
        playSound(sound: "shuffle", type: "mp3")
        for _ in 0..<npcNum {
            npc.append(Player())
        }
        //先各發五張牌
        for _ in 0..<5 {
            player.handCards.append(cardDeck.Draw())
            for i in 0..<npcNum {
                npc[i].handCards.append(cardDeck.Draw())
            }
            
        }
    }
}

var audioPlayer: AVAudioPlayer?

func playSound(sound: String, type: String) {
    if let path = Bundle.main.path(forResource: sound, ofType: type) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.play()
        } catch {
            print("ERROR")
        }
    }
}
