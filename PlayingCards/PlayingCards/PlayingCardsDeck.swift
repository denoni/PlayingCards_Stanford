//
//  PlayingCardsDeck.swift
//  PlayingCards
//
//  Created by Gabriel on 12/9/21.
//

import Foundation

struct PlayingCardsDeck {
  private(set) var cards = [PlayingCard]()

  init() {
    for suit in PlayingCard.Suit.allCases {
      for rank in PlayingCard.Rank.allCases {
        cards.append(PlayingCard(suit: suit, rank: rank))
      }
    }
  }

  mutating func draw() -> PlayingCard? {
    if cards.count > 0 {
      return cards.remove(at: Int.random(in: 0 ..< cards.count))
    } else {
      return nil
    }
  }

}
