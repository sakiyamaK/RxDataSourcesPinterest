//
//  RxCollectionViewCell.swift
//  RxDataSourcesPinterest
//
//  Created by sakiyamaK on 2019/12/08.
//  Copyright © 2019 sakiyamaK. All rights reserved.
//

import UIKit
import Kingfisher

class RxCollectionViewCell: UICollectionViewCell {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var textLabel: UILabel!
  @IBOutlet weak var imageAspectRatioConst: NSLayoutConstraint!

  func configCell(text:String, urlStr:String){

    self.imageView.isHidden = true
    self.textLabel.isHidden = true

    if let url = URL.init(string: urlStr){
      self.imageView.isHidden = false
      self.imageView.kf.setImage(with: url)
    }

    if text.count != 0{
      self.textLabel.isHidden = false
      self.textLabel.text = text
    }

    self.setNeedsLayout()
    self.layoutIfNeeded()
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    self.configCell(text: "", urlStr: "")
  }

  //セルの高さを取得する
  func height(cellWidth: CGFloat) -> CGFloat {

    let ivHeight = self.imageView.isHidden ? 0 : cellWidth / imageAspectRatioConst.multiplier

    self.textLabel.sizeToFit()
    let lblHeight = self.textLabel.isHidden ? 0 :  self.textLabel.frame.height

    //ラベルの高さ計算こっちの方が速い？？
    //    let text = self.textLabel.text ?? ""
    //    let lblHeight = NSString(string: text).boundingRect(
    //      with: CGSize(width: cellWidth, height: CGFloat(MAXFLOAT)),
    //      options: .usesLineFragmentOrigin,
    //      attributes: [NSAttributedString.Key.font: self.textLabel.font], context: nil).height

    return ceil(ivHeight + lblHeight)
  }
}
