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
    
    private let kAnimationHeight: CGFloat = 24
    private let kDotsJumpsCountMax = 5
    
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
        self.buttonCenter = fakeButtonView.center
        self.startButton.alpha = 0
        let animator = UIViewPropertyAnimator(duration: 0.3, controlPoint1: controlPoint1, controlPoint2: controlPoint2, animations: {
            self.fakeButtonView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
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
            print("springAnimator completion fake button frame \(self.fakeButtonView.frame)")
            self.fakeButtonView.isHidden = true
            print("springAnimator completion fake button frame \(self.fakeButtonView.frame)")
            self.dotViewLeft.isHidden = false
            self.dotViewCenter.isHidden = false
            self.dotViewRight.isHidden = false
            self.createHorizontalDotsAnimation(isForward: true)
        }

        print("animateJumpUp fake button frame \(self.fakeButtonView.frame)")
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
                self.dotViewLeft.isHidden = true
                self.dotViewCenter.isHidden = true
                self.dotViewRight.isHidden = true

                let confirmationAnimatedView = ConfirmationAnimatedView(color: UIColor.appBrandColor())
                self.view.addSubview(confirmationAnimatedView)
                confirmationAnimatedView.didFinish = {
                    let finishConfirmationAnimator = UIViewPropertyAnimator(duration: 0.32, controlPoint1: self.controlPoint1, controlPoint2: self.controlPoint2, animations: {
                        confirmationAnimatedView.addCompletionActions()
                    })
                    finishConfirmationAnimator.addCompletion { _ in
                        self.fakeButtonView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
                        self.fakeButtonView.center = confirmationAnimatedView.dotViewCenter()
                        confirmationAnimatedView.removeFromSuperview()
                        self.animateJumpDown()
                    }
                    finishConfirmationAnimator.startAnimation()
                }
                confirmationAnimatedView.showConfirmation(startPoint: CGPoint(x: self.view.center.x, y: 150))
            })
        }
        animator.startAnimation()
    }
    
    func createDotsAnimation() {
        let dotLeftAnimator = UIViewPropertyAnimator(duration: 0.37, controlPoint1: controlPoint1, controlPoint2: controlPoint2, animations: {
            self.dotViewLeft.center.y = self.dotViewLeft.center.y - self.kAnimationHeight
        })
        dotsUpAnimator.append(dotLeftAnimator)
        
        let dotCenterAnimator = UIViewPropertyAnimator(duration: 0.43, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        dotCenterAnimator.addAnimations ({
            self.dotViewCenter.center.y = self.dotViewCenter.center.y - self.kAnimationHeight
        }, delayFactor: 0.2)
        
        dotsUpAnimator.append(dotCenterAnimator)
        
        let dotRightAnimator = UIViewPropertyAnimator(duration: 0.53, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        dotRightAnimator.addAnimations ({
            self.dotViewRight.center.y = self.dotViewRight.center.y - self.kAnimationHeight
        }, delayFactor: 0.32)
        
        dotsUpAnimator.append(dotRightAnimator)
    }
    
    func startReversedDotsAnimation() {
        if dotsJumpsCount < kDotsJumpsCountMax {

            dotsJumpsCount += 1
            toTop = !toTop
            
            dotsUpAnimator[0].addAnimations ({
                self.dotViewLeft.center.y = self.toTop ? self.dotViewLeft.center.y - self.kAnimationHeight : self.dotViewLeft.center.y + self.kAnimationHeight
            })
            
            dotsUpAnimator[1].addAnimations ({
                self.dotViewCenter.center.y = self.toTop ? self.dotViewCenter.center.y - self.kAnimationHeight : self.dotViewCenter.center.y + self.kAnimationHeight
                }, delayFactor: 0.2)
            
            dotsUpAnimator[2].addAnimations ({
                self.dotViewRight.center.y = self.toTop ? self.dotViewRight.center.y - self.kAnimationHeight : self.dotViewRight.center.y + self.kAnimationHeight
                }, delayFactor: 0.32)

            // add complition action after finishing jumping of the third dot
            if dotsJumpsCount == kDotsJumpsCountMax {
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
        self.descriptionLabel.center.y += 50
        self.logoImageView.center.y += 50
        let showContentAnimator = UIViewPropertyAnimator(duration: 0.7, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        showContentAnimator.addAnimations({ _ in
            self.descriptionLabel.alpha = 1
            self.logoImageView.alpha = 1
            self.descriptionLabel.center.y -= 50
            self.logoImageView.center.y -= 50
            self.fakeButtonView.frame = self.startButton.frame
        }, delayFactor: 0.6)

        self.fakeButtonView.isHidden = false
        self.fakeButtonView.backgroundColor = UIColor.gray
        self.fakeButtonView.layer.cornerRadius = 7.0
        self.fakeButtonView.clipsToBounds = true
        showContentAnimator.addCompletion { _ in
            self.fakeButtonView.layer.cornerRadius = 0.0
        }

        let showButtonTextAnimator = UIViewPropertyAnimator(duration: 0.3, controlPoint1: controlPoint1, controlPoint2: controlPoint2, animations: {
            self.startButton.alpha = 1
        })
        showButtonTextAnimator.addCompletion { _ in 
            let radiusFakeButtonAnimator = UIViewPropertyAnimator(duration: 0.3, controlPoint1: self.controlPoint1, controlPoint2: self.controlPoint2, animations: {
                self.fakeButtonView.layer.cornerRadius = 0.0
            })
            radiusFakeButtonAnimator.startAnimation()
        }

        let animatorJumpDown = UIViewPropertyAnimator(duration: 0.49, controlPoint1: CGPoint(x: 0.68, y: -0.55), controlPoint2: CGPoint(x: 0.3, y: 1.45), animations: {
            self.fakeButtonView.center = self.startButton.center
        })
        animatorJumpDown.addCompletion { _ in
            showButtonTextAnimator.startAnimation()
        }

        animatorJumpDown.startAnimation()
        showContentAnimator.startAnimation()
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

