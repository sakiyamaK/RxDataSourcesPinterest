//
//  PinterestLayout.swift
//  RxDataSourcesPinterest
//
//  Created by sakiyamaK on 2019/12/08.
//  Copyright © 2019 sakiyamaK. All rights reserved.
//

import UIKit

//MARK: - PinterestLayoutDelegate
protocol PinterestLayoutDelegate {
  func cellHeight(collectionView: UICollectionView,
                  indexPath: IndexPath,
                  cellWidth: CGFloat) -> CGFloat
}

//MARK: - PinterestLayoutAttributes
class PinterestLayoutAttributes: UICollectionViewLayoutAttributes {

  var cellHeight:CGFloat = 0.0

  override func copy(with zone: NSZone?) -> Any {

    let copy = super.copy(with: zone) as! PinterestLayoutAttributes
    copy.cellHeight = cellHeight
    return copy
  }

  override func isEqual(_ object: Any?) -> Bool {
    guard let attributes = object as? PinterestLayoutAttributes,
      attributes.cellHeight == cellHeight else{return false}
    return super.isEqual(object)
  }
}

//MARK: - PinterestLayout
class PinterestLayout: UICollectionViewLayout {

  var delegate: PinterestLayoutDelegate?
  var cache = [(attributes:PinterestLayoutAttributes, height:CGFloat)]()

  let NUMBER_OF_COLUMN = 3    //カラム数
  let CELL_PADDING:CGFloat = 8.0 //セルのパディング

  var contentHeight:CGFloat = 0.0
  var contentWidth: CGFloat {
    let insets = collectionView!.contentInset
    return collectionView!.bounds.width - (insets.left + insets.right)
  }

  //１列分の幅
  var columnWidth:CGFloat{return contentWidth / CGFloat(NUMBER_OF_COLUMN)}
  //セルの幅
  var cellWidth:CGFloat{return columnWidth - CELL_PADDING * 2}


  override class var layoutAttributesClass : AnyClass {
    return PinterestLayoutAttributes.self
  }

  //MARK:- Layout LifeCycle
  //1. レイアウトの事前計算を行う
  override func prepare() {
    super.prepare()

    guard
      let collectionView = self.collectionView,
      collectionView.numberOfSections > 0,
      let delegate = self.delegate
      else{ return }

    //セルが消えていたらキャッシュを削除する
    self.removeCacheIfNeeded()

    //各セルのx,y座標を初期化
    var (xOffsets, yOffsets) = self.initXYOffset()

    //列番号のindexの初期化
    var columnIndex = 0

    for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
      //ループの次のindexに行く前に情報を更新させるメソッド
      func loopNext(height:CGFloat){
        //各列のy座標のoffsetを更新
        yOffsets[columnIndex] = yOffsets[columnIndex] + height
        //列番号を更新
        columnIndex = (columnIndex + 1) % NUMBER_OF_COLUMN
      }

      guard item >= cache.count else{
        loopNext(height: cache[item].height)
        continue
      }

      let indexPath = IndexPath(item: item, section: 0)

      let cellHeight = delegate.cellHeight(collectionView: collectionView, indexPath: indexPath, cellWidth: self.cellWidth)

      let rowHeight = 2*CELL_PADDING + cellHeight

      let frame = CGRect(x: xOffsets[columnIndex],
                         y: yOffsets[columnIndex],
                         width: self.columnWidth,
                         height: rowHeight)

      do{//attributesを設定してキャッシュに登録
        let attributes = PinterestLayoutAttributes(forCellWith: indexPath)
        attributes.cellHeight = cellHeight
        attributes.frame = frame.insetBy(dx: self.CELL_PADDING, dy: self.CELL_PADDING)
        cache.append((attributes, rowHeight))
      }

      do{//次のループのために情報を更新する
        //最終的なコンテンツの高さ
        contentHeight = max(contentHeight, frame.maxY)
        loopNext(height: rowHeight)
      }
    }
  }

  //2. コンテンツのサイズを返す
  override var collectionViewContentSize : CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }

  //3. 表示する要素のリストを返す
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return cache.filter {$0.attributes.frame.intersects(rect)}.map{$0.attributes}
  }
}

//MARK: - private
private extension PinterestLayout{

  func removeCacheIfNeeded(){
    guard
      let collectionView = self.collectionView,
      collectionView.numberOfSections > 0
    else{
      cache.removeAll()
      return
    }

    let numberOfItems = collectionView.numberOfItems(inSection: 0)
    if cache.count - numberOfItems > 0 {
      for _ in 0 ..< cache.count - numberOfItems{
        cache.removeLast()
      }
    }
  }

  func initXYOffset()->([CGFloat], [CGFloat]){
    //x座標のオフセットの初期化
    var xOffsets = [CGFloat]()
    for column in 0 ..< NUMBER_OF_COLUMN {
      xOffsets.append(CGFloat(column) * columnWidth)
    }
    //y座標のオフセットの初期化
    let yOffsets = [CGFloat](repeating: 0, count: NUMBER_OF_COLUMN)

    return (xOffsets, yOffsets)
  }
}

