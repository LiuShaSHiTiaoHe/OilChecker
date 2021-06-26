//
//  FuelConsumptionView.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/25.
//

import UIKit
import Charts
import RealmSwift
import BetterSegmentedControl

class FuelConsumptionView: UIView {
    let realm = try! Realm()
    var currentDevice: UserAndCarModel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action handlers
    @objc func segmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        
        guard currentDevice != nil else {
            return
        }
        if sender.index == 0{
            let dataSource = RealmHelper.queryObject(objectClass: FuelConsumptionModel(), filter: "deviceID = '\(currentDevice.deviceID)' ").sorted { $0.recordIDFromDevice < $1.recordIDFromDevice}.suffix(20)
            updateChartData(Array(dataSource))
        }else if sender.index == 1{
            let dataSource = RealmHelper.queryObject(objectClass: FuelConsumptionModel(), filter: "deviceID = '\(currentDevice.deviceID)' ").sorted { $0.recordIDFromDevice < $1.recordIDFromDevice}.suffix(40)
            updateChartData(Array(dataSource))
        }else {
            let dataSource = RealmHelper.queryObject(objectClass: FuelConsumptionModel(), filter: "deviceID = '\(currentDevice.deviceID)' ").sorted { $0.recordIDFromDevice < $1.recordIDFromDevice}.suffix(60)
            updateChartData(Array(dataSource))
        }
    }
    
    func updateCurrentDevice(model: UserAndCarModel) {
        currentDevice = model
//        let dataSource = RealmHelper.queryObject(objectClass: FuelConsumptionModel(), filter: "deviceID = '\(currentDevice.deviceID)' ").sorted { $0.recordIDFromDevice < $1.recordIDFromDevice}.suffix(50)
        let dataSource = RealmHelper.queryObject(objectClass: FuelConsumptionModel(), filter: "deviceID = '\(currentDevice.deviceID)' ").sorted { $0.recordIDFromDevice < $1.recordIDFromDevice}
//        var datas: [FuelConsumptionModel] = []
//        for index in 0...2000 {
//            let model = FuelConsumptionModel.init()
//            model.recordIDFromDevice = Int64(index)
//            model.consumption = drand48()*200
//            datas.append(model)
//        }
//
//        updateChartData(datas)
        updateChartData(Array(dataSource))
    }
    
    func updateChartData(_ dataSource: [FuelConsumptionModel]) {
 
        if dataSource.count == 0 {
            emptyImageView.isHidden = false
            fuelChartView.isHidden = true
            return
        }else{
            emptyImageView.isHidden = true
            fuelChartView.isHidden = false
        }
        
        let values = dataSource.map { (model) -> BarChartDataEntry in
            return BarChartDataEntry(x: Double(model.recordIDFromDevice), y: model.consumption)
        }
  
        let set1 = BarChartDataSet(entries: values, label: "Consumption")
        set1.setColor(kRedAlphaColor)
        set1.highlightColor = kRedFontColor
        set1.drawValuesEnabled = true
        set1.valueTextColor = kBlackColor
        set1.axisDependency = .left
        let data = BarChartData(dataSet: set1)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
        data.barWidth = 0.9
        fuelChartView.data = data
        
//        fuelChartView.zoomToCenter(scaleX: values.count.cgFloat/15, scaleY: 1)
        fuelChartView.zoomAndCenterViewAnimated(scaleX: values.count.cgFloat/15, scaleY: 1, xValue: values.last!.x, yValue: values.last!.y, axis: .left, duration: 0.1)
    }
    
    
//    func updateChartAxis() {
//        let xAxis = fuelChartView.xAxis
//        xAxis.labelPosition = .bottom
//        xAxis.labelFont = k10Font
//        xAxis.labelTextColor = kSecondBlackColor
//        xAxis.drawAxisLineEnabled = false
//        xAxis.drawGridLinesEnabled = false
//
//        
//        let leftAxis = fuelChartView.leftAxis
//        leftAxis.labelPosition = .outsideChart
//        leftAxis.labelFont = k12Font
//        leftAxis.axisMinimum = 0
//        leftAxis.axisMaximum = 170
//        leftAxis.yOffset = -9
//        leftAxis.labelTextColor = kSecondBlackColor
//        leftAxis.gridColor = kLightGaryFontColor
//    }
    
    
    func initUI() {
        self.layer.cornerRadius = 10
        self.backgroundColor = kWhiteColor
        
        self.addSubview(emptyImageView)
        self.addSubview(detailButton)
        self.addSubview(fuelChartView)
        
        emptyImageView.isHidden = false
        fuelChartView.isHidden = true
        
        detailButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-kMargin)
            make.top.equalToSuperview().offset(kMargin)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        emptyImageView.snp.makeConstraints { make  in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(200)
            make.centerY.equalToSuperview().offset(kMargin)
        }
        
        fuelChartView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(detailButton.snp.bottom)
            make.bottom.equalToSuperview().offset(-kMargin/2)
        }
    }

    
    lazy var segment: BetterSegmentedControl = {
        let segmentedControl = BetterSegmentedControl(
            frame: CGRect.zero,
            segments: LabelSegment.segments(withTitles: ["Week".localized(), "Month".localized(),"Year".localized()],
                                            normalTextColor: kWhiteColor,
                                            selectedTextColor: kThemeGreenColor),
            options:[.backgroundColor(kThemeGreenColor),
                     .indicatorViewBackgroundColor(kWhiteColor),
                     .cornerRadius(15.0),
                     .animationSpringDamping(1.0)])
        segmentedControl.addTarget(self,action: #selector(segmentedControlValueChanged(_:)),for: .valueChanged)
        segmentedControl.alwaysAnnouncesValue = true
        return segmentedControl
    }()
    
    lazy var detailButton: ExpandButton = {
        let btn = ExpandButton.init(type: .custom)
        btn.setImage(UIImage(named: "btn_list_icon"), for: .normal)
        return btn
    }()
    
    lazy var lineView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(hex: 0x515151, transparency: 0.2)
        return view
    }()
    
    lazy var fuelChartView: BarChartView = {
        let chartView = BarChartView.init()
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = true
//        chartView.maxVisibleCount = 20
        chartView.legend.enabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.rightAxis.enabled = false
        chartView.scaleYEnabled = false
        chartView.setVisibleXRangeMinimum(20)

        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 7
//        xAxis.axisMaximum = 200
    
        xAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0
        
        return chartView
    }()
    
    lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "em_charts")
        return imageView
    }()

    
}
