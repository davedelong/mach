import XCTest
@testable import Mach

final class MachTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
        
//        let images = Dyld.images
//        for image in images {
//            dumpImage(image)
//        }
        
        let img = FAT(file: URL(filePath: "/Applications/Base.app/Contents/MacOS/Base"))
        for header in img?.headers ?? [] {
            dumpHeader(header)
        }
    }
    
    func dumpHeader(_ header: Header) {
        print("=========")
        print(header)
        for command in header.commands {
            print("\t", command)
            if let segment = command as? SegmentCommand {
                for section in segment.sections {
                    print("\t\t", section)
                }
            } else if let build = command as? BuildVersionCommand {
                for tool in build.tools {
                    print("\t\t", tool)
                }
            }
        }
        print("-----------")
        var strCount = 0
        for _ in header.strings { strCount += 1 }
        print(strCount, "strings")
        print(header.entitlements)
    }
}
