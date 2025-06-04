//
//  ViewController.swift
//  WIFI_Sample_Code
//
//  Created by on 2021/12/3.
//

import Foundation
import IOS_SWIFT_WIFI_SDK
import UIKit
import PhotosUI

final class ViewController: UIViewController {
    // MARK: - Outlet

    @IBOutlet var mStackView: UIStackView!
    @IBOutlet var mScrollView: UIScrollView!

    @IBOutlet var IPText: UITextField!
    @IBOutlet var PortText: UITextField!
    @IBOutlet var connectStatusLabel: UILabel!

    @IBOutlet var connectButton: UIButton!
    @IBOutlet var disconnectButton: UIButton!
    @IBOutlet var printSetupButton: UIButton!
    @IBOutlet var printBarcodeButton: UIButton!
    @IBOutlet var printQRcodeButton: UIButton!
    @IBOutlet var printBmpButton: UIButton!
    @IBOutlet var printSimpChinButton: UIButton!
    @IBOutlet var printFontBlockButton: UIButton!
    @IBOutlet var printStautsButton: UIButton!
    @IBOutlet var topDirectionButton: UIButton!
    @IBOutlet var bottomDirectionButton: UIButton!
    @IBOutlet var mirrorButton: UIButton!
    @IBOutlet var setShiftButton: UIButton!
    @IBOutlet var yShiftTextField: UITextField!
    @IBOutlet var setReverseButton: UIButton!
    @IBOutlet var setOffsetButton: UIButton!
    @IBOutlet var setCutModeButton: UIButton!
    @IBOutlet var setTearButton: UIButton!
    @IBOutlet var setPeelButton: UIButton!
    @IBOutlet var setCutForwardButton: UIButton!
    @IBOutlet var genericDefaultButton: UIButton!
    @IBOutlet var sensorDefaultButton: UIButton!
    @IBOutlet var printPicture1Button: UIButton!
    @IBOutlet var printPicture3Button: UIButton!
    @IBOutlet var pictureWidthTextField: UITextField!
    @IBOutlet var pictureHeightTextField: UITextField!
    @IBOutlet var wifiTo24GButton: UIButton!
    @IBOutlet var wifiTo5GButton: UIButton!
    @IBOutlet var wifiToBothButton: UIButton!
    @IBOutlet var getSDKVerButton: UIButton!
    
    @IBOutlet var showRFIDErrorCodeBtn: UIButton!
    @IBOutlet var printerDPITextField: UITextField!
    @IBOutlet var setReadPositionBtn: UIButton!
    @IBOutlet var writeGen2Btn: UIButton!
    @IBOutlet var readGen2Btn: UIButton!
    @IBOutlet var readGen2QueryBtn: UIButton!
    @IBOutlet var setGjbBtn: UIButton!
    @IBOutlet var writeGjbBtn: UIButton!
    @IBOutlet var readGjbBtn: UIButton!
    @IBOutlet var rfidDefaultBtn: UIButton!
    @IBOutlet var rfidCalibrationBtn: UIButton!
    
    @IBOutlet var realTimeStatusOnBtn: UIButton!
    @IBOutlet var realTimeStatusOffBtn: UIButton!
    @IBOutlet var getRealTimeBtn: UIButton!
    @IBOutlet var realTimeShowLabel: UILabel!

    // MARK: - Properties

    private let gswifi = GTSPL_WIFI()
    private var timer = Timer()
    // 判斷實時命令是不是開啟
    private var isRealTimeOn: Bool = false {
        willSet {
            // 避免重覆啟動
            timer.invalidate()
        }
        didSet {
            if isRealTimeOn {
                readPrinterStatusEverySecond()
            }
        }
    }
    private let timeOutMsg = "time_out"
    // 連線狀態
    enum connectStatusEnum: String {
        case connect = "connected"
        case disconnect = "disconnected"
        case connecting = "connecting"
        case connectFailed = "Connect failed."
        case noConnection = "Connection doesn't exist."
        case connectError = "Connection Error"
    }
    
