import UIKit
import Kingfisher

class AdvertisementCell: UITableViewCell {
    static let identifier = "AdvertisementCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let adImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray6
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let knowMoreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Know More", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        button.backgroundColor = .white
        button.layer.cornerRadius = 19
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let sponsoredLabel: UILabel = {
        let label = UILabel()
        label.text = "Sponsored"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let whatsappButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(" WhatsApp", for: .normal)
        button.setImage(UIImage(named: "whatsappshare"), for: .normal)
        button.setTitleColor(UIColor(red: 37/255, green: 211/255, blue: 102/255, alpha: 1), for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.layer.cornerRadius = 22
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor(red: 37/255, green: 211/255, blue: 102/255, alpha: 1).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let callButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(" Call", for: .normal)
        button.setImage(UIImage(named: "call"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.layer.cornerRadius = 22
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var onKnowMore: (() -> Void)?
    var onWhatsapp: (() -> Void)?
    var onCall: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .white
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(adImageView)
        containerView.addSubview(knowMoreButton)
        containerView.addSubview(sponsoredLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(whatsappButton)
        containerView.addSubview(callButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            adImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            adImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            adImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            adImageView.heightAnchor.constraint(equalToConstant: 600),
            
            knowMoreButton.bottomAnchor.constraint(equalTo: adImageView.bottomAnchor, constant: -20),
            knowMoreButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            knowMoreButton.widthAnchor.constraint(equalToConstant: 120),
            knowMoreButton.heightAnchor.constraint(equalToConstant: 38),
            
            sponsoredLabel.topAnchor.constraint(equalTo: adImageView.bottomAnchor, constant: 12),
            sponsoredLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            descriptionLabel.topAnchor.constraint(equalTo: sponsoredLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            whatsappButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            whatsappButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            whatsappButton.heightAnchor.constraint(equalToConstant: 44),
            whatsappButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            callButton.topAnchor.constraint(equalTo: whatsappButton.topAnchor),
            callButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            callButton.leadingAnchor.constraint(equalTo: whatsappButton.trailingAnchor, constant: 20),
            callButton.widthAnchor.constraint(equalTo: whatsappButton.widthAnchor),
            callButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        knowMoreButton.addTarget(self, action: #selector(knowMoreTapped), for: .touchUpInside)
        whatsappButton.addTarget(self, action: #selector(whatsappTapped), for: .touchUpInside)
        callButton.addTarget(self, action: #selector(callTapped), for: .touchUpInside)
    }
    
    func configure(with ad: AdvertisementModel) {
        titleLabel.isHidden = true // In screenshot, title is not shown below image
        descriptionLabel.text = ad.description
        knowMoreButton.setTitle("Know More", for: .normal)
        
        if let firstImage = ad.images?.first {
            adImageView.kf.setImage(with: URL(string: firstImage), placeholder: UIImage(named: "news_placeholder"))
        } else {
            adImageView.image = UIImage(named: "news_placeholder")
        }
    }
    
    @objc private func knowMoreTapped() { onKnowMore?() }
    @objc private func whatsappTapped() { onWhatsapp?() }
    @objc private func callTapped() { onCall?() }
}
