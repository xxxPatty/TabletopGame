//
//  ContentView.swift
//  TabletopGame
//
//  Created by 林湘羚 on 2021/3/10.
//

import SwiftUI

struct ContentView: View {
    @StateObject var game:Game
    @StateObject var player:Player
    @State private var gameStart=false
    @State private var result=true
    @State private var showAlert = false
    @State private var PreviousCard=Image(systemName: "photo")
    @State private var BargainingChip=3
    @State private var isPresented = false
    @State private var GameOver=false
    @State private var activeAlert: ActiveAlert = .first
    func npcAction()->Void{ //換電腦出牌，延遲1.5秒再做
        let time:TimeInterval = 1.5
        DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + time) {
            game.turn=1
            let temp = game.npc.PlayACard()
            game.cardDeck.AddToDiscard(card: temp)
            PreviousCard=Image("\(temp.rank)\(temp.suit)")
            //加/減分數
            switch temp.rank{
            case "A":
                if temp.suit=="♠" {
                    result=game.SetScores(scores: 0)
                }else{
                    result=game.SetScores(scores: game.totalscores+1)
                }
            case "2", "3", "6", "7", "8", "9":
                result=game.SetScores(scores: game.totalscores+(Int(temp.rank) ?? 0))
            case "4":   //迴轉
                print("迴轉")
            case "5":   //指定
                print("指定")
            case "10":  //加/減10
                if game.totalscores-10>=0 {
                    result=game.SetScores(scores: game.totalscores-10)
                }else{
                    result=game.SetScores(scores: game.totalscores+10)
                }
            case "J":   //pass
                print("pass")
            case "Q":   //加/減20
                if game.totalscores-20>=0 {
                    result=game.SetScores(scores: game.totalscores-20)
                }else{
                    result=game.SetScores(scores: game.totalscores+20)
                }
            case "K":   //scores維持在99
                result=game.SetScores(scores: 99)
            default:
                print("??")
            }
            //再抽一張牌
            let temp2 = game.cardDeck.Draw()
            //加入手牌中
            game.npc.AddToHandCards(card: temp2)
            if result==false {
                isPresented=true
            }
        }
    }
    var body: some View {
        if gameStart==false{
            Button(action:{
                gameStart=true
            }){
                Text("Play")
            }
        }else{
            if GameOver==false{
                VStack{
                    Text("Community Cards: \(game.cardDeck.cards.count)")
                    Text("Discard Cards: \(game.cardDeck.discard.count)")
                    Text("Bargaining Chip: \(BargainingChip)")
                    Text("total scores: \(game.totalscores)")
                    ZStack{
                        PreviousCard
                            .resizable()
                            .frame(width:100, height:150)
                            .scaledToFit()
//                        PreviousCard2
//                            .resizable()
//                            .frame(height:150)
//                            .scaledToFit()
//                            .rotationEffect(.degrees(90))
                    }
                    HStack{
                        ForEach(game.player.handCards.indices){(index) in
                            Button(action:{
                                game.turn=0
                                //加進棄牌區
                                let temp3=game.player.handCards[index]
                                game.cardDeck.AddToDiscard(card: temp3)
                                PreviousCard=Image("\(temp3.rank)\(temp3.suit)")
                                //從手牌中移除
                                game.player.RemoveFromHandCards(card: temp3)
                                //加/減分數
                                switch temp3.rank{
                                case "A":
                                    if temp3.suit=="♠" {
                                        result=game.SetScores(scores: 0)
                                    }else{
                                        result=game.SetScores(scores: game.totalscores+1)
                                    }
                                    if result != false {
                                        npcAction()
                                    }
                                case "2", "3", "6", "7", "8", "9":
                                    result=game.SetScores(scores: game.totalscores+(Int(temp3.rank) ?? 0))
                                    if result != false {
                                        npcAction()
                                    }
                                case "4":   //迴轉
                                    print("迴轉")
                                    npcAction()
                                case "5":   //指定
                                    print("指定")
                                    npcAction()
                                case "10":  //加/減10
                                    if game.totalscores-10>=0{
                                        showAlert = true
                                        activeAlert = .first
                                    }else{
                                        result=game.SetScores(scores: game.totalscores+10)
                                        if result != false {
                                            npcAction()
                                        }
                                    }
                                case "J":   //pass
                                    print("pass")
                                    npcAction()
                                case "Q":   //加/減20
                                    if game.totalscores-20>=0{
                                        showAlert = true
                                        activeAlert = .second
                                    }else{
                                        result=game.SetScores(scores: game.totalscores+20)
                                        if result != false {
                                            npcAction()
                                        }
                                    }
                                case "K":   //scores維持在99
                                    result=game.SetScores(scores: 99)
                                    npcAction()
                                default:
                                    print("??")
                                }
                                //再抽一張牌
                                let temp = game.cardDeck.Draw()
                                //加入手牌中
                                game.player.AddToHandCards(card: temp)
                                print(game.player.handCards[2])
                                print(game.player.handCards[4])
                                
                                if result==false {
                                    isPresented=true
                                }
                            }){
                                //Player手牌
                                PokerView(game:game, index:index)
                            }
                            .alert(isPresented: $showAlert, content: {
                                switch activeAlert {
                                case .first:
                                    return Alert(
                                                title: Text("Choose an action"),
                                                message: Text("Plus 10 or substract 10?"),
                                                primaryButton: .destructive(Text("Plus")) {
                                                    result=game.SetScores(scores: game.totalscores+10)
                                                    if result != false {
                                                        npcAction()
                                                    }
                                                    if result==false {
                                                        isPresented=true
                                                    }
                                                },
                                                secondaryButton: .destructive(Text("Substract")) {
                                                    result=game.SetScores(scores: game.totalscores-10)
                                                    if result != false {
                                                        npcAction()
                                                    }
                                                    if result==false {
                                                        isPresented=true
                                                    }
                                                }
                                            )
                                case .second:
                                    return Alert(
                                                title: Text("Choose an action"),
                                                message: Text("Plus 20 or substract 20?"),
                                                primaryButton: .destructive(Text("Plus")) {
                                                    result=game.SetScores(scores: game.totalscores+20)
                                                    if result != false {
                                                        npcAction()
                                                    }
                                                    if result==false {
                                                        isPresented=true
                                                    }
                                                },
                                                secondaryButton: .destructive(Text("Substract")) {
                                                    result=game.SetScores(scores: game.totalscores-20)
                                                    if result != false {
                                                        npcAction()
                                                    }
                                                    if result==false {
                                                        isPresented=true
                                                    }
                                                }
                                        )
                                }
                            })
                            .sheet(isPresented: $isPresented){
                                ResultView(isPresented:$isPresented, turn: game.turn, BargainingChip: $BargainingChip, game:game, GameOver:$GameOver, PreviousCard:$PreviousCard, result:$result)
                            }
                        }
                    }
                }
            }else{  //遊戲結束
                VStack{
                    Text("Game Over")
                    Button(action:{
                        game.PlayAgain()
                        result=true
                        gameStart=false
                        BargainingChip=3
                        GameOver=false
                        PreviousCard=Image(systemName: "photo")
                        isPresented=false
                    }){
                        Text("Reset")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game=Game()
        ContentView(game:game, player:game.player)
            //.previewLayout(.fixed(width: 414, height: 896))
    }
}

struct ResultView: View {
    @Binding var isPresented:Bool
    let turn: Int
    @Binding var BargainingChip:Int
    var game:Game
    @Binding var GameOver:Bool
    @Binding var PreviousCard:Image
    @Binding var result:Bool
    var body: some View {
        VStack{
            if turn==0 {
                Text("輸了")
            }else{
                Text("恭喜贏了")
            }
            Button("Play Again") {
                if turn==0 {
                    BargainingChip-=1
                }else{
                    BargainingChip+=1
                }
                if BargainingChip<=0 {
                    GameOver=true
                }
                result=true
                game.PlayAgain()
                PreviousCard=Image(systemName: "photo")
                isPresented=false
            }
        }
    }
}

enum ActiveAlert {
    case first, second
}


struct PokerView: View {
    @StateObject var game:Game
    let index:Int
    var body: some View {
        Image("\(game.player.handCards[index].rank)\(game.player.handCards[index].suit)")
            .resizable()
            .frame(height:150)
            .scaledToFit()
    }
}