    // 鏡像狀態
    private var mMirrorNumber = 2 // 每次+1偶數為正常，奇數為鏡像
    
    private let mImagePicker = UIImagePickerController()
    private var mPrintMode = 1

    // MARK: - View Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        layoutInsideScrollerView()

        IPText.text = "192.168.66.89" // default
        PortText.text = "9100"

        let tapAction = UITapGestureRecognizer(target: self, action: #selector(hidingKeyboard))
        view.addGestureRecognizer(tapAction)
        
        if mMirrorNumber % 2 == 0 {
            // 整除 = 正常
            mirrorButton.setTitle("Mirror On", for: .normal)
        } else {
            // 不整除 = 鏡像
            mirrorButton.setTitle("Mirror Off", for: .normal)
        }
    }
}

// MARK: - Action

extension ViewController {
    @IBAction func connect_onClick(_: Any) {
        view.endEditing(true)
        let ip = IPText.text
        let port: Int? = Int(PortText.text!)
        if ip == "" {
            showDialog(title: "Error", msg: "IP is empty.")
            return
        }
        if port == nil {
            showDialog(title: "Error", msg: "Port is empty.")
            return
        }
        gswifi.openPort(IP: ip!, port: port!) { msg in // 用closure帶callback回傳連線狀態
            self.connectStatusLabel.text = msg
        }
    }

    @IBAction func disconnect_onClick(_: Any) {
        view.endEditing(true)
        gswifi.closePort { msg in
            DispatchQueue.main.async {
                self.showDialog(title: "Disconnect", msg: msg)
                self.connectStatusLabel.text = msg
            }
        }
    }

    // setup printer
    @IBAction func setup_onClick(_: Any) {
        view.endEditing(true)
        gswifi.setup(width: 81, height: 106, speed: 4, density: 7, sensor: 0, sensorDistance: 3, sensorOffset: 0) { msg in
            DispatchQueue.main.async {
                self.showDialog(title: "Error", msg: msg)
                return
            }
        }
    }

    // print barcode
    @IBAction func barcode_onCllick(_: Any) {
        view.endEditing(true)
        gswifi.clearBuffer()
        gswifi.printBarcode(x: 30, y: 30, type: "128", height: 100, readable: 1, rotation: 0, narrow: 2, wide: 2, content: "Barcode12345678") { msg in
            DispatchQueue.main.async {
                self.showDialog(title: "Error", msg: msg)
                return
            }
        }
        gswifi.printLabel(set: 1, copy: 1)
    }

    // print qrcode
    @IBAction func qrcode_onClick(_: Any) {
        view.endEditing(true)
        gswifi.clearBuffer()
        gswifi.printQRCode(x: 50, y: 50, eccLevel: "H", cellWidth: 4, rotation: 0, content: "ABCabc123") { msg in
            DispatchQueue.main.async {
                self.showDialog(title: "Error", msg: msg)
                return
            }
        }
        gswifi.printLabel(set: 1, copy: 1)
    }

    // print bmp
    @IBAction func bmp_onClick(_: Any) {
        view.endEditing(true)
        gswifi.clearBuffer()
        let url = Bundle.main.url(forResource: "CIRCLE", withExtension: "bmp")!
        gswifi.downloadBMP(filePath: url, fileName: "CIRCLE.bmp") { msg in
            DispatchQueue.main.async {
                self.showDialog(title: "Error", msg: msg)
                return
            }
        }
        gswifi.sendCommand("PUTBMP 30,30,\"CIRCLE.bmp\"\r\n")
        gswifi.printLabel(set: 1, copy: 1)
    }

    // print simplified chinese font
    @IBAction func printfont_onClick(_: Any) {
        view.endEditing(true)
        let cn = "默认简体中文测试"
        gswifi.clearBuffer()
        gswifi.printFont(x: 200, y: 200, fontName: "TSS24.BF2", rotation: 0, x_scale: 1, y_scale: 1, content: cn) { msg in
            DispatchQueue.main.async {
                self.showDialog(title: "Error", msg: msg)
                return
            }
        }
        gswifi.printLabel(set: 1, copy: 1)
    }

