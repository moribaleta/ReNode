//
//  DateUtil.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 2/22/22.
//

import Foundation
import DateTools

public extension Calendar {
    public static var gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
}

/**
 
 An enumeration of possible date format strings.
 
 - ShortReadable: ie: Nov 31, 2016
 
 */
public enum DateFormat : String {
    
    case MMddyyyy = "MM/dd/yyyy"
    case ddMMyyyy = "dd/MM/yyyy"
    
    /// i.e. 16:30
    case ShortTime = "HH:mm"
    
    /// i.e. 16:00:01
    case MediumTime = "HH:mm:ss"
    
    /// i.e. 16:00:01.001
    case LongTime = "HH:mm:ss.SSS"
    
    /// i.e. 04:30 PM
    case TimeReadable = "hh:mm a"
    
    
    
    /// i.e. Nov 31, 2016
    case ShortReadable = "MMM dd, yyyy"
    
    /// i.e. November 31, 2016
    case LongReadable = "MMMM dd, yyyy"
    
    /// i.e. Sunday, Feb 11 2018
    case ShortReadWeek = "EEEE, dd MMM yyyy"
    
    /// i.e. Nov 31 2016
    case ShortRead = "MMM dd yyyy"
    
    /// i.e. November 31 2016
    case LongRead = "MMMM dd yyyy"
    
    /// i.e. 2016-11-31;
    case Date = "yyyy-MM-dd"
    
    /// i.e. 2016-01-31T08:00:00.000
    case UTC = "yyyy-MM-dd'T'HH:mm:ss.SSS"

    /// i.e. 2016-01-31T08:00:00Z100
    case UTCIso8601 = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    
    /// i.e. 2016-01-31T08:00:00
    case UTCShort = "yyyy-MM-dd'T'HH:mm:ss"
    
    /// i.e. 2016-01-31 08:00:00
    case UTCShortSpace = "yyyy-MM-dd HH:mm:ss"
    
    /// i.e. 2016-01-31 08:00:00 am
    case UTCShortSpaceA = "yyyy-MM-dd h:mm:ss a"

    case TwentyFour = "HHmm"
    
    /// Currently used for cramps and for Billing invoice
    case Cramp = "yyyyMMddHHmmssSS"
    
    /// i.e. Wednesday, 30 November 2016
    case UKFullReadable = "EEEE, dd MMMM yyyy"
    
    /// i.e. 30 November 2016
    case UKLongReadable = "dd MMMM yyyy"
    
    /// i.e. 30 Nov 2016
    case UKShortReadable = "dd MMM yyyy"

    case DOWHour = "EEE HH"
    
    case Hour = "HH:00"
    
    case Day = "dd EEE"

    case DayOnly = "dd"

    case DayMonth = "dd MMM"
    
    case MonthDay = "MMMM dd"

    case MnthDay = "MMM dd"
    
    /// i.e. Nov
    case Month3 = "MMM"
    
    case MonthYear = "MMM yyyy"

    /// i.e. November
    case MonthFull = "MMMM"
    
    // TODO: conflict with Cramp
    // case Invoice = "yyyyMMddHHmmssSS"
    
    case YearDateTimeReadable = "dd MMM yyyy',' hh:mm a"
    case DateTimeReadable = "MMM dd',' hh:mm a"
    case WeekTimeReadable = "E',' hh:mm a"
    
    case UTCShort12 = "yyyy-MM-dd'T'hh:mm:ss"
    
    case yyyy_MM = "yyyy-MM"
    
    case iso1861 = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    
    case MMMddEEEE = "MMM dd, EEEE"
}

public class DateFormatterFactory {
    static var _UTC           : DateFormatter?
    static var _UTCShort      : DateFormatter?
    static var _UTCShortSpace : DateFormatter?
    static var _UTCShortSpaceA : DateFormatter?
    static var _MediumTime    : DateFormatter?
    static var _Date    : DateFormatter?
    
    public static var UTC : DateFormatter {
        if _UTC == nil {
            _UTC = DateFormatter()
            _UTC!.dateFormat = DateFormat.UTC.rawValue
            _UTC!.timeZone = TimeZone(abbreviation: "UTC")
            _UTC!.locale = Locale(identifier: "en_US_POSIX")
        }
        return _UTC!
    }

