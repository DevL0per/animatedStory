//
//  ViewController.swift
//  animatedStory
//
//  Created by Роман Важник on 29.03.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import UIKit

struct Constants {
    static let textViewWidth = UIScreen.main.bounds.width-65
    static let textViewHeight = UIScreen.main.bounds.height/2.5
    static let imageViewWidth: CGFloat = UIScreen.main.bounds.height/2*1.2
    static let imageViewHeight: CGFloat = UIScreen.main.bounds.height/2
    static let buttonWidth: CGFloat = 300
    static let buttonHeight: CGFloat = 100
}

class ViewController: UIViewController {
    
    // MARK: - Properties
    private lazy var characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.imageViewWidth,
                                 height: Constants.imageViewHeight)
        imageView.center = view.center
        imageView.image = dialogues.first?.characterImage
        originalCharacterImageViewFrame = imageView.frame
        return imageView
    }()
    
    private lazy var dialogueLabel: UITextView = {
        let textview = UITextView()
        textview.backgroundColor = .white
        textview.alpha = 0.8
        textview.translatesAutoresizingMaskIntoConstraints = false
        textview.isScrollEnabled = true
        textview.font = UIFont.systemFont(ofSize: 20)
        textview.layer.cornerRadius = 10
        textview.isSelectable = false
        return textview
    }()
    private var isEndScreenActive = false
    private var characterImageAnimation: CABasicAnimation!
    private var originalCharacterImageViewFrame: CGRect!
    private var singleGestureRecognizer: UIGestureRecognizer!
    private var fullDialogueText = dialogues.first!.characterText
    private var currentDialogueText = ""
    private var currentDialogueIndex = 1
    private var currentLetterIndex = 0
    private lazy var endSreen: UIView = {
        let view = UIView(frame: self.view.frame)
        view.alpha = 0
        let gradient = CAGradientLayer()
        gradient.colors = [#colorLiteral(red: 0.242534399, green: 0.5001540184, blue: 0.7016959786, alpha: 1).cgColor, #colorLiteral(red: 0.447070241, green: 0.6915690303, blue: 0.7781583667, alpha: 1).cgColor]
        gradient.locations = [0, 1]
        gradient.frame = view.frame
        view.layer.addSublayer(gradient)
        return view
    }()
    fileprivate lazy var rebootButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: -Constants.buttonHeight,
                                            width: Constants.buttonWidth,
                                            height: Constants.buttonHeight))
        button.center.x = view.center.x
        button.setTitleColor(#colorLiteral(red: 0.1965343356, green: 0.1965343356, blue: 0.1965343356, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont(name: "Georgia", size: 30)
        button.setTitle("WATCH AGAIN", for: .normal)
        button.backgroundColor = .clear
        //button.clipsToBounds = true
        button.layer.cornerRadius = Constants.buttonHeight/2
        button.addTarget(self, action: #selector(rebootButtonWasPressed), for: .touchUpInside)
        button.backgroundColor = .yellow
        let gradient = CAGradientLayer()
        gradient.colors = [#colorLiteral(red: 1, green: 0.9450980392, blue: 0.2862745098, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0.7966067777, blue: 0.1592854299, alpha: 1).cgColor]
        gradient.cornerRadius = Constants.buttonHeight/2
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.frame = button.bounds
        button.layer.insertSublayer(gradient, at: 0)
        return button
    }()
    private lazy var backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "BackgroundHouse")
        imageView.frame = self.view.frame
        return imageView
    }()
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        //addElements on view
        view.addSubview(backgroundView)
        endSreen.addSubview(rebootButton)
        backgroundView.addSubview(characterImageView)
        backgroundView.addSubview(dialogueLabel)
        layoutDialogueLabel()
    
        //Start animations
        setupAnimateCharacterImage()
        startAnimation()
        setupDisplayLink()
        
        //setup gestureRecognizers
        setupGestureRecognizer()
    }
    
    @objc private func rebootButtonWasPressed() {
        rebootValuesOfItems()
        isEndScreenActive = false
        stopAllTheAnimations()
        currentDialogueIndex = 1
        fullDialogueText = dialogues.first!.characterText
        characterImageView.image = dialogues.first!.characterImage
        UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseOut, animations: { [unowned self] in
            self.endSreen.alpha = 0
            self.rebootButton.frame.origin.y = -Constants.buttonHeight
        }, completion: nil)
    }
    
    private func setupGestureRecognizer() {
        singleGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewWasTapped))
        view.addGestureRecognizer(singleGestureRecognizer)
    }
    
    @objc private func viewWasTapped() {
        if currentDialogueIndex < dialogues.count && !isEndScreenActive {
            rebootValuesOfItems()
            fullDialogueText = dialogues[currentDialogueIndex].characterText
            characterImageView.frame = originalCharacterImageViewFrame
            characterImageView.image = dialogues[currentDialogueIndex].characterImage
            startAnimation()
            currentDialogueIndex+=1
        } else if !isEndScreenActive {
            isEndScreenActive = true
            view.addSubview(endSreen)
            UIView.animate(withDuration: 1, delay: 0.2, options: .curveEaseIn, animations: { [unowned self] in
                self.endSreen.alpha = 1
            }, completion: { [unowned self] (_) in
                self.animateRebootButton()
                self.createClouds()
            })
        }
    }
    
    private func rebootValuesOfItems() {
        currentDialogueText = ""
        currentLetterIndex = 0
    }
    
    private func setupDisplayLink() {
        let displayLink = CADisplayLink(target: self, selector: #selector(animateDialogueLabel))
        displayLink.add(to: .main, forMode: .default)
    }
    
    @objc private func animateDialogueLabel() {
        if currentLetterIndex < fullDialogueText.count {
            let index = fullDialogueText.index(fullDialogueText.startIndex,
                                               offsetBy: currentLetterIndex)
            let letter = String(fullDialogueText[index])
            currentDialogueText += letter
            dialogueLabel.text = currentDialogueText
            currentLetterIndex += 1
        }
    }
    
    // EndScreen Animations
    
    // arrey to delete all the animations if user press the repeet button
    var clouds: [UIImageView] = []

    private func createClouds() {
        clouds = []
        for _ in 0...5 {
            let cloudNumber = Int.random(in: 1...3)
            let cloudName = "Cloud" + String(cloudNumber)
            let randomWidth = CGFloat.random(in: 60...80)
            let randomHeight = CGFloat.random(in: 40...50)
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: randomWidth, height: randomHeight))
            imageView.image = UIImage(named: cloudName)
            view.addSubview(imageView)
            clouds.append(imageView)
            createCloudsAnimation(cloudImage: imageView)
        }
    }
    
    private func stopAllTheAnimations() {
        clouds.forEach { (cloud) in
            cloud.layer.removeAnimation(forKey: "cloudAnimation")
            cloud.removeFromSuperview()
        }
        clouds = []
    }
    
    private func animateRebootButton() {
        let animation = CASpringAnimation(keyPath: "position.y")
        animation.fromValue = -Constants.buttonHeight-30
        animation.toValue = view.center.y
        animation.damping = 4.5
        animation.duration = 2.5
        animation.fillMode = .backwards
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        rebootButton.layer.add(animation, forKey: "rebootButtonAnimation")
    }
    
    private func createCloudsAnimation(cloudImage: UIImageView) {
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = createRandomBezierPathForClouds().cgPath
        animation.duration = Double.random(in: 3...6)
        animation.repeatCount = .infinity
        animation.fillMode = .both
        animation.isRemovedOnCompletion = false
        cloudImage.layer.add(animation, forKey: "cloudAnimation")
    }
    
    private func createRandomBezierPathForClouds() -> UIBezierPath {
        let bezierPath = UIBezierPath()
        let randomY: CGFloat = CGFloat.random(in: 10...view.frame.height-10)
        let startPoind = CGPoint(x: -20, y: randomY)
        bezierPath.move(to: startPoind)
        let halfOfViewWidth = view.frame.width/2
        let point1 = CGPoint(x: halfOfViewWidth-halfOfViewWidth/2, y: CGFloat.random(in: randomY+50...randomY+100))
        let point2 = CGPoint(x: halfOfViewWidth+halfOfViewWidth/2, y: CGFloat.random(in: randomY-100...randomY-50))
        bezierPath.addCurve(to: CGPoint(x: view.frame.width+50, y: randomY), controlPoint1: point1, controlPoint2: point2)
        return bezierPath
    }
    
    // CharacterImage animation
    private func startAnimation() {
        characterImageView.layer.add(characterImageAnimation, forKey: "animation")
    }
    
    private func setupAnimateCharacterImage() {
        characterImageAnimation = CABasicAnimation(keyPath: "transform.scale")
        characterImageAnimation.toValue = 1.5
        characterImageAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        characterImageAnimation.duration = 2
        characterImageAnimation.fillMode = .both
        characterImageAnimation.isRemovedOnCompletion = false
    }

    //MARK: - layouts
    private func layoutDialogueLabel() {
        dialogueLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        dialogueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dialogueLabel.widthAnchor.constraint(equalToConstant: Constants.textViewWidth).isActive = true
        dialogueLabel.heightAnchor.constraint(equalToConstant: Constants.textViewHeight).isActive = true
    }

}

extension ViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        rebootButton.center.y = view.center.y
    }
}
