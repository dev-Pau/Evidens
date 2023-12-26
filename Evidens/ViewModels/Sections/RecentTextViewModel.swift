//
//  RecentTextCellViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/5/22.
//

import UIKit

/// The viewModel for a RecentText.
struct RecentTextViewModel {
    
    let recentText: String
    
    var textToDisplay: String {
        return recentText
    }
}
