//
//  ViewController.swift
//  PlayingCards
//
//  Created by Gabriel on 12/9/21.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

  var deck = PlayingCardsDeck()

  lazy var animator = UIDynamicAnimator(referenceView: view)
  lazy var cardBehaviour = CardBehaviour(in: animator)

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if CMMotionManager.shared.isAccelerometerAvailable {
      cardBehaviour.gravityBehaviour.magnitude = 1
      CMMotionManager.shared.accelerometerUpdateInterval = 0.1
      CMMotionManager.shared.startAccelerometerUpdates(to: .main,
                                                       withHandler: { (data, error) in
        if let x = data?.acceleration.x, let y = data?.acceleration.y {
          self.cardBehaviour.gravityBehaviour.gravityDirection = CGVector(dx: x, dy: -y)
        }
      })
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    cardBehaviour.gravityBehaviour.magnitude = 0
    CMMotionManager.shared.stopAccelerometerUpdates()
  }

  @IBOutlet var playingCardViews: [PlayingCardView]!

  override func viewDidLoad() {
    super.viewDidLoad()
    var cards = [PlayingCard]()
    for _ in 1...((playingCardViews.count + 1) / 2) {
      let card = deck.draw()!
      cards += [card, card]
    }
    for cardView in playingCardViews {
      let card = cards.remove(at: Int.random(in: 0 ..< cards.count))
      cardView.rank = card.rank.order
      cardView.suit = card.suit.rawValue
      cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))

      cardBehaviour.addItem(cardView)
    }
  }

  private var currentFaceUpCardViews: [PlayingCardView] {
    return playingCardViews.filter { $0.isFaceUp &&
      !$0.isHidden &&
      // To don't count cards that where just matches(but still animating) as a face up card
      $0.transform != CGAffineTransform.identity.scaledBy(x: 2, y: 2) &&
      $0.alpha == 1 }
  }

  private var faceUpCardsViewMatch: Bool {
    return currentFaceUpCardViews.count == 2 &&
    (currentFaceUpCardViews[0].rank == currentFaceUpCardViews[1].rank) &&
    (currentFaceUpCardViews[0].suit == currentFaceUpCardViews[1].suit)
  }

  var lastChosenCardView: PlayingCardView?

  @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
    switch recognizer.state {
    case .ended:
      if let chosenCardView = recognizer.view as? PlayingCardView, currentFaceUpCardViews.count < 2 {
        lastChosenCardView = chosenCardView
        // Remove the behaviours from card when the card is flipped (just to stop keep it still)
        cardBehaviour.removeItem(chosenCardView)

        UIView.transition(
          with: chosenCardView,
          duration: 0.5,
          options: [.transitionFlipFromLeft],
          animations: { chosenCardView.isFaceUp = !chosenCardView.isFaceUp },
          completion: { _ in
            // Capture the cards that were chosen, so the animation doesn't get clunky if more than one card is selected too fast
            let cardsToAnimate = self.currentFaceUpCardViews
            if self.faceUpCardsViewMatch {
              UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.5,
                delay: 0,
                options: [],
                animations: {
                  cardsToAnimate.forEach {
                    $0.transform = CGAffineTransform.identity.scaledBy(x: 2, y: 2)
                  }
                },
                completion: { _ in
                  UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.7,
                    delay: 0,
                    options: [],
                    animations: {
                      cardsToAnimate.forEach {
                        $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                        $0.alpha = 0
                      }
                    },
                    completion: { _ in
                      cardsToAnimate.forEach {
                        $0.isHidden = true
                        $0.alpha = 1
                        $0.transform = .identity
                      }
                    })
                })
            }
            // If there are two cards faced up, flip all cards that are currently faced up
            else if cardsToAnimate.count == 2 {
              // So only the last card controls the cards turning back, otherwise both cards would try to do the same think messing up the animations
              if chosenCardView == self.lastChosenCardView {
                cardsToAnimate.forEach { cardView in
                  UIView.transition(
                    with: cardView,
                    duration: 0.5,
                    options: [.transitionFlipFromLeft],
                    animations: { cardView.isFaceUp = false },
                    // Add back the card behaviour that were previously removed
                    completion: { _ in self.cardBehaviour.addItem(cardView) })
                }
              }
            }
            // If the user flips back the card
            else {
              if !chosenCardView.isFaceUp {
                // Add back the card behaviour that were previously removed
                self.cardBehaviour.addItem(chosenCardView)
              }
            }
          })
      }
    default: break
    }
  }


}