    // print font block
    @IBAction func onPrintFontBlockClick(_: Any) {
        view.endEditing(true)
        let paragraph = "Print Font Test: We stand behind our products with one of the most comprehensive support programs in the Auto-ID industry."
        gswifi.clearBuffer()
        gswifi.printFontBlock(x: 15, y: 15, width: 300, height: 90, fontName: "TSS16.BF2", rotation: 0, x_scale: 2, y_scale: 2, space: 20, align: 0, content: paragraph) { msg in
            DispatchQueue.main.async {
                self.showDialog(title: "Error", msg: msg)
                return
            }
        }
        gswifi.printLabel(set: 1, copy: 1)
    }

    // get printer status
    @IBAction func status_onClick(_: Any) {
        view.endEditing(true)
        gswifi.printerStatus { status in
            if status == connectStatusEnum.noConnection.rawValue {
                self.showDialog(title: "Error", msg: status)
                return
            } else if status == self.timeOutMsg {
                self.showDialog(title: "Error", msg: "time out")
                return
            }
            let statusStr = self.readStatusNumber(status)
            self.showDialog(title: "Printer Status", msg: statusStr)
        }
    }
    
    @IBAction func topDirection_onClick(_ sender: Any) {
        gswifi.setDirectionAndMirror(direction: 0, mirror: 0)
    }
    
    @IBAction func bottomDirection_onClick(_ sender: Any) {
        gswifi.setDirectionAndMirror(direction: 1, mirror: 0)
    }
    
    @IBAction func mirror_onClick(_ sender: Any) {
        if mMirrorNumber % 2 == 0 {
            // 整除 = 正常
            gswifi.setDirectionAndMirror(direction: 0, mirror: 1)
            mirrorButton.setTitle("Mirror Off", for: .normal)
            mMirrorNumber += 1
        } else {
            // 不整除 = 鏡像
            gswifi.setDirectionAndMirror(direction: 0, mirror: 0)
            mirrorButton.setTitle("Mirror On", for: .normal)
            mMirrorNumber += 1
        }
    }
    
    @IBAction func setShift_onClick(_ sender: Any) {
        if let number = yShiftTextField.text,
           let int = Int(number) {
            gswifi.setShift(shiftY: int)
        }
    }
    
    @IBAction func setReverse_onClick(_ sender: Any) {
        gswifi.printReverse(x_start: 0, y_start: 0, x_width: 30, y_height: 30)
    }
    
    @IBAction func setOffset_onClick(_ sender: Any) {
        gswifi.setOffset(offset: 9.9) //9.9mm
    }
    
    @IBAction func setCutMode_onClick(_ sender: Any) {
        gswifi.setCutMode(mode: 1, piece: 3)
    }
    
    @IBAction func setTear_onClick(_ sender: Any) {
        gswifi.setAfterPrintAction(mode: 1)
    }
    
    @IBAction func setPeel_onClick(_ sender: Any) {
        gswifi.setAfterPrintAction(mode: 2)
    }
    
    @IBAction func setCutForward_onClick(_ sender: Any) {
        gswifi.setAfterPrintAction(mode: 3)
    }
    
    @IBAction func genericDefault_onClick(_ sender: Any) {
        gswifi.genericDefault()
    }
    
    @IBAction func sensorDefault_onClick(_ sender: Any) {
        gswifi.sensorDefault()
    }
    
    @IBAction func printPicture_1_onClick(_ sender: Any){
        mPrintMode = 1
        loadImage()
    }
    
    @IBAction func printPicture_3_onClick(_ sender: Any){
        mPrintMode = 3
        loadImage()
    }
    
    @IBAction func wifi_24G_onClick(_ sender: Any) {
        gswifi.switchWifiFrequency(frequency: "2.4G") { msg in
            DispatchQueue.main.async {
                self.showDialog(title: "Error", msg: msg)
                return
            }
        }
    }
    
    @IBAction func wifi_5G_onClick(_ sender: Any) {
        gswifi.switchWifiFrequency(frequency: "5G") { msg in
            DispatchQueue.main.async {
                self.showDialog(title: "Error", msg: msg)
                return
            }
        }
    }
    
