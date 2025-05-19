//
//  ViewController.swift
//  Exchange Rate
//
//  Created by Trakya7 on 10.05.2025.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        exchangeRate?.data.keys.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var list:[String] = []  //[String] ((exchangeRate?.data.keys)!)
        var list2:[Curr] = [] //[Curr] ((exchangeRate?.data.values)!)
        let sorted = exchangeRate!.data.sorted {$0.key < $1.key}
        sorted.forEach {
            list.append($0.key)
            list2.append($0.value)
        }

        let sourceValue = list2.map { ($0.value / (list2.first{ $0.code == sourceCurrency!.code }!.value )) }
        cell.textLabel?.text = sourceCurrency!.code + " = " + list[indexPath.item] + " " + String(format: "%.2f", sourceValue[indexPath.item])
        return cell
    }
    
    var currencies: [Currency] = []
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row].code
    }
    
    
    @IBOutlet var containerBox: UIView?
    @IBOutlet var fromContainer: UIView?
    @IBOutlet var toContainer: UIView?
    @IBOutlet var switchButton: UIButton?
    @IBOutlet var currencyPicker: UIPickerView?
    @IBOutlet var sourceButton: UIButton?
    @IBOutlet var targetButton: UIButton?
    @IBOutlet var sourceTextField: UITextField?
    @IBOutlet var targetTextField: UITextField?
    @IBOutlet var sourceLabel: UILabel?
    @IBOutlet var targetLabel: UILabel?
    @IBOutlet var table: UITableView?
    var isSourceButton = true
    var currentButton: UIButton?
    var sourceCurrency: Currency?
    var targetCurrency: Currency?
    var container: UIView?
    var exchangeRate: ExhangeRateResponse?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerBox?.layer.borderColor = UIColor.red.cgColor
        containerBox?.layer.borderWidth = 1
        containerBox?.layer.cornerRadius = 10
        fromContainer?.layer.borderColor = UIColor.lightGray.cgColor
        fromContainer?.layer.borderWidth = 1
        fromContainer?.layer.cornerRadius = 10
        toContainer?.layer.borderColor = UIColor.lightGray.cgColor
        toContainer?.layer.borderWidth = 1
        toContainer?.layer.cornerRadius = 10
        currencyPicker?.dataSource = self
        currencyPicker?.delegate = self

        
        let tapGesture = UITapGestureRecognizer(target: self,action:#selector(dismissPicker))
        view.addGestureRecognizer(tapGesture)
        ExchangeRate.getExchangeRates { erResponse in
            self.exchangeRate = erResponse
            self.createCurrenciesFromExchangeRate()
            self.sourceCurrency = self.currencies.first {$0.code == "USD"}
            self.targetCurrency = self.currencies.first {$0.code == "TRY"}
            self.updateSourceButton()
            self.updateTargetButton()
            self.table?.delegate = self
            self.table?.dataSource = self
            self.table?.reloadData()
        }
        sourceTextField?.delegate = self
        //setRectangle()
        // Do any additional setup after loading the view.
    }
    
    func createCurrenciesFromExchangeRate() {
        let sortedData = exchangeRate!.data.sorted { $0.key < $1.key }
        sortedData.forEach {
            let number = $0.value.value

            self.currencies.append(Currency(code: $0.key, amount: number))
            self.currencyPicker?.dataSource = self
        }

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if isSourceButton {
            let currency = currencies.first { currencies[row].code==$0.code }
            let exrate = getExchangeRate(source: currency!.code, target: targetCurrency!.code)
            currency?.amount = Double(String(sourceTextField!.text!)) ?? 0
            sourceCurrency = currency
            targetCurrency = sourceCurrency?.convertTo(targetCode: targetCurrency!.code, exchangeRate: exrate)
            updateSourceButton()
            updateTargetButton()
        } else {
            let exrate = getExchangeRate(source: sourceCurrency!.code, target: currencies[row].code)
            targetCurrency = sourceCurrency?.convertTo(targetCode: currencies[row].code, exchangeRate: exrate)
            updateSourceButton()
            updateTargetButton()
        }
        
        
    }
    
    @objc func dismissPicker() {
        UIView.animate(withDuration: 0.5) {
            self.currencyPicker!.frame.origin.y = self.view.frame.height
        }
    }

    func setSourceCurrency(code: String) {
        let sourceCurr = currencies.first {
            $0.code == code
        }
        self.currencies = self.currencies.map {
            let exrate = getExchangeRate(source: sourceCurr!.code, target: $0.code)
            return sourceCurr!.convertTo(targetCode: $0.code, exchangeRate: exrate)//Currency(code: $0.code, amount: roundedNumber)
        }
    }
    
    func updateSourceButton() {
        self.sourceButton!.setTitle(self.sourceCurrency?.code, for: .normal)
        self.sourceTextField!.text = String(format: "%.2f", self.sourceCurrency!.amount)
        let exrate = getExchangeRate(source: sourceCurrency!.code, target: targetCurrency!.code)
        sourceLabel?.text = "1 \(sourceCurrency!.code) = \(String(format: "%.2f", exrate)) \(targetCurrency!.code)"
        table?.reloadData()
    }
    
    func updateTargetButton() {
        self.targetButton!.setTitle(self.targetCurrency?.code, for: .normal)
        self.targetTextField!.text = String(format: "%.2f", self.targetCurrency!.amount)
        let exrate = getExchangeRate(source: targetCurrency!.code, target: sourceCurrency!.code)
        targetLabel?.text = "1 \(targetCurrency!.code) = \(String(format: "%.2f", exrate)) \(sourceCurrency!.code)"
    }
    
    @IBAction func setSourceButtonTrue() {
        UIView.animate(withDuration: 0.5) {
            self.currencyPicker!.frame.origin.y = self.view.frame.height - self.currencyPicker!.frame.height
        }
        self.isSourceButton = true
    }
    
    @IBAction func setSourceButtonFalse() {
        UIView.animate(withDuration: 0.5) {
            self.currencyPicker!.frame.origin.y = self.view.frame.height - self.currencyPicker!.frame.height
        }
        self.isSourceButton = false
    }
    
    @IBAction func switchSources() {
        var c = sourceCurrency
        sourceCurrency = targetCurrency
        targetCurrency = c
        
        updateTargetButton()
        updateSourceButton()
    }
    
    @IBAction func textFieldDidChangeSelection(_ textField: UITextField) {
        var exrate = getExchangeRate(source: sourceCurrency!.code, target: targetCurrency!.code)
        sourceCurrency?.amount = Double(String(textField.text!)) ?? 0
        targetCurrency = sourceCurrency?.convertTo(targetCode: targetCurrency!.code, exchangeRate: exrate)
        updateTargetButton()
    
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        let existingText = textField.text ?? ""

        // Ensure only one decimal point is allowed
        if string == "." && existingText.contains(".") {
            return false
        }

        return allowedCharacters.isSuperset(of: CharacterSet(charactersIn: string))
    }
    
    func getExchangeRate(source: String, target: String) -> Double {
        var source = exchangeRate?.data.first {
            $0.key == source
        }
        var target = exchangeRate?.data.first {
            $0.key == target
        }
        "20 usd = 40 tl"
        return target!.value.value / source!.value.value
    }
}