    public static var ISO8601: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.UTCIso8601.rawValue
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }

    public static var UTCShort : DateFormatter {
        if _UTCShort == nil {
            _UTCShort = DateFormatter()
            _UTCShort!.dateFormat = DateFormat.UTCShort.rawValue
            _UTCShort!.timeZone = TimeZone(abbreviation: "UTC")
            _UTCShort!.locale = Locale(identifier: "en_US_POSIX")
        }
        return _UTCShort!
    }
    
    public static var UTCShortSpace : DateFormatter {
        if _UTCShortSpace == nil {
            _UTCShortSpace = DateFormatter()
            _UTCShortSpace!.dateFormat = DateFormat.UTCShortSpace.rawValue
            _UTCShortSpace!.timeZone = TimeZone(abbreviation: "UTC")
            _UTCShortSpace!.locale = Locale(identifier: "en_US_POSIX")
        }
        return _UTCShortSpace!
    }
    
    public static var UTCShortSpaceA : DateFormatter {
        if _UTCShortSpaceA == nil {
            _UTCShortSpaceA = DateFormatter()
            _UTCShortSpaceA!.dateFormat = DateFormat.UTCShortSpaceA.rawValue
            _UTCShortSpaceA!.timeZone = TimeZone(abbreviation: "UTC")
            _UTCShortSpaceA!.locale = Locale(identifier: "en_US_POSIX")
        }
        return _UTCShortSpaceA!
    }
    
    public static var MediumTime : DateFormatter {
        if _MediumTime == nil {
            _MediumTime = DateFormatter()
            _MediumTime!.dateFormat = DateFormat.MediumTime.rawValue
            _MediumTime!.timeZone = TimeZone(abbreviation: "UTC")
            _MediumTime!.locale = Locale(identifier: "en_US_POSIX")
        }
        return _MediumTime!
    }
    
    public static var Date : DateFormatter {
        if _Date == nil {
            _Date = DateFormatter()
            _Date!.dateFormat = DateFormat.Date.rawValue
            _Date!.timeZone = TimeZone(abbreviation: "UTC")
            _Date!.locale = Locale(identifier: "en_US_POSIX")
        }
        return _Date!
    }
}

public extension Date {

    /// Removes time data from the date.
    public func sanitise() -> Date {

        let comp = DateUtil.utcCalendar.dateComponents([ .day, .month, .year ], from: self)
        return DateUtil.utcCalendar.date(from: comp)!
    }

    public static func fromUTC(_ dateString: String, _ dateTimeDivider: Character = "T") -> Date? {

        let     dateTime        = dateString.components(separatedBy: dateTimeDivider.description)
        guard   dateTime.count  == 2 else { return nil }

        let     date            = dateTime[0].components(separatedBy: "-")
        guard   date.count      == 3 else { return nil }

        let     time            = dateTime[1].components(separatedBy: ":")
        guard   time.count      == 3 else { return nil }

        var     components      = DateComponents()

        components.year         = Int(date[0])
        components.month        = Int(date[1])
        components.day          = Int(date[2])

        components.hour         = Int(time[0])
        components.minute       = Int(time[1])
        components.second       = Int(time[2])

        return DateUtil.utcCalendar.date(from: components)
    }

    /**
     Returns the UTC string of a date.
     This is much more CPU effecient than using ios dateformatter.
     `2016-01-31T04:23:11`
     
     - Parameter dateTimeDivider: The divider for the date and the time. By default it is `"T"`
     - Returns: Date in string format.
     */
    public func toUTCString(dateTimeDivider: String = "T") -> String {
        
        let c               = (DateUtil.utcCalendar as NSCalendar).components(DateUtil.allComponentUnits, from: self)
        
        let yearString      = c.year!
        
        let monthString     = String(format: "%02d", c.month!   )
        
        let dayString       = String(format: "%02d", c.day!     )
        
        let hourString      = String(format: "%02d", c.hour!    )
        
        let minuteString    = String(format: "%02d", c.minute!  )
        
        let seconds         = 0.000000001 * Double(c.nanosecond!) + Double(c.second!)
        
        var secondString    = String(format:"%.3f", seconds);
        
        if secondString.index(of: ".") == secondString.index(secondString.startIndex, offsetBy: 1) {
            secondString = "0" + secondString
        }
        
        return "\(yearString)-\(monthString)-\(dayString)\(dateTimeDivider)\(hourString):\(minuteString):\(secondString)"
    }
    
    /**
     By default, dates are read as the UTC string of a date.
     
     `2016-01-31T04:23:11`
     
     - Returns: Date in string format.
     */
    public func toString() -> String {
        return toUTCString()
    }
    
    /**
     Converts a date to a string using a specified format. Note: Date is in UTC and does not show local time.
     - Parameter format: The date format to use.
     - Returns: Date in string format.
     */
    public func toString(withFormat format: DateFormat = .UTC) -> String {
        let formatter: DateFormatter = DateFormatter()
        
        formatter.dateFormat = format.rawValue
        formatter.timeZone = DateUtil.utcTimeZone
        
        return formatter.string(from: self)
    }
    
