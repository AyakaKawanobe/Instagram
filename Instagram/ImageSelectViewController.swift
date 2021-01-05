//
//  ImageSelectViewController.swift
//  Instagram
//
//  Created by aykawano on 2020/12/28.
//  Copyright © 2020 ayaka. All rights reserved.
//

import UIKit

class ImageSelectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //ライブラリ（カメラロール）を指定してピッカーを開く
    @IBAction func handleLibraryButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
        
    }
    
    //カメラを指定してピッカーを開く
    @IBAction func handleCameraButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func handleCancelButton(_ sender: Any) {
        //画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //写真撮影/選択した時に呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //撮影/選択された画像を取得
        if info[.originalImage] != nil{
            let image = info[.originalImage] as! UIImage
            
            //後でCLImageEditorライブラリで加工する
            print("DEBUG_PRINT: image = \(image)")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //ImageSelectViewController画面を閉じてタブ画面に戻る
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    

}
