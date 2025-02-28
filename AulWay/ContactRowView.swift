//
//  ContactRowView.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 28.02.2025.
//

import UIKit

class ContactRowView: UIView {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backgroundContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.3, alpha: 0.7) 
        view.layer.cornerRadius = 25
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        view.layer.cornerRadius = 25
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(icon: UIImage?, text: String) {
        super.init(frame: .zero)
        
        iconImageView.image = icon
        textLabel.text = text
        
        addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        addSubview(backgroundContainer)
        backgroundContainer.addSubview(textLabel)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Icon Container
            iconContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 50),
            iconContainer.heightAnchor.constraint(equalToConstant: 50),
            
            // Icon ImageView
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Background Container
            backgroundContainer.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 10),
            backgroundContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            backgroundContainer.heightAnchor.constraint(equalToConstant: 50),
            
            // Text Label
            textLabel.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor, constant: 15),
            textLabel.centerYAnchor.constraint(equalTo: backgroundContainer.centerYAnchor)
        ])
    }
}

