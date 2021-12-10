//
//  ViewController.swift
//  PlayingCards
//
//  Created by Gabriel on 12/9/21.
//

import UIKit

class ViewController: UIViewController {

  var deck = PlayingCardsDeck()

  @IBOutlet weak var playingCardView: PlayingCardView! {
    didSet {
      // The target is self(controller) because it communicates with the model
      let swipe = UISwipeGestureRecognizer(target: self, action: #selector(goToNextCard))
      swipe.direction = [.left, .right]

      // The target is the view because it doesn't communicate with the model
      let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector(PlayingCardView.adjustFaceCardScale(byHandlingGestureRecognizedBy:)))

      playingCardView.addGestureRecognizer(swipe)
      playingCardView.addGestureRecognizer(pinch)
    }
  }


  @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
      switch sender.state {
      case .ended:
        playingCardView.isFaceUp = !playingCardView.isFaceUp
      default: break
      }


  }


  @objc func goToNextCard() {
    if let card = deck.draw() {
      playingCardView.rank = card.rank.order
      playingCardView.suit = card.suit.rawValue
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }


}

