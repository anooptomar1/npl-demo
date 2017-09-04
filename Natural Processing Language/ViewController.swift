//
//  ViewController.swift
//  Natural Processing Language
//
//  Created by Oscar De Moya on 9/4/17.
//  Copyright © 2017 Koombea. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var textField: UITextField!
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func proccessText() {
        textView.text = ""
        guard let text = textField.text else { return }
        processTextWithLinguisticTagger(text)
        processTextWithDataDetector(text)
    }
    
    func processTextWithLinguisticTagger(_ text: String) {
        let tagger = NSLinguisticTagger(tagSchemes: [.nameType], options: 0)
        tagger.string = text
        let range = NSRange(location: 0, length: text.characters.count)
        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tags: [NSLinguisticTag] = [.placeName]
        var result = ""
        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { tag, tokenRange, stop in
            if let tag = tag, tags.contains(tag) {
                let name = (text as NSString).substring(with: tokenRange)
                result.append("\(tag.rawValue): \(name)\n")
            }
        }
        textView.text.append(contentsOf: result)
    }
    
    func processTextWithDataDetector(_ text: String) {
        guard let text = textField.text else { return }
        var result = ""
        let types: NSTextCheckingResult.CheckingType = [.address , .date, .transitInformation]
        let dataDetector = try? NSDataDetector(types: types.rawValue)
        dataDetector?.enumerateMatches(in: text, options: [], range: NSMakeRange(0, text.characters.count)) { (match, flags, _) in
            guard let match = match else { return }
            let matchString = (text as NSString).substring(with: match.range)
            result.append("\(match.resultType.name): \(matchString)\n")
            if match.resultType == .address, let address = match.addressComponents {
                result.append("Address Components:\n")
                address.forEach { (key, value) in
                    result.append("\(key.rawValue): \(value)\n")
                }
            }
            if match.resultType == .date, let date = match.date {
                result.append("\(date)\n")
            }
        }
        textView.text.append(contentsOf: result)
    }
    
}

extension NSTextCheckingResult.CheckingType {
    
    var name: String {
        switch self {
        case .address: return "Address"
        case .date: return "Date"
        case .phoneNumber: return "Phone Number"
        case .link: return "Link"
        case .transitInformation: return "Flight"
        default: return "\(self)"
        }
    }
    
}