    @IBAction func wifi_both_onClick(_ sender: Any) {
        gswifi.switchWifiFrequency(frequency: "BOTH") { msg in
            DispatchQueue.main.async {
                self.showDialog(title: "Error", msg: msg)
                return
            }
        }
    }


    // get sdk version
    @IBAction func getVersion_Onclick(_: Any) {
        view.endEditing(true)
        let version = gswifi.getSdkVersion()
        showDialog(title: "WIFI SDK Version", msg: version)
    }

    //MARK: - Gen2 Action
    
    @IBAction func setReadPositionAction(_ sender: Any) {
        guard let dpiText = printerDPITextField.text else { return }
        gswifi.setRFIDProcedure(tagType: 8, rw_position: 2, void_printout: 12, tryEncode_times: 3, error_handle: "N", speed: 2, retry_times: 6, dpi: dpiText) { msg in
            print("rfid set mm error: \(msg)")
        }
    }

    // Write GEN2
    @IBAction func writeGen2Action(_: Any) {
        view.endEditing(true)
        gswifi.clearBuffer()
        gswifi.writeUHF(dataFormat: "H", startBlockNo: 2, byteSize: 12, Gen2MemoryBank: "E", dataString: "11223344556677889900AABB") { msg in
            DispatchQueue.main.async {
                self.showDialog(title: "Error", msg: msg)
                return
            }
        }
        gswifi.printLabel(set: 1, copy: 1)
        DispatchQueue.main.async {
            self.showDialog(title: "Write EPC", msg: "11223344556677889900AABB")
        }
    }

    @IBAction func readGen2Action(_: Any) {
        view.endEditing(true)
        gswifi.readUHF(dataFormat: "H", startBlockNo: 2, byteSize: 12, Gen2MemoryBank: "E") { msg in
            DispatchQueue.main.async {
                if msg == ViewController.connectStatusEnum.noConnection.rawValue {
                    self.showDialog(title: "Error", msg: msg)
                } else if msg == self.timeOutMsg {
                    self.showDialog(title: "Error", msg: "time out")
                } else {
                    self.showDialog(title: "Read GEN2", msg: msg)
                }
            }
        }
    }

    @IBAction func readGen2QueryAction(_: Any) {
        view.endEditing(true)
        gswifi.query_UHF(dataFormat: "H", PCReturnStatus: 1, CRCReturnStatus: 1) { msg in
            DispatchQueue.main.async {
                if msg == ViewController.connectStatusEnum.noConnection.rawValue {
                    self.showDialog(title: "Error", msg: msg)
                    return
                } else if msg == self.timeOutMsg {
                    self.showDialog(title: "Error", msg: "time out")
                    return
                } else {
                    self.showDialog(title: "Read Query", msg: msg)
                    return
                }
            }
        }
    }

    // MARK: - GJB Action

    @IBAction func setGjbStatusAction(_: Any) {
        view.endEditing(true)
        gswifi.clearBuffer()
        gswifi.set_GJB_Status_UHF(GJBMemoryBank: "E", action: "A", statusPassword: "12345678") { msg in
            DispatchQueue.main.async {
                self.showDialog(title: "Error", msg: msg)
                return
            }
        }
        gswifi.printLabel(set: 1, copy: 1)
        DispatchQueue.main.async {
            self.showDialog(title: "set GJB Status", msg: "readable & writable")
        }
    }

    @IBAction func writeGjbAction(_: Any) {
        view.endEditing(true)
        gswifi.clearBuffer()
        gswifi.writeGJB_UHF(dataFormat: "H", startBlockNo: 1, byteSize: 12, GJBMemoryBank: "E", dataString: "404041414242434344444545", writePassword: "12345678") { msg in
            DispatchQueue.main.async {
                self.showDialog(title: "Error", msg: msg)
                return
            }
        }
        gswifi.printLabel(set: 1, copy: 1)
        DispatchQueue.main.async {
            self.showDialog(title: "Write GJB EPC", msg: "404041414242434344444545")
        }
    }

