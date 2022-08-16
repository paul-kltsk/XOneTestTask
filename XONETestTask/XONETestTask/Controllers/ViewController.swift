//
//  ViewController.swift
//  XONETestTask
//
//  Created by Павел Кулицкий on 28.11.21.
//

import UIKit
import Photos
import PhotosUI
import SwiftUI

//MARK: - Protocol CustomDelegateCell
protocol CustomDelegateCell: ViewController {
    func sharedPressed(cell: CollectionViewCell)
    func updateImage(image: UIImage, cell: CollectionViewCell, i: Int)
}

class ViewController: UIViewController, PHPickerViewControllerDelegate, CustomDelegateCell {
    
    var heightCell: Int = 65
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = #colorLiteral(red: 0.9803065658, green: 0.9804469943, blue: 0.9802758098, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsHorizontalScrollIndicator = false
        view.allowsMultipleSelection = true
        view.alwaysBounceVertical = true
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    private let imageView: UIImageView = {
        var imageView = UIImageView(image: UIImage(named: "xone"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var image: [UIImage] = []
    
    private var currentCountOfImages: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setConstraints()
        
        FirebaseManager.getImagesCount { count in
            self.currentCountOfImages = count
        }
        FirebaseManager.getImagesCount { i in
            self.heightCell = i % 3 == 0 ?  i/3 * Int(self.collectionView.contentSize.width)/3 :  (i/3+1) * Int(self.collectionView.contentSize.width)/3
            self.heightCell+=65
            self.collectionView.reloadData()
        }
        
    }
    
    //MARK: - Setup View
    private func setupView(){
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(imageView)
        view.addSubview(collectionView)
    }

    
    func updateImage(image: UIImage, cell: CollectionViewCell, i: Int) {
        cell.arrayOfImage[i].image = image
    }
    
    func sharedPressed(cell: CollectionViewCell) {
        var config = PHPickerConfiguration()
//        FirebaseManager.getImagesCount { count in
//            config.selectionLimit = 24 - count
//        }
        config.selectionLimit = 24
        config.filter = .images
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true, completion: nil)
        let group = DispatchGroup()
        var i = currentCountOfImages+1
        results.forEach { result in
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                print("1231231231231")
                defer {
                    group.leave()
                }
                guard let image = reading as? UIImage else { print("Reading error"); return }
                FirebaseManager.uploadImages(image: image, name: String(i))
                self.image.append(image)
                i+=1
            }
        }
        
        group.notify(queue: .main) {
            print("COUNT: \(self.image.count)")
            DispatchQueue.main.async {
                FirebaseManager.getImagesCount { count in
                    FirebaseManager.saveCountOfImages(count: count+self.image.count)
                    self.collectionView.reloadData()
                    print("RELOAD DATA")
                }
            }
        }
    }
    
    //MARK: - Set Constraints
    private func setConstraints() {
        
        print(view.frame)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: view.frame.height * 1/6)
        ])
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

//MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        cell.delegate = self
        
        FirebaseManager.getImagesCount { count in
            guard count > 0 else { return }
            for int in 0...count-1 {
                DispatchQueue.main.async {
                    FirebaseManager.downloadImages(i: int) { image in
                        cell.arrayOfImage[int-1].image = image
                }
                }
            }
        }
        
        return cell
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.bounds.width, height: CGFloat(self.heightCell))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        24
    }
}
