//
//  PostViewController.swift
//  Instagram
//
//  Created by aykawano on 2020/12/28.
//  Copyright © 2020 ayaka. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class PostViewController: UIViewController {
    
    var image : UIImage!

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textField: UITextField!
    
    //投稿ボタンをタップした時に呼ばれるメソッド
    @IBAction func handlePostButton(_ sender: Any) {
        //画像をJPEG形式に変換する（圧縮率の指定）
        let imageData = image.jpegData(compressionQuality: 0.75)
        
        //投稿データの保存場所を定義する
        //Const.PostPathで指定したフォルダ
        //document()をつけることで、一意の投稿になる
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        //画像の保存場所を定義する
        //ストレージサービス内のConst.ImagePathで指定したフォルダの中の該当画像の参照取得
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg")
        
        //HUDで投稿処理中の表示を開始
        SVProgressHUD.show()
        //Storageに画像をアップロードする
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        imageRef.putData(imageData!, metadata: metadata){(metadata, error) in
            if error != nil{
                //画像のアップロード失敗
                print(error!)
                SVProgressHUD.showError(withStatus: "画像のアップロードに失敗しました")
                //投稿処理をキャンセルし、先頭画面に戻る
                //アプリのインスタンスを取得
                //アプリの全画面=キーウィンドウ(+キーボード)を取得
                //その中からisKeyWindowでキーウィンドウを検索
                //rootController = キーウィンドウの中で一番最初に表示されるViewController
                UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                return
            }
            
            //FireStoreに投稿データを保存する
            let name = Auth.auth().currentUser?.displayName
            let postDic = [
                "name" : name!,
                "caption" : self.textField.text!,
                //Firestoreのサーバー上の時計を使用して日時を保存
                "date" : FieldValue.serverTimestamp()
                ] as [String : Any]
            postRef.setData(postDic)
            //HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "投稿しました")
            //投稿処理が完了したので先頭画面に戻る
            UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    //キャンセルボタンをタップした時に呼ばれるメソッド
    @IBAction func handleCancelButton(_ sender: Any) {
        //加工画面に戻る
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //受け取った画像をimageViewにセットする
        imageView.image = image
        }
    


}
