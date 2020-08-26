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
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let defaults = UserDefaults.standard
    
    //var countMoneySpent:[NSManagedObject]?
    var countMoneySpent:[Gastos]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        fetchSpent()
        
        self.tableView.reloadData()
    }
    
    func fetchSpent() {
        
        do{
            self.countMoneySpent = try context.fetch(Gastos.fetchRequest())
            refreshMoneySpent()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            
        }
    }
    
    func refreshMoneySpent() {
        
        if (countMoneySpent!.isEmpty == false){
            
            print(countMoneySpent!.count)
            let spent = self.defaults.double(forKey: "gastoTotal")
            moneySpent.text = self.formattedSpent(spent: spent)
            
        } else {
            
            print("Variável não inicializada")
            moneySpent.text = formattedSpent(spent: 0)
            
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
        
        // Adicona text fields e os configura
        alert.addTextField()
        alert.addTextField()
        alert.textFields![0].attributedPlaceholder = NSAttributedString(string: "100,50")
        alert.textFields![0].keyboardType = UIKeyboardType(rawValue: 8)!
        alert.textFields![1].placeholder = "Discrição"
        
        // Configurar as ações do botão
        /// Botão para cancelar
        let cancelButton = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        /// Botão para adicionar gastos
        let submitButton = UIAlertAction(title: "Adicionar", style: .default) { (submitButton) in
            
            // Pegar o texto do textfield e tratar valores para salvar no BD
            var spent:Double
            var description:String
            
            description = alert.textFields![1].text!
            print(description)
            
            let textField:Double? = self.treatTextfieldInput(input: alert.textFields![0].text!)
            if textField == nil {
                return
            }
            spent = textField!
            
            // Cria novo Gasto
            let newSpent = Gastos(context: self.context)
            newSpent.descricao = description
            newSpent.valor = spent
            
            // Salva valor no user default
            let currentDefaults = self.defaults.double(forKey: "gastoTotal")
            self.defaults.set(currentDefaults + spent, forKey: "gastoTotal")
            
            // Salvar os dados do novo objeto
            do{
                try self.context.save()
            } catch {
                
            }
            
            // Atualizar os dados da label
            self.refreshMoneySpent()
            
            // Atualizar os dados do array local
            self.fetchSpent()
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
            for i in 0..<self.countMoneySpent!.count {
                let gastoToRemove = self.countMoneySpent![i]
                self.context.delete(gastoToRemove)
            }
            
            // Zerar gasto total do user default
            self.defaults.set(0, forKey: "gastoTotal")
            
            // Salvar a alteração no BD
            do {
                try self.context.save()
            } catch {
                print("Erro ao tentar salva alteração no BD")
            }
            
            // Atualizar contéudo da label
            self.fetchSpent()
            self.refreshMoneySpent()
        }
        
        
        
        // Adicionar butões ao alerta
        alert.addAction(cancelButton)
        alert.addAction(resetButton)
        
        // Mostrar alerta
        self.present(alert, animated: true, completion: nil)
        
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.countMoneySpent?.count ?? 0

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        let spent = countMoneySpent![indexPath.row]
        
        cell.valueLabel.text = self.formattedSpent(spent: spent.valor)
        cell.descriptionLabel.text = spent.descricao
        //cell.backgroundColor = UIColor(red: 218, green: 254, blue: 208, alpha: 1)
        cell.isUserInteractionEnabled = false
        cell.contentView.backgroundColor = UIColor(red: 218, green: 254, blue: 208, alpha: 1)
        cell.backgroundColor = UIColor(red: 50, green: 50, blue: 50, alpha: 1)
        
        return cell
        
    }
    
    
}
