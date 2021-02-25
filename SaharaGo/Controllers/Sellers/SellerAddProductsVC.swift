//
//  SellerAddProductsVC.swift
//  SaharaGo
//
//  Created by Ritesh on 15/12/20.
//

import UIKit
import ImagePicker
import Alamofire
import YangMingShan

struct image_Struct: Codable {
    var fileName: String = ""
}

class SellerAddProductsVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var viewAllBtn: UIButton!
    @IBOutlet var discountPercentTxt: UITextField!
    @IBOutlet var priceTxt: UITextField!
    @IBOutlet var currencyTxt: UITextField!
    @IBOutlet var stockTxt: UITextField!
    @IBOutlet var productDscrptionTxt: UITextView!
    @IBOutlet var productNameTxt: UITextField!
    @IBOutlet var prodImage: UIImageView!
    var isHomeProducts = ""
    
    var metaDataDic: NSMutableDictionary = NSMutableDictionary()
    var imagesStrArr: NSMutableArray = NSMutableArray()
    var catId: String = String()
    var isSubCategoryAvailable: Bool = false
    var pickedImageUrl:URL?
    var imagesUrlArr = [URL]()
    var imagesArr = [URL]()
    var testArr = [String]()
    var currencyListArr = ["USD"]
    
    var selectedProductsInfo = [categoryProductListStruct]()
    let imagePickerController = ImagePickerController()
    
    var picker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.currencyTxt.delegate = self
        if self.selectedProductsInfo.count > 0 {
            self.titleLbl.text = selectedProductsInfo[0].name
            self.productNameTxt.text = selectedProductsInfo[0].name
            self.productDscrptionTxt.text = selectedProductsInfo[0].description
            self.stockTxt.text = selectedProductsInfo[0].stock
            self.currencyTxt.text = selectedProductsInfo[0].currency
            self.priceTxt.text = selectedProductsInfo[0].price
            self.discountPercentTxt.text = selectedProductsInfo[0].discountPercent
            self.productDscrptionTxt.text = selectedProductsInfo[0].description
            
            if selectedProductsInfo[0].images!.count > 0 {
                self.viewAllBtn.isHidden = false
                self.testArr = selectedProductsInfo[0].images!
                self.prodImage.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(selectedProductsInfo[0].images![0])"), placeholderImage: UIImage(named: "edit cat_img"))
            }
            
        } else {
            self.productDscrptionTxt.text = ""
        }
        
        self.productDscrptionTxt.delegate = self
        self.productDscrptionTxt.textColor = UIColor.lightGray
        self.productDscrptionTxt.borderColor = UIColor.lightGray
        self.productDscrptionTxt.layer.borderWidth = 1.0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            textField.resignFirstResponder()
        }
        
        //call your function here
        self.openActionsheet()
    }
    
    private func openActionsheet() {
        let alert = UIAlertController(title: "Currency", message: "Please Select your Currency.", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "USD", style: .default , handler:{ (UIAlertAction)in
            self.currencyTxt.text = "USD"
        }))
        
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        //uncomment for iPad Support
        //alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.selectedProductsInfo.removeAll()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func viewAllAction(_ sender: Any) {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerViewProductsVC") as! SellerViewProductsVC
        vc.prodcuctImgArr = self.testArr
        
        vc.completionHandlerCallback = {(arr: [String]!)->Void in
            self.testArr = arr
            if self.selectedProductsInfo.count > 0 {
                self.selectedProductsInfo[0].images! = arr
            }
            
        }
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func uploadImgAction(_ sender: Any) {
        
        //        imagePickerController.delegate = self
        //        present(imagePickerController, animated: true, completion: nil)
        
        
        //        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        //        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
        //            self.openCamera()
        //        }))
        //
        //        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
        //            self.openGallery()
        //        }))
        //
        //        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        //
        //        self.present(alert, animated: true, completion: nil)
        
        self.openImageVideoPicker()
        
    }
    
    func openImageVideoPicker()
    {
        let pickerViewController = YMSPhotoPickerViewController.init()
        pickerViewController.numberOfPhotoToSelect = .max
        
        let customColor = UIColor.init(red: 15.0/255.0, green: 82.0/255.0, blue: 45.0/255.0, alpha: 1.0)
        let customCameraColor = UIColor.init(red: 15.0/255.0, green: 82.0/255.0, blue: 45.0/255.0, alpha: 1.0)
        
        pickerViewController.theme.titleLabelTextColor = UIColor.white
        pickerViewController.theme.navigationBarBackgroundColor = customColor
        pickerViewController.theme.tintColor = UIColor.white
        pickerViewController.theme.orderTintColor = customCameraColor
        pickerViewController.theme.cameraVeilColor = customCameraColor
        pickerViewController.theme.cameraIconColor = UIColor.white
        pickerViewController.theme.statusBarStyle = .lightContent
        
        self.yms_presentCustomAlbumPhotoView(pickerViewController, delegate: self)
    }
    
    func uploadImageAPI()
    {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegate.window!)
            
            ServerClass.sharedInstance.sendMultipartRequestToServerWithMultipleImages(urlString: BASE_URL + PROJECT_URL.VENDOR_UPLOAD_MULTIPLE_FILE, imageKeyName: "files", imageUrl: self.imagesArr, successBlock: {(json) in
                hideAllProgressOnView(appDelegateInstance.window!)
                print(json)
                
                //                self.testArr.removeAll()
                
                for i in 0..<json["files"].count {
                    let file = json["files"][i].stringValue
                    self.testArr.append(file)
                }
                
                
                self.view.makeToast("Image Uploaded Successfully")
                
                self.prodImage.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(self.testArr[0])"), placeholderImage: UIImage(named: "edit cat_img"))
                if self.testArr.count > 0 {
                    self.viewAllBtn.isHidden = false
                } else {
                    self.viewAllBtn.isHidden = true
                }
                
            }, errorBlock: { (NSError) in
                hideAllProgressOnView(appDelegateInstance.window!)
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
            })
            
        }
        else {
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
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
    
    @IBAction func submitBtnAction(_ sender: Any) {
        
        if self.productNameTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Product Name.")
            return
        } else if self.productDscrptionTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Product Description.")
            return
        } else if self.stockTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Stock.")
            return
        } else if self.priceTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Price.")
            return
        } else if self.discountPercentTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Discount Percent")
            return
        } else if Int(self.discountPercentTxt.text!)! > 100 {
            self.view.makeToast("Discount Value should not be greater than 100.")
            return
        } else if self.testArr.count == 0 {
            self.view.makeToast("Please upload Image.")
            return
        }
        
        metaDataDic.setValue(self.productDscrptionTxt.text!, forKey: "description")
        metaDataDic.setValue(self.testArr, forKey: "images")
        
        if selectedProductsInfo.count > 0 {
            self.updateProductAPI()
        } else {
            self.addProductApiCall()
        }
        
    }
    
    func addProductApiCall() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:Any] = [ "name": self.productNameTxt.text!,"category":self.catId,"stock":self.stockTxt.text!, "currency": self.currencyTxt.text!,"price":self.priceTxt.text!,"discountPercent": self.discountPercentTxt.text!, "metaData": self.metaDataDic]
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_ADD_PRODUCTS, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    //save data in userdefault..
                    self.view.makeToast(json["message"].stringValue)
