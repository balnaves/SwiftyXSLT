import XCTest
@testable import SwiftyXSLT

final class SwiftyXSLTTests: XCTestCase {
    
    let xmlData = """
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
    """.data(using: .utf8)!
    
    let stylesheetData = """
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
    """.data(using: .utf8)!

    let stylesheetDataV2 = """
    <?xml version="1.0"?>
    <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

      <xsl:output method="text"/>

      <xsl:template match="/">
        Article - <xsl:value-of select="/Article/Title"/>
        Authors: <xsl:apply-templates select="/Article/Authors/Author"/>
      </xsl:template>

      <xsl:template match="Author">
        - <xsl:value-of select="." />
      </xsl:template>

    </xsl:stylesheet>
    """.data(using: .utf8)!
    
    let resultString = "\n    Article - My Article\n    Authors: \n    - Mr. Foo\n    - Mr. Bar"
    
    func testTransform() {
        let result = try? SwiftyXSLT.shared().transformXML(xmlData, withStyleSheet: stylesheetData)
        XCTAssertNotNil(result)
        XCTAssertEqual(result.flatMap { String(data: $0, encoding: .utf8) }, resultString)
    }
    
    func testMalformedStylesheet() {
        do {
            let _ = try SwiftyXSLT().transformXML(xmlData, withStyleSheet: Data())
        }
        catch {
            XCTAssertNotNil(error)
            return
        }
        XCTFail("Malformed stylesheet did not throw error")
    }

    func testIncomptibleVersionStylesheet() {
        do {
            let _ = try SwiftyXSLT().transformXML(xmlData, withStyleSheet: stylesheetDataV2)
        }
        catch {
            XCTAssertNotNil(error)
            return
        }
        XCTFail("XSL versin >1.1 did not throw an error")
    }

    static var allTests = [
        ("testTransform", testTransform),
        ("testMalformedStylesheet", testMalformedStylesheet),
        ("testIncomptibleVersionStylesheet", testIncomptibleVersionStylesheet),
    ]
}
