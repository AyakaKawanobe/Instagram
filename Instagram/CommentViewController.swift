//
//  CommentViewController.swift
//  Instagram
//
//  Created by aykawano on 2021/01/14.
//  Copyright © 2021 ayaka. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class CommentViewController: UIViewController {

    var id : String!
    var caption: String = ""
    var name: String = ""
    
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //キャプションをセット
        captionLabel.text = "\(name): \(caption)"
        
        //コメント入力がない限り投稿ボタンは非活性
        commentButton.isEnabled = false
        
        // ツールバー生成 サイズはsizeToFitメソッドで自動で調整される。
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        //サイズの自動調整
        toolBar.sizeToFit()
        // ボタンを右側に寄せる余白
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        // 完了ボタン
        let commitButton = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(commitButtonTapped))
        // BarButtonItemの配置
        toolBar.items = [spacer, commitButton]
        // textViewのキーボードにツールバーを設定
        commentTextField.inputAccessoryView = toolBar
        
    }
    
    //キーボードを閉じる処理
    @objc func commitButtonTapped() {
        self.view.endEditing(true)
    }
    
    //コメント投稿ボタンの処理
    @IBAction func handleCommentText(_ sender: Any) {
        //空文字の場合はcommentButtonを非活性に
        if commentTextField.text == "" {
            commentButton.isEnabled = false
            return
        }
        
        //コメントが入力されていたらcommentButtonを活性化
        commentButton.isEnabled = true
    }
    
    @IBAction func commentButton(_ sender: Any) {
        //HUDで投稿処理中の表示を開始
        SVProgressHUD.show()
        
        //コメントデータの保存場所を定義する
        let postRef = Firestore.firestore().collection(Const.PostPath).document(id)
        
        //FireStoreに投稿データを保存する
        //コメントを追加する更新データを作成
        let name = Auth.auth().currentUser?.displayName
        
        var updateComment: FieldValue
        let commentText = "\(name!): \(commentTextField.text!)"
        updateComment = FieldValue.arrayUnion([commentText])
        
        let postDic = [
            "comment" : updateComment
            //Firestoreのサーバー上の時計を使用して日時を保存
            //"date" : FieldValue.serverTimestamp()
            ] as [String : Any]
        postRef.updateData(postDic)
        
        //HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        // 画面を閉じてタブ画面に戻る
        self.dismiss(animated: true, completion: nil)
    }
    

}
