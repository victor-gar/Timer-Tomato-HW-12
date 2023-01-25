//
//  ViewController.swift
//  Timer-Tomato-HW-12
//
//  Created by Victor Garitskyu on 25.01.2023.
//

import UIKit
import SnapKit

class ViewController: UIViewController, CAAnimationDelegate{
    
    //MARK: - Outlets

    private let imagePlay = UIImage(systemName: "play")
    private let imageStop = UIImage(systemName: "pause")
    private let imageStart = UIImage(systemName: "clock.arrow.2.circlepath")
    
    var timer = Timer()
    var isTimerStarted = false
    var isAnimationStarted = false
    var time = 10
    
    let foreProgresslayer = CAShapeLayer()
    let backProgresslayer = CAShapeLayer()
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    
    private lazy var labelTimeText: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.text = "00:10"
        label.font = UIFont.systemFont(ofSize: 50, weight: .light)
        return label
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.black
        //        button.setTitle("Play", for: .normal)
        button.setTitleColor(UIColor.systemGreen, for: .normal)
        button.setImage(imagePlay!, for: .normal)
        button.tintColor = UIColor.systemGreen
        //        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 50, weight: UIImage.SymbolWeight.thin), forImageIn: .normal)
        button.addTarget(self, action: #selector(startButtonTupped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        button.addTarget(self, action: #selector(cancelButtonTupped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHierarchy()
        setupLayout()
        drawBackLayer()
        
    }
    //MARK: - Setup

    private func setupView(){
        view.backgroundColor = .white
    }
    
    private func setupHierarchy() {
        view.addSubview(cancelButton)
        view.addSubview(playButton)
        view.addSubview(labelTimeText)
    }
    
    private func setupLayout() {
            playButton.snp.makeConstraints { make in
            make.bottom.equalTo(labelTimeText.snp.bottom).offset(50)
            make.centerX.equalTo(view)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalTo(playButton.snp.bottom).offset(100)
            make.centerX.equalTo(view)
        }
        
        labelTimeText.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
        }
    }
    
    private func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
   
    
    private func formatTimer() -> String{
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    private func drawBackLayer() {
        backProgresslayer.path = UIBezierPath(arcCenter:
                                                CGPoint(x: view.frame.midX, y: view.frame.midY),
                                              radius: 100,
                                              startAngle: -90.degreesToRadians,
                                              endAngle: 270.degreesToRadians,
                                              clockwise: true).cgPath
        backProgresslayer.strokeColor = UIColor.lightGray.cgColor
        backProgresslayer.fillColor = UIColor.clear.cgColor
        backProgresslayer.lineWidth = 15
        view.layer.addSublayer(backProgresslayer)
    }
    
    private func drawFrontLayer() {
        foreProgresslayer.path = UIBezierPath(arcCenter:
                                                CGPoint(x: view.frame.midX, y: view.frame.midY),
                                              radius: 100,
                                              startAngle: -90.degreesToRadians,
                                              endAngle: 270.degreesToRadians,
                                              clockwise: true).cgPath
        foreProgresslayer.strokeColor = UIColor.systemGreen.cgColor
        foreProgresslayer.fillColor = UIColor.clear.cgColor
        foreProgresslayer.lineWidth = 15
        view.layer.addSublayer(foreProgresslayer)
    }
    
    func startResumAnimation() {
        if !isAnimationStarted {
            startAnimation()
        } else {
            resumeAnimation()
        }
    }
    
    private func startAnimation() {
            resetAnimation()
            foreProgresslayer.strokeEnd = 0.0
            animation.keyPath = "strokeEnd"
            animation.fromValue = 0
            animation.toValue = 1
        if time == 5 {
            animation.duration = 5
            foreProgresslayer.strokeColor = UIColor.systemRed.cgColor
        } else {
            animation.duration = 10
            foreProgresslayer.strokeColor = UIColor.systemGreen.cgColor
        }
            animation.delegate = self
            animation.isRemovedOnCompletion = false
            animation.isAdditive = true
            animation.fillMode = CAMediaTimingFillMode.forwards
            foreProgresslayer.add(animation, forKey: "strokeEnd")
            isAnimationStarted = true
    }
    
    private func resetAnimation(){
        foreProgresslayer.speed = 1.0
        foreProgresslayer.timeOffset = 0.0
        foreProgresslayer.beginTime = 0.0
        foreProgresslayer.strokeEnd = 0.0
        isAnimationStarted = false
    }
    
    private func pauseAnimation(){
        let pausedTime = foreProgresslayer.convertTime(CACurrentMediaTime(), to: nil)
        foreProgresslayer.speed = 0.0
        foreProgresslayer.timeOffset = pausedTime
    }
    
    private func resumeAnimation(){
        let pausedTime = foreProgresslayer.timeOffset
        foreProgresslayer.speed = 1.0
        foreProgresslayer.timeOffset = 0.0
        foreProgresslayer.beginTime = 0.0
        let timeSincePaused = foreProgresslayer.convertTime(CACurrentMediaTime(), to: nil) - pausedTime
        foreProgresslayer.beginTime = timeSincePaused
    }
    
    private func stopAnimation(){
        foreProgresslayer.speed = 1.0
        foreProgresslayer.timeOffset = 0.0
        foreProgresslayer.beginTime = 0.0
        foreProgresslayer.strokeEnd = 0.0
        foreProgresslayer.removeAllAnimations()
        isAnimationStarted = false
    }
    
    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        stopAnimation()
    }
    
    //MARK: - Action
    
    @objc func startButtonTupped() {
        cancelButton.isEnabled = true
        cancelButton.alpha = 1.0
        if !isTimerStarted {
            drawFrontLayer()
            startResumAnimation()
            startTimer()
            isTimerStarted = true
            cancelButton.isEnabled = true
            cancelButton.alpha = 1.0
            playButton.setImage(imagePlay, for: .normal)
            playButton.setTitle("", for: .normal)
        } else {
            pauseAnimation()
            timer.invalidate()
            isTimerStarted = false
            playButton.setImage(imageStop, for: .normal)
            playButton.setTitle("", for: .normal)
        }
    }
    
    @objc func cancelButtonTupped() {
        labelTimeText.text = "00:05"
        stopAnimation()
        cancelButton.isEnabled = false
        cancelButton.alpha = 0.5
        timer.invalidate()
        time = 5
        isTimerStarted = false
        playButton.setImage(imageStart, for: .normal)
        playButton.setTitle("Start", for: .normal)
    }
        
    @objc func updateTimer() {
        if time < 1{
            cancelButton.isEnabled = false
            cancelButton.alpha = 0.5
            timer.invalidate()
            time = 10
            isTimerStarted = false
            labelTimeText.text = "00:10"
            startAnimation()
            startTimer()
            isTimerStarted = true
            cancelButton.isEnabled = true
            cancelButton.alpha = 1.0
            playButton.setImage(imageStop, for: .normal)
            playButton.setTitle("", for: .normal)
            foreProgresslayer.strokeColor = UIColor.systemGreen.cgColor

        } else {
            time -= 1
            labelTimeText.text = formatTimer()
        }
    }
}

