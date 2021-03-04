//
//  Texts.swift
//  CallCenterContacts
//
//  Created by jang gukjin on 2020/04/22.
//  Copyright © 2020 jang gukjin. All rights reserved.
//

import Foundation

enum Texts: String, CaseIterable {
    case title = "CC Book"
    case confirm = "OK"
    case cancle = "cancle"
    case alertTitle = "추가하기"
    case alertContents = "이름과 번호를 입력하세요"
    case overlap = "중복된 이름"
    case overlapMessage = "중복되지 않는 이름을 입력해주세요"
    case anotherListOverlapTitle = "다른 항목에 존재하는 이름"
    case anotherListOverlapMessage = "다른 항목에서 즐겨찾기를 해주세요"
    case fail = "등록 실패"
    case emptyName = "이름을 입력하세요."
    case emptyNumber = "번호를 입력하세요."
    case name = "name"
    case number = "number"
    case callingNotSupport = "Calling not supported"

}
