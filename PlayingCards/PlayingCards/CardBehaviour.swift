//
//  CardBehaviour.swift
//  PlayingCards
//
//  Created by Gabriel on 12/10/21.
//

import UIKit

class CardBehaviour: UIDynamicBehavior {

  override init() {
    super.init()
    addChildBehavior(collisionBehaviour)
    addChildBehavior(itemBehaviour)
    addChildBehavior(gravityBehaviour)
  }

  convenience init(in animator: UIDynamicAnimator) {
    self.init()
    animator.addBehavior(self)
  }

  lazy var collisionBehaviour: UICollisionBehavior = {
    let behaviour = UICollisionBehavior()
    behaviour.translatesReferenceBoundsIntoBoundary = true
    return behaviour
  }()

  lazy var itemBehaviour: UIDynamicItemBehavior = {
    let behaviour = UIDynamicItemBehavior()
    behaviour.allowsRotation = false
    behaviour.elasticity = 1
    behaviour.resistance = 0
    return behaviour
  }()

  lazy var gravityBehaviour: UIGravityBehavior = {
    let behaviour = UIGravityBehavior()
    behaviour.magnitude = 0
    return behaviour
  }()

  private func push(_ item: UIDynamicItem) {
    let push = UIPushBehavior(items: [item], mode: .instantaneous)

    // To make the card have a bias towards the center
    if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
      let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
      switch (item.center.x, item.center.y) {
      case let (x, y) where x < center.x && y < center.y:
        push.angle = CGFloat.random(in: 0...(CGFloat.pi / 2))
      case let (x, y) where x > center.x && y < center.y:
        push.angle = CGFloat.pi - CGFloat.random(in: 0...(CGFloat.pi / 2))
      case let (x, y) where x < center.x && y > center.y:
        push.angle = CGFloat.random(in: (-CGFloat.pi / 2)...0)
      case let (x, y) where x > center.x && y > center.y:
        push.angle = CGFloat.pi + CGFloat.random(in: 0...(CGFloat.pi / 2))
      default:
        push.angle = CGFloat.random(in: 0...(CGFloat.pi * 2))
      }
    }

    push.magnitude = 2.0 + CGFloat.random(in: 0...2)
    // change the push action just so that when the push is called, we remove the behaviour right after it was already used
    push.action = { [unowned push, weak self] in self?.removeChildBehavior(push) }
    addChildBehavior(push)
  }

  func addItem(_ item: UIDynamicItem) {
    collisionBehaviour.addItem(item)
    itemBehaviour.addItem(item)
    gravityBehaviour.addItem(item)
    push(item)
  }

  func removeItem(_ item: UIDynamicItem) {
    collisionBehaviour.removeItem(item)
    itemBehaviour.removeItem(item)
    gravityBehaviour.removeItem(item)
  }

}
