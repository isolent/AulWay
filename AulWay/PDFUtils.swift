//
//  PDFUtils.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 01.04.2025.
//

import UIKit

func createPDF(from view: UIView) -> Data {
    let pdfRenderer = UIGraphicsPDFRenderer(bounds: view.bounds)
    return pdfRenderer.pdfData { context in
        context.beginPage()
        view.layer.render(in: context.cgContext)
    }
}
