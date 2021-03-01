//
//  SellerProfileVC.swift
//  SaharaGo
//
//  Created by Ritesh on 29/12/20.
//

import UIKit
import CropViewController

struct vendorProfile_Struct {
    
    var firstName:String = ""
    var lastName:String = ""
    var country:String = ""
    var state:String = ""
    var city :String = ""
    var zipcode :String = ""
    var landmark:String = ""
    var streetAddress:String = ""
    var sourcing:String = ""
    var emailMobile:String = ""
    var userImage:String = ""
    var coverImage:String = ""
    
}

class SellerProfileVC: UIViewController, UIPickerViewDelegate, CropViewControllerDelegate {
    
    @IBOutlet var coverCameraBtn: UIButton!
    @IBOutlet var userCoverImg: UIImageView!
    @IBOutlet var userProfileImg: UIImageView!
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var updatebtn: UIButton!
    @IBOutlet var editBtn: UIButton!
    @IBOutlet var countryTxt: UITextField!
    @IBOutlet var zipcodeTxt: UITextField!
    @IBOutlet var stateTxt: UITextField!
    @IBOutlet var cityTxt: UITextField!
    @IBOutlet var landmarkTxt: UITextField!
    @IBOutlet var streetAddressTxt: UITextField!
    @IBOutlet var emailMobileTxt: UITextField!
    @IBOutlet var lastNameTxt: UITextField!
    @IBOutlet var firstNameTxt: UITextField!
    
    @IBOutlet var profileLbl: UILabel!
    
    var profileInfo = [vendorProfile_Struct]()
    var metadataDic: NSMutableDictionary = NSMutableDictionary()
    
    var CountryList = [Country_List_Struct]()
    var picker = UIPickerView()
    var isProfileImg = ""
    
    private var image: UIImage?
    private var croppingStyle = CropViewCroppingStyle.default
    
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    
    struct Country_List_Struct {
        var countryName:String = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.getCountryList()
        self.picker.delegate = self
        self.picker.dataSource = self
        self.countryTxt.inputView = picker
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.getVendorProfile()
        
    }
    