    @IBAction func readGjbAction(_: Any) {
        view.endEditing(true)
        gswifi.readGJB_UHF(dataFormat: "H", startBlockNo: 1, byteSize: 12, GJBMemoryBank: "E", readPassword: "12345678") { msg in
            DispatchQueue.main.async {
                if msg == ViewController.connectStatusEnum.noConnection.rawValue {
                    self.showDialog(title: "Error", msg: msg)
                    return
                } else if msg == self.timeOutMsg {
                    self.showDialog(title: "Error", msg: "time out")
                    return
                } else {
                    self.showDialog(title: "Read GJB", msg: msg)
                    return
                }
            }
        }
    }
    
    @IBAction func rfidDefault_onClick(_ sender: Any) {
        gswifi.rfidSetupDefault()
    }
    
    @IBAction func rfidCalibration_onClick(_ sender: Any) {
        gswifi.rfid_calibration { msg in
            self.showDialog(title: "Error", msg: msg)
            return
        }
    }

    // MARK: - Real Time Action

    @IBAction func realTimeOnAction(_: Any) {
        view.endEditing(true)
        gswifi.setRealTimeStatus("1") { msg in
            self.showDialog(title: "Error", msg: msg)
            return
        }
        isRealTimeOn = true
    }

    @IBAction func realTimeOffAction(_: Any) {
        view.endEditing(true)
        gswifi.setRealTimeStatus("0") { msg in
            self.showDialog(title: "Error", msg: msg)
            return
        }
        isRealTimeOn = false
        DispatchQueue.main.async {
            self.realTimeShowLabel.text = "Off"
        }
    }

    @IBAction func getRealTimeStatusAction(_: Any) {
        view.endEditing(true)
        gswifi.getRealTimeStatus { msg in
            switch msg {
            case "time_out":
                DispatchQueue.main.async {
                    self.showDialog(title: "Alert", msg: "Time Out")
                }
            case "FB:1\r\n":
                self.isRealTimeOn = true
                DispatchQueue.main.async {
                    self.showDialog(title: "Alert", msg: "Function On")
                }
            case "FB:0\r\n":
                self.isRealTimeOn = false
                DispatchQueue.main.async {
                    self.showDialog(title: "Alert", msg: "Function Off")
                }
            default:
                DispatchQueue.main.async {
                    self.showDialog(title: "Error", msg: msg)
                }
            }
        }
    }

    // MARK: Perpare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ErrorCodeViewController {
            let errorStr = gswifi.getRFIDErrorCode()
            controller.errorCodeString = errorStr
        }
            
        
    }

    // MARK: other function

    @objc func hidingKeyboard() {
        view.endEditing(true)
    }

    /* 關閉鍵盤 */
