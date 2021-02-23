//
//  SellerAddCategoryVC.swift
//  SaharaGo
//
//  Created by Ritesh on 18/12/20.
//

import UIKit

class SellerAddCategoryVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet var descriptionTxtview: UITextView!
    @IBOutlet var categoryTxt: UITextField!
    @IBOutlet var prodimg: UIImageView!
    
    var metaDataDic: NSMutableDictionary = NSMutableDictionary()
    var imagesArr: NSMutableArray = NSMutableArray()
    var catInfo = categoryListStruct()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        descriptionTxtview.delegate = self
        descriptionTxtview.text = ""
        descriptionTxtview.textColor = UIColor.lightGray
        descriptionTxtview.borderColor = UIColor.lightGray
        descriptionTxtview.layer.borderWidth = 1.0
        if isCategoryEdit == "yes" {
            self.setData()
        }
    }
    
    @IBAction func uploadImgAction(_ sender: Any) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func requestNativeImageUpload(image: UIImage) {
        showProgressOnView(appDelegate.window!)
        guard let url = NSURL(string: "http://35.160.227.253:8081/api/v1/saharaGo/uploadSingleFile") else { return }
        let boundary = generateBoundary()
        var request = URLRequest(url: url as URL)
        
        let parameters = ["file": ""]
        
        guard let mediaImage = Media(withImage: image, forKey: "file") else { return }
        
        request.httpMethod = "POST"
        
        request.allHTTPHeaderFields = [
            "X-User-Agent": "ios",
            "Accept-Language": "en",
            "Accept": "application/json",
            "Content-Type": "multipart/form-data; boundary=\(boundary)",
            "ApiKey": ""
        ]
        
        let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
        request.httpBody = dataBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
                DispatchQueue.main.async {
                    hideAllProgressOnView(appDelegateInstance.window!)
                }
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    let jsonDic = json as! NSDictionary
                    print(jsonDic)
                    self.imagesArr.removeAllObjects()
                    self.imagesArr.add(jsonDic.value(forKey: "file") as! String)
                    DispatchQueue.main.async {
                        self.view.makeToast("Image Uploaded Successfully.")
                    }
                    
                } catch {
                    //hideAllProgressOnView(self.view)
                    print(error)
                }
            }
        }.resume()
    }
    
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createDataBody(withParameters params: [String: String]?, media: [Media]?, boundary: String) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.fileName)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
    
    struct Media {
        let key: String
        let fileName: String
        let data: Data
        let mimeType: String
        
        init?(withImage image: UIImage, forKey key: String) {
            self.key = key
            self.mimeType = "image/jpg"
            self.fileName = "\(arc4random()).jpeg"
            
            guard let data = image.jpegData(compressionQuality: 0.5) else { return nil }
            self.data = data
        }
    }
    
    
    @IBAction func submitBtn(_ sender: Any) {
        
        if self.categoryTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Name.")
            return
        } else if self.descriptionTxtview.text!.isEmpty {
            self.view.makeToast("Please Enter Description.")
            return
        } else if self.imagesArr.count == 0 {
            self.view.makeToast("Please Upload Image.")
            return
        }
        
        metaDataDic.setValue(self.descriptionTxtview.text!, forKey: "description")
        if self.imagesArr.count > 0 {
            metaDataDic.setValue("\(self.imagesArr[0])", forKey: "image")
        } else {
            metaDataDic.setValue("", forKey: "image")
        }
        
        
        if isCategoryEdit == "yes" {
            self.updateCategoryAPI()
        } else {
            self.addCategoryApiCall("parentCategoryId")
        }
        
    }
    
    func setData() {
        self.categoryTxt.text = self.catInfo.name
        self.descriptionTxtview.text = self.catInfo.description
        self.imagesArr.removeAllObjects()
        self.imagesArr.add(self.catInfo.image)
        self.prodimg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(self.catInfo.image)"), placeholderImage: UIImage(named: "edit cat_img"))
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        isCategoryEdit = "no"
        self.dismiss(animated: true, completion: nil)
    }
    
    func addCategoryApiCall(_ catKey: String) {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
//            let param:[String:Any] = [ "name": self.categoryTxt.text!,catKey: categoryId, "metaData": self.metaDataDic]
            
            var param:[String:Any] = [:]
            if categoryIdArr.count > 0 {
                param = ["name": self.categoryTxt.text!,catKey: categoryIdArr.lastObject as! String, "metaData": self.metaDataDic]
            } else {
                param = ["name": self.categoryTxt.text!,catKey: categoryId, "metaData": self.metaDataDic]
            }
            
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_ADD_NEWCATEGORY, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    //save data in userdefault..
                    //self.view.makeToast(json["message"].stringValue)
                    
                    //                    UIAlertController.showInfoAlertWithTitle(json["message"].stringValue, message: "Your Request has been sent. you can check the status in the more section of the app by clicking on Manage Categories.", buttonTitle: "OK", viewController: self)
                    
                    let alert = UIAlertController(title: "Category Created Successfully.", message: "Your Request has been sent. you can check the status in the more section of the app by clicking on Manage Categories.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        switch action.style{
                        case .default:
                            if isSubcategory == "yes" {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.presentingViewController?
                                        .presentingViewController?.dismiss(animated: true, completion: nil)
                                }
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                            
                        case .cancel:
                            print("cancel")
                            
                        case .destructive:
                            print("destructive")
                            
                            
                        @unknown default:
                            print("error")
                        }}))
                    self.present(alert, animated: true, completion: nil)
                
                }
                else {
                    self.view.makeToast("\(json["message"].stringValue)")
                }
            }, errorBlock: { (NSError) in
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
            
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
    func updateCategoryAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:Any] = [ "name": self.categoryTxt.text!,"parentCategoryId":catInfo.parentCategory, "metaData": self.metaDataDic]
            
            var apiUrl = BASE_URL + PROJECT_URL.VENDOR_UPDATE_ADDED_CATEGORY
            apiUrl = apiUrl + "\(catInfo.id)"
            
            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: apiUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                
                if success == "true"
                {
                    
                    self.view.makeToast(json["message"].stringValue)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                }
                else {
                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                }
            }, errorBlock: { (NSError) in
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
            
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if descriptionTxtview.text == "Description" {
            descriptionTxtview.text = nil
            descriptionTxtview.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTxtview.text.isEmpty {
            descriptionTxtview.text = ""
            descriptionTxtview.textColor = UIColor.lightGray
        }
    }
    
}

extension SellerAddCategoryVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.prodimg.contentMode = .scaleToFill
            self.prodimg.image = pickedImage
            self.requestNativeImageUpload(image: pickedImage)
            //saveImageDocumentDirectory(usedImage: pickedImage)
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
}
