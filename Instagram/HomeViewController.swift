//
//  HomeViewController.swift
//  Instagram
//
//  Created by aykawano on 2020/12/28.
//  Copyright © 2020 ayaka. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    //投稿データを格納する配列
    var postArray: [PostData] = []
    
    //FireStoreのデータ更新の監視を行うリスナー
    var listener : ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        //xibファイル読み込み
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        //カスタムセルを登録する
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil{
            //ログイン済
            if listener == nil{
                //listener未登録なら、登録してスナップショットを受信する
                let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
                listener = postsRef.addSnapshotListener(){(querySnapshot, error) in
                    //querySnapshotに最新のデータが入っている
                    //listenerが更新データを自動検出して、クロージャが呼び出される
                    //ドキュメントが追加されたり、更新されるたびに呼び出される
                    if let error = error{
                        print("DEBUG_PRINT: スナップショットの取得に失敗しました。\(error)")
                        return
                    }
                    
                    //取得したdocumentを基にPostDataを作成し、postArrayの配列にする
                    self.postArray = querySnapshot!.documents.map{document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let postData = PostData(document: document)
                        return postData
                    }
                    
                    //TableViewの表示を更新する
                    self.tableView.reloadData()
                }
            }
        }else{
            //ログイン未(またはログアウト済)
            if listener != nil{
                //listener登録済なら削除してpostArrayをクリアする
                listener.remove()
                listener = nil
                postArray = []
                tableView.reloadData()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        
        //セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action: #selector(handleButton(_:forEvent:)), for: .touchUpInside)
        cell.commentButton.addTarget(self, action: #selector(handleCommentButton(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }
    
    //いいねボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent){
        
        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        //配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        //likesを更新する
        if let myid = Auth.auth().currentUser?.uid{
            //更新データを作成する
            var updateValue: FieldValue
            
            if postData.isLiked{
                //すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            }else{
                //今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            
            //likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes" : updateValue])
        }
    }
    
    //コメントボタンがタップされた時に呼ばれるメソッド
    @objc func handleCommentButton(_ sender: UIButton, forEvent event: UIEvent){
        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        //配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        self.performSegue(withIdentifier: "commentSegue", sender: (postData.caption, postData.id))
    }
    
    //コメントした投稿のID,キャプションをコメント画面に渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentSegue",
            let data: (caption: String, id: String) = sender as? (String, String),
            let commentViewController = segue.destination as? CommentViewController{
            if sender != nil{
                commentViewController.caption = data.caption
                commentViewController.id = data.id
            }
        }
    }
}