//    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
//        UIView.animate(withDuration: 0.3) {
//            self.view.endEditing(true)
//        }
//    }

    // dialog function
    private func showDialog(title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true, completion: nil)
    }

    private func layoutInsideScrollerView() {
#warning("隨元件行數更改。")
        let height = calculateTotalHeight(componentNum: 49)

        let moblieWidth = UIScreen.main.bounds.width

        mScrollView.contentLayoutGuide.owningView?.translatesAutoresizingMaskIntoConstraints = false
        mScrollView.contentLayoutGuide.centerXAnchor.constraint(equalTo: mScrollView.centerXAnchor).isActive = true
        mScrollView.contentLayoutGuide.widthAnchor.constraint(equalToConstant: moblieWidth).isActive = true
        mScrollView.contentLayoutGuide.heightAnchor.constraint(equalToConstant: height).isActive = true

        mStackView.translatesAutoresizingMaskIntoConstraints = false
        mStackView.centerXAnchor.constraint(equalTo: mScrollView.contentLayoutGuide.centerXAnchor).isActive = true
        mStackView.topAnchor.constraint(equalTo: mScrollView.contentLayoutGuide.topAnchor, constant: 10).isActive = true
        mStackView.trailingAnchor.constraint(equalTo: mScrollView.contentLayoutGuide.trailingAnchor, constant: -10).isActive = true
        mStackView.bottomAnchor.constraint(equalTo: mScrollView.contentLayoutGuide.bottomAnchor, constant: -10).isActive = true
        mStackView.leadingAnchor.constraint(equalTo: mScrollView.contentLayoutGuide.leadingAnchor, constant: 10).isActive = true

        setCornerRadius(connectButton)
        setCornerRadius(disconnectButton)
        setCornerRadius(printSetupButton)
        setCornerRadius(printBarcodeButton)
        setCornerRadius(printQRcodeButton)
        setCornerRadius(printBmpButton)
        setCornerRadius(printSimpChinButton)
        setCornerRadius(printFontBlockButton)
        setCornerRadius(printStautsButton)
        setCornerRadius(topDirectionButton)
        setCornerRadius(bottomDirectionButton)
        setCornerRadius(mirrorButton)
        setCornerRadius(setShiftButton)
        setCornerRadius(setReverseButton)
        setCornerRadius(setOffsetButton)
        setCornerRadius(setCutModeButton)
        setCornerRadius(setTearButton)
        setCornerRadius(setPeelButton)
        setCornerRadius(setCutForwardButton)
        setCornerRadius(genericDefaultButton)
        setCornerRadius(sensorDefaultButton)
        setCornerRadius(printPicture1Button)
        setCornerRadius(printPicture3Button)
        setCornerRadius(wifiTo24GButton)
        setCornerRadius(wifiTo5GButton)
        setCornerRadius(wifiToBothButton)
        setCornerRadius(getSDKVerButton)
        
        setCornerRadius(showRFIDErrorCodeBtn)
        showRFIDErrorCodeBtn.setTitle("Error Code", for: .normal)
        setCornerRadius(setReadPositionBtn)
        setCornerRadius(writeGen2Btn)
        setCornerRadius(readGen2Btn)
        setCornerRadius(readGen2QueryBtn)
        setCornerRadius(setGjbBtn)
        setCornerRadius(writeGjbBtn)
        setCornerRadius(readGjbBtn)
        setCornerRadius(rfidDefaultBtn)
        setCornerRadius(rfidCalibrationBtn)
        
        setCornerRadius(realTimeStatusOnBtn)
        setCornerRadius(realTimeStatusOffBtn)
        setCornerRadius(getRealTimeBtn)

        IPText.keyboardType = .numbersAndPunctuation
        PortText.keyboardType = .numberPad
        yShiftTextField.keyboardType = .numberPad
        pictureWidthTextField.keyboardType = .numberPad
        pictureHeightTextField.keyboardType = .numberPad
        printerDPITextField.keyboardType = .numberPad
    }

    // 每秒讀取印表機狀態
    private func readPrinterStatusEverySecond() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
            if let statusNumber = self.gswifi.getStatusNumber() {
                let statusStr = self.readStatusNumber(statusNumber)
                DispatchQueue.main.async {
                    self.realTimeShowLabel.text = statusStr
                }
            }
        })
    }

    private func calculateTotalHeight(componentNum: Int) -> CGFloat {
        let blockNum = componentNum - 1
        let totalHeight = 39 * componentNum + 20 * blockNum
        return CGFloat(totalHeight)
    }

    private func setCornerRadius(_ button: UIButton) {
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
    }

    private func readStatusNumber(_ statusNumber: String) -> String {
        var statusStr = "Other error"
        switch statusNumber {
        case "00":
            statusStr = "Normal"
        case "01":
            statusStr = "Head opened"
        case "02":
            statusStr = "Paper Jam"
        case "03":
            statusStr = "Paper Jam and head opened"
        case "04":
            statusStr = "Out of paper"
        case "05":
            statusStr = "Out of paper and head opened"
        case "08":
            statusStr = "Out of ribbon"
        case "09":
            statusStr = "Out of ribbon and head opened"
        case "0A":
            statusStr = "Out of ribbon and paper jam"
        case "0B":
            statusStr = "Out of ribbon, paper jam and head opened"
        case "0C":
            statusStr = "Out of ribbon and out of paper"
        case "0D":
            statusStr = "Out of ribbon, out of paper and head opened"
        case "10":
            statusStr = "Pause"
        case "20":
            statusStr = "Printing"
        case "80":
            statusStr = "Other error"
        default:
            break
        }
        return statusStr
    }
    
    /// 打開圖片選擇器
    @available(iOS 14, *)
    private func openPHPicker() {
        let configuration = phPickerSetting()
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @available(iOS 14, *)
    private func phPickerSetting() -> PHPickerConfiguration {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        // 選擇照片的檔案類型 圖片 動態圖片 或 影片
        configuration.filter = PHPickerFilter.images
        // 打開看到的第一個畫面嗎?
        configuration.preferredAssetRepresentationMode = .current
        // 可選的照片上限
        configuration.selectionLimit = 1
        return configuration
    }
    
    private func loadImage() {
        if #available(iOS 14, *) {
            openPHPicker()
        } else {
            mImagePicker.sourceType = .savedPhotosAlbum
            present(mImagePicker, animated: true, completion: nil)
        }
    }
}

