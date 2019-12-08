//
//  RxCollectionViewModel.swift
//  RxDataSourcesPinterest
//
//  Created by sakiyamaK on 2019/12/08.
//  Copyright © 2019 sakiyamaK. All rights reserved.
//

import RxCocoa
import RxSwift
import RxDataSources

//テストデータ
let TEST_DATA =
    (urlStrs:["https://sharelifestyle.info/wp-content/uploads/2018/01/Unknown-5.jpeg",
              "https://i1.wp.com/lovemimi-channel.com/wp-content/uploads/2018/09/cc015d525d521f5b6e69f7e6a41d379b.png"]
        ,names: ["","あいうえお\nかきくけこさしすせそ\nたちつてとなにぬねの\nはひふへほ", "まみむめも\nやゆよ\nらりるれろ\nわ\nを\nん\nAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBCCCCCCCCCCCCCCCCDDDDDDDD"])

//もとのデータ構造
struct SampleData {
    let id = UUID().uuidString
    let name: String
    let urlStr: String
}

//RxDatasourcesを利用するために必要なextension
extension SampleData: IdentifiableType, Equatable{
    var identity: String {return id}
    static func == (lhs: SampleData, rhs: SampleData) -> Bool {
        return lhs.identity == rhs.identity
    }
}

protocol RxDataSourcesModelProtocol {
    //RxDataSourcesで使うデータ
    associatedtype Data:IdentifiableType,Equatable
    //RxDatasourcesで使うセクションのモデル
    typealias SectionModel = AnimatableSectionModel<Int, Data>
    //
    var dataObservable: Observable<[SectionModel]>{get}
}

class RxCollectionViewModel:RxDataSourcesModelProtocol {

    typealias Data = SampleData
    typealias SectionModel = AnimatableSectionModel<Int, Data>

    var dataObservable: Observable<[SectionModel]> {
        return dataRelay.asObservable()
    }

    private let dataRelay = BehaviorRelay<[SectionModel]>(value: [])

    private func fetch(shouldRefresh: Bool = false, type: Data) {
        var preItems = dataRelay.value.first?.items ?? []
        preItems.append(type)
        let items = shouldRefresh ? [type] : preItems
        let section = 0
        let sectionModel = SectionModel(model: section, items: items)
        dataRelay.accept([sectionModel])
    }

    func add() {
        let name = TEST_DATA.names.randomElement()!
        let urlStr = TEST_DATA.urlStrs.randomElement()!
        let data = Data(name: name, urlStr: urlStr)
        fetch(type: data)
    }

    func remove(item:Data){
        var preItems = dataRelay.value.first?.items ?? []
        guard let index = preItems.firstIndex(of: item) else { return }
        preItems.remove(at: index)
        let section = 0
        let sectionModel = SectionModel(model: section, items: preItems)
        dataRelay.accept([sectionModel])
    }

    func remove(){
        var preItems = dataRelay.value.first?.items ?? []
        guard preItems.count > 0 else {return}
        preItems.removeLast()
        let section = 0
        let sectionModel = SectionModel(model: section, items: preItems)
        dataRelay.accept([sectionModel])
    }
}