//                    if isAddProduct == "yes" {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                            //self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
//                            self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
//                        }
//                    } else {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
//                        }
//                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                    
                }
                else {
                    self.view.makeToast("\(json["message"].stringValue)")
                    // UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
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
    
    func updateProductAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:Any] = [ "name": self.productNameTxt.text!,"category":self.catId,"stock":self.stockTxt.text!, "currency": self.currencyTxt.text!,"price":self.priceTxt.text!,"discountPercent": self.discountPercentTxt.text!, "metaData": self.metaDataDic]
            
            var apiUrl = BASE_URL + PROJECT_URL.VENDOR_UPDATE_PRODUCT
            apiUrl = apiUrl + "\(selectedProductsInfo[0].productId)"
            
            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: apiUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                
                if success == "true"
                {
                    
                    self.view.makeToast(json["message"].stringValue)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        if self.isHomeProducts == "yes" {
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            self.presentingViewController?
                            .presentingViewController?.dismiss(animated: true, completion: nil)
                        }
                        
                    }
                    
                    // NotificationCenter.default.post(name: Notification.Name("updateCatProducts"), object: nil)
                    
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
                    
                    self.imagesStrArr.add(jsonDic.value(forKey: "file") as! String)
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
    
}

extension SellerAddProductsVC: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        //        guard images.count > 0 else { return }
        //        let lightboxImages = images.map {
        //          return LightboxImage(image: $0)
        //        }
        //        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        //        imagePicker.present(lightbox, animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        //requestNativeMultipleImageUpload(image: images)
        //        var imagesData: NSMutableArray = NSMutableArray()
        //        let imgArr: NSMutableArray = NSMutableArray()
        //        imgArr.removeAllObjects()
        //        imagesData.removeAllObjects()
        //        for image in images {
        //            //let image = imageAssets
        //            let jpegData = image.jpegData(compressionQuality: 1.0)
        //            imagesData.add(jpegData)
        //            imgArr.add(image)
        //        }
        //
        //        let urlString = BASE_URL + PROJECT_URL.VENDOR_UPLOAD_MULTIPLE_FILE
        //        let parameters = ["files": images]
        //        Alamofire.upload(multipartFormData: { multipartFormData in
        //            // import image to request
        //            var i = 0
        //            for imageData in imagesData {
        //                i += 1
        //                multipartFormData.append(imageData as! Data, withName: "\(arc4random()).jpeg", mimeType: "image/png")
        //            }
        //            for (key, value) in parameters {
        //                multipartFormData.append(value, withName: key)
        //            }
        //        }, to: urlString,
        //
        //            encodingCompletion: { encodingResult in
        //                switch encodingResult {
        //                case .success(let upload, _, _):
        //                    upload.responseJSON { response in
        //                        print(response)
        //                    }
        //                case .failure(let error):
        //                    print(error)
        //                }
        //
        //        })
        
        //>>>>>>
        
        //        for i in 0..<images.count {
        //            var img = images[i]
        //            saveImageDocumentDirectory(usedImage: img, nameStr : "file\(i).jpeg")
        //            let imageToUploadURL = URL(fileURLWithPath: (getDirectoryPath() as NSString).appendingPathComponent("file\(i).jpeg"))
        //            self.imagesUrlArr.append(imageToUploadURL)
        //        }
        //
        //        print(self.imagesUrlArr)
        //
        //        self.uploadMultipleFiles(self.imagesUrlArr, imageArr: images)
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    public var imageAssets: [UIImage] {
        return AssetManager.resolveAssets(imagePickerController.stack.assets)
    }
}



extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

extension SellerAddProductsVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
  
        if productDscrptionTxt.text == "Product Description" {
            productDscrptionTxt.text = nil
            productDscrptionTxt.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.productDscrptionTxt.text.isEmpty {
            self.productDscrptionTxt.text = ""
            self.productDscrptionTxt.textColor = UIColor.lightGray
        }
    }
}

extension SellerAddProductsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.prodImage.contentMode = .scaleToFill
            self.prodImage.image = pickedImage
            self.requestNativeImageUpload(image: pickedImage)
            //saveImageDocumentDirectory(usedImage: pickedImage)
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
}

extension SellerAddProductsVC : YMSPhotoPickerViewControllerDelegate {
    
    func photoPickerViewControllerDidReceivePhotoAlbumAccessDenied(_ picker: YMSPhotoPickerViewController!) {
        let alertController = UIAlertController(title: "Allow photo album access?", message: "Need your permission to access photo albums", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        alertController.addAction(dismissAction)
        alertController.addAction(settingsAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func photoPickerViewControllerDidReceiveCameraAccessDenied(_ picker: YMSPhotoPickerViewController!) {
        let alertController = UIAlertController(title: "Allow camera album access?", message: "Need your permission to take a photo", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        alertController.addAction(dismissAction)
        alertController.addAction(settingsAction)
        
        // The access denied of camera is always happened on picker, present alert on it to follow the view hierarchy
        picker.present(alertController, animated: true, completion: nil)
    }
    
    func photoPickerViewController(_ picker: YMSPhotoPickerViewController!, didFinishPickingImages photoAssets: [PHAsset]!) {
        
        self.imagesArr.removeAll()
        picker.dismiss(animated: true) {
            for i in 0..<photoAssets.count {
                let asset: PHAsset = photoAssets[i]
                var img: UIImage?
                let manager = PHImageManager.default()
                let options = PHImageRequestOptions()
                options.version = .original
                options.isSynchronous = true
                options.isNetworkAccessAllowed = true
                
                manager.requestImageData(for: asset, options: options, resultHandler: { (data, str, orientaion, hakeem) in
                    if let data = data {
                        img = UIImage(data: data)
                        
                        saveImageDocumentDirectory(usedImage: img!, nameStr : "file\(i).jpeg")
                        let imageToUploadURL = URL(fileURLWithPath: (getDirectoryPath() as NSString).appendingPathComponent("file\(i).jpeg"))
                        self.imagesArr.append(imageToUploadURL)
                    }
                })
            }
            if (self.imagesArr.count == photoAssets.count)
            {
                self.uploadImageAPI()
            }
        }
    }
}