// MARK: - photo delegate

extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // 拍照回傳照片，壓縮成1/5大小
        if let image = info[.originalImage] as? UIImage {
            // 1 壓縮圖片
            let jpgDataOneFifth = image.jpegData(compressionQuality: 0.2)
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

// 從相簿選取的照片，限定只能選一張
@available(iOS 14, *)
extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        var newSelection = [String: PHPickerResult]()
        let selectedAssetIdentifiers = results.map(\.assetIdentifier!)
        var selectedAssetIdentifierIterator: IndexingIterator<[String]>?
        selectedAssetIdentifierIterator = selectedAssetIdentifiers.makeIterator()
        for result in results {
            let identifier = result.assetIdentifier!
            newSelection[identifier] = result
        }
        guard let assetIdentifier = selectedAssetIdentifierIterator?.next() else { return }
        
        let itemProvider = newSelection[assetIdentifier]!.itemProvider
        
        if mPrintMode == 1 {
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                _ = itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            // (1) 查看檔案大小
                            if let imageJpegData = image.jpegData(compressionQuality: 1) {
                                let imageJpegDataSize = imageJpegData.count
                                print("原始圖片大小：", imageJpegDataSize, "bytes")
                                if let widthStr = self?.pictureWidthTextField.text,
                                   let heightStr = self?.pictureHeightTextField.text,
                                   let width = Int(widthStr),
                                   let height = Int(heightStr) {
                                    self?.gswifi.clearBuffer()
                                    self?.gswifi.printBitmap(imageData: imageJpegData, x: 0, y: 0, width: width, height: height, mode: 1) { errorMessage in
                                        print("Error Message: \(errorMessage)")
                                    }
                                } else {
                                    // 不指定大小
                                    self?.gswifi.clearBuffer()
                                    self?.gswifi.printBitmap(imageData: imageJpegData, x: 0, y: 0, mode: 1) { errorMessage in
                                        print("Error Message: \(errorMessage)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else if mPrintMode == 3 {
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                _ = itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            // (1) 查看檔案大小
                            if let imageJpegData = image.jpegData(compressionQuality: 1) {
                                let imageJpegDataSize = imageJpegData.count
                                print("原始圖片大小：", imageJpegDataSize, "bytes")
                                if let widthStr = self?.pictureWidthTextField.text,
                                   let heightStr = self?.pictureHeightTextField.text,
                                   let width = Int(widthStr),
                                   let height = Int(heightStr) {
                                    self?.gswifi.clearBuffer()
                                    self?.gswifi.printBitmap(imageData: imageJpegData, x: 0, y: 0, width: width, height: height, mode: 3) { errorMessage in
                                        print("Error Message: \(errorMessage)")
                                    }
                                } else {
                                    // 不指定大小
                                    self?.gswifi.clearBuffer()
                                    self?.gswifi.printBitmap(imageData: imageJpegData, x: 0, y: 0, mode: 3) { errorMessage in
                                        print("Error Message: \(errorMessage)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
