<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:functx="http://www.functx.com"
    exclude-result-prefixes="xs functx"
    version="2.0">
    
    <!-- separator between authors and titles at the beginning - string (beware - the same separator in regex-param.xsl - but as regex) -->
    <xsl:param name="separator-authors_titles">.</xsl:param>
    
    <!-- seperator between title and subtitle -->
    <xsl:param name="seperator-titles">: </xsl:param>
    <!-- seperator between firs and second subtitle -->
    <xsl:param name="seperator-subtitles">; </xsl:param>
    
    <!-- opening quotation mark (» etc.) - string (beware - the same separator in regex-param.xsl - but as regex) -->
    <xsl:param name="quotation_mark-opening">"</xsl:param>
    <!-- closing quotation mark (« etc.) - string (beware - the same separator in regex-param.xsl - but as regex) -->
    <xsl:param name="quotation_mark-closing">"</xsl:param>
    
    
    
</xsl:stylesheet>