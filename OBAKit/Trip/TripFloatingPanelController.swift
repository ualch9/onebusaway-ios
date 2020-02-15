//
//  TripDetailsController.swift
//  OBAKit
//
//  Created by Aaron Brethorst on 8/4/19.
//

import UIKit
import IGListKit
import OBAKitCore

/// Displays a list of stops for the trip corresponding to an `ArrivalDeparture` object.
public class TripFloatingPanelController: UIViewController, ListProvider, ListAdapterDataSource, ListKitStopConverters, AppContext {

    let application: Application

    var tripDetails: TripDetails? {
        didSet {
            if isLoadedAndOnScreen {
                collectionController.reload(animated: false)
            }
        }
    }

    var tripConvertible: TripConvertible? {
        didSet {
            if isLoadedAndOnScreen, let arrivalDeparture = stopArrivalView.arrivalDeparture {
                stopArrivalView.arrivalDeparture = arrivalDeparture
            }
        }
    }

    private let operation: TripDetailsModelOperation?

    // MARK: - Init/Deinit

    /// Initializes the `TripDetailsController` with an OBA application object.
    /// - Parameter application: The application object
    /// - Parameter tripConvertible: Optional `TripConvertible` object.
    ///
    /// It is assumed that the creator of this controller will pass in a `TripDetails` object via
    /// the `tripDetails` property later on in order to finish configuring this controller.
    init(application: Application, tripConvertible: TripConvertible? = nil) {
        self.application = application
        self.tripConvertible = tripConvertible
        self.operation = nil

        super.init(nibName: nil, bundle: nil)
    }

    /// Initializes the `TripDetailsController` with an OBA application object and an in-flight model operation.
    /// - Parameter application: The application object
    /// - Parameter operation: An operation that will result in a `TripDetails` object that can be used to finish configuring this controller.
    init(application: Application, operation: TripDetailsModelOperation) {
        self.application = application
        self.operation = operation

        super.init(nibName: nil, bundle: nil)

        self.operation?.then { [weak self] in
            guard let self = self else { return }
            self.tripDetails = self.operation?.tripDetails
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        operation?.cancel()
    }

    // MARK: - UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ThemeColors.shared.systemBackground

        prepareChildController(collectionController) {
            view.addSubview(outerStack)
            outerStack.pinToSuperview(.edges)
        }
    }

    // MARK: - Public Methods

    public func highlightStopInList(_ stop: Stop) {
        var listItem: TripStopListItem?

        for obj in collectionController.listAdapter.objects() {
            if let obj = obj as? TripStopListItem {
                if obj.stop.id == stop.id {
                    listItem = obj
                    break
                }
            }
        }

        if let listItem = listItem {
            collectionController.listAdapter.scroll(to: listItem, supplementaryKinds: nil, scrollDirection: .vertical, scrollPosition: .centeredVertically, animated: true)
        }
    }

    public func removeBottomInsetPadding() {
        collectionController.collectionView.contentInset.bottom = 0
    }

    public func addBottomInsetPadding() {
        collectionController.collectionView.contentInset.bottom = 300.0
    }

    // MARK: - UI

    public lazy var collectionController: CollectionController = {
        let collection = CollectionController(application: application, dataSource: self)
        collection.collectionView.showsVerticalScrollIndicator = false

        return collection
    }()

    private lazy var stopArrivalView: StopArrivalView = {
        let view = StopArrivalView.autolayoutNew()
        view.formatters = application.formatters
        if let arrDep = tripConvertible?.arrivalDeparture {
            view.arrivalDeparture = arrDep
        }
        return view
    }()

    private lazy var topPaddingView: UIView = {
        let view = UIView.autolayoutNew()
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 8.0)
        ])
        return view
    }()

    private lazy var separatorView: UIView = {
        let view = UIView.autolayoutNew()
        view.backgroundColor = ThemeColors.shared.separator
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 1.0)
        ])
        return view
    }()

    private lazy var outerStack = UIStackView.verticalStack(arangedSubviews: [topPaddingView, stopArrivalView, separatorView, collectionController.view])

    // MARK: - ListAdapterDataSource (Data Loading)

    public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let tripDetails = tripDetails else {
            return []
        }

        var sections = [ListDiffable]()

        // Section: Service Alerts
        if tripDetails.situations.count > 0 {
            sections.append(buildServiceAlertsSection(situations: tripDetails.situations))
        }

        // Section: Previous Trip
        if let previousTrip = tripDetails.previousTrip {
            let section = AdjacentTripSection(trip: previousTrip, order: .previous) { [weak self] in
                self?.showAdjacentTrip(previousTrip)
            }
            sections.append(section)
        }

        // Section: Stop Times
        let arrivalDeparture = tripConvertible?.arrivalDeparture
        for stopTime in tripDetails.stopTimes {
            sections.append(TripStopListItem(stopTime: stopTime, arrivalDeparture: arrivalDeparture, formatters: application.formatters))
        }

        // Section: Next Trip
        if let nextTrip = tripDetails.nextTrip {
            let section = AdjacentTripSection(trip: nextTrip, order: .next) { [weak self] in
                self?.showAdjacentTrip(nextTrip)
            }
            sections.append(section)
        }

        return sections
    }

    public func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is ArrivalDeparture {
            return StopArrivalSectionController(formatters: application.formatters)
        }
        else {
            let sectionController = defaultSectionController(for: object)
            sectionController.inset = .zero
            return sectionController
        }
    }

    public func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }

    private func showAdjacentTrip(_ trip: Trip) {
        guard
            let apiService = self.application.restAPIModelService,
            let tripDetails = self.tripDetails
        else { return }

        let op = apiService.getTripDetails(tripID: trip.id, vehicleID: tripDetails.status?.vehicleID, serviceDate: tripDetails.serviceDate)
        let controller = TripFloatingPanelController(application: self.application, operation: op)
        self.application.viewRouter.navigate(to: controller, from: self)
    }

    private func buildServiceAlertsSection(situations: [Situation]) -> TableSectionData {
        var rows = [TableRowData]()
        for serviceAlert in situations.sorted(by: { $0.createdAt > $1.createdAt }) {
            let row = TableRowData(title: serviceAlert.summary.value, accessoryType: .disclosureIndicator) { [weak self] _ in
                guard let self = self else { return }
                let alert = SituationAlertPresenter.buildAlert(from: serviceAlert, application: self.application)
                self.application.viewRouter.present(alert, from: self)
            }
            rows.append(row)
        }

        let section = TableSectionData(title: OBALoc("trip_details_controller.service_alerts.header", value: "Service Alerts", comment: "Service alerts header in the trip details controller."), rows: rows)
        section.footer = OBALoc("trip_details_controller.service_alerts_footer", value: "Trip Details", comment: "Service alerts header in the trip details controller. Cleverly, it looks like the header for the next section.")

        return section
    }
}