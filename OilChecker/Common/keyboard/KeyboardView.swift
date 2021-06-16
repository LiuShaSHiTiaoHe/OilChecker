//
//  KeyboardView.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/6/15.
//

import UIKit

protocol KeyboardViewDelegate: NSObjectProtocol {
    func keyboardViewDeleteText()
    func keyboardEnterText(_ text: String)
}

class KeyboardView: UIView {

    let dataSource: Array<String> = ["0","1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B","C", "D","E", "F"]
    weak var delegate: KeyboardViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.addSubview(digitsCollectionView)
        self.addSubview(deleteButton)
        
        digitsCollectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-DigtesKeyboardDeleteButtonWidth)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.left.equalTo(digitsCollectionView.snp.right)
        }
    }
    
    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
//        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.itemSize = CGSize(width: (kScreenWidth - DigtesKeyboardDeleteButtonWidth - 3)/4, height: (DigtesKeyboardHeight - 3)/4)
        
        return layout
    }()
    
    lazy var digitsCollectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = kBackgroundColor
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DigitsCell.self, forCellWithReuseIdentifier: "DigitsCell")
        return collectionView
    }()
    
    lazy var deleteButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "btn_delete"), for: .normal)
        btn.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        return btn
    }()
    
    @objc
    func deleteButtonAction() {
        delegate?.keyboardViewDeleteText()
    }

}

extension KeyboardView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DigitsCell", for: indexPath) as! DigitsCell
        let value = dataSource[indexPath.row]
        cell.updateCellValue(value)
        cell.backgroundColor = kWhiteColor
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let value = dataSource[indexPath.row]
        delegate?.keyboardEnterText(value)
        logger.info("\(value)")
    }
    
}
