//
//  RefuelRecord.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/25.
//

import UIKit
import Charts
import RealmSwift

class RefuelRecordView: UIView {
    let realm = try! Realm()
    var currentDevice: UserAndCarModel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateCurrentDevice(model: UserAndCarModel) {
        currentDevice = model
        let startDate = getDataRegion().dateAt(.startOfWeek).date
        let endDate = getDataRegion().dateAt(.endOfWeek).date
        let fuelLeverDataSource = realm.objects(RefuelRecordModel.self).filter("time BETWEEN {%@, %@} and deviceID == %@", startDate, endDate, currentDevice!.deviceID).sorted(byKeyPath: "time")
        let start = startDate.timeIntervalSince1970
        let end = endDate.dateAt(.startOfDay).timeIntervalSince1970
        let xAxis = fuelChartView.xAxis
        xAxis.axisMinimum = start
        xAxis.axisMaximum = end
        xAxis.valueFormatter = WeekValueFormatter()
        xAxis.setLabelCount(7, force: true)
        updateChartData(Array(fuelLeverDataSource))
    }
    
    func updateChartData(_ dataSource: [RefuelRecordModel]) {
 
        let values = dataSource.map { (model) -> ChartDataEntry in
            logger.info("\(model.time)")
            logger.info("\(model.refuelLevel)")
            return ChartDataEntry.init(x: model.time.dateAt(.startOfDay).timeIntervalSince1970, y: model.refuelLevel)
        }
        
        let set1 = LineChartDataSet(entries: values, label: "DataSet 1")
        set1.axisDependency = .left
        set1.setColor(kGreenFontColor)
        set1.lineWidth = 1.0
        set1.mode = .cubicBezier
        set1.drawValuesEnabled = true
        set1.fillAlpha = 0.1
        set1.fillColor = kGreenFontColor
        set1.drawFilledEnabled = true
        set1.drawCirclesEnabled = true
        set1.drawCircleHoleEnabled = false
        set1.setCircleColor(kGreenFontColor)
        set1.circleRadius = 2
        let data = LineChartData(dataSet: set1)
        data.setValueTextColor(kGreenFontColor)
        data.setValueFont(k12Font)
        
        fuelChartView.data = data
    }
    
    
    func updateChartAxis() {
        let xAxis = fuelChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = k10Font
        xAxis.labelTextColor = kSecondBlackColor
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false

        
        let leftAxis = fuelChartView.leftAxis
        leftAxis.labelPosition = .outsideChart
        leftAxis.labelFont = k12Font
//        leftAxis.drawGridLinesEnabled = false
//        leftAxis.granularityEnabled = false
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 170
        leftAxis.yOffset = -9
        leftAxis.labelTextColor = kSecondBlackColor
        leftAxis.gridColor = kLightGaryFontColor

    }
    
    func initUI() {
        self.layer.cornerRadius = 10
        self.backgroundColor = kWhiteColor
        
        self.addSubview(titleLabel)
        self.addSubview(detailButton)
        self.addSubview(lineView)
        self.addSubview(fuelChartView)
        updateChartAxis()
        lineView.isHidden = true
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.top.equalToSuperview().offset(kMargin/2)
            make.height.equalTo(30)
            make.right.equalToSuperview().offset(-100)
        }
        
        detailButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-kMargin/2)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.right.equalToSuperview().offset(-kMargin/2)
            make.height.equalTo(1)
            make.top.equalTo(titleLabel.snp.bottom).offset(kMargin/4)
        }
        
        fuelChartView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(lineView.snp.bottom)
            make.bottom.equalToSuperview().offset(-kMargin/2)
        }
        

    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = kSecondBlackColor
        label.font = k15Font
        label.text = "Refuel Record"
        return label
    }()
    
    lazy var detailButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "icon_arrow"), for: .normal)
        btn.setTitleColor(kBlackColor, for: .normal)
        btn.titleLabel?.font = k13BoldFont
        return btn
    }()
    
    lazy var lineView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(hex: 0x515151, transparency: 0.2)
        return view
    }()
    
    lazy var fuelChartView: LineChartView = {
        let chartView = LineChartView.init()
        chartView.delegate = self
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = false
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        chartView.highlightPerDragEnabled = true
        chartView.rightAxis.enabled = false
        chartView.backgroundColor = .white
        chartView.legend.enabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.animate(xAxisDuration: 1.5)

        
        return chartView
    }()
    
    lazy var emptyView: BaseEmptyView = {
        let view = BaseEmptyView.init()
        view.emptyImageView.image = UIImage.init(named: "em_charts")
        return  view
    }()

}

extension RefuelRecordView: ChartViewDelegate{
    
}
