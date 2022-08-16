//
//  CollectionViewCell.swift
//  XONETestTask
//
//  Created by Павел Кулицкий on 28.11.21.
//

import Photos
import PhotosUI
import Foundation
import UIKit


class CollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    private var countOfPhoto: Int = 0
    
    private lazy var nameTextField: UITextField = {
        var textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.placeholder = "Название локации"
        textField.delegate = self
        return textField
    }()
    
    private let addButton: UIButton = {
        var button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .black
        button.tintColor = .white
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(addButtonTap), for: .touchUpInside)
        return button
    }()
    
    private let imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .red
        return imageView
    }()
    
    var arrayOfImage: [UIImageView] = []
    
    var countOfImages: Int = 0
    
    var delegate: CustomDelegateCell?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = #colorLiteral(red: 0.9293815494, green: 0.9537270665, blue: 0.9575147033, alpha: 1)
        setupView()
        setConstraints()
        
        DispatchQueue.main.async {
            self.setConstraintsForImageViews()
        }
        
        FirebaseManager.getLibraryName { name in
            self.nameTextField.text = name
        }
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
        setConstraints()
        setConstraintsForImageViews()
        
    }

    
    //MARK: - button action
    @objc private func addButtonTap() {
        delegate?.sharedPressed(cell: self)
    }
    
    //MARK: - Setup View
    private func setupView() {
        self.layer.cornerRadius = 20
        self.layer.borderWidth = 10
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: -5, height: 5)
    
        contentView.addSubview(nameTextField)
        contentView.addSubview(addButton)

    }
    
    //MARK: - Set Constraints
    private func setConstraints() {
        
        let layoutGuide = contentView.layoutMarginsGuide
        print(contentView.frame)

        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 10),
            nameTextField.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 10),
            nameTextField.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -50),
            nameTextField.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 10),
            addButton.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -10),
            addButton.heightAnchor.constraint(equalToConstant: 30),
            addButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        
    }
    
    
    private func setConstraintsForImageViews() {

        let height = (contentView.frame.width - 80) / 3
        let layoutGuide = contentView.layoutMarginsGuide
        var x:CGFloat = 0
        var y:CGFloat = 0
        var xCount = 0
        
        
        DispatchQueue.main.async {
            FirebaseManager.getImagesCount { count in
                
                guard count > 0 else { return }
                for _ in 0...count-1 {
    
                    let imageView1: UIImageView = {
                        var imageView1 = UIImageView()
                        imageView1.translatesAutoresizingMaskIntoConstraints = false
                        imageView1.contentMode = .scaleAspectFill
                        imageView1.clipsToBounds = true
                        imageView1.layer.cornerRadius = 10
                        return imageView1
                    }()
                    
                    self.arrayOfImage.append(imageView1)
                    self.contentView.addSubview(imageView1)
                    
                    NSLayoutConstraint.activate([
                        imageView1.topAnchor.constraint(equalTo: self.nameTextField.bottomAnchor, constant: 16+y),
                        imageView1.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 16+x),
                        imageView1.heightAnchor.constraint(equalToConstant: height),
                        imageView1.widthAnchor.constraint(equalToConstant: height)
                    ])
                    
                    x += height+16
                    xCount += 1
                    if xCount % 3 == 0 {
                        x = 0
                        y+=height+16
                    }
                }
            }
        }
    }

    
    //MARK: - TextField delegate funcs
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        setTextField(textField: textField, range: range, string: string)
        return false
    }
    
    private func setTextField(textField: UITextField, range: NSRange, string: String) {
      
            let text = (textField.text ?? "") + string
            var result: String!
            
            if range.length == 1 {
                let end = text.index(text.startIndex, offsetBy: text.count-1)
                result = String(text[text.startIndex..<end])
            } else {
                result = text
            }
        
            textField.text = result
            FirebaseManager.saveLibraryName(name: result as! String)
    }
}

