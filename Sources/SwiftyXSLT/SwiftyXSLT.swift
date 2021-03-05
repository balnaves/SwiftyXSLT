import Foundation
import Wrapper

public struct SwiftyXSLT {
    public func transform(xml: String, with stylesheet: String) -> String? {
        guard let result = WrapperXSLT.transformXML(xml, withStyleSheet: stylesheet) else {
            print("Unable to transform text")
            return nil
        }
        print("Got transformed text: \(result)")
        return result
    }
}
