//
//  TutorialView.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/09/10.
//

import UIKit

struct TutorialItem {
    var title = ""
    var subtitle = ""
    var image: UIImage?
}

class TutorialView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var tapLabel: UILabel!
    @IBOutlet var itemStackViews: [UIStackView]!
    @IBOutlet var itemImageViews: [UIImageView]!
    @IBOutlet var itemTitleLabels: [UILabel]!
    @IBOutlet var itemSubtitleLabels: [UILabel]!
    
    var tutorialTitle = ""
    var tutorialSubtitle = ""
    var tutorialItems = [TutorialItem]()
    
    required init(frame: CGRect, type: String) {
        super.init(frame: frame)
        
        if type == "approach" {
            tutorialTitle = "カードの操作"
            tutorialSubtitle = "次のジェスチャーでカードを\nコントロールできます。"
            tutorialItems = [
                TutorialItem(title: "Good", subtitle: "右スワイプ", image: UIImage(named: "SwipeRight")),
                TutorialItem(title: "Skip", subtitle: "左スワイプ", image: UIImage(named: "SwipeLeft")),
                TutorialItem(title: "次の画像を表示する", subtitle: "画像右側をタップ", image: UIImage(named: "TapRight")),
                TutorialItem(title: "前の画像を表示する", subtitle: "画像左側をタップ", image: UIImage(named: "TapLeft")),
            ]
            
        } else if type == "approachMatch" {
            tutorialTitle = "カードの操作"
            tutorialSubtitle = "次のジェスチャーでカードを\nコントロールできます。"
            tutorialItems = [
                TutorialItem(title: "Match", subtitle: "右スワイプ", image: UIImage(named: "SwipeRight")),
                TutorialItem(title: "NG", subtitle: "左スワイプ", image: UIImage(named: "SwipeLeft")),
                TutorialItem(title: "次の画像を表示する", subtitle: "画像右側をタップ", image: UIImage(named: "TapRight")),
                TutorialItem(title: "前の画像を表示する", subtitle: "画像左側をタップ", image: UIImage(named: "TapLeft")),
                TutorialItem(title: "通報する", subtitle: "右上の通報ボタンをタップ", image: UIImage(named: "Tap")),
            ]
            
        } else if type == "message" {
            tutorialTitle = "メッセージ機能について"
            tutorialSubtitle = "\nマッチしたユーザにメッセージを\n送信することができます。\n\n※メッセージ送信後\n送信済みチェックアイコンが表示されます。\n\n※一度削除したルームは\n復元することができません。\n\n※メッセージ関連の機能を利用するためには\n本人確認が必要です。"
            tutorialItems = [
                TutorialItem(title: "ルームを削除", subtitle: "ルームを左スワイプして削除をタップ", image: UIImage(named: "TapLeft")),
            ]
            
        } else if type == "invitation" {
            tutorialTitle = "お誘い機能について"
            tutorialSubtitle = "\n気に入ったお誘いに「興味あり」を送って、\nお誘いマッチングすることができます。\n\nマッチング後はメッセージにて\n日程などを相談することができます。\n\n※お誘い関連の機能を利用するためには\n本人確認が必要です。"
            tutorialItems = [
                TutorialItem(title: "興味ありを送信", subtitle: "「興味あり」ボタンをタップ", image: UIImage(named: "Tap")),
                TutorialItem(title: "お誘い作成", subtitle: "右下の「募集する」ボタンをタップ", image: UIImage(named: "Tap"))
            ]
            
        } else if type == "board" {
            tutorialTitle = "掲示板機能について"
            tutorialSubtitle = "\n気になった投稿に「足あと」を送ることで、\n相手に興味があることを伝えられます。\n\n※掲示板機能を利用するためには\n本人確認が必要です。"
            tutorialItems = [
                TutorialItem(title: "足あとを送信", subtitle: "「足あと」ボタンをタップ", image: UIImage(named: "Tap")),
                TutorialItem(title: "投稿を作成", subtitle: "右下の「+」ボタンをタップ", image: UIImage(named: "Tap"))
            ]
            
        }  else if type == "phone" {
            tutorialTitle = "通話機能について"
            tutorialSubtitle = "\nメッセージを「5往復」以上やりとりした時のみ、\n通話することができます。\n\n通話時間に制限はありませんので、\n気の済むまで通話をお楽しみください！！🤗"
            tutorialItems = [
                TutorialItem(title: "マイクのON/OFF", subtitle: "「マイク」ボタンをタップ", image: UIImage(systemName: "mic.fill")),
                TutorialItem(title: "通話を切る", subtitle: "「通話OFF」ボタンをタップ", image: UIImage(systemName: "phone.down.fill")),
                TutorialItem(title: "スピーカーのON/OFF", subtitle: "「スピーカー」ボタンをタップ", image: UIImage(systemName: "speaker.1.fill"))
            ]
        }
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setupNIB()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
        
        titleLabel.text = tutorialTitle
        subtitleLabel.text = tutorialSubtitle
        
        alpha = 0
        titleLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(translationX: 50, y: 0)
        subtitleLabel.alpha = 0
        subtitleLabel.transform = CGAffineTransform(translationX: 50, y: 0)
        tapLabel.alpha = 0
        
        itemStackViews.forEach {
            $0.transform = CGAffineTransform(translationX: 50, y: 0)
            $0.isHidden = true
            $0.alpha = 0
        }
        
        for i in 0..<tutorialItems.count {
            itemStackViews[i].isHidden = false
        }

        UIView.animate(withDuration: 0.3) { [self] in
            alpha = 1
        }
        
        let delayForTitle: TimeInterval = 0.3
        UIView.animate(withDuration: 0.3, delay: delayForTitle, options: .curveEaseOut, animations: { [self] in
            titleLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            titleLabel.alpha = 1
            subtitleLabel.alpha = 1
        }, completion: { [self] _ in
            for i in 0..<tutorialItems.count {
                itemStackViews[i].isHidden = false
                itemImageViews[i].image = tutorialItems[i].image
                itemTitleLabels[i].text = tutorialItems[i].title
                itemSubtitleLabels[i].text = tutorialItems[i].subtitle
                
                let delay: TimeInterval = Double(i) * 0.2
                UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseOut, animations: { [self] in
                    itemStackViews[i].transform = CGAffineTransform(translationX: 0, y: 0)
                    itemStackViews[i].alpha = 1
                })
            }
        })
        
        let delayForItems = Double(tutorialItems.count) * 0.2
        UIView.animate(withDuration: 0.3, delay: delayForItems + 1.1, options: .curveEaseOut, animations: { [self] in
            tapLabel.alpha = 1
        })
    }
    
    @objc func close() {
        UIView.animate(withDuration: 0.3) { [self] in
            alpha = 0
        } completion: { [self] _ in
            isHidden = true
            NotificationCenter.default.post(
                name: Notification.Name(NotificationName.ClosedTutorial.rawValue),
                object: self
            )
        }
    }
}