    /**
     Converts a date to a string using a specified format. The date is displayed in localtime.
     - Parameter format: The date format to use.
     - Returns: Date in string format.
     */
    public func toLocalString(withFormat format: DateFormat = .UTC) -> String {
        let formatter: DateFormatter = DateFormatter()
        
        formatter.dateFormat = format.rawValue
        formatter.timeZone = NSTimeZone.default
        formatter.calendar = Calendar.gregorian
        
        return formatter.string(from: self)
    }
    
    public static func create(_ fromDouble :Double) -> Date {
        return Date(timeIntervalSince1970: fromDouble)
    }
    
    
    public static func create(fromString string: String, usingFormatter format: DateFormatter) throws -> Date {
        /*let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        */
        guard let iso8601String = format.date(from: string) else {
            throw ParseError.castFailed(key: "date")
        }
        return iso8601String
    }

    public static func createUsingLocal(fromString string: String, usingFormat format: DateFormat) throws -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.timeZone = NSTimeZone.default
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let iso8601String = dateFormatter.date(from: string) else {
            throw ParseError.castFailed(key: "date")
        }
        return iso8601String
    }
    
    public static func create(fromString string: String, usingFormat format: DateFormat) throws -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.timeZone = TimeZone.init(identifier: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let iso8601String = dateFormatter.date(from: string) else {
            throw ParseError.castFailed(key: "date")
        }
        return iso8601String
    }

    
    public static func create(fromString: String) throws -> Date {
        let dateAsNSString = fromString as NSString
        
        let year    = Int(dateAsNSString.substring(to: 4))!
        let month   = Int(dateAsNSString.substring(with: NSMakeRange(5, 2)))!
        let day     = Int(dateAsNSString.substring(with: NSMakeRange(8, 2)))!
        
        let length  = dateAsNSString.length
        
        //YYYY-MM-DDTHH:mm:ss.SSS
        // date part is of length 10
        // T 11
        
        var hour = 0, minute = 0, second : Double = 0;
        if(length >= 13){
            let hourString = dateAsNSString.substring(with: NSMakeRange(11, 2))
            hour = Int(hourString)!
            
            
            if (length >= 16){
                let minuteString = dateAsNSString.substring(with: NSMakeRange(14, 2))
                minute = Int(minuteString)!
                
                if(length >= 18){
                    let secondString = dateAsNSString.substring(from: 17) as NSString
                    
                    //s.substringFromIndex(17)
                    second = secondString.doubleValue;
                    
                }
            }
        }
        
        var dateComponents = DateComponents()
        
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        // (dateComponents as NSDateComponents).timeZone = DateUtil.utcTimeZone
        dateComponents.timeZone = DateUtil.utcTimeZone
        
        var date = Calendar.gregorian.date(from: dateComponents)
        
        date = date?.addingTimeInterval(second)
        
        guard let dat = date else {
            throw ParseError.unknown(message: "Failed to produce date object")
        }
        
        return dat
    }
    
    /// Serializes the date using the date formatter specified in DateUtil.
    public func serialize() ->String {
        return DateUtil.dateFormatter.string(from: self)
    }
    
    
    public func dateOnly() -> Date {
        let components: DateComponents = (NSCalendar.current as NSCalendar).components([.year, .month, .day], from: self )
        let targetDate: Date = (NSCalendar.current as NSCalendar).date(from: components as DateComponents)!
        return targetDate
    }
    
    /**
     
     This method has unwanted side effects. It is unreliable, because of the line
     that assigns the value for `targetDate`.
     
     ## Migration phase
     
     When we reach internationalization, this method may not be scalable because
     the time zone is not a specified parameter.
     
     ## Current use
     
     Somehow, it works when used in the context of `UIPatientMainVitalEdit`, but
     it needs to be reviewed to make sure that the vitals works correctly.
     
     Noted on September 14, 2017.
     */
    @available(*, deprecated)
    public func timeOnly() -> Date {
        let format = DateFormatter()
        format.dateFormat = "hh:mm:ss"
        do {
            let targetDate = try Date.create(fromString: format.string(from: self), usingFormatter: format)
            return targetDate
        } catch _ {
            fatalError("Cannot create time from date")
        }
        //let targetDate: Date = (NSCalendar.current as NSCalendar).date(from: components as DateComponents)!
        
    }
    
    
    public func differenceInYears ( to: Date) -> Double {
        let comps: DateComponents = (NSCalendar.current as NSCalendar).components([.year, .month], from: self, to: to, options: NSCalendar.Options())
        return  Double(comps.year!) + (Double(comps.month!) / 12)
    }
    
    func days (from start: Date) -> Int {
        return (self as NSDate).days(from: start)
    }
    
    func        numberOfDaysUntilDateTime   (toDateTime: NSDate, inTimeZone timeZone: TimeZone? = nil) -> Int {
        
        let calendar = (NSCalendar.current as NSCalendar)
        
        if let timeZone = timeZone {
            calendar.timeZone = timeZone
        }
        
        var fromDate: NSDate?, toDate: NSDate?
        
        calendar.range(of: .day, start: &fromDate, interval: nil, for: self)
        calendar.range(of: .day, start: &toDate, interval: nil, for: toDateTime as Date)
        
        return calendar.components(.day, from: fromDate! as Date, to: toDate! as Date, options: [ ]).day!
    }
}

