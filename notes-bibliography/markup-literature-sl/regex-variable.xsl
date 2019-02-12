<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:functx="http://www.functx.com"
    exclude-result-prefixes="xs functx"
    version="2.0">
    
    <!-- main components of journal article -->
    <xsl:variable name="regex-journal_article">
        <!-- 
             article title in quotation mark: $quotation_mark-opening.*?$quotation_mark-closing
             journal title in italic: \[\[italic\]\].*?\[/\[italic\]\]
             date of publication in parenthesis: \(.*?\d{4}\)
        -->
        
        <xsl:text>(</xsl:text> <!-- opening parenthesis for regex group 1 -->
        <xsl:text>.*?</xsl:text> <!-- ungreedy to -->
        <xsl:value-of select="$separator-authors_titles"/>
        <xsl:text>\s</xsl:text> <!-- space -->
        <xsl:value-of select="$quotation_mark-opening"/>
        <xsl:text>.*?</xsl:text> <!-- title of the article inside opening and closing parenthesis -->
        <xsl:value-of select="$quotation_mark-closing"/>
        <xsl:text>.*?</xsl:text> <!-- ungreedy to space and opening italic string in next regex groups -->
        <xsl:text>)</xsl:text> <!-- closing parenthesis for regex group 1 -->
        
        <xsl:text>(</xsl:text> <!-- opening parenthesis for regex group 2 -->
        <xsl:text>\s</xsl:text> <!-- space before opening italic string in next regex group -->
        <xsl:text>)</xsl:text> <!-- closing parenthesis for regex group 2 -->
        
        <xsl:text>(</xsl:text> <!-- opening parenthesis for regex group 3 -->
        <xsl:text>\[\[italic\]\]</xsl:text> <!-- opening italic string -->
        <xsl:text>.*?</xsl:text> <!-- title of the jornal inside opening and closing italic strings -->
        <xsl:text>\[/\[italic\]\]</xsl:text> <!-- closing italic string -->
        <xsl:text>.*?</xsl:text> <!-- ungreedy to -->
        <xsl:text>\(.*?\d{4}\)</xsl:text> <!-- date in parenthesis -->
        <xsl:text>.*</xsl:text> <!-- greedy to end -->
        <xsl:text>)</xsl:text> <!-- closing parenthesis for regex group 3 -->
        
    </xsl:variable>
    
    
</xsl:stylesheet>