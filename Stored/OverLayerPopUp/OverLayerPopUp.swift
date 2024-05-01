//
//  OverLayerPopUp.swift
//  Stored
//
//  Created by Archit Malik on 01/05/24.
//

import UIKit

class OverLayerPopUp: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var popUpView: UIView!
    
    
    init(){
        super.init(nibName: "OverLayerPopUp", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView();
        
    }
    
    func configView() {
        self.view.backgroundColor = .clear
        self.backView.backgroundColor = .black.withAlphaComponent(0.6)
        self.backView.alpha = 0
        self.popUpView.alpha = 0
        self.popUpView.layer.cornerRadius = 10
    }
    
    func appear (sender: UIViewController) {
        sender.present(self, animated: false) {
            self.show()
        }
    }
    
    private func show() {
        UIView.animate(withDuration: 0.3, delay: 0.1) {
            self.backView.alpha = 1
            self.popUpView.alpha = 1
        }
        }
        
    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut) {
            self.backView.alpha = 0
            self.popUpView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
            self.removeFromParent()
        }
    }
    @IBAction func okBtn(_ sender: UIButton) {
        hide()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
