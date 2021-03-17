import XCTest
@testable import SwiftyXSLT

final class SwiftyXSLTTests: XCTestCase {
    
    let xmlString = """
    <?xml version="1.0"?>
    <?xml-stylesheet type="text/xsl" href="example.xsl"?>
    <Article>
      <Title>My Article</Title>
      <Authors>
        <Author>Mr. Foo</Author>
        <Author>Mr. Bar</Author>
      </Authors>
      <Body>This is my article text.</Body>
    </Article>
    """
    
    let stylesheetString = """
    <?xml version="1.0"?>
    <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

      <xsl:output method="text"/>

      <xsl:template match="/">
        Article - <xsl:value-of select="/Article/Title"/>
        Authors: <xsl:apply-templates select="/Article/Authors/Author"/>
      </xsl:template>

      <xsl:template match="Author">
        - <xsl:value-of select="." />
      </xsl:template>

    </xsl:stylesheet>
    """
    
    let resultString = "\n    Article - My Article\n    Authors: \n    - Mr. Foo\n    - Mr. Bar"
    
    func testTransform() {
        let result = try? SwiftyXSLT.shared().transformXML(xmlString, withStyleSheet: stylesheetString)
        XCTAssertNotNil(result)
        XCTAssertEqual(result, resultString)
    }
    
    func testMalformedStylesheet() {
        do {
            let _ = try SwiftyXSLT().transformXML(xmlString, withStyleSheet: "<?bleh>")
        }
        catch {
            XCTAssertNotNil(error)
            return
        }
        XCTFail("Malformed stylesheet did not throw error")
    }

    static var allTests = [
        ("testTransform", testTransform), ("testMalformedStylesheet", testMalformedStylesheet)
    ]
}
