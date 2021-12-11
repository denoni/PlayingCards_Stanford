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

  private func push(_ item: UIDynamicItem) {
    let push = UIPushBehavior(items: [item], mode: .instantaneous)
    push.angle = CGFloat.random(in: 0...(2 * CGFloat.pi))
    push.magnitude = 1.0 + CGFloat.random(in: 0...2)
    // change the push action just so that when the push is called, we remove the behaviour right after it was already used
    push.action = { [unowned push, weak self] in self?.removeChildBehavior(push) }
    addChildBehavior(push)
  }

  func addItem(_ item: UIDynamicItem) {
    collisionBehaviour.addItem(item)
    itemBehaviour.addItem(item)
    push(item)
  }

}
