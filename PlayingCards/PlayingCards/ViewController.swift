//
//  ViewController.swift
//  PlayingCards
//
//  Created by Gabriel on 12/9/21.
//

import UIKit

class ViewController: UIViewController {

  var deck = PlayingCardsDeck()

  @IBOutlet var playingCardViews: [PlayingCardView]!

  override func viewDidLoad() {
    super.viewDidLoad()
    var cards = [PlayingCard]()
    for _ in 1...((playingCardViews.count + 1) / 2) {
      let card = deck.draw()!
      cards += [card, card]
    }
    for cardView in playingCardViews {
      cardView.isFaceUp = true
      let card = cards.remove(at: Int.random(in: 0 ..< cards.count))
      cardView.rank = card.rank.order
      cardView.suit = card.suit.rawValue
      cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
    }
  }

  @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
    switch recognizer.state {
    case .ended:
      if let chosenCardView = recognizer.view as? PlayingCardView {
        UIView.transition(with: chosenCardView,
                          duration: 0.5,
                          options: [.transitionFlipFromLeft],
                          animations: { chosenCardView.isFaceUp = !chosenCardView.isFaceUp })
      }
    default: break
    }
  }


}

