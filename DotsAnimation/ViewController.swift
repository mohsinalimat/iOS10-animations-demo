//
//  ViewController.swift
//  LoginAnimation
//
//  Created by Olga Konoreva on 30/09/16.
//  Copyright © 2016 Olga Konoreva. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var fakeButtonView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    private  let animationHeight: CGFloat = 24
    
    private let controlPoint1 = CGPoint(x: 0.25, y: 0.1)
    private let controlPoint2 = CGPoint(x: 0.25, y: 1)
    
    private let dotViewLeft = DotView(color: UIColor.appBrandColor())
    private let dotViewCenter = DotView(color: UIColor.appBrandColor())
    private let dotViewRight = DotView(color: UIColor.appBrandColor())
    
    private var dotsUpAnimator: [UIViewPropertyAnimator] = []
    private var timer: Timer?
    private var toTop = true
    private var buttonCenter: CGPoint!

    private var dotsJumpsCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressLabel.alpha = 0.0
        setupDotView(dotView: dotViewLeft)
        setupDotView(dotView: dotViewCenter)
        setupDotView(dotView: dotViewRight)
        fakeButtonView.clipsToBounds = true
    }
    
    @IBAction func startAnimationTapped(_ sender: AnyObject) {
        animateJumpUp()
    }
    
    func animateJumpUp() {
        buttonCenter = fakeButtonView.center
        self.startButton.alpha = 0
        let animator = UIViewPropertyAnimator(duration: 0.3, controlPoint1: controlPoint1, controlPoint2: controlPoint2, animations: {
            self.fakeButtonView.frame = CGRect(x: 0, y: 0, width: 14, height: 14)
            self.fakeButtonView.center = self.buttonCenter
            self.fakeButtonView.layer.cornerRadius = 7.0
            self.descriptionLabel.alpha = 0
            self.logoImageView.alpha = 0
        })
        
        let velocity = CGVector(dx: 0, dy: 0)
        let springParameters = UISpringTimingParameters(mass: 1.8, stiffness: 330, damping: 33, initialVelocity: velocity)
        
        let springAnimator = UIViewPropertyAnimator(duration: 0.0, timingParameters: springParameters)
        springAnimator.addAnimations ({
            self.fakeButtonView.center.y = self.dotViewCenter.center.y
        }, delayFactor: 0.3)
        springAnimator.addCompletion { _ in
            self.fakeButtonView.isHidden = true
            self.dotViewLeft.isHidden = false
            self.dotViewCenter.isHidden = false
            self.dotViewRight.isHidden = false
            self.createHorizontalDotsAnimation(isForward: true)
        }
        
        animator.startAnimation()
        springAnimator.startAnimation()
    }
    
    func createHorizontalDotsAnimation(isForward: Bool) {
        let animator = UIViewPropertyAnimator(duration: 0.3, controlPoint1: controlPoint1, controlPoint2: controlPoint2, animations: {
            self.progressLabel.center.y = isForward ? self.progressLabel.center.y - 60 :
                self.progressLabel.center.y + 60
            self.progressLabel.alpha = isForward ? 1.0 : 0.0
            self.dotViewLeft.center.x = isForward ? self.view.center.x - self.dotViewLeft.frame.width * 1.8 : self.view.center.x
            self.dotViewRight.center.x = isForward ? self.view.center.x + self.dotViewLeft.frame.width * 1.8 : self.view.center.x
        })
        if isForward {
            animator.addCompletion( { _ in
                self.timer = Timer.scheduledTimer(timeInterval: 0.53, target: self, selector: #selector(self.startReversedDotsAnimation), userInfo: nil, repeats: true)
                self.createDotsAnimation()
                for dotAnimator in self.dotsUpAnimator {
                    dotAnimator.startAnimation()
                }
            })
        } else {
            animator.addCompletion({ _ in
                let confirmationAnimatedView = ConfirmationAnimatedView(color: UIColor.appBrandColor())
                self.view.addSubview(confirmationAnimatedView)
                confirmationAnimatedView.didFinish = {
                    confirmationAnimatedView.removeFromSuperview()
                    self.animateJumpDown()
                }
                confirmationAnimatedView.showConfirmation(startPoint: CGPoint(x: self.view.center.x, y: 150))
            })
        }
        animator.startAnimation()
    }
    
    func createDotsAnimation() {
        let dotLeftAnimator = UIViewPropertyAnimator(duration: 0.37, controlPoint1: controlPoint1, controlPoint2: controlPoint2, animations: {
            self.dotViewLeft.center.y = self.dotViewLeft.center.y - self.animationHeight
        })
        dotsUpAnimator.append(dotLeftAnimator)
        
        let dotCenterAnimator = UIViewPropertyAnimator(duration: 0.43, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        dotCenterAnimator.addAnimations ({
            self.dotViewCenter.center.y = self.dotViewCenter.center.y - self.animationHeight
        }, delayFactor: 0.2)
        
        dotsUpAnimator.append(dotCenterAnimator)
        
        let dotRightAnimator = UIViewPropertyAnimator(duration: 0.53, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        dotRightAnimator.addAnimations ({
            self.dotViewRight.center.y = self.dotViewRight.center.y - self.animationHeight
        }, delayFactor: 0.32)
        
        dotsUpAnimator.append(dotRightAnimator)
    }
    
    func startReversedDotsAnimation() {
        if dotsJumpsCount < 5 {

            dotsJumpsCount += 1
            toTop = !toTop
            
            dotsUpAnimator[0].addAnimations ({
                self.dotViewLeft.center.y = self.toTop ? self.dotViewLeft.center.y - self.animationHeight : self.dotViewLeft.center.y + self.animationHeight
            })
            
            dotsUpAnimator[1].addAnimations ({
                self.dotViewCenter.center.y = self.toTop ? self.dotViewCenter.center.y - self.animationHeight : self.dotViewCenter.center.y + self.animationHeight
                }, delayFactor: 0.2)
            
            dotsUpAnimator[2].addAnimations ({
                self.dotViewRight.center.y = self.toTop ? self.dotViewRight.center.y - self.animationHeight : self.dotViewRight.center.y + self.animationHeight
                }, delayFactor: 0.32)

            // add complition action after finishing jumping of the third dot
            if dotsJumpsCount == 5 {
                dotsUpAnimator[2].addCompletion { _ in
                    self.createHorizontalDotsAnimation(isForward: false)
                    self.dotsUpAnimator.removeAll()
                    self.toTop = true
                }
                dotsJumpsCount = 0
                finishDotsProgressAnimation()
            }
            
            for dotAnimator in dotsUpAnimator {
                dotAnimator.startAnimation()
            }
        }
    }
    
    func animateJumpDown() {
        self.dotViewLeft.isHidden = true
        self.dotViewCenter.isHidden = true
        
        let velocity = CGVector(dx: 0, dy: 0)
        let springParameters = UISpringTimingParameters(mass: 1.8, stiffness: 330, damping: 33, initialVelocity: velocity)
        
        let springAnimator = UIViewPropertyAnimator(duration: 0.0, timingParameters: springParameters)
        springAnimator.addAnimations ({
            self.fakeButtonView.center.y = self.dotViewCenter.center.y
        }, delayFactor: 0.3)
        springAnimator.addCompletion { _ in
            self.fakeButtonView.isHidden = false
            self.fakeButtonView.layer.cornerRadius = 0.0
            self.dotViewRight.isHidden = true
            self.startButton.alpha = 1
        }
        
        springAnimator.startAnimation()
    }
    
    func finishDotsProgressAnimation() {
        timer?.invalidate()
        timer = nil
    }
    
    private func setupDotView(dotView: DotView) {
        dotView.center = centerPoint()
        dotView.isHidden = true
        view.addSubview(dotView)
    }
    
    private func centerPoint() -> CGPoint {
        return CGPoint(x: self.view.center.x, y: 150)
    }
}

