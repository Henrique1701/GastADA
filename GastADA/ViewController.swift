//
//  ViewController.swift
//  GastADA
//
//  Created by José Henrique Fernandes Silva on 18/08/20.
//  Copyright © 2020 José Henrique Fernandes Silva. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var moneySpent: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var countMoneySpent:[NSManagedObject]?
    //var countMoneySpent:[Gastos]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        fetchSpent()
    }
    
    func fetchSpent() {
        
        do{
            self.countMoneySpent = try context.fetch(Gastos.fetchRequest())
            refreshMoneySpent()
    
        } catch {
            
        }
    }
    
    func refreshMoneySpent() {
        
        if (countMoneySpent?.isEmpty == false){
            
            let spent = countMoneySpent?[0].value(forKey: "quantidade") as! Double
            moneySpent.text = self.formattedSpent(spent: spent)
            
        } else {
            
            print("Variável não inicializada")
            moneySpent.text = "0,00"
            
        }
    }
    
    func formattedSpent(spent:Double) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        
        return formatter.string(from: spent as NSNumber)!
    }
    
    func treatTextfieldInput(input:String) -> Double? {
        // Verifica se a entrada do text field do numeria
        var crudTextField = Double(input)
        if crudTextField == nil {
            // Verifica se o erro foi com a vírgula
            let newInput = input.replacingOccurrences(of: ",", with: ".")
            crudTextField = Double(newInput)
            if crudTextField == nil {
                
                // A entrada realmente não é númerica
                // Envia alerta avisando sobre o erro
                let alert = UIAlertController(title: "Erro", message: "Você tentou adicionar um gasto que não é do tipo: 0,00 ou 0.00", preferredStyle: .alert)

                let okButton = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                return nil
            }
            return Double(newInput)
        }
        return Double(input)
    }

    @IBAction func addTapped(_ sender: Any) {
        
        // Cria alerta
        let alert = UIAlertController(title: "Adicionar gastos", message: "Diz aí quanto foi o prejuizo agora :(", preferredStyle: .alert)
        alert.addTextField()
        alert.textFields![0].attributedPlaceholder = NSAttributedString(string: "100,50")
        alert.textFields![0].keyboardType = UIKeyboardType(rawValue: 8)!
        
        // Configurar as ações do botão
        /// Botão para cancelar
        let cancelButton = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        /// Botão para adicionar gastos
        let submitButton = UIAlertAction(title: "Adicionar", style: .default) { (submitButton) in
            
            // Pegar o texto do textfield e tratar valores para salvar no BD
            var spent:Double
            let textField:Double? = self.treatTextfieldInput(input: alert.textFields![0].text!)
            if textField == nil {
                return
            }
            if self.countMoneySpent?.isEmpty == true {
                spent = textField!
            } else {
                spent = self.countMoneySpent?[0].value(forKey: "quantidade") as! Double + textField!
            }
            
            // Atualizar valores no banco de dados
            self.countMoneySpent?[0].setValue(spent, forKey: "quantidade")
            
            // Salvar os dados do novo objeto
            do{
                try self.context.save()
            } catch {
                
            }
            
            // Atualizar os dados da label
            self.moneySpent.text = self.formattedSpent(spent: spent)
        }
        
        // Adicionar botão
        alert.addAction(cancelButton)
        alert.addAction(submitButton)
        
        // Mostrar alerta
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func resetTapped(_ sender: Any) {
        
        // Cirar alerta
        let alert = UIAlertController(title: "Resetar gastos", message: "Tem certeza que você quer resetar os gastos?\n Isso fará com que os gastos fiquem zerados", preferredStyle: .alert)
        
        
        // Configurar botões de resetar e cancelar
        /// Botão para cancelar
        let cancelButton = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        /// Botão para resetar
        let resetButton = UIAlertAction(title: "Resetar", style: .default) { (action) in
            
            // Zerar os gastos que estão no BD
            self.countMoneySpent?[0].setValue(0, forKey: "quantidade")
            
            // Salvar a alteração no BD
            do {
                try self.context.save()
            } catch {
                print("Erro ao tentar salva alteração no BD")
            }
            
            // Atualizar contéudo da label
            self.refreshMoneySpent()
        }
        
        
        
        // Adicionar butões ao alerta
        alert.addAction(cancelButton)
        alert.addAction(resetButton)
        
        // Mostrar alerta
        self.present(alert, animated: true, completion: nil)
        
    }
    
}

