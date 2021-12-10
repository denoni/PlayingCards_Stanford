//
//  PlayingCard.swift
//  PlayingCard
//
//  Created by Gabriel on 12/9/21.
//

import Foundation

struct PlayingCard {
  var suit: Suit
  var rank: Rank

  enum Suit: String, CaseIterable {
    case spades = "♠️"
    case hearts = "♥️"
    case diamonds = "♣️"
    case clubs = "♦️"
  }

  enum Rank {
    case ace
    case face(String)
    case numeric(Int)

    var order: Int {
      switch self {
      case .ace: return 1
      case .numeric(let number): return number
      case .face(let kind) where kind == "J": return 11
      case .face(let kind) where kind == "Q": return 12
      case .face(let kind) where kind == "K": return 13
      default: return 0
      }
    }

    static var allCases: [Rank] {
      var allRanks = [Rank.ace]
      for number in 2...10 {
        allRanks.append(Rank.numeric(number))
      }
      allRanks += [.face("J"), .face("Q"), .face("K")]
      return allRanks
    }

  }
}
