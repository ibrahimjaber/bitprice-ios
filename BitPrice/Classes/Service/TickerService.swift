//
//  TickerService.swift
//  BitPrice
//
//  Created by Bruno Tortato Furtado on 02/02/18.
//  Copyright © 2018 Bruno Tortato Furtado. All rights reserved.
//

import Foundation

class TickerService: Service<Ticker> {

    // MARK: - Variable

    weak var delegate: TickerServiceDelegate?

    private let apiService = TickerApiService()

    // MARK: - Public

    func get() {
        apiService.get(success: { (data) in
            self.success(data: data)
        }, failure: { failure in
            self.failure(failure)
        })
    }

    // MARK: - Private

    private func success(data: Data) {
        DispatchQueue.main.async {
            if let ticker = self.jsonDecode(data: data) {
                let date = Date()
                self.delegate?.tickerGetDidComplete(ticker: ticker, date: date, fromCache: false)
                self.dbInsert(data: data, date: date)
            } else {
                self.delegate?.tickerGetDidComplete(failure: .server)
            }
        }
    }

    private func failure(_ failure: ServiceFailureType) {
        DispatchQueue.main.async {
            guard let request = RequestDbService().fetch(reference: nil) else {
                self.delegate?.tickerGetDidComplete(failure: failure)
                return
            }

            if let ticker = self.jsonDecode(data: request.data) {
                self.delegate?.tickerGetDidComplete(ticker: ticker, date: request.date, fromCache: true)
                return
            }

            self.delegate?.tickerGetDidComplete(failure: failure)
        }
    }

}

protocol TickerServiceDelegate: class {
    func tickerGetDidComplete(ticker: Ticker, date: Date, fromCache: Bool)
    func tickerGetDidComplete(failure: ServiceFailureType)
}
