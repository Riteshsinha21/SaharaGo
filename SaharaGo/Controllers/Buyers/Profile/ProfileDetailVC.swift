//
//  ProfileDetailVC.swift
//  SaharaGo
//
//  Created by Ritesh on 07/12/20.
//

import UIKit
import CropViewController

struct profileDetail_Struct {
    var firstName:String = ""
    var lastName:String = ""
    var emailMobile:String = ""
    var country:String = ""
    var userImage:String = ""
    var coverImage:String = ""
}

class ProfileDetailVC: UIViewController, CropViewControllerDelegate {
    
    @IBOutlet var coverBtn: UIButton!
    @IBOutlet var userCoverImg: UIImageView!
    @IBOutlet var userProfileImg: UIImageView!
    @IBOutlet var cameraBtn: UIButton!
    @IBOutlet var profileNameLbl: UILabel!
    @IBOutlet var countryTxt: UITextField!
    @IBOutlet var mailTxt: UITextField!
    @IBOutlet var lastNameTxt: UITextField!
    @IBOutlet var firstNameTxt: UITextField!
    @IBOutlet var updateProfileBtn: UIButton!
    
    var metaDataDic: NSMutableDictionary = NSMutableDictionary()
    var isProfileImg = ""
    
    private var image: UIImage?
    private var croppingStyle = CropViewCroppingStyle.default
    
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
         self.getProfileDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
//        self.setData(self.profileDetail)
       
    }
    
    
    @IBAction func changePswrdAction(_ sender: Any) {
        let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = userStoryboard.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func editProfileAction(_ sender: Any) {
        self.updateProfileBtn.isUserInteractionEnabled = true
        self.updateProfileBtn.alpha = 1.0
        self.firstNameTxt.isUserInteractionEnabled = true
        self.lastNameTxt.isUserInteractionEnabled = true
        self.cameraBtn.isHidden = false
        self.coverBtn.isHidden = false
    }
    
    @IBAction func uploadImgAction(_ sender: UIButton) {
        if sender.tag == 101 {
            self.isProfileImg = "yes"
        } else {
            self.isProfileImg = "no"
        }
        
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
            self.croppingStyle = .default
            
            let imagePicker = UIImagePickerController()
            imagePicker.modalPresentationStyle = .popover
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.delegate = self
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
//                    self.imagesArr.removeAllObjects()
//                    self.imagesArr.add(jsonDic.value(forKey: "file") as! String)
                    if self.isProfileImg == "yes" {
                        self.metaDataDic.setValue(jsonDic.value(forKey: "file") as! String, forKey: "image")
                    } else {
                        self.metaDataDic.setValue(jsonDic.value(forKey: "file") as! String, forKey: "coverImage")
                    }
                    
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
    
    func getProfileDetail() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_GET_DETAIL_BY_TOKEN, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                //success == "true"
                if success == "true"
                {
                    let firstName = json["metaData"]["firstName"].stringValue
                    let lastName = json["metaData"]["lastName"].stringValue
                    let userImage = json["metaData"]["image"].stringValue
                    let coverImage = json["metaData"]["coverImage"].stringValue
                    let emailMobile = json["emailMobile"].stringValue
                    let country = json["country"].stringValue
                    
                    self.setData(profileDetail_Struct.init(firstName: firstName, lastName: lastName, emailMobile: emailMobile, country: country, userImage: userImage, coverImage: coverImage))
                    
                } else {
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
    
    func setData(_ profileInfo: profileDetail_Struct) {
        self.firstNameTxt.text = profileInfo.firstName
        self.lastNameTxt.text = profileInfo.lastName
        self.mailTxt.text = profileInfo.emailMobile
        self.countryTxt.text = profileInfo.country
        self.profileNameLbl.text = "\(profileInfo.firstName) \(profileInfo.lastName)"
        self.userProfileImg.contentMode = .scaleToFill
        self.userProfileImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(profileInfo.userImage)"), placeholderImage: UIImage(named: "pp"))
        self.userCoverImg.contentMode = .scaleToFill
        self.userCoverImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(profileInfo.coverImage)"), placeholderImage: UIImage(named: "cover"))
        
        if profileInfo.userImage.count > 0 && profileInfo.coverImage.count == 0 {
            self.metaDataDic.setValue(profileInfo.userImage, forKey: "image")
        } else if profileInfo.userImage.count == 0 && profileInfo.coverImage.count > 0 {
            self.metaDataDic.setValue(profileInfo.coverImage, forKey: "coverImage")
        } else if profileInfo.userImage.count == 0 && profileInfo.coverImage.count == 0 {
            self.metaDataDic.setValue("", forKey: "coverImage")
            self.metaDataDic.setValue("", forKey: "image")
        } else {
            self.metaDataDic.setValue(profileInfo.coverImage, forKey: "coverImage")
            self.metaDataDic.setValue(profileInfo.userImage, forKey: "image")
        }
        
    }
    
    @IBAction func updateProfileAction(_ sender: Any) {
        
        self.updateProfileAPI()
        
    }
    
    func updateProfileAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            self.metaDataDic.setValue(self.firstNameTxt.text!, forKey: "firstName")
            self.metaDataDic.setValue(self.lastNameTxt.text!, forKey: "lastName")
            
            
            let param:[String:Any] = [ "metaData": self.metaDataDic]
            
            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_UPDATE_PROFILE, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                
                if success == "true"
                {
                    
                    self.view.makeToast(json["message"].stringValue)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.dismiss(animated: true, completion: nil)
                        self.navigationController?.popViewController(animated: true)
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
    
    func presentCropViewController(_ image: UIImage) {
      //let image: UIImage = ... //Load an image

      let cropViewController = CropViewController(image: image)
      cropViewController.delegate = self
      present(cropViewController, animated: true, completion: nil)
    }

    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            // 'image' is the newly cropped version of the original image

        if self.isProfileImg == "yes" {

           // self.userProfileImg.contentMode = .scaleToFill
            self.userProfileImg.image = image
        } else {
            
            //self.userCoverImg.contentMode = .scaleToFill
            self.userCoverImg.image = image
        }
            
//        self.userProfileImg.image = image
        self.requestNativeImageUpload(image: image)
        cropViewController.dismiss(animated: true, completion: nil)

        }
    
//    public func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
//        self.croppedRect = cropRect
//        self.croppedAngle = angle
//        self.userProfileImg.image = image
//        cropViewController.dismiss(animated: true, completion: nil)
//    }
    
}

extension ProfileDetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let pickedImage = info[.originalImage] as? UIImage {
//            if self.isProfileImg == "yes" {
//
//                self.userProfileImg.contentMode = .scaleToFill
//                self.userProfileImg.image = pickedImage
//            } else {
//
//                self.userCoverImg.contentMode = .scaleToFill
//                self.userCoverImg.image = pickedImage
//            }
//
//           // self.requestNativeImageUpload(image: pickedImage)
//            self.presentCropViewController(pickedImage)
//
//        }
//
//        picker.dismiss(animated: true, completion: nil)
        
        guard let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
        
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        //cropController.modalPresentationStyle = .fullScreen
        cropController.delegate = self
        
        self.image = image
        //If profile picture, push onto the same navigation stack
        if croppingStyle == .circular {
            if picker.sourceType == .camera {
                picker.dismiss(animated: true, completion: {
                    self.present(cropController, animated: true, completion: nil)
                })
            } else {
                picker.pushViewController(cropController, animated: true)
            }
        }
        else { //otherwise dismiss, and then present from the main controller
            picker.dismiss(animated: true, completion: {
                self.present(cropController, animated: true, completion: nil)
                //self.navigationController!.pushViewController(cropController, animated: true)
            })
        }

        
        
    }
}
