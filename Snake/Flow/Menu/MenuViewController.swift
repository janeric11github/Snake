//
//  MenuViewController.swift
//  Snake
//
//  Created by Eric on 2021/7/6.
//

import UIKit
import Combine

final class MenuViewController: UIViewController {
    private let viewModel: MenuViewModel
    
    private var disposeBag = Set<AnyCancellable>()
    
    init(viewModel: MenuViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupSubviews()
        
        viewModel.$action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                guard let self = self else { return }
                self.actionButton.setTitle(action.title, for: .normal)
                self.actionButton.addAction(.init { _ in action.handler?() }, for: .touchUpInside)
            }
            .store(in: &disposeBag)
    }
    
    // MARK: - Subviews
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 36, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private func setupSubviews() {
        view.backgroundColor = .black.withAlphaComponent(0.3)
        
        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        actionButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        actionButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        actionButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
