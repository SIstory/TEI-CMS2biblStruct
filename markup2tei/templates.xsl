<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:variable name="months">
        <month n="1" name="januar" slvName="januar" engName="January">01</month>
        <month name="januarja" slvName="januar" engName="January">01</month>
        <month n="2" name="februar" slvName="februar" engName="February">02</month>
        <month name="februarja" slvName="februar" engName="February">02</month>
        <month n="3" name="marec" slvName="marec" engName="March">03</month>
        <month name="marca" slvName="marec" engName="March">03</month>
        <month n="4" name="april" slvName="april" engName="April">04</month>
        <month name="aprila" slvName="april" engName="April">04</month>
        <month n="5" name="maj" slvName="maj" engName="May">05</month>
        <month name="maja" slvName="maj" engName="May">05</month>
        <month n="6" name="junij" slvName="junij" engName="June">06</month>
        <month name="junija" slvName="junij" engName="June">06</month>
        <month n="7" name="julij" slvName="julij" engName="July">07</month>
        <month name="julija" slvName="julij" engName="July">07</month>
        <month n="8" name="avgust" slvName="avgust" engName="August">08</month>
        <month name="avgusta" slvName="avgust" engName="August">08</month>
        <month n="9" name="september" slvName="september" engName="September">09</month>
        <month name="septembra" slvName="september" engName="September">09</month>
        <month n="10" name="oktober" slvName="oktober" engName="October">10</month>
        <month name="oktobra" slvName="oktober" engName="October">10</month>
        <month n="11" name="november" slvName="november" engName="November">11</month>
        <month name="novembra" slvName="november" engName="November">11</month>
        <month n="12" name="december" slvName="december" engName="December">12</month>
        <month name="decembra" slvName="december" engName="December">12</month>
    </xsl:variable>
    
    <xsl:variable name="days">
        <day n="1">01</day>
        <day n="2">02</day>
        <day n="3">03</day>
        <day n="4">04</day>
        <day n="5">05</day>
        <day n="6">06</day>
        <day n="7">07</day>
        <day n="8">08</day>
        <day n="9">09</day>
        <day n="10">10</day>
        <day n="11">11</day>
        <day n="12">12</day>
        <day n="13">13</day>
        <day n="14">14</day>
        <day n="15">15</day>
        <day n="16">16</day>
        <day n="17">17</day>
        <day n="18">18</day>
        <day n="19">19</day>
        <day n="20">20</day>
        <day n="21">21</day>
        <day n="22">22</day>
        <day n="23">23</day>
        <day n="24">24</day>
        <day n="25">25</day>
        <day n="26">26</day>
        <day n="27">27</day>
        <day n="28">28</day>
        <day n="29">29</day>
        <day n="30">30</day>
        <day n="31">31</day>
    </xsl:variable>
    
    <xsl:template name="formatDate">
        <xsl:variable name="DAY" select="substring-before(tokenize(.,' ')[1],'.')"/>
        <xsl:variable name="MONTH" select="substring-before(tokenize(.,' ')[2],'.')"/>
        <xsl:variable name="YEAR" select="tokenize(.,' ')[3]"/>
        <xsl:value-of select="concat($YEAR,'-',$months/month[@n = $MONTH],'-',$days/day[@n = $DAY])"/>
    </xsl:template>
    
    <xsl:template name="authors-main">
        <xsl:for-each select="author">
            <xsl:call-template name="creator"/>
        </xsl:for-each>
        <xsl:for-each select="organization">
            <author>
                <orgName>
                    <xsl:value-of select="."/>
                </orgName>
            </author>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="editors-main">
        <xsl:for-each select="editor">
            <xsl:call-template name="creator"/>
        </xsl:for-each>
        <xsl:for-each select="translator">
            <xsl:call-template name="creator"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="editors-additional">
        <xsl:for-each select="author">
            <xsl:call-template name="creator"/>
        </xsl:for-each>
        <xsl:for-each select="editor">
            <xsl:call-template name="creator"/>
        </xsl:for-each>
        <xsl:for-each select="translator">
            <xsl:call-template name="creator"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="creator">
        <xsl:variable name="creator-element-name">
            <xsl:choose>
                <xsl:when test="name(.) eq 'editor'">editor</xsl:when>
                <xsl:when test="name(.) eq 'translator'">editor</xsl:when>
                <!-- all others are authors -->
                <xsl:otherwise>author</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="{$creator-element-name}">
            <xsl:choose>
                <xsl:when test="name(.) eq 'translator'">
                    <xsl:attribute name="role">translator</xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <!-- Surname Surname, Forename Forename -->
                <xsl:when test="contains(.,', ')">
                    <persName>
                        <xsl:for-each select="tokenize(substring-after(.,', '),' ')">
                            <forename>
                                <xsl:choose>
                                    <!-- when name initial without period -->
                                    <xsl:when test="matches(.,'^[A-Z]$','m')">
                                        <xsl:attribute name="full">init</xsl:attribute>
                                        <xsl:value-of select="concat(.,'.')"/>
                                    </xsl:when>
                                    <!-- when name initial with period -->
                                    <xsl:when test="matches(.,'^[A-Z]\.$','m')">
                                        <xsl:attribute name="full">init</xsl:attribute>
                                        <xsl:value-of select="."/>
                                    </xsl:when>
                                    <!-- full name -->
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </forename>
                        </xsl:for-each>
                        <xsl:for-each select="tokenize(substring-before(.,', '),' ')">
                            <surname>
                                <xsl:choose>
                                    <!-- when name initial with period -->
                                    <xsl:when test="matches(.,'^[A-Z]\.$','m')">
                                        <xsl:attribute name="full">init</xsl:attribute>
                                        <xsl:value-of select="."/>
                                    </xsl:when>
                                    <!-- full name -->
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </surname>
                        </xsl:for-each>
                    </persName>
                </xsl:when>
                <!-- Forename Surname -->
                <xsl:when test=" matches(.,'\s') and not(matches(.,',\s')) and not(matches(.,'(.*?)\s(.*?)\s(.*?)'))">
                    <persName>
                        <forename>
                            <xsl:for-each select="tokenize(.,'\s')[1]">
                                <xsl:choose>
                                    <!-- when name initial with period -->
                                    <xsl:when test="matches(.,'^[A-Z]\.$','m')">
                                        <xsl:attribute name="full">init</xsl:attribute>
                                        <xsl:value-of select="."/>
                                    </xsl:when>
                                    <!-- full name -->
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </forename>
                        <surname>
                            <xsl:for-each select="tokenize(.,'\s')[2]">
                                <xsl:choose>
                                    <!-- when name initial with period -->
                                    <xsl:when test="matches(.,'^[A-Z]\.$','m')">
                                        <xsl:attribute name="full">init</xsl:attribute>
                                        <xsl:value-of select="."/>
                                    </xsl:when>
                                    <!-- full name -->
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </surname>
                    </persName>
                </xsl:when>
                <!-- Forename Forename Surname Surname - there is no rule for spliting the string in forename(s) and surename(s) -->
                <xsl:otherwise>
                    <persName>
                        <xsl:value-of select="."/>
                    </persName>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="title-monogr-m">
        <xsl:for-each select="i/title[1]">
            <title level="m" type="main">
                <xsl:value-of select="."/>
            </title>
        </xsl:for-each>
        <xsl:for-each select="i/title[position() gt 1]">
            <title level="m" type="sub">
                <xsl:value-of select="."/>
            </title>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="addTitle-monogr-m">
        <xsl:for-each select="addTitle">
            <title level="m" type="parallel">
                <xsl:value-of select="."/>
            </title>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="title-monogr-j">
        <xsl:for-each select="i/title[1]">
            <title level="j" type="main">
                <xsl:value-of select="."/>
            </title>
        </xsl:for-each>
        <xsl:for-each select="i/title[position() gt 1]">
            <title level="j" type="sub">
                <xsl:value-of select="."/>
            </title>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="addTitle-monogr-j">
        <xsl:for-each select="addTitle">
            <title level="m" type="parallel">
                <xsl:value-of select="."/>
            </title>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="title-analytic">
        <xsl:for-each select="title[1]">
            <title level="a" type="main">
                <xsl:value-of select="."/>
            </title>
        </xsl:for-each>
        <xsl:for-each select="title[position() gt 1]">
            <title level="a" type="sub">
                <xsl:value-of select="."/>
            </title>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="addTitle-analytic">
        <xsl:for-each select="addTitle">
            <title level="a" type="parallel">
                <xsl:value-of select="."/>
            </title>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="date">
        <date>
            <xsl:choose>
                <xsl:when test="matches(.,'^\d{4}$','m')">
                    <xsl:attribute name="when">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="matches(.,'^(\d{4})([-–])(\d+)$','m')">
                    <xsl:analyze-string select="." regex="^(\d{{4}})([-–])(\d+)$" flags="m">
                        <xsl:matching-substring>
                            <xsl:attribute name="from">
                                <xsl:value-of select="regex-group(1)"/>
                            </xsl:attribute>
                            <xsl:attribute name="to">
                                <xsl:choose>
                                    <xsl:when test="string-length(regex-group(3)) eq 4">
                                        <xsl:value-of select="."/>
                                    </xsl:when>
                                    <xsl:when test="string-length(regex-group(3)) eq 3">
                                        <xsl:value-of select="concat(substring(regex-group(1),1,1),regex-group(3))"/>
                                    </xsl:when>
                                    <xsl:when test="string-length(regex-group(3)) eq 2">
                                        <xsl:value-of select="concat(substring(regex-group(1),1,2),regex-group(3))"/>
                                    </xsl:when>
                                    <xsl:when test="string-length(regex-group(3)) eq 1">
                                        <xsl:value-of select="concat(substring(regex-group(1),1,3),regex-group(3))"/>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </date>
    </xsl:template>
    
    <xsl:template name="origDate">
        <origDate>
            <xsl:choose>
                <xsl:when test="matches(.,'^\d{4}$','m')">
                    <xsl:attribute name="when">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </origDate>
    </xsl:template>
    
    <xsl:template name="extent">
        <xsl:for-each select="extent">
            <extent>
                <xsl:value-of select="."/>
            </extent>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="edition">
        <xsl:for-each select="edition">
            <edition>
                <xsl:choose>
                    <xsl:when test="matches(.,'^\d+$','m')">
                        <xsl:attribute name="n">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </edition>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="imprint">
        <imprint>
            <xsl:for-each select="pubPlace">
                <pubPlace>
                    <xsl:value-of select="."/>
                </pubPlace>
            </xsl:for-each>
            <xsl:for-each select="publisher">
                <publisher>
                    <xsl:value-of select="."/>
                </publisher>
            </xsl:for-each>
            <xsl:for-each select="date">
                <xsl:call-template name="date"/>
            </xsl:for-each>
            <xsl:for-each select="origDate">
                <date>
                    <xsl:call-template name="origDate"/>
                </date>
            </xsl:for-each>
        </imprint>
    </xsl:template>
    
    <xsl:template name="imprint-partOfMultivol">
        <imprint>
            <xsl:for-each select="date">
                <xsl:call-template name="date"/>
            </xsl:for-each>
            <xsl:for-each select="origDate">
                <date>
                    <xsl:call-template name="origDate"/>
                </date>
            </xsl:for-each>
        </imprint>
    </xsl:template>
    
    <xsl:template name="imprint-multivol">
        <imprint>
            <xsl:for-each select="pubPlace">
                <pubPlace>
                    <xsl:value-of select="."/>
                </pubPlace>
            </xsl:for-each>
            <xsl:for-each select="publisher">
                <publisher>
                    <xsl:value-of select="."/>
                </publisher>
            </xsl:for-each>
        </imprint>
    </xsl:template>
    
    <xsl:template name="volume">
        <xsl:for-each select="volume">
            <biblScope unit="volume">
                <xsl:value-of select="."/>
            </biblScope>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="series">
        <xsl:for-each select="series">
            <series>
                <xsl:choose>
                    <xsl:when test="matches(.,'\s\d+$','m')">
                        <xsl:analyze-string select="." regex="^(.*)(\s)(\d+)$" flags="m">
                            <xsl:matching-substring>
                                <title level="s">
                                    <xsl:value-of select="regex-group(1)"/>
                                </title>
                                <biblScope unit="volume">
                                    <xsl:value-of select="regex-group(3)"/>
                                </biblScope>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <xsl:otherwise>
                        <title level="s">
                            <xsl:value-of select="."/>
                        </title>
                    </xsl:otherwise>
                </xsl:choose>
            </series>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="page">
        <xsl:for-each select="page">
            <biblScope unit="page">
                <xsl:if test="matches(.,'[-–−]')">
                    <xsl:analyze-string select="." regex="^(\d+|[ivxlIVXL]+)([-–−])(\d+|[ivxlIVXL]+)$" flags="m">
                        <xsl:matching-substring>
                            <xsl:attribute name="from">
                                <xsl:value-of select="regex-group(1)"/>
                            </xsl:attribute>
                            <xsl:attribute name="to">
                                <xsl:value-of select="regex-group(3)"/>
                            </xsl:attribute>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:if>
                <xsl:value-of select="."/>
            </biblScope>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="online">
        <xsl:for-each select="../online/ref">
            <ref target="{.}">
                <xsl:value-of select="."/>
            </ref>
            <xsl:if test="../when">
                <!-- TODO - attempts to arrange date as yead-month-day format-->
                <xsl:for-each select="../when">
                    <note type="accessed">
                        <date>
                            <xsl:attribute name="when">
                                <xsl:call-template name="formatDate"/>
                            </xsl:attribute>
                        </date>
                    </note>
                </xsl:for-each>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>