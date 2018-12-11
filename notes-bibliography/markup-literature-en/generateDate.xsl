<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:function name="tei:generateDate">
        <xsl:param name="context"/>
        <xsl:for-each select="$context">
            <xsl:choose>	
                <xsl:when test="ancestor-or-self::tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date">
                    <xsl:analyze-string
                        select="ancestor-or-self::tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date"
                        regex="([0-9][0-9][0-9][0-9]) ([A-z]+)( \(TCP [^\)]+\))?">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(1)"/>
                            <xsl:text>-</xsl:text>
                            <xsl:choose>
                                <xsl:when test="regex-group(2)='January'">01</xsl:when>
                                <xsl:when test="regex-group(2)='February'">02</xsl:when>
                                <xsl:when test="regex-group(2)='March'">03</xsl:when>
                                <xsl:when test="regex-group(2)='April'">04</xsl:when>
                                <xsl:when test="regex-group(2)='May'">05</xsl:when>
                                <xsl:when test="regex-group(2)='June'">06</xsl:when>
                                <xsl:when test="regex-group(2)='July'">07</xsl:when>
                                <xsl:when test="regex-group(2)='August'">08</xsl:when>
                                <xsl:when test="regex-group(2)='September'">09</xsl:when>
                                <xsl:when test="regex-group(2)='October'">10</xsl:when>
                                <xsl:when test="regex-group(2)='November'">11</xsl:when>
                                <xsl:when test="regex-group(2)='December'">12</xsl:when>
                            </xsl:choose>  
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:value-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:when test="ancestor-or-self::tei:TEI/tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition">
                    <xsl:apply-templates select="ancestor-or-self::tei:TEI/tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="format-dateTime(current-dateTime(),'[Y]-[M02]-[D02]')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    
</xsl:stylesheet>