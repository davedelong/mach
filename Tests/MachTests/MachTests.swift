import XCTest
@testable import Mach

final class MachTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
        
//        let headers = Dyld.images
//        for header in headers {
//            dumpHeader(header)
//        }
        
        let headers = FAT.headers(from: URL(filePath: "/Applications/BBEdit.app/Contents/MacOS/BBEdit"))
        for header in headers {
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
            } else if let sym = command as? SymbolTableCommand {
                for symbol in sym.symbols {
                    print("\t\t", symbol.name)
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
