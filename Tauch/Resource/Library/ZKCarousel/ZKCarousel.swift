//
//  ZKCarousel.swift
//  Delego
//
//  Created by Zachary Khan on 6/8/17.
//  Copyright © 2017 ZacharyKhan. All rights reserved.
//

import UIKit

@objc public protocol ZKCarouselDelegate: AnyObject {
    func carouselDidTap(cell: ZKCarouselCell)
}

final public class ZKCarousel: UIView,
                               UICollectionViewDelegateFlowLayout,
                               UICollectionViewDelegate,
                               UICollectionViewDataSource {
    
    // MARK: - Properties
    private var timer: Timer = Timer()
    public var interval: Double = 1.0
    public var delegate: ZKCarouselDelegate?
    
    public var slides: [ZKCarouselSlide] = [] {
        didSet {
            updateUI()
        }
    }
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(tap:)))
        return tap
    }()
    
    public lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.isPagingEnabled = true
        cv.register(ZKCarouselCell.self, forCellWithReuseIdentifier: ZKCarouselCell.identifier)
        cv.clipsToBounds = true
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.bounces = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // MARK: - Default Methods
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupCarousel()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCarousel()
    }
    
    // MARK: - Internal Methods
    private func setupCarousel() {
        backgroundColor = .clear
        
        addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        collectionView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapGestureHandler(tap: UITapGestureRecognizer?) {
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath: IndexPath = collectionView.indexPathForItem(at: visiblePoint) ?? IndexPath(item: 0, section: 0)
        let index = visibleIndexPath.item

        let indexPathToShow = IndexPath(item: index == slides.count - 1 ? 0 : index + 1, section: 0)
        collectionView.selectItem(at: indexPathToShow,
                                  animated: true,
                                  scrollPosition: .centeredHorizontally)
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Exposed Methods
    public func start() {
        timer = Timer.scheduledTimer(timeInterval: interval,
                                     target: self,
                                     selector: #selector(tapGestureHandler(tap:)),
                                     userInfo: nil,
                                     repeats: true)
        timer.fire()
    }
    
    public func stop() {
        timer.invalidate()
    }
    
    public func disableTap() {
        /* This method is provided in case you want to remove the
         * default gesture and provide your own. The default gesture
         * changes the slides on tap.
         */
        collectionView.removeGestureRecognizer(tapGesture)
    }
    
    // MARK: - UICollectionViewDelegate & DataSource
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZKCarouselCell.identifier, for: indexPath) as! ZKCarouselCell
        cell.slide = slides[indexPath.item]
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZKCarouselCell.identifier, for: indexPath) as! ZKCarouselCell
        cell.slide = slides[indexPath.item]
        delegate?.carouselDidTap(cell: cell)
    }
    
}
