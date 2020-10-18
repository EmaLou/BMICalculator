//
//  ViewController.swift
//  BMICalculator
//
//  Created by Jia Lou on 17/10/20.
//

import UIKit
import Combine

class ViewController: UIViewController {

  @Published var height: Double?
  @Published var weight: Double?

  @IBOutlet weak var heightTextField: UITextField!
  @IBOutlet weak var weightTextField: UITextField!
  @IBOutlet weak var resultLabel: UILabel!

  private let notificationCenter = NotificationCenter.default
  private var subscribers = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()
    observeTextFields()
    // Do any additional setup after loading the view.
  }
  private func observeTextFields(){
    notificationCenter.publisher(for: UITextField.textDidChangeNotification, object: heightTextField).sink(receiveValue: {
      guard let textField = $0.object as? UITextField,
            let text = textField.text, !text.isEmpty,
            let height = Double(text)
      else {
        self.height = nil
        return }
      self.height = height
    }).store(in: &subscribers)

    notificationCenter.publisher(for: UITextField.textDidChangeNotification, object: weightTextField).sink(receiveValue: {
      guard let textField = $0.object as? UITextField,
            let text = textField.text, !text.isEmpty,
            let weight = Double(text)
      else {
        self.weight = nil
        return
      }
      self.weight = weight
    }).store(in: &subscribers)

    Publishers.CombineLatest($height, $weight).sink { [weak self] (height, weight) in
      guard let self = self else { return }
      guard let height = height,
            let weight = weight else {
        self.resultLabel.text = "Input weight and height"
        return
      }
      let BMI: String = self.calculateBMI(height: height, weight: weight).toString() ?? "unable to calculate"
      self.resultLabel.text = "BMI: \(BMI)"
    }.store(in: &subscribers)
  }

  private func calculateBMI(height: Double, weight: Double) -> Double {
    return (weight / (height * height)).rounded()
  }
}

extension Double {
  func toString() -> String? {
    return String(describing: self)
  }
}


