//
//  FilterViewController.swift
//  Yelp
//
//  Created by Charles Yeh on 2/12/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

enum FilterSections: Int {
    case Deal = 0, Distance, SortBy, Categories
}

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var filtersTableView: UITableView!
        var switchStates = [Int: [Int: Bool]]()
    
    let filters = [
        ("Deal", ["Offering a Deal"]),
        ("Distance", ["Auto", "0.3 miles", "1 mile", "5 miles", "20 miles"]),
        ("Sort By", ["Best Match", "Distance", "Rating", "Most Reviewed"]),
        ("Categories", []),
    ]
    
    let filterCategories = FilterViewController.categories()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        filtersTableView.delegate = self
        filtersTableView.dataSource = self
        cancelButton.targetForAction("cancelAction", withSender: self)
    }
    
    func initSwitchStates(deal: Bool, distance: Float, sortBy: CustomYelpSortMode, categories: [String]) {
        
        switchStates[FilterSections.Deal.rawValue] = [0: deal]
        switchStates[FilterSections.Distance.rawValue] = [distanceToSwitchStateIndex(distance): true]
        switchStates[FilterSections.SortBy.rawValue] = [sortBy.rawValue: true]
        
        switchStates[FilterSections.Categories.rawValue] = [Int: Bool]()
        for (index, category) in filterCategories.enumerate() {
            if let code = category["code"] as? String {
                if categories.contains(code) {
                    self.switchStates[FilterSections.Categories.rawValue]![index] = true
                }
            }
        }
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func onSearchButton(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
        
        let vc = self.navigationController!.topViewController as! FiltersDelegate
        
        let deal = switchStates[FilterSections.Deal.rawValue]?[0] ?? false
        let distance = getDistance()
        let sortBy = getSortBy()
        let categories = getCategories()
        
        vc.setFilters(deal, distance: distance, sortBy: sortBy, categories: categories)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return filters.count
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.filters[section].0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == FilterSections.Categories.rawValue {
            return self.filterCategories.count
        } else {
            if section == FilterSections.Distance.rawValue && self.switchStates[FilterSections.Distance.rawValue]?[0] ?? false {
                // if distance, only expand if not Auto
                return 1
            } else {
                return self.filters[section].1.count
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath
        // populate rows in section
        indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("filters.item")! as! FilterTableViewCell
        
        cell.cellLabel.text = getSectionRow(indexPath.section, row: indexPath.row)
        cell.cellSwitch.on = (switchStates[indexPath.section] ?? [Int: Bool]())[indexPath.row] ?? false
        cell.delegate = self
        
        return cell
    }

    func switchCell(switchCell: FilterTableViewCell, didChangeValue value: Bool) {
        if let indexPath = filtersTableView.indexPathForCell(switchCell) {
            
            // if in the first 3 sections, make sure only one row is on
            if indexPath.section != FilterSections.Categories.rawValue {
                
                if !value {
                    // don't allow turning a value off
                    if indexPath.section == FilterSections.Distance.rawValue && indexPath.row == 0 {
                        // except for distance = Auto
                        setSwitchState(FilterSections.Distance.rawValue, row: 1, value: true)
                    } else {
                        switchCell.cellSwitch.on = true
                        return
                    }
                } else {
                    for (row, _) in filters[indexPath.section].1.enumerate() {
                        if row == indexPath.row {
                            continue
                        }
                        
                        setSwitchState(indexPath.section, row: row, value: false)
                        if let otherCell = filtersTableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: indexPath.section)) as? FilterTableViewCell {
                            
                            otherCell.cellSwitch.setOn(false, animated: true)
                        }
                    }
                }
            }
            
            setSwitchState(indexPath.section, row: indexPath.row, value: value)
            
            // if changing distance = Auto, expand section
            self.filtersTableView.reloadSections(NSIndexSet(index: FilterSections.Distance.rawValue), withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    
    func setSwitchState(section: Int, row: Int, value: Bool) {
        var sectionStates = switchStates[section] ?? [Int: Bool]()
        sectionStates[row] = value
        switchStates[section] = sectionStates
    }
    
    func getSectionRow(section: Int, row: Int) -> String {
        if section == FilterSections.Categories.rawValue {
            return (filterCategories[row] as! NSDictionary)["name"] as! String
        } else {
            return self.filters[section].1[row]
        }
    }
    
    func getDistance() -> Float {
        for (key, value) in switchStates[1]! {
            if value {
                switch (key) {
                case 0:
                    // auto
                    return  0
                case 1:
                    // 0.3 miles
                    return  0.3
                case 2:
                    // 1 mile
                    return  1
                case 3:
                    // 5 miles
                    return 5
                case 4:
                    // 20 miles
                    return 20
                default:
                    return 0
                }
            }
        }
        return 0
    }
    
    func distanceToSwitchStateIndex(distance: Float) -> Int {
        if distance == 0 {
            return 0
        } else if (distance <= 0.3) {
            return 1
        } else if (distance <= 1) {
            return 2
        } else if (distance <= 5) {
            return 3
        } else {
            return 4
        }
    }
    
    func getSortBy() -> CustomYelpSortMode {
        for (key, value) in switchStates[2]! {
            if value {
                switch key {
                case 0:
                    // best matched
                    return CustomYelpSortMode.BestMatched
                case 1:
                    // distance
                    return CustomYelpSortMode.Distance
                case 2:
                    // rating
                    return CustomYelpSortMode.HighestRated
                case 3:
                    // TODO: most reviewed
                    return CustomYelpSortMode.MostReviewed
                default:
                    return CustomYelpSortMode.BestMatched
                }
            }
        }
        return CustomYelpSortMode.BestMatched
    }
    
    func getCategories() -> [String] {
        var categories: [String] = []
        
        for (key, value) in switchStates[FilterSections.Categories.rawValue]! {
            if value {
                categories.append(filterCategories[key]["code"] as! String)
            }
        }
        
        return categories
    }
    
    class func categories() -> NSArray {
        return [
            ["name" : "TV Rentals/Tours", "code" : "atvrentals"],
            ["name" : "Amateur Sports Teams", "code" : "amateursportsteams"],
            ["name" : "Badminton", "code" : "badminton"],
            ["name" : "Baseball Fields", "code" : "baseballfields"],
            ["name" : "Basketball Courts", "code" : "basketballcourts"],
            ["name" : "Batting Cages", "code" : "battingcages"],
            ["name" : "Challenge Courses", "code" : "challengecourses"],
            ["name" : "Cycling Classes", "code" : "cyclingclasses"],
            ["name" : "Day Camps", "code" : "daycamps"],
            ["name" : "Disc Golf", "code" : "discgolf"],
            ["name" : "Barre Classes", "code" : "barreclasses"],
            ["name" : "Boot Camps", "code" : "bootcamps"],
            ["name" : "Boxing", "code" : "boxing"],
            ["name" : "Golf Lessons", "code" : "golflessons"],
            ["name" : "Meditation Centers", "code" : "meditationcenters"],
            ["name" : "Gun/Rifle Ranges", "code" : "gun_ranges"],
            ["name" : "Gymnastics", "code" : "gymnastics"],
            ["name" : "Hang Gliding", "code" : "hanggliding"],
            ["name" : "Horse Racing", "code" : "horseracing"],
            ["name" : "Hot Air Balloons", "code" : "hot_air_balloons"],
            ["name" : "Kids Activities", "code" : "kids_activities"],
            ["name" : "Kiteboarding", "code" : "kiteboarding"],
            ["name" : "Laser Tag", "code" : "lasertag"],
            ["name" : "Leisure Centers", "code" : "leisure_centers"],
            ["name" : "Mini Golf", "code" : "mini_golf"],
            ["name" : "Paddleboarding", "code" : "paddleboarding"],
            ["name" : "Paintball", "code" : "paintball"],
            ["name" : "Races & Competitions", "code" : "races"],
            ["name" : "Rock Climbing", "code" : "rock_climbing"],
            ["name" : "Sledding", "code" : "sledding"],
            ["name" : "Snorkeling", "code" : "snorkeling"],
            ["name" : "Squash", "code" : "squash"],
            ["name" : "Surfing", "code" : "surfing"],
            ["name" : "Trampoline Parks", "code" : "trampoline"],
            ["name" : "Tubing", "code" : "tubing"],
            ["name" : "Water Parks", "code" : "waterparks"],
            ["name" : "Wildlife Hunting Ranges", "code" : "wildlifehunting"],
            ["name" : "Bingo Halls", "code" : "bingo"],
            ["name" : "Cabaret", "code" : "cabaret"],
            ["name" : "Casinos", "code" : "casinos"],
            ["name" : "Country Clubs", "code" : "countryclubs"],
            ["name" : "Cultural Center", "code" : "culturalcenter"],
            ["name" : "Attraction Farms", "code" : "attractionfarms"],
            ["name" : "Pick Your Own Farms", "code" : "pickyourown"],
            ["name" : "Ranches", "code" : "ranches"],
            ["name" : "LAN Centers", "code" : "lancenters"],
            ["name" : "Paint & Sip", "code" : "paintandsip"],
            ["name" : "Race Tracks", "code" : "racetracks"],
            ["name" : "Ticket Sales", "code" : "ticketsales"],
            ["name" : "Wineries", "code" : "wineries"],
            ["name" : "Aircraft Dealers", "code" : "aircraftdealers"],
            ["name" : "Auto Customization", "code" : "autocustomization"],
            ["name" : "Auto Detailing", "code" : "auto_detailing"],
            ["name" : "Auto Glass Services", "code" : "autoglass"],
            ["name" : "Auto Loan Providers", "code" : "autoloanproviders"],
            ["name" : "Boat Dealers", "code" : "boatdealers"],
            ["name" : "Body Shops", "code" : "bodyshops"],
            ["name" : "Car Brokers", "code" : "carbrokers"],
            ["name" : "Car Buyers", "code" : "carbuyers"],
            ["name" : "Car Share Services", "code" : "carshares"],
            ["name" : "Car Stereo Installation", "code" : "stereo_installation"],
            ["name" : "Commercial Truck Dealers", "code" : "truckdealers"],
            ["name" : "Commercial Truck Repair", "code" : "truckrepair"],
            ["name" : "Fuel Docks", "code" : "fueldocks"],
            ["name" : "Marinas", "code" : "marinas"],
            ["name" : "Mobile Dent Repair", "code" : "mobiledentrepair"],
            ["name" : "Mobility Equipment Sales & Services", "code" : "mobilityequipment"],
            ["name" : "Motorcycle Dealers", "code" : "motorcycledealers"],
            ["name" : "Motorsport Vehicle Dealers", "code" : "motodealers"],
            ["name" : "Motorsport Vehicle Repairs", "code" : "motorepairs"],
            ["name" : "Oil Change Stations", "code" : "oilchange"],
            ["name" : "RV Dealers", "code" : "rv_dealers"],
            ["name" : "RV Repair", "code" : "rvrepair"],
            ["name" : "Registration Services", "code" : "registrationservices"],
            ["name" : "Roadside Assistance", "code" : "roadsideassist"],
            ["name" : "Smog Check Stations", "code" : "smog_check_stations"],
            ["name" : "Trailer Dealers", "code" : "trailerdealers"],
            ["name" : "Trailer Repair", "code" : "trailerrepair"],
            ["name" : "Transmission Repair", "code" : "transmissionrepair"],
            ["name" : "Truck Rental", "code" : "truck_rental"],
            ["name" : "Vehicle Shipping", "code" : "vehicleshipping"],
            ["name" : "Vehicle Wraps", "code" : "vehiclewraps"],
            ["name" : "Wheel & Rim Repair", "code" : "wheelrimrepair"],
            ["name" : "Windshield Installation & Repair", "code" : "windshieldinstallrepair"],
            ["name" : "Eyelash Service", "code" : "eyelashservice"],
            ["name" : "Hair Extensions", "code" : "hair_extensions"],
            ["name" : "Laser Hair Removal", "code" : "laser_hair_removal"],
            ["name" : "Sugaring", "code" : "sugaring"],
            ["name" : "Blow Dry/Out Services", "code" : "blowoutservices"],
            ["name" : "Hair Extensions", "code" : "hair_extensions"],
            ["name" : "Hair Stylists", "code" : "hairstylists"],
            ["name" : "Men's Hair Salons", "code" : "menshair"],
            ["name" : "Nail Technicians", "code" : "nailtechnicians"],
            ["name" : "Permanent Makeup", "code" : "permanentmakeup"],
            ["name" : "Rolfing", "code" : "rolfing"],
            ["name" : "Spray Tanning", "code" : "spraytanning"],
            ["name" : "Tanning Beds", "code" : "tanningbeds"],
            ["name" : "Teeth Whitening", "code" : "teethwhitening"],
            ["name" : "Art Classes", "code" : "artclasses"],
            ["name" : "College Counseling", "code" : "collegecounseling"],
            ["name" : "Educational Services", "code" : "educationservices"],
            ["name" : "Preschools", "code" : "preschools"],
            ["name" : "Religious Schools", "code" : "religiousschools"],
            ["name" : "Special Education", "code" : "specialed"],
            ["name" : "CPR Classes", "code" : "cprclasses"],
            ["name" : "Childbirth Education", "code" : "childbirthedu"],
            ["name" : "Firearm Training", "code" : "firearmtraining"],
            ["name" : "First Aid Classes", "code" : "firstaidclasses"],
            ["name" : "Food Safety Training", "code" : "foodsafety"],
            ["name" : "Pole Dancing Classes", "code" : "poledancingclasses"],
            ["name" : "Bartenders", "code" : "bartenders"],
            ["name" : "Boat Charters", "code" : "boatcharters"],
            ["name" : "Caricatures", "code" : "caricatures"],
            ["name" : "Clowns", "code" : "clowns"],
            ["name" : "Face Painting", "code" : "facepainting"],
            ["name" : "Game Truck Rental", "code" : "gametruckrental"],
            ["name" : "Golf Cart Rentals", "code" : "golfcartrentals"],
            ["name" : "Henna Artists", "code" : "hennaartists"],
            ["name" : "Mountain Huts", "code" : "mountainhuts"],
            ["name" : "Rest Stops", "code" : "reststops"],
            ["name" : "Magicians", "code" : "magicians"],
            ["name" : "Mohels", "code" : "mohels"],
            ["name" : "Musicians", "code" : "musicians"],
            ["name" : "Party Bike Rentals", "code" : "partybikerentals"],
            ["name" : "Party Bus Rentals", "code" : "partybusrentals"],
            ["name" : "Party Equipment Rentals", "code" : "partyequipmentrentals"],
            ["name" : "Photo Booth Rentals", "code" : "photoboothrentals"],
            ["name" : "Event Photography", "code" : "eventphotography"],
            ["name" : "Session Photography", "code" : "sessionphotography"],
            ["name" : "Trivia Hosts", "code" : "triviahosts"],
            ["name" : "Valet Services", "code" : "valetservices"],
            ["name" : "Wedding Chapels", "code" : "weddingchappels"],
            ["name" : "Check Cashing/Pay-day Loans", "code" : "paydayloans"],
            ["name" : "Debt Relief Services", "code" : "debtrelief"],
            ["name" : "Auto Insurance", "code" : "autoinsurance"],
            ["name" : "Life Insurance", "code" : "lifeinsurance"],
            ["name" : "Bagels", "code" : "bagels"],
            ["name" : "Bubble Tea", "code" : "bubbletea"],
            ["name" : "Butcher", "code" : "butcher"],
            ["name" : "CSA", "code" : "csa"],
            ["name" : "Cideries", "code" : "cideries"],
            ["name" : "Convenience Stores", "code" : "convenience"],
            ["name" : "Cupcakes", "code" : "cupcakes"],
            ["name" : "Do-It-Yourself Food", "code" : "diyfood"],
            ["name" : "Donuts", "code" : "donuts"],
            ["name" : "Empanadas", "code" : "empanadas"],
            ["name" : "Food Trucks", "code" : "foodtrucks"],
            ["name" : "Gelato", "code" : "gelato"],
            ["name" : "Pretzels", "code" : "pretzels"],
            ["name" : "Shaved Ice", "code" : "shavedice"],
            ["name" : "Ethnic Food", "code" : "ethnicmarkets"],
            ["name" : "Macarons", "code" : "macarons"],
            ["name" : "Pasta Shops", "code" : "pastashops"],
            ["name" : "Popcorn Shops", "code" : "popcorn"],
            ["name" : "Street Vendors", "code" : "streetvendors"],
            ["name" : "Wineries", "code" : "wineries"],
            ["name" : "Blood & Plasma Donation Centers", "code" : "blooddonation"],
            ["name" : "Cannabis Clinics", "code" : "cannabis_clinics"],
            ["name" : "Cannabis Tours", "code" : "cannabistours"],
            ["name" : "Colonics", "code" : "colonics"],
            ["name" : "Concierge Medicine", "code" : "conciergemedicine"],
            ["name" : "Psychologists", "code" : "psychologists"],
            ["name" : "Sports Psychologists", "code" : "sportspsychologists"],
            ["name" : "Cosmetic Dentists", "code" : "cosmeticdentists"],
            ["name" : "Endodontists", "code" : "endodontists"],
            ["name" : "General Dentistry", "code" : "generaldentistry"],
            ["name" : "Diagnostic Imaging", "code" : "diagnosticimaging"],
            ["name" : "Laboratory Testing", "code" : "laboratorytesting"],
            ["name" : "Dialysis Clinics", "code" : "dialysisclinics"],
            ["name" : "Anesthesiologists", "code" : "anesthesiologists"],
            ["name" : "Audiologist", "code" : "audiologist"],
            ["name" : "Endocrinologists", "code" : "endocrinologists"],
            ["name" : "Family Practice", "code" : "familydr"],
            ["name" : "Internal Medicine", "code" : "internalmed"],
            ["name" : "Nephrologists", "code" : "nephrologists"],
            ["name" : "Rheumatologists", "code" : "rhematologists"],
            ["name" : "Spine Surgeons", "code" : "spinesurgeons"],
            ["name" : "Surgeons", "code" : "surgeons"],
            ["name" : "Urologists", "code" : "urologists"],
            ["name" : "Doulas", "code" : "doulas"],
            ["name" : "Emergency Rooms", "code" : "emergencyrooms"],
            ["name" : "Halotherapy", "code" : "halotherapy"],
            ["name" : "Health Insurance Offices", "code" : "healthinsurance"],
            ["name" : "Hearing Aid Providers", "code" : "hearingaidproviders"],
            ["name" : "Home Health Care", "code" : "homehealthcare"],
            ["name" : "Hypnosis/Hypnotherapy", "code" : "hypnosis"],
            ["name" : "IV Hydration", "code" : "ivhydration"],
            ["name" : "Lactation Services", "code" : "lactationservices"],
            ["name" : "Lice Services", "code" : "liceservices"],
            ["name" : "Massage Therapy", "code" : "massage_therapy"],
            ["name" : "Walk-in Clinics", "code" : "walkinclinics"],
            ["name" : "Medical Transportation", "code" : "medicaltransportation"],
            ["name" : "Occupational Therapy", "code" : "occupationaltherapy"],
            ["name" : "Orthotics", "code" : "orthotics"],
            ["name" : "Oxygen Bars", "code" : "oxygenbars"],
            ["name" : "Personal Care Services", "code" : "personalcare"],
            ["name" : "Placenta Encapsulations", "code" : "placentaencapsulation"],
            ["name" : "Prenatal/Perinatal Care", "code" : "prenatal"],
            ["name" : "Prosthetics", "code" : "prosthetics"],
            ["name" : "Prosthodontists", "code" : "prosthodontists"],
            ["name" : "Reflexology", "code" : "reflexology"],
            ["name" : "Rehabilitation Center", "code" : "rehabilitation_center"],
            ["name" : "Reiki", "code" : "reiki"],
            ["name" : "Saunas", "code" : "saunas"],
            ["name" : "Sperm Clinic", "code" : "spermclinic"],
            ["name" : "Traditional Chinese Medicine", "code" : "tcm"],
            ["name" : "Cabinetry", "code" : "cabinetry"],
            ["name" : "Carpenters", "code" : "carpenters"],
            ["name" : "Childproofing", "code" : "childproofing"],
            ["name" : "Chimney Sweeps", "code" : "chimneysweeps"],
            ["name" : "Countertop Installation", "code" : "countertopinstall"],
            ["name" : "Damage Restoration", "code" : "damagerestoration"],
            ["name" : "Demolition Services", "code" : "demolitionservices"],
            ["name" : "Door Sales/Installation", "code" : "doorsales"],
            ["name" : "Drywall Installation & Repair", "code" : "drywall"],
            ["name" : "Fences & Gates", "code" : "fencesgates"],
            ["name" : "Firewood", "code" : "firewood"],
            ["name" : "Furniture Assembly", "code" : "furnitureassembly"],
            ["name" : "Garage Door Services", "code" : "garage_door_services"],
            ["name" : "Glass & Mirrors", "code" : "glassandmirrors"],
            ["name" : "Gutter Services", "code" : "gutterservices"],
            ["name" : "Holiday Decorating Services", "code" : "seasonaldecorservices"],
            ["name" : "Home Automation", "code" : "homeautomation"],
            ["name" : "Home Network Installation", "code" : "homenetworkinstall"],
            ["name" : "Home Organization", "code" : "home_organization"],
            ["name" : "Home Theatre Installation", "code" : "hometheatreinstallation"],
            ["name" : "Home Window Tinting", "code" : "homewindowtinting"],
            ["name" : "House Sitters", "code" : "housesitters"],
            ["name" : "Irrigation", "code" : "irrigation"],
            ["name" : "Landscaping", "code" : "landscaping"],
            ["name" : "Masonry/Concrete", "code" : "masonry_concrete"],
            ["name" : "Patio Coverings", "code" : "patiocoverings"],
            ["name" : "Pool Cleaners", "code" : "poolcleaners"],
            ["name" : "Pressure Washers", "code" : "pressurewashers"],
            ["name" : "Art Space Rentals", "code" : "artspacerentals"],
            ["name" : "Commercial Real Estate", "code" : "commercialrealestate"],
            ["name" : "Estate Liquidation", "code" : "estateliquidation"],
            ["name" : "Home Staging", "code" : "homestaging"],
            ["name" : "Kitchen Incubators", "code" : "kitchenincubators"],
            ["name" : "Mobile Home Dealers", "code" : "mobilehomes"],
            ["name" : "Mobile Home Parks", "code" : "mobileparks"],
            ["name" : "Mortgage Brokers", "code" : "mortgagebrokers"],
            ["name" : "Real Estate Services", "code" : "realestatesvcs"],
            ["name" : "Roof Inspectors", "code" : "roofinspectors"],
            ["name" : "Shutters", "code" : "shutters"],
            ["name" : "Tiling", "code" : "tiling"],
            ["name" : "Utilities", "code" : "utilities"],
            ["name" : "Vinyl Siding", "code" : "vinylsiding"],
            ["name" : "Water Purification Services", "code" : "waterpurification"],
            ["name" : "Bed & Breakfast", "code" : "bedbreakfast"],
            ["name" : "Guest Houses", "code" : "guesthouses"],
            ["name" : "Health Retreats", "code" : "healthretreats"],
            ["name" : "Mountain Huts", "code" : "mountainhuts"],
            ["name" : "Rest Stops", "code" : "reststops"],
            ["name" : "Motorcycle Rental", "code" : "motorcycle_rental"],
            ["name" : "RV Parks", "code" : "rvparks"],
            ["name" : "RV Rental", "code" : "rvrental"],
            ["name" : "Ski Resorts", "code" : "skiresorts"],
            ["name" : "Cable Cars", "code" : "cablecars"],
            ["name" : "Pedicabs", "code" : "pedicabs"],
            ["name" : "Trains", "code" : "trains"],
            ["name" : "Vacation Rental Agents", "code" : "vacationrentalagents"],
            ["name" : "Vacation Rentals", "code" : "vacation_rentals"],
            ["name" : "Air Duct Cleaning", "code" : "airductcleaning"],
            ["name" : "Bail Bondsmen", "code" : "bailbondsmen"],
            ["name" : "Clock Repair", "code" : "clockrepair"],
            ["name" : "Community Gardens", "code" : "communitygardens"],
            ["name" : "Furniture Rental", "code" : "rentfurniture"],
            ["name" : "Data Recovery", "code" : "datarecovery"],
            ["name" : "Telecommunications", "code" : "telecommunications"],
            ["name" : "Jewelry Repair", "code" : "jewelryrepair"],
            ["name" : "Knife Sharpening", "code" : "knifesharpening"],
            ["name" : "Mailbox Centers", "code" : "mailboxcenters"],
            ["name" : "Metal Fabricators", "code" : "metalfabricators"],
            ["name" : "Nanny Services", "code" : "nannys"],
            ["name" : "Notaries", "code" : "notaries"],
            ["name" : "Powder Coating", "code" : "powdercoating"],
            ["name" : "Propane", "code" : "propane"],
            ["name" : "Screen Printing/T-Shirt Printing", "code" : "screen_printing_tshirt_printing"],
            ["name" : "Septic Services", "code" : "septicservices"],
            ["name" : "Shipping Centers", "code" : "shipping_centers"],
            ["name" : "Snow Removal", "code" : "snowremoval"],
            ["name" : "Water Delivery", "code" : "waterdelivery"],
            ["name" : "Well Drilling", "code" : "welldrilling"],
            ["name" : "Beer Bar", "code" : "beerbar"],
            ["name" : "Champagne Bars", "code" : "champagne_bars"],
            ["name" : "Dive Bars", "code" : "divebars"],
            ["name" : "Drive-Thru Bars", "code" : "drivethrubars"],
            ["name" : "Hookah Bars", "code" : "hookah_bars"],
            ["name" : "Sports Bars", "code" : "sportsbars"],
            ["name" : "Beer Gardens", "code" : "beergardens"],
            ["name" : "Comedy Clubs", "code" : "comedyclubs"],
            ["name" : "Country Dance Halls", "code" : "countrydancehalls"],
            ["name" : "Piano Bars", "code" : "pianobars"],
            ["name" : "Horse Boarding", "code" : "horse_boarding"],
            ["name" : "Pet Adoption", "code" : "petadoption"],
            ["name" : "Aquarium Services", "code" : "aquariumservices"],
            ["name" : "Pet Breeders", "code" : "petbreeders"],
            ["name" : "Bird Shops", "code" : "birdshops"],
            ["name" : "Local Fish Stores", "code" : "localfishstores"],
            ["name" : "Reptile Shops", "code" : "reptileshops"],
            ["name" : "Boat Repair", "code" : "boatrepair"],
            ["name" : "Business Consulting", "code" : "businessconsulting"],
            ["name" : "Editorial Services", "code" : "editorialservices"],
            ["name" : "Business Law", "code" : "businesslawyers"],
            ["name" : "Contract Law", "code" : "contractlaw"],
            ["name" : "DUI Law", "code" : "duilawyers"],
            ["name" : "Entertainment Law", "code" : "entertainmentlaw"],
            ["name" : "Estate Planning Law", "code" : "estateplanning"],
            ["name" : "Wills, Trusts, & Probates", "code" : "willstrustsprobates"],
            ["name" : "IP & Internet Law", "code" : "iplaw"],
            ["name" : "Personal Injury Law", "code" : "personal_injury"],
            ["name" : "Tax Law", "code" : "taxlaw"],
            ["name" : "Legal Services", "code" : "legalservices"],
            ["name" : "Matchmakers", "code" : "matchmakers"],
            ["name" : "Mediators", "code" : "mediators"],
            ["name" : "Payroll Services", "code" : "payroll"],
            ["name" : "Personal Assistants", "code" : "personalassistants"],
            ["name" : "Product Design", "code" : "productdesign"],
            ["name" : "Security Services", "code" : "security"],
            ["name" : "Shredding Services", "code" : "shredding"],
            ["name" : "Signmaking", "code" : "signmaking"],
            ["name" : "Talent Agencies", "code" : "talentagencies"],
            ["name" : "Taxidermy", "code" : "taxidermy"],
            ["name" : "Tenant and Eviction Law", "code" : "tenantlaw"],
            ["name" : "Translation Services", "code" : "translationservices"],
            ["name" : "Community Centers", "code" : "communitycenters"],
            ["name" : "Courthouses", "code" : "courthouses"],
            ["name" : "Departments of Motor Vehicles", "code" : "departmentsofmotorvehicles"],
            ["name" : "Embassy", "code" : "embassy"],
            ["name" : "Fire Departments", "code" : "firedepartments"],
            ["name" : "Art Space Rentals", "code" : "artspacerentals"],
            ["name" : "Commercial Real Estate", "code" : "commercialrealestate"],
            ["name" : "Estate Liquidation", "code" : "estateliquidation"],
            ["name" : "Home Staging", "code" : "homestaging"],
            ["name" : "Kitchen Incubators", "code" : "kitchenincubators"],
            ["name" : "Mobile Home Dealers", "code" : "mobilehomes"],
            ["name" : "Mobile Home Parks", "code" : "mobileparks"],
            ["name" : "Mortgage Brokers", "code" : "mortgagebrokers"],
            ["name" : "Real Estate Services", "code" : "realestatesvcs"],
            ["name" : "Afghan", "code" : "afghani"],
            ["name" : "African", "code" : "african"],
            ["name" : "Senegalese", "code" : "senegalese"],
            ["name" : "South African", "code" : "southafrican"],
            ["name" : "American (New)", "code" : "newamerican"],
            ["name" : "Arabian", "code" : "arabian"],
            ["name" : "Argentine", "code" : "argentine"],
            ["name" : "Armenian", "code" : "armenian"],
            ["name" : "Australian", "code" : "australian"],
            ["name" : "Austrian", "code" : "austrian"],
            ["name" : "Bangladeshi", "code" : "bangladeshi"],
            ["name" : "Barbeque", "code" : "bbq"],
            ["name" : "Basque", "code" : "basque"],
            ["name" : "Belgian", "code" : "belgian"],
            ["name" : "Brasseries", "code" : "brasseries"],
            ["name" : "British", "code" : "british"],
            ["name" : "Burmese", "code" : "burmese"],
            ["name" : "Cafes", "code" : "cafes"],
            ["name" : "Cafeteria", "code" : "cafeteria"],
            ["name" : "Cajun/Creole", "code" : "cajun"],
            ["name" : "Cambodian", "code" : "cambodian"],
            ["name" : "Caribbean", "code" : "caribbean"],
            ["name" : "Dominican", "code" : "dominican"],
            ["name" : "Haitian", "code" : "haitian"],
            ["name" : "Puerto Rican", "code" : "puertorican"],
            ["name" : "Trinidadian", "code" : "trinidadian"],
            ["name" : "Catalan", "code" : "catalan"],
            ["name" : "Cheesesteaks", "code" : "cheesesteaks"],
            ["name" : "Chicken Shop", "code" : "chickenshop"],
            ["name" : "Chicken Wings", "code" : "chicken_wings"],
            ["name" : "Cantonese", "code" : "cantonese"],
            ["name" : "Dim Sum", "code" : "dimsum"],
            ["name" : "Shanghainese", "code" : "shanghainese"],
            ["name" : "Szechuan", "code" : "szechuan"],
            ["name" : "Comfort Food", "code" : "comfortfood"],
            ["name" : "Cuban", "code" : "cuban"],
            ["name" : "Czech", "code" : "czech"],
            ["name" : "Delis", "code" : "delis"],
            ["name" : "Diners", "code" : "diners"],
            ["name" : "Ethiopian", "code" : "ethiopian"],
            ["name" : "Filipino", "code" : "filipino"],
            ["name" : "Fish & Chips", "code" : "fishnchips"],
            ["name" : "Fondue", "code" : "fondue"],
            ["name" : "Food Court", "code" : "food_court"],
            ["name" : "Gastropubs", "code" : "gastropubs"],
            ["name" : "Halal", "code" : "halal"],
            ["name" : "Hawaiian", "code" : "hawaiian"],
            ["name" : "Hot Pot", "code" : "hotpot"],
            ["name" : "Hungarian", "code" : "hungarian"],
            ["name" : "Iberian", "code" : "iberian"],
            ["name" : "Indonesian", "code" : "indonesian"],
            ["name" : "Calabrian", "code" : "calabrian"],
            ["name" : "Sardinian", "code" : "sardinian"],
            ["name" : "Tuscan", "code" : "tuscan"],
            ["name" : "Teppanyaki", "code" : "teppanyaki"],
            ["name" : "Kosher", "code" : "kosher"],
            ["name" : "Laotian", "code" : "laotian"],
            ["name" : "Colombian", "code" : "colombian"],
            ["name" : "Salvadoran", "code" : "salvadoran"],
            ["name" : "Venezuelan", "code" : "venezuelan"],
            ["name" : "Malaysian", "code" : "malaysian"],
            ["name" : "Falafel", "code" : "falafel"],
            ["name" : "Middle Eastern", "code" : "mideastern"],
            ["name" : "Egyptian", "code" : "egyptian"],
            ["name" : "Lebanese", "code" : "lebanese"],
            ["name" : "Modern European", "code" : "modern_european"],
            ["name" : "Mongolian", "code" : "mongolian"],
            ["name" : "Moroccan", "code" : "moroccan"],
            ["name" : "Peruvian", "code" : "peruvian"],
            ["name" : "Polish", "code" : "polish"],
            ["name" : "Portuguese", "code" : "portuguese"],
            ["name" : "Poutineries", "code" : "poutineries"],
            ["name" : "Scandinavian", "code" : "scandinavian"],
            ["name" : "Scottish", "code" : "scottish"],
            ["name" : "Singaporean", "code" : "singaporean"],
            ["name" : "Slovakian", "code" : "slovakian"],
            ["name" : "Soul Food", "code" : "soulfood"],
            ["name" : "Southern", "code" : "southern"],
            ["name" : "Sri Lankan", "code" : "srilankan"],
            ["name" : "Supper Clubs", "code" : "supperclubs"],
            ["name" : "Taiwanese", "code" : "taiwanese"],
            ["name" : "Tapas Bars", "code" : "tapas"],
            ["name" : "Tex-Mex", "code" : "tex-mex"],
            ["name" : "Turkish", "code" : "turkish"],
            ["name" : "Ukrainian", "code" : "ukrainian"],
            ["name" : "Uzbek", "code" : "uzbek"],
            ["name" : "Embroidery & Crochet", "code" : "embroideryandcrochet"],
            ["name" : "Auction Houses", "code" : "auctionhouses"],
            ["name" : "Battery Stores", "code" : "batterystores"],
            ["name" : "Bespoke Clothing", "code" : "bespoke"],
            ["name" : "Brewing Supplies", "code" : "brewingsupplies"],
            ["name" : "Drugstores", "code" : "drugstores"],
            ["name" : "Formal Wear", "code" : "formalwear"],
            ["name" : "Hats", "code" : "hats"],
            ["name" : "Plus Size Fashion", "code" : "plus_size_fashion"],
            ["name" : "Surf Shop", "code" : "surfshop"],
            ["name" : "Fireworks", "code" : "fireworks"],
            ["name" : "Gift Shops", "code" : "giftshops"],
            ["name" : "Gold Buyers", "code" : "goldbuyers"],
            ["name" : "Golf Equipment Shops", "code" : "golfshops"],
            ["name" : "Guns & Ammo", "code" : "guns_and_ammo"],
            ["name" : "High Fidelity Audio Equipment", "code" : "hifi"],
            ["name" : "Paint Stores", "code" : "paintstores"],
            ["name" : "Pumpkin Patches", "code" : "pumpkinpatches"],
            ["name" : "Rugs", "code" : "rugs"],
            ["name" : "Horse Equipment Shops", "code" : "horsequipment"],
            ["name" : "Medical Supplies", "code" : "medicalsupplies"],
            ["name" : "Mobile Phone Accessories", "code" : "cellphoneaccessories"],
            ["name" : "Motorcycle Gear", "code" : "motorcyclinggear"],
            ["name" : "Pawn Shops", "code" : "pawn"],
            ["name" : "Personal Shopping", "code" : "personal_shopping"],
            ["name" : "Pool & Billiards", "code" : "poolbilliards"],
            ["name" : "Pop-up Shops", "code" : "popupshops"],
            ["name" : "Souvenir Shops", "code" : "souvenirs"],
            ["name" : "Dive Shops", "code" : "diveshops"],
            ["name" : "Golf Equipment", "code" : "golfequipment"],
            ["name" : "Ski & Snowboard Shops", "code" : "skishops"],
            ["name" : "Thrift Stores", "code" : "thrift_stores"],
            ["name" : "Trophy Shops", "code" : "trophyshops"],
            ["name" : "Uniforms", "code" : "uniforms"],
            ["name" : "Used Bookstore", "code" : "usedbooks"],
            ["name" : "Vape Shops", "code" : "vapeshops"],
            ["name" : "Vitamins & Supplements", "code" : "vitaminssupplements"],
            ["name" : "Wigs", "code" : "wigs"]]
    }
}
