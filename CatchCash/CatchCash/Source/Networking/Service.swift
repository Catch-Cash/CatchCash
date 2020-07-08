//
//  Service.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/08.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import Alamofire
import RxAlamofire
import RxSwift

private func requestData(_ api: API) -> Observable<(HTTPURLResponse, Data)> {
    return requestData(api.method,
                       api.baseURL + api.path,
                       parameters: api.parameters,
                       encoding: JSONEncoding.prettyPrinted,
                       headers: api.headers)
}

