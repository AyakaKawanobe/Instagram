//
//  PostData.swift
//  Instagram
//
//  Created by aykawano on 2021/01/06.
//  Copyright © 2021 ayaka. All rights reserved.
//

import UIKit
import Firebase

class PostData: NSObject {
    var id: String
    var name: String?
    var caption: String?
    var date: Date?
    //いいねを押したユーザーのidを格納
    var likes: [String] = []
    var isLiked: Bool = false
    var comment: [String] = []
    
    //FireStoreからデータ取得
    init(document: QueryDocumentSnapshot){
        self.id = document.documentID
        
        //辞書形式でデータを取得
        let postDic = document.data()
        
        self.name = postDic["name"] as? String
        
        self.caption = postDic["caption"] as? String
        
        let timeStamp = postDic["date"] as? Timestamp
        self.date = timeStamp?.dateValue()
        
        if let likes = postDic["likes"] as? [String]{
            self.likes = likes
        }
        
        if let comment = postDic["comment"] as? [String]{
            self.comment = comment
            //self.commentUser = postDic["commentUser"] as! [String]
        }
        
        if let myid = Auth.auth().currentUser?.uid{
            //likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているか判断
            if self.likes.firstIndex(of: myid) != nil{
                //myidがあれば、いいねを押していると判定する
                self.isLiked = true
            }
        }
    }
    
}