public extension Date {
    
    /// gets utc midnight
    public func utc() -> Date {
        let date = self.dateOnly()
        let offset = NSTimeZone.default.secondsFromGMT()
        let midnightUTC = (date as NSDate).addingSeconds(offset)
        return midnightUTC!
    }
    
    /// changes utc date to local dates
    public func local() -> Date {
        let offset = NSTimeZone.default.secondsFromGMT()
        let local = (self as NSDate).addingSeconds(-1 * offset)
        return local!
    }
}

public final class DateUtil {
    
    // MARK : Constants
    fileprivate static var dateFormatString:NSString = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    
    /**
     The maximum length for a date is 23, as counted from the format of the following:
     
     `yyyy-MM-ddTHH:mm:ss.SSS`
     
     */
    fileprivate static var dateStringMaxLength = 23
    
    /**
     All the component units for a calendar: year, month, day, hour, minute, second, nanosecond.
     */
    fileprivate static var allComponentUnits: NSCalendar.Unit = [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second, NSCalendar.Unit.nanosecond];
    
    /**
     The UTC Timezone.
     */
    fileprivate static var utcTimeZone = TimeZone(identifier: "UTC")
    
    fileprivate static var _timeFormatter :DateFormatter?
    
    /**
     The Date formatter.
     */
    fileprivate static var _dateFormatter : DateFormatter?
    
    public class var dateFormatter : DateFormatter{
        
        if _dateFormatter == nil {
            _dateFormatter = DateFormatter()
            _dateFormatter!.dateFormat = dateFormatString as String
            _dateFormatter!.calendar = Calendar.gregorian
        }
        
        return _dateFormatter!
        
    }
    
    /**
     The UTC Calendar.
     */
    fileprivate static var _utcCalendar : Calendar?
    
    public class var utcCalendar : Calendar
    {
        if _utcCalendar == nil
        {
            _utcCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
            _utcCalendar?.timeZone = TimeZone(secondsFromGMT: 0)!
            
        }
        
        return _utcCalendar!;
    }
    
    public class func parseDateLocal(_ dateString: String) -> Date?{
        
        let dateFormat = DateFormatter();
        
        
        let formatString = dateFormatString.substring(
            to: dateFormatString.length -
                (dateStringMaxLength - dateString.count )
        )
        
        //println(formatString)
        dateFormat.dateFormat = formatString
        //dateFormat.timeZone = NSTimeZone(name: "UTC")
        return dateFormat.date(from: dateString)
        
    }
    
    // MicrosoftDateFormat /Date(1505116527923)/
    public class func parseMSDateFormat(string: String) -> Date? {
        
        guard string.count >= 8 else {
            return nil
        }
        
//        let right = string.replacingOccurrences(of: "/Date(", with: "", options: .literal, range: string.startIndex..<string.index(string.startIndex, offsetBy: 6))
//        let middle = right.replacingOccurrences(of: ")/", with: "", range: string.index(string.endIndex, offsetBy: -2)..<string.endIndex)
//        string.index(before: string.index(before: string.endIndex))
        
        let middle  = string.replacingOccurrences(of: "/Date(", with: "").replacingOccurrences(of: ")/", with: "")
        
        if let epoch_ms = Int64(middle) {
            let epoch_s = epoch_ms / 1000
            let date    = Date(timeIntervalSince1970: TimeInterval(epoch_s))
            return date
        }
        
        return nil
    }
    
    
    public static func monthName(_ month: Int, short: Bool = false) -> String {
        let jan = Date(timeIntervalSince1970: 0)
        let mon = (jan as NSDate).addingMonths(month - 1)
        let utc = TimeZone(secondsFromGMT: 0)
        return (mon! as NSDate).formattedDate(withFormat: short ? "MMM" : "MMMM", timeZone: utc)
    }
    
    public static func weekName(_ weekday: Int, short: Bool = false) -> String {
        switch weekday {
        case 1: return short ? "Su" : "Sunday"
        case 2: return short ? "Mo" : "Monday"
        case 3: return short ? "Tu" : "Tuesday"
        case 4: return short ? "We" : "Wednesday"
        case 5: return short ? "Th" : "Thursday"
        case 6: return short ? "Fr" : "Friday"
        case 7: return short ? "Sa" : "Saturday"
        default: return ""
        }
    }
}


