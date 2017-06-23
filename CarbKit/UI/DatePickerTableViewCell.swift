//
//  DatePickerTableViewCell.swift
//  CarbKit
//
//  Created by Nathan Racklyeft on 1/15/16.
//  Copyright © 2016 Nathan Racklyeft. All rights reserved.
//

import UIKit

protocol DatePickerTableViewCellDelegate: class {
    func datePickerTableViewCellDidUpdateDate(_ cell: DatePickerTableViewCell)
}


class DatePickerTableViewCell: UITableViewCell {

    weak var delegate: DatePickerTableViewCellDelegate?

    var date: Date {
        get {
            return datePicker.date
        }
        set {
            datePicker.setDate(newValue, animated: true)
            updateDateLabel()
        }
    }

    var duration: TimeInterval {
        get {
            return datePicker.countDownDuration
        }
        set {
            datePicker.countDownDuration = newValue
            updateDateLabel()
        }
    }

    private lazy var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()

        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .short

        return formatter
    }()

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var datePicker: UIDatePicker!

    @IBOutlet weak var datePickerHeightConstraint: NSLayoutConstraint!

    private var datePickerExpandedHeight: CGFloat = 0

    var isDatePickerHidden: Bool {
        get {
            return datePicker.isHidden || !datePicker.isEnabled
        }
        set {
            if datePicker.isEnabled {
                datePicker.isHidden = newValue
                datePickerHeightConstraint.constant = newValue ? 0 : datePickerExpandedHeight

                if newValue {
                    // Workaround for target-action change notifications not firing if initial value is set while view is hidden
                    DispatchQueue.main.async {
                        self.datePicker.countDownDuration = self.datePicker.countDownDuration
                        self.datePicker.date = self.datePicker.date
                    }
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        datePickerExpandedHeight = datePickerHeightConstraint.constant

        setSelected(true, animated: false)
        updateDateLabel()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            isDatePickerHidden = !isDatePickerHidden
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.layoutMargins.left = separatorInset.left
        contentView.layoutMargins.right = separatorInset.left
    }

    private func updateDateLabel() {
        switch datePicker.datePickerMode {
        case .countDownTimer:
            dateLabel.text = durationFormatter.string(from: duration)
        case .date, .dateAndTime, .time:
            dateLabel.text = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
        }
    }

    @IBAction func dateChanged(_ sender: UIDatePicker) {
        updateDateLabel()

        delegate?.datePickerTableViewCellDidUpdateDate(self)
    }
}
