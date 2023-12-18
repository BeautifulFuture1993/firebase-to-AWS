//
//  HobbyTagListView.swift
//  Tauch
//
//  Created by Apple on 2023/04/30.
//

import UIKit
import TagListView

final class HobbyTagListView: UIView {

    @IBOutlet weak var hobbyCategory: UILabel!
    @IBOutlet weak var hobbyTagList: TagListView!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        nibInit()
    }
    
    init(category: String, tagList: [String], selectedTagList: [String]) {
        self.init()
        
        hobbyTagList.textFont = .boldSystemFont(ofSize: 20)
        
        hobbyCategory.text = category
        setTagList(tagList: tagList, selectedTagList: selectedTagList)
    }
    
    deinit {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // カスタムビューの初期化
    private func nibInit() {
        let nib = UINib(nibName: "HobbyTagListView", bundle: nil)
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            view.frame = self.bounds
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            self.addSubview(view)
        }
    }
    
    // タグリスト設定
    private func setTagList(tagList: [String], selectedTagList: [String]) {
        hobbyTagList.removeAllTags()
        let tagViews = hobbyTagList.addTags(tagList)
        tagViews.forEach { tagView in
            if let currentValue = tagView.currentTitle {
                if selectedTagList.firstIndex(of: currentValue) != nil {
                    tagView.textColor = .white
                    tagView.tagBackgroundColor = .accentColor
                }
            }
        }
    }
}
