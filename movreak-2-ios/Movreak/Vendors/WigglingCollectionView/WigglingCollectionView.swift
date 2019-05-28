//  WigglingCollectionView.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 2/28/17.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit

protocol Wiggleable {
    func viewForWiggling() -> UIView
    func didStartWiggling()
    func didStopWiggling()
}

class WiggleableViewCell: UICollectionViewCell, Wiggleable {
    func viewForWiggling() -> UIView { return self }
    func didStartWiggling() { }
    func didStopWiggling() { }
}

class WigglingCollectionView: UICollectionView {
    
    // Wiggle code below from  https://github.com/LiorNn/DragDropCollectionView
    
    var isWiggling = false
    
    var longPressRecognizer: UILongPressGestureRecognizer = {
        let longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.minimumPressDuration = 0.5
        return longPressRecognizer
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    private func commonInit() {
        longPressRecognizer.addTarget(self, action: #selector(WigglingCollectionView.handleLongPress(longPressRecognizer:)))
        addGestureRecognizer(longPressRecognizer)
    }
    
    @objc private func handleLongPress(longPressRecognizer: UILongPressGestureRecognizer) {
        let touchLocation = longPressRecognizer.location(in: self)
        
        switch longPressRecognizer.state {
        case UIGestureRecognizerState.began:
            if let _ = indexPathForItem(at: touchLocation) {
                startWiggle()
            }
            
        default:
            break
        }
    }
    
    func startWiggle() {
        for cell in visibleCells {
            if let cell = cell as? WiggleableViewCell {
                addWiggleAnimation(to: cell)
                cell.viewForWiggling().isUserInteractionEnabled = false
                cell.didStartWiggling()
            }
        }
        isWiggling = true
    }
    
    func stopWiggle() {
        for cell in visibleCells {
            if let cell = cell as? WiggleableViewCell {
                cell.viewForWiggling().layer.removeAllAnimations()
                cell.viewForWiggling().isUserInteractionEnabled = true
                cell.didStopWiggling()
            }
        }
        isWiggling = false
    }
    
    func addWiggleAnimation(to cell: WiggleableViewCell) {
        CATransaction.begin()
        CATransaction.setDisableActions(false)
        cell.viewForWiggling().layer.add(rotationAnimation(), forKey: "rotation")
        cell.viewForWiggling().layer.add(bounceAnimation(), forKey: "bounce")
        CATransaction.commit()
    }
    
    override func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        if let cell = cell as? WiggleableViewCell {
            if isWiggling {
                addWiggleAnimation(to: cell)
            }
            else {
                cell.viewForWiggling().layer.removeAllAnimations()
            }
        }
        return cell
    }
    
    private func rotationAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        let angle = CGFloat(0.02)
        let duration = TimeInterval(0.1)
        let variance = Double(0.025)
        animation.values = [angle, -angle]
        animation.autoreverses = true
        animation.duration = randomize(interval: duration, withVariance: variance)
        animation.repeatCount = Float.infinity
        return animation
    }
    
    private func bounceAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        let bounce = CGFloat(3.0)
        let duration = TimeInterval(0.12)
        let variance = Double(0.025)
        animation.values = [bounce, -bounce]
        animation.autoreverses = true
        animation.duration = randomize(interval: duration, withVariance: variance)
        animation.repeatCount = Float.infinity
        
        return animation
    }
    
    private func randomize(interval: TimeInterval, withVariance variance:Double) -> TimeInterval {
        let random = (Double(arc4random_uniform(1000)) - 500.0) / 500.0
        return interval + variance * random
    }
}
