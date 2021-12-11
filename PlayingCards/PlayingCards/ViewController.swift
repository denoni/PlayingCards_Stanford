//
//  ViewController.swift
//  PlayingCards
//
//  Created by Gabriel on 12/9/21.
//

import UIKit

class ViewController: UIViewController {

  var deck = PlayingCardsDeck()

  lazy var animator = UIDynamicAnimator(referenceView: view)
  lazy var collisionBehaviour: UICollisionBehavior = {
    let behaviour = UICollisionBehavior()
    behaviour.translatesReferenceBoundsIntoBoundary = true
    animator.addBehavior(behaviour)
    return behaviour
  }()

  lazy var itemBehaviour: UIDynamicItemBehavior = {
    let behaviour = UIDynamicItemBehavior()
    // behaviour.allowsRotation = false
    behaviour.elasticity = 1
    behaviour.resistance = 0
    animator.addBehavior(behaviour)
    return behaviour
  }()

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

      collisionBehaviour.addItem(cardView)
      itemBehaviour.addItem(cardView)
      let push = UIPushBehavior(items: [cardView], mode: .instantaneous)
      push.angle = CGFloat.random(in: 0...(2 * CGFloat.pi))
      push.magnitude = 1.0 + CGFloat.random(in: 0...2)
      // change the push action just so that when the push is called, we remove the behaviour right after it was already used
      push.action = { [unowned push] in push.dynamicAnimator?.removeBehavior(push) }
      animator.addBehavior(push)
    }
  }

  private var currentFaceUpCardViews: [PlayingCardView] {
    return playingCardViews.filter { $0.isFaceUp && !$0.isHidden }
  }

  private var faceUpCardsViewMatch: Bool {
    return currentFaceUpCardViews.count == 2 &&
    (currentFaceUpCardViews[0].rank == currentFaceUpCardViews[1].rank) &&
    (currentFaceUpCardViews[0].suit == currentFaceUpCardViews[1].suit)
  }

  @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
    switch recognizer.state {
    case .ended:
      if let chosenCardView = recognizer.view as? PlayingCardView {
        UIView.transition(
          with: chosenCardView,
          duration: 0.5,
          options: [.transitionFlipFromLeft],
          animations: { chosenCardView.isFaceUp = !chosenCardView.isFaceUp },
          completion: { _ in
            if self.faceUpCardsViewMatch {
              UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.5,
                delay: 0,
                options: [],
                animations: {
                  self.currentFaceUpCardViews.forEach {
                    $0.transform = CGAffineTransform.identity.scaledBy(x: 2, y: 2)
                  }
                },
                completion: { _ in
                  UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.7,
                    delay: 0,
                    options: [],
                    animations: {
                      self.currentFaceUpCardViews.forEach {
                        $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                        $0.alpha = 0
                      }
                    },
                    completion: { _ in
                      self.currentFaceUpCardViews.forEach {
                        $0.isHidden = true
                        $0.alpha = 1
                        $0.transform = .identity
                      }
                    })
                })
            }
            // If there are two cards faced up, flip all cards that are currently faced up
            else if self.currentFaceUpCardViews.count == 2 {
              self.currentFaceUpCardViews.forEach { cardView in
                UIView.transition(
                  with: cardView,
                  duration: 0.5,
                  options: [.transitionFlipFromLeft],
                  animations: { cardView.isFaceUp = false })
              }
            }
          })
      }
    default: break
    }
  }


}

