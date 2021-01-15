//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by aykawano on 2021/01/06.
//  Copyright © 2021 ayaka. All rights reserved.
//

import UIKit
import FirebaseUI

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //PostDataの内容をセルに表示
    func setPostData(_ postData:PostData){
        //画像の表示
        //CloudStorageから画像をダウンロードしている間、ダウンロード中であることを示すインジケーターを表示
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        //指定場所から画像をダウンロードして、UIImageViewに表示
        //一度ダウンロードした画像はローカルストレージにキャッシュされるので、２回目以降の表示はキャッシュを使用
        postImageView.sd_setImage(with: imageRef)
        
        //キャプションの表示
        self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"
        
        //コメントの表示
        
//        for (user, comment) in postData.comment{
//            self.commentLabel.text = "\(user): \(comment)"
//        }
        
        var allComments = ""
        
        if postData.comment != []{
            for i in 0..<postData.comment.count{
                allComments += "\(postData.comment[i])\n"
            }
            self.commentLabel.text = "[コメント]\n\(allComments)"
        }
        
        //日時の表示
        self.dateLabel.text = ""
        if let date = postData.date{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.dateLabel.text = dateString
        }
        
        //いいね数の表示
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        //いいねボタンの表示
        if postData.isLiked{
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        }else{
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
    }
    
}
