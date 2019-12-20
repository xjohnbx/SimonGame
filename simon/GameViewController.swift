//
//  GameViewController.swift
//  simon
//
//  Created by John Brechon on 12/11/19.
//  Copyright © 2019 John Brechon. All rights reserved.
//

import UIKit
import CoreData

public enum Color: CaseIterable {
    case Green
    case Red
    case Yellow
    case Blue
}

class GameViewController: UIViewController {

    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    private var color: Color = .Red
    private var colorOrder: [Color] = []
    
    private var highScore = 0
    private var userScore = 0
    private var index = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func startGame() {
        self.view.sendSubviewToBack(homeView)
        homeView.isHidden = true
        colorOrder = []
        startRound()
    }
    
    @objc private func startRound() {
        index = 0
        color = Color.allCases.randomElement()!
        colorOrder.append(color)
        showOrder()
    }
    
    private func startTurn() {
        self.perform(#selector(depopAllButtons), with: nil, afterDelay: 0.5)
        if index != colorOrder.count {
            if !(color == colorOrder[index]) {
                endGame()
                return
            }
            index += 1
        }
        
        if index == colorOrder.count {
            userScore = colorOrder.count
            instructionLabel.text = "Good Job!"
            show(element: instructionLabel)
            self.perform(#selector(self.startRound), with: nil, afterDelay: 1.0)
        }
    }
    
    private func endGame() {
        self.view.bringSubviewToFront(instructionLabel)
        instructionLabel.isHidden = false
        depopAllButtons()
        disableButtons()
        
        if userScore > Int(highScoreLabel.text ?? "0") ?? 0 {
            saveHighScore()
        }
        getHighScore()
        self.perform(#selector(self.startGameOver), with: nil, afterDelay: 2.0)
    }
    
    private func showOrder() {
        disableButtons()
        instructionLabel.text = "Watch Pattern"
        show(element: instructionLabel)
        
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { time in
            self.hide(element: self.instructionLabel)
            if self.index == self.colorOrder.count {
                self.instructionLabel.text = "Go!"
                self.show(element: self.instructionLabel)
                self.perform(#selector(self.showOrderLoopEnd), with: nil, afterDelay: 0.5)
                time.invalidate()
            } else {
                self.depopAllButtons()
                self.perform(#selector(self.showColor), with: nil, afterDelay: 0.5)
            }
        }
    }
    
    @objc func startGameOver() {
        scoreLabel.text = "\(userScore)"
        homeView.isHidden = false
        self.view.bringSubviewToFront(homeView)
        hide(element: instructionLabel)
    }
    
    @objc func showOrderLoopEnd() {
        depopAllButtons()
        enableButtons()
        index = 0
        hide(element: instructionLabel)
        instructionLabel.text = "Game Over"
    }
    
    @objc func showColor() {
        switch colorOrder[index] {
            case .Green:
               popGreen()
            case .Red:
               popRed()
            case .Yellow:
               popYellow()
            case .Blue:
               popBlue()
        }
        index += 1
    }
    
    @IBAction func startButtonClicked(_ sender: Any) {
        startGame()
    }
    
    @IBAction func greenTapped(_ sender: Any) {
        color = .Green
        popGreen()
        startTurn()
    }
    
    @IBAction func redTapped(_ sender: Any) {
        color = .Red
        popRed()
        startTurn()
    }
    
    @IBAction func yellowTapped(_ sender: Any) {
        color = .Yellow
        popYellow()
        startTurn()
    }
    
    @IBAction func blueTapped(_ sender: Any) {
        color = .Blue
        popBlue()
        startTurn()
    }
    
    private func popGreen() {
        depopButton(button: redButton)
        depopButton(button: yellowButton)
        depopButton(button: blueButton)
        popButton(button: greenButton)
    }
    
    private func popRed() {
        depopButton(button: greenButton)
        depopButton(button: yellowButton)
        depopButton(button: blueButton)
        popButton(button: redButton)
    }
    
    private func popYellow() {
        depopButton(button: greenButton)
        depopButton(button: redButton)
        depopButton(button: blueButton)
        popButton(button: yellowButton)
    }
    
    private func popBlue() {
        depopButton(button: greenButton)
        depopButton(button: redButton)
        depopButton(button: yellowButton)
        popButton(button: blueButton)
    }
    
    private func popButton(button: UIButton) {
        button.layer.shadowColor = UIColor.white.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 3.0
        
        button.layer.borderWidth = 4.0
        button.layer.borderColor = UIColor.white.cgColor
    }
    
    private func depopButton(button: UIButton) {
        button.layer.shadowColor = .none
        button.layer.shadowOpacity = 0
        button.layer.shadowRadius = 0
        
        button.layer.borderWidth = 0
        button.layer.borderColor = .none
    }
    
    @objc private func depopAllButtons() {
        depopButton(button: greenButton)
        depopButton(button: redButton)
        depopButton(button: yellowButton)
        depopButton(button: blueButton)
    }
    
    private func enableButtons() {
        greenButton.isEnabled = true
        redButton.isEnabled = true
        yellowButton.isEnabled = true
        blueButton.isEnabled = true
    }
    
    private func disableButtons() {
        greenButton.isEnabled = false
        redButton.isEnabled = false
        yellowButton.isEnabled = false
        blueButton.isEnabled = false
    }
    
    private func setupUI() {
        disableButtons()
        
        self.view.backgroundColor = .black
        self.navigationController?.navigationBar.isHidden = true
        
        startButton.formatButton()
        startLabel.textColor = .black
        
        homeView.isHidden = false
        self.view.bringSubviewToFront(homeView)
        homeView.formatView()
        
        instructionLabel.formatLabel()
        hide(element: instructionLabel)
        scoreLabel.text = ""
        
        getHighScore()
    }
    
    private func hide(element: UILabel) {
        self.view.sendSubviewToBack(element)
        element.isHidden = true
    }
    
    private func show(element: UILabel) {
        self.view.bringSubviewToFront(element)
        element.isHidden = false
    }
    
    private func getHighScore(){
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Score")
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                highScoreLabel.text = "\(data.value(forKey: "highScore") ?? "0")"
            }
        } catch {
            print("Error: High Score not fetched.")
        }
    }
    
    private func saveHighScore() {
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Score", in: context)!
        
        let score = NSManagedObject(entity: entity, insertInto: context)
        score.setValue(userScore, forKeyPath: "highScore")
        
        do {
            try context.save()
        } catch {
            print("Error: Failed to save high score.")
        }
    }
}

extension UILabel {
    func formatLabel() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        self.backgroundColor = .white
        self.textColor = .black
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2.0
    }
}

extension UIView {
    func formatView() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        self.backgroundColor = .white
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2.0
    }
}

extension UIButton {
    func formatButton() {
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2.0
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 0.2
        self.setTitleColor(.black, for: .normal)
        self.layer.cornerRadius = 10
    }
}