    func getCountryList() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_COUNTY_LIST_COLOR_CODE, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    for i in 0..<json["countryColorCodeList"].count
                    {
                        let countryName =  json["countryColorCodeList"][i]["countryName"].stringValue
                        self.CountryList.append(Country_List_Struct.init(countryName: countryName))
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
    
    
    func getVendorProfile() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_DETAIL_BY_TOKEN, successBlock: { (json) in
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
                    let state = json["metaData"]["state"].stringValue
                    let streetAddress = json["metaData"]["streetAddress"].stringValue
                    let landmark = json["metaData"]["landmark"].stringValue
                    let city = json["metaData"]["city"].stringValue
                    let zipcode = json["metaData"]["zipcode"].stringValue
                    let sourcing = json["metaData"]["sourcing"].stringValue
                    let country = json["country"].stringValue
                    let emailMobile = json["emailMobile"].stringValue
                    
                    self.profileInfo.append(vendorProfile_Struct.init(firstName: firstName, lastName: lastName, country: country, state: state, city: city, zipcode: zipcode, landmark: landmark, streetAddress: streetAddress, sourcing: sourcing, emailMobile: emailMobile, userImage: userImage, coverImage: coverImage))
                    
                    self.setDetails(self.profileInfo[0])
                    
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
    
    func setDetails(_ profileInfo: vendorProfile_Struct) {
        self.cityTxt.text = profileInfo.city
        self.stateTxt.text = profileInfo.state
        self.zipcodeTxt.text = profileInfo.zipcode
        self.countryTxt.text = profileInfo.country
        self.firstNameTxt.text = profileInfo.firstName
        self.lastNameTxt.text = profileInfo.lastName
        self.emailMobileTxt.text = profileInfo.emailMobile
        self.streetAddressTxt.text = profileInfo.streetAddress
        self.landmarkTxt.text = profileInfo.landmark
       // self.userProfileImg.contentMode = .scaleToFill
        self.userProfileImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(profileInfo.userImage)"), placeholderImage: UIImage(named: "profile-1"))
        self.userCoverImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(profileInfo.coverImage)"), placeholderImage: UIImage(named: "cover-1"))
        
        
        if profileInfo.userImage.count > 0 && profileInfo.coverImage.count == 0 {
            self.metadataDic.setValue(profileInfo.userImage, forKey: "image")
        } else if profileInfo.userImage.count == 0 && profileInfo.coverImage.count > 0 {
            self.metadataDic.setValue(profileInfo.coverImage, forKey: "coverImage")
        } else if profileInfo.userImage.count == 0 && profileInfo.coverImage.count == 0 {
            self.metadataDic.setValue("", forKey: "coverImage")
            self.metadataDic.setValue("", forKey: "image")
        } else {
            self.metadataDic.setValue(profileInfo.coverImage, forKey: "coverImage")
            self.metadataDic.setValue(profileInfo.userImage, forKey: "image")
        }
        
    }
    
    @IBAction func editAction(_ sender: Any) {
        self.isProfileImg = "yes"
        if self.profileLbl.text == "Update Profile" {
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
        
        self.firstNameTxt.isUserInteractionEnabled = true
        self.lastNameTxt.isUserInteractionEnabled = true
        self.cityTxt.isUserInteractionEnabled = true
        self.stateTxt.isUserInteractionEnabled = true
        self.zipcodeTxt.isUserInteractionEnabled = true
        //self.countryTxt.isUserInteractionEnabled = true
        //self.emailMobileTxt.isUserInteractionEnabled = true
        self.streetAddressTxt.isUserInteractionEnabled = true
        self.landmarkTxt.isUserInteractionEnabled = true
        self.profileLbl.text = "Update Profile"
        self.editBtn.setImage(UIImage.init(named: "camera-1"), for: .normal)
        self.updatebtn.isHidden = false
        self.coverCameraBtn.isHidden = false
        
    }
    
    @IBAction func coverCameraAction(_ sender: Any) {
        self.isProfileImg = "no"
        
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
    
    
    func updateProfileApi() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:Any] = ["metaData": self.metadataDic]
            
            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_UPDATE_PROFILE, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                
                if success == "true"
                {
                    self.view.makeToast(json["message"].stringValue)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
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
    
    @IBAction func updateProfileAction(_ sender: Any) {
        
        if self.firstNameTxt.text!.isEmpty {
            self.view.makeToast("Please Enter First Name.")
            return
        } else if self.lastNameTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Last Name.")
            return
        } else if self.streetAddressTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Street Address.")
            return
        } else if self.landmarkTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Landmark.")
            return
        } else if self.cityTxt.text!.isEmpty {
            self.view.makeToast("Please Enter City.")
            return
        } else if self.stateTxt.text!.isEmpty {
            self.view.makeToast("Please Enter State.")
            return
        } else if self.zipcodeTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Zipcode.")
            return
        }
        
        self.metadataDic.setValue(self.firstNameTxt.text!, forKey: "firstName")
        self.metadataDic.setValue(self.lastNameTxt.text!, forKey: "lastName")
        self.metadataDic.setValue(self.streetAddressTxt.text!, forKey: "streetAddress")
        self.metadataDic.setValue(self.countryTxt.text!, forKey: "country")
        self.metadataDic.setValue(self.stateTxt.text!, forKey: "state")
        self.metadataDic.setValue(self.cityTxt.text!, forKey: "city")
        self.metadataDic.setValue(self.zipcodeTxt.text!, forKey: "zipcode")
        self.metadataDic.setValue(self.landmarkTxt.text!, forKey: "landmark")
        
        self.updateProfileApi()
    }
    
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
                        self.metadataDic.setValue(jsonDic.value(forKey: "file") as! String, forKey: "image")
                    } else {
                        self.metadataDic.setValue(jsonDic.value(forKey: "file") as! String, forKey: "coverImage")
                    }
                    
                    
                   // self.metadataDic.setValue(jsonDic.value(forKey: "file") as! String, forKey: "image")
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

extension SellerProfileVC : UIDocumentPickerDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CountryList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let countryDic = self.CountryList[row]
        return countryDic.countryName
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let countryDic = self.CountryList[row]
        self.countryTxt.text = countryDic.countryName
        //self.isdCode = countryDic.value(forKey: "isdCode") as! String
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
    
}

extension SellerProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //        if let pickedImage = info[.originalImage] as? UIImage {
        //            self.userProfileImg.contentMode = .scaleToFill
        //            self.userProfileImg.image = pickedImage
        //            self.requestNativeImageUpload(image: pickedImage)
        //            //saveImageDocumentDirectory(usedImage: pickedImage)
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
