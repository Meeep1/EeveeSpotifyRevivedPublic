import UIKit

final class EeveeSplashScreenController: UIViewController {
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        // אם יש לך לוגו בתיקיית Images
        iv.image = UIImage(named: "AppIcon")
        iv.layer.cornerRadius = 24
        iv.clipsToBounds = true
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "EeveeSpotify"
        l.font = .systemFont(ofSize: 32, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Enhanced Spotify Experience"
        l.font = .systemFont(ofSize: 16, weight: .medium)
        l.textColor = UIColor(white: 1.0, alpha: 0.7)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let creditLabel: UILabel = {
        let l = UILabel()
        l.text = "by jaydenjcpy • forked from Meeep1"
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor(white: 1.0, alpha: 0.5)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let versionLabel: UILabel = {
        let l = UILabel()
        // קרא את הגרסה דינמית מה-plist
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        l.text = "v\(version)"
        l.font = .systemFont(ofSize: 12, weight: .light)
        l.textColor = UIColor(red: 0.11, green: 0.73, blue: 0.33, alpha: 0.8) // ירוק ספוטיפיי
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let dotsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private var dots: [UIView] = []
    private var dotAnimationTimer: Timer?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance()
        startDotAnimation()
        scheduleDismissal()
    }
    
    // MARK: - Setup
    
    private func setupBackground() {
        // גרדיאנט שחור עם גוון ירוק
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1).cgColor,
            UIColor(red: 0.02, green: 0.15, blue: 0.07, alpha: 1).cgColor,
            UIColor(red: 0.0,  green: 0.0,  blue: 0.0,  alpha: 1).cgColor
        ]
        gradient.locations = [0, 0.5, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint   = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        containerView.addSubview(logoImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(creditLabel)
        containerView.addSubview(versionLabel)
        
        // נקודות אנימציה
        for i in 0..<3 {
            let dot = UIView()
            dot.backgroundColor = i == 0
                ? UIColor(red: 0.11, green: 0.73, blue: 0.33, alpha: 1) // ירוק
                : UIColor(white: 1, alpha: 0.3)
            dot.layer.cornerRadius = 4
            dot.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 8),
                dot.heightAnchor.constraint(equalToConstant: 8)
            ])
            dotsStackView.addArrangedSubview(dot)
            dots.append(dot)
        }
        containerView.addSubview(dotsStackView)
        
        // התחל כבלתי נראה לאנימציה
        containerView.alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            logoImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            
            creditLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            creditLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 4),
            
            versionLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            versionLabel.topAnchor.constraint(equalTo: creditLabel.bottomAnchor, constant: 4),
            
            dotsStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            dotsStackView.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 30),
            dotsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    // MARK: - Animations
    
    private func animateEntrance() {
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.containerView.alpha = 1
            self.containerView.transform = .identity
        }
    }
    
    private func startDotAnimation() {
        var currentDot = 0
        dotAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            for (i, dot) in self.dots.enumerated() {
                UIView.animate(withDuration: 0.2) {
                    dot.backgroundColor = i == currentDot
                        ? UIColor(red: 0.11, green: 0.73, blue: 0.33, alpha: 1)
                        : UIColor(white: 1, alpha: 0.3)
                    dot.transform = i == currentDot
                        ? CGAffineTransform(scaleX: 1.4, y: 1.4)
                        : .identity
                }
            }
            currentDot = (currentDot + 1) % self.dots.count
        }
    }
    
    private func scheduleDismissal() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.dismissSplash()
        }
    }
    
    private func dismissSplash() {
        dotAnimationTimer?.invalidate()
        dotAnimationTimer = nil
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn) {
            self.containerView.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
}
