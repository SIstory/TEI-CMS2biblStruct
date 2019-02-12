<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:functx="http://www.functx.com"
    exclude-result-prefixes="xs functx"
    version="2.0">
    
    <!-- separator between title of chapter and title of monography -->
    <xsl:param name="separator-part_of_monogr-regex" as="xs:string">\sV:\s</xsl:param>
    
    <!-- separator between authors and titles at the beginning - regex (beware - the same separator in param.xsl - but not as regex) -->
    <xsl:param name="separator-authors_titles-regex">\.</xsl:param>
    
    <!-- opening quotation mark (» etc.) - regex (beware - the same separator in param.xsl - but not as regex) -->
    <xsl:param name="quotation_mark-opening-regex">"</xsl:param>
    <!-- closing quotation mark (« etc.) - together with posible punctation before or after
         - regex (beware - the same separator in param.xsl - but not as regex) -->
    <xsl:param name="quotation_mark-closing-regex">\.?"\.?</xsl:param>
    
</xsl:stylesheet>