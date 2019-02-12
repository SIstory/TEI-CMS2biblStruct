<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:functx="http://www.functx.com"
    exclude-result-prefixes="xs functx"
    version="2.0">
    
    <xsl:template name="journal">
        <xsl:analyze-string select="." regex="^(\[\[italic\]\].*?\[/\[italic\]\])(\s\d*[-–−/]?\d+)?(,\sšt\.\s\d*[-–−/]?\d+)?(\s\(.*?\))(.*?)$" flags="m">
            <xsl:matching-substring>
                <!-- title of the journal in italic -->
                <xsl:for-each select="regex-group(1)">
                    <xsl:call-template name="title-step1-italic"/>
                </xsl:for-each>
                <!-- posible volume (letnik revije) -->
                <xsl:for-each select="regex-group(2)">
                    <xsl:analyze-string select="." regex="^(\s)(\d*[-–−/]?\d+)$" flags="m">
                        <xsl:matching-substring>
                            <!-- space after italic -->
                            <xsl:value-of select="regex-group(1)"/>
                            <!-- volume number(s) -->
                            <volume>
                                <xsl:value-of select="regex-group(2)"/>
                            </volume>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:value-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:for-each>
                <!-- posible issue (številka revije) -->
                <xsl:for-each select="regex-group(3)">
                    <xsl:analyze-string select="." regex="^(,\sšt\.\s)(\d*[-–−/]?\d+)$" flags="m">
                        <xsl:matching-substring>
                            <!-- comma, space, abbreviation for number (št.), space -->
                            <xsl:value-of select="regex-group(1)"/>
                            <!-- issue number -->
                            <issue>
                                <xsl:value-of select="regex-group(2)"/>
                            </issue>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:value-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:for-each>
                <!-- date of publication -->
                <xsl:for-each select="regex-group(4)">
                    <xsl:analyze-string select="." regex="^(\s\()(.*?)(\))$" flags="m">
                        <xsl:matching-substring>
                            <!-- space and left parenthesis - uvodni oklepaj ( -->
                            <xsl:value-of select="regex-group(1)"/>
                            <!-- date string -->
                            <date>
                                <xsl:value-of select="regex-group(2)"/>
                            </date>
                            <!-- right parenthesis -->
                            <xsl:value-of select="regex-group(3)"/>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:value-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:for-each>
                <!-- pages -->
                <xsl:for-each select="regex-group(5)">
                    <xsl:analyze-string select="." regex="^(:\s)([\dXLI]*[-–−]?[\dXLI]+)(.*?)$">
                        <xsl:matching-substring>
                            <!-- colon (dvopičje :) an space before page number -->
                            <xsl:value-of select="regex-group(1)"/>
                            <!-- page(s) -->
                            <page>
                                <xsl:value-of select="regex-group(2)"/>
                            </page>
                            <!-- posible unknown data -->
                            <xsl:if test="string-length(regex-group(3)) gt 0">
                                <unknown>
                                    <xsl:value-of select="regex-group(3)"/>
                                </unknown>
                            </xsl:if>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:value-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:for-each>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!-- book with separate chapters (zbornik) -->
    <xsl:template name="book_chs-step1">
        <!-- beware: if thera are no data for pages, period as separator betwen posible editors and publication palce
                       may not be immediately after the
                         space and capital leter (abbreviation for personal name)
                         abbreviation for creators:
                           ur.
                           prev.
                           avt.
              See solution in regex group 4 and 5. -->
        <xsl:analyze-string select="." regex="^(\[\[italic\]\].*?\[/\[italic\]\])(,?\s)(.*?)([^u][^r]|[^p][^r][^e][^v]|[^a][^v][^t])(\S[^A-Z])(\.\s)(.*?)(,\s)(\d{{4}})$" flags="m">
            <xsl:matching-substring>
                <!-- title and subtitles in italic -->
                <xsl:for-each select="regex-group(1)">
                    <xsl:call-template name="title-step1-italic"/>
                </xsl:for-each>
                <!-- comma (posible) and place between title and additional creators-->
                <xsl:value-of select="regex-group(2)"/>
                <!-- data after title of the book and before publication place and publisher -->
                <xsl:for-each select="concat(regex-group(3),regex-group(4),regex-group(5))">
                    <xsl:call-template name="book_chs-step2-other_metadata"/>
                </xsl:for-each>
                <!-- period and space after page data -->
                <xsl:value-of select="regex-group(6)"/>
                <!-- data about pubPlace and publisher -->
                <xsl:for-each select="regex-group(7)">
                    <xsl:call-template name="place_publisher-step1"/>
                </xsl:for-each>
                <!-- comma and place before date of publication (only year) -->
                <xsl:value-of select="regex-group(8)"/>
                <date>
                    <xsl:value-of select="regex-group(9)"/>
                </date>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template name="book_chs-step2-other_metadata">
        <xsl:choose>
            <!-- when there are numbers at the end of the string (for pages) -->
            <xsl:when test="matches(.,'[\dXLI]*[-–−]?[\dXLI]$','m')">
                <xsl:analyze-string select="." regex="^(.*?)(,?\s?)([\dXLI]*[-–−]?[\dXLI]+)$" flags="m">
                    <xsl:matching-substring>
                        <!-- additional creators. TODO: if problems with transformation, arrange similar as in template_pass1-other_metadata -->
                        <xsl:for-each select="regex-group(1)">
                            <xsl:call-template name="additional_creators"/>
                        </xsl:for-each>
                        <!-- comma (posible) nad place before posible page numbers -->
                        <xsl:value-of select="regex-group(2)"/>
                        <!-- pages -->
                        <xsl:if test="string-length(regex-group(3)) gt 0">
                            <page>
                                <xsl:value-of select="regex-group(3)"/>
                            </page>
                        </xsl:if>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <!-- otherwise only additional creators -->
            <xsl:otherwise>
                <!-- additional creators. TODO: if problems with transformation, arrange similar as in template_pass1-other_metadata -->
                <xsl:for-each select=".">
                    <xsl:call-template name="additional_creators"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="book_step1-other_metadata">
        <!-- PREVAJALCI, UREDNIKI, KRAJI IZDAJE, ZALOŽBE, OSTALO -->
        <xsl:choose>
            <!-- when string begins with square brackets and text within [text] then additiona [translated] title  -->
            <xsl:when test="matches(.,'^(\[.+\]\.\s)','m')">
                <xsl:call-template name="book_step2-addTitle"/>
            </xsl:when>
            <!-- when string begins with year of first publication and then information about reprint (ponatis) -->
            <xsl:when test="matches(.,'^\d{4}\.\sPonatis','m')">
                <xsl:call-template name="book_step2-reprint"/>
            </xsl:when>
            <!-- when string begins with 
                   number of edition (št. izdaje) or
                   abbreviation for revised edition (popravljena izdaja Popr. izd)
            -->
            <xsl:when test="matches(.,'^(\d+\.\s|[Pp]opr\.\s)(izd\.\s)')">
                <xsl:call-template name="book_step2-edition"/>
            </xsl:when>
            <!-- when string begins with number of all volumens (skupno število zvezkov, 3 zv.) -->
            <xsl:when test="matches(.,'^\d+\szv\.','m')">
                <xsl:call-template name="book_step2-volumes"/>
            </xsl:when>
            <!-- when string begins with citing only one volume (zvezek) -->
            <xsl:when test="matches(.,'^Zv\.\s\d+','m')">
                <xsl:call-template name="book_step2-volume"/>
            </xsl:when>
            <!-- when string begins with abbreviation for creator (editor, translator, author) -->
            <xsl:when test="matches(.,'^([Pp]rev\.\s|[Uu]r\.\s|[Aa]vt\.\s)','m')">
                <!-- processing text to period: suitable only for monographic publication (not for books with chapters) -->
                <xsl:call-template name="book_step2-additional_creators"/>
            </xsl:when>
            <!-- When string begins with series (books collection - zbirka).
                 Unfortunately there is no reliable way to recognise series data with regex.
                 Posible solution:
                   when
                     not (period and space) and then also colon : in text (indicator for pubPlace and publisher)
                     not begins with [ (indicator for addTitle)
                     not begins with number (indicator for original year of publication, number of edition and number of all volumens)
                     not begins with Zv. (indicator for citing only one volume)
                     not begins with abbreviation for translator, author or editor (indicator of additional creators)
                   then is
                     series -->
            <xsl:when test="matches(.,'^(.*?)(\.\s)(.*?)(:\s)','m') 
                and not(matches(.,'^\[','m')) 
                and not(matches(.,'^\d','m')) 
                and not(matches(.,'^Zv\.\s','m')) 
                and not(matches(.,'^([Pp]rev\.\s|[Uu]r\.\s|[Aa]vt\.\s)','m'))">
                <xsl:call-template name="book_step2-series"/>
            </xsl:when>
            <!-- otherwise publication place and publisher -->
            <xsl:otherwise>
                <xsl:for-each select=".">
                    <xsl:call-template name="place_publisher-step1"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="book_step2-series">
        <!-- after data about series (book collection - zbirka) follows:
               - data about additional creators (editors or translators) or 
               - data about publication place and publisher -->
        <xsl:analyze-string select="." regex="^(.*?)(\.\s|,\sur\.\s|,\sprev\.\s)(.*?)$" flags="m">
            <xsl:matching-substring>
                <series>
                    <xsl:value-of select="regex-group(1)"/>
                </series>
                <xsl:choose>
                    <xsl:when test="matches(regex-group(2),',\sur\.\s')">
                        <xsl:text>, </xsl:text>
                        <!-- the remainder of the text processing once again with book-step1 -->
                        <!-- beware to add abbreviation for editor at the beginning -->
                        <xsl:for-each select="concat('ur. ',regex-group(3))">
                            <xsl:call-template name="book_step1-other_metadata"/>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="matches(regex-group(2),',\sprev\.\s')">
                        <xsl:text>, </xsl:text>
                        <!-- the remainder of the text processing once again with book-step1 -->
                        <!-- beware to add abbreviation for translator at the beginning -->
                        <xsl:for-each select="concat('prev. ',regex-group(3))">
                            <xsl:call-template name="book_step1-other_metadata"/>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- period and place -->
                        <xsl:value-of select="regex-group(2)"/>
                        <!-- the remainder of the text processing once again with book-step1 -->
                        <xsl:for-each select="regex-group(3)">
                            <xsl:call-template name="book_step1-other_metadata"/>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template name="book_step2-addTitle">
        <!-- string begins with square brackets and text within [text] then additiona [translated] title  -->
        <xsl:analyze-string select="." regex="^(\[.+\]\.\s)(.*?)$" flags="m">
            <xsl:matching-substring>
                <xsl:for-each select="regex-group(1)">
                    <xsl:call-template name="addTitle"/>
                </xsl:for-each>
                <!-- the remainder of the text processing once again with book-step1 -->
                <xsl:for-each select="regex-group(2)">
                    <xsl:call-template name="book_step1-other_metadata"/>
                </xsl:for-each>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template name="addTitle">
        <xsl:analyze-string select="." regex="^(\[)(.*?)(\])(\.\s)?$" flags="m">
            <xsl:matching-substring>
                <!-- opening square bracket [ -->
                <xsl:value-of select="regex-group(1)"/>
                <!-- additional title -->
                <addTitle>
                    <xsl:value-of select="regex-group(2)"/>
                </addTitle>
                <!-- closing square bracket -->
                <xsl:value-of select="regex-group(3)"/>
                <!-- period and space at the end -->
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template name="book_step2-reprint">
        <!-- string begins with year of first publication and then data about Reprint (Ponatis) -->
        <xsl:analyze-string select="." regex="^(\d{{4}}\.\sPonatis,\s)(.*?)$" flags="m">
            <xsl:matching-substring>
                <xsl:for-each select="regex-group(1)">
                    <xsl:call-template name="reprint"/>
                </xsl:for-each>
                <!-- the remainder of the text processing once again with book-step1 -->
                <xsl:for-each select="regex-group(2)">
                    <xsl:call-template name="book_step1-other_metadata"/>
                </xsl:for-each>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template name="reprint">
        <xsl:analyze-string select="." regex="^(\d{{4}})(\.\sPonatis,\s)$" flags="m">
            <xsl:matching-substring>
                <!-- original date (year) of publication -->
                <origDate>
                    <xsl:value-of select="regex-group(1)"/>
                </origDate>
                <xsl:value-of select="regex-group(2)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template name="book_step2-edition">
        <!-- string begins with number of edition (št. izdaje) -->
        <xsl:analyze-string select="." regex="^(\d+\.\s|[Pp]opr\.\s)(izd\.\s)(.*?)$" flags="m">
            <xsl:matching-substring>
                <xsl:for-each select="concat(regex-group(1),regex-group(2))">
                    <xsl:call-template name="edition"/>
                </xsl:for-each>
                <!-- the remainder of the text processing once again with book-step1 -->
                <xsl:for-each select="regex-group(3)">
                    <xsl:call-template name="book_step1-other_metadata"/>
                </xsl:for-each>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template name="edition">
        <xsl:choose>
            <xsl:when test="matches(.,'^(\d+\.)','m')">
                <xsl:analyze-string select="." regex="^(\d+)(\.\sizd\.\s)$" flags="m">
                    <xsl:matching-substring>
                        <edition>
                            <xsl:value-of select="regex-group(1)"/>
                        </edition>
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches(.,'^([Pp]opr\.)','m')">
                <xsl:analyze-string select="." regex="^(\d+\.\s|[Pp]opr\.\s)(izd\.)(\s)$" flags="m">
                    <xsl:matching-substring>
                        <edition>
                            <xsl:value-of select="concat(regex-group(1),regex-group(2))"/>
                        </edition>
                        <xsl:value-of select="regex-group(3)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="book_step2-volumes">
        <!-- string begins with number of all volumens (skupno število zvezkov, 3 zv.) -->
        <!-- if the abbreviation is not followed by pubPlace and publisher (space seperator)
             then consider rewriting code (comma seperator?) -->
        <xsl:analyze-string select="." regex="^(\d+\szv\.\s)(.*?)$" flags="m">
            <xsl:matching-substring>
                <xsl:for-each select="regex-group(1)">
                    <xsl:call-template name="volumes"/>
                </xsl:for-each>
                <!-- the remainder of the text processing once again with book-step1 -->
                <xsl:for-each select="regex-group(2)">
                    <xsl:call-template name="book_step1-other_metadata"/>
                </xsl:for-each>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template name="volumes">
        <xsl:analyze-string select="." regex="^(\d+\szv\.)(\s)$" flags="m">
            <xsl:matching-substring>
                <!-- data about all volumens of cited monography write in extent element -->
                <extent>
                    <xsl:value-of select="regex-group(1)"/>
                </extent>
                <!-- space outside extent element -->
                <xsl:value-of select="regex-group(2)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template name="book_step2-volume">
        <!-- string begins with citing only one volume (zvezek) -->
        <xsl:choose>
            <!-- when after volume number also volume title in italic -->
            <xsl:when test="matches(.,'(\[\[italic\]\])(.*?)(\[/\[italic\]\])')">
                <!-- pattern Zv. 1, title-italic -->
                <xsl:analyze-string select="." regex="^(Zv\.\s\d+)(,\s)(\[\[italic\]\].*?\[/\[italic\]\])([\.,]?\s)(.*?)$" flags="m">
                    <xsl:matching-substring>
                        <xsl:for-each select="regex-group(1)">
                            <xsl:call-template name="volume"/>
                        </xsl:for-each>
                        <!-- comma and space between volume number and volume title in italic -->
                        <xsl:value-of select="regex-group(2)"/>
                        <!-- VOLUME TITLE -->
                        <vol>
                            <xsl:for-each select="regex-group(3)">
                                <xsl:call-template name="title-step1-italic"/>
                            </xsl:for-each>
                        </vol>
                        <!-- period (posible) or comma (posible) and space -->
                        <xsl:value-of select="regex-group(4)"/>
                        <!-- the remainder of the text processing once again with book-step1 -->
                        <xsl:for-each select="regex-group(5)">
                            <xsl:call-template name="book_step1-other_metadata"/>
                        </xsl:for-each>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <!-- pattern Zv. 5 dela title-italic -->
                        <xsl:analyze-string select="." regex="^(Zv\.\s\d+)(\sdela\s)(\[\[italic\]\].*?\[/\[italic\]\])([\.,]?\s)(.*?)$" flags="m">
                            <xsl:matching-substring>
                                <xsl:for-each select="regex-group(1)">
                                    <xsl:call-template name="volume"/>
                                </xsl:for-each>
                                <!-- space and word dela and another space between volume number and volume title in italic -->
                                <xsl:value-of select="regex-group(2)"/>
                                <!-- TITLE OF MULTIVOLUME WORK -->
                                <multivol>
                                    <xsl:for-each select="regex-group(3)">
                                        <xsl:call-template name="title-step1-italic"/>
                                    </xsl:for-each>
                                </multivol>
                                <!-- period (posible) or comma (posible) and space -->
                                <xsl:value-of select="regex-group(4)"/>
                                <!-- the remainder of the text processing once again with book-step1 -->
                                <xsl:for-each select="regex-group(5)">
                                    <xsl:call-template name="book_step1-other_metadata"/>
                                </xsl:for-each>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <!-- otherwise only volume number -->
            <xsl:otherwise>
                <xsl:analyze-string select="." regex="^(Zv\.\s\d+)([\.,]\s)(.*?)$" flags="m">
                    <xsl:matching-substring>
                        <xsl:for-each select="regex-group(1)">
                            <xsl:call-template name="volume"/>
                        </xsl:for-each>
                        <!-- period (posible) or comma (posible) and space -->
                        <xsl:value-of select="regex-group(2)"/>
                        <!-- the remainder of the text processing once again with book-step1 -->
                        <xsl:for-each select="regex-group(3)">
                            <xsl:call-template name="book_step1-other_metadata"/>
                        </xsl:for-each>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="volume">
        <xsl:analyze-string select="." regex="^(Zv\.\s)(\d+)$" flags="m">
            <xsl:matching-substring>
                <!-- abbreviation Zv. for volume -->
                <xsl:value-of select="regex-group(1)"/>
                <volume>
                    <xsl:value-of select="regex-group(2)"/>
                </volume>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template name="place_publisher-step1">
        <xsl:choose>
            <xsl:when test="matches(.,';\s')">
                <xsl:for-each select="tokenize(.,';\s')">
                    <xsl:choose>
                        <xsl:when test="position() eq last()">
                            <xsl:call-template name="place_publisher-step2"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="place_publisher-step2"/>
                            <xsl:text>; </xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="place_publisher-step2"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="place_publisher-step2">
        <xsl:choose>
            <xsl:when test="matches(.,':\s')">
                <xsl:analyze-string select="." regex="^(.*?)(:\s)(.*?)$" flags="m">
                    <xsl:matching-substring>
                        <xsl:for-each select="tokenize(regex-group(1),',\s')">
                            <xsl:choose>
                                <xsl:when test="position() eq last()">
                                    <pubPlace>
                                        <xsl:value-of select="."/>
                                    </pubPlace>
                                </xsl:when>
                                <xsl:otherwise>
                                    <pubPlace>
                                        <xsl:value-of select="."/>
                                    </pubPlace>
                                    <xsl:text>, </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                        <xsl:value-of select="regex-group(2)"/>
                        <xsl:for-each select="tokenize(regex-group(3),',\s')">
                            <xsl:choose>
                                <xsl:when test="position() eq last()">
                                    <publisher>
                                        <xsl:value-of select="."/>
                                    </publisher>
                                </xsl:when>
                                <xsl:otherwise>
                                    <publisher>
                                        <xsl:value-of select="."/>
                                    </publisher>
                                    <xsl:text>, </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <!-- it is not posible to know what it is: pubPlace or publisher -->
                <xsl:if test="string-length(.) gt 0">
                    <pubPlaceORpublisher>
                        <xsl:value-of select="."/>
                    </pubPlaceORpublisher>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="title-step1-italic">
        <xsl:analyze-string select="." regex="^(\[\[italic\]\])(.*?)(\[/\[italic\]\])$" flags="m">
            <xsl:matching-substring>
                <!-- start italic tag - regex group 1 -->
                <i>
                    <!-- title and posible subtitles -->
                    <xsl:for-each select="tokenize(regex-group(2),$seperator-titles)">
                        <xsl:choose>
                            <xsl:when test="position() eq last()">
                                <xsl:for-each select=".">
                                    <xsl:call-template name="title-step2"/>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select=".">
                                    <xsl:call-template name="title-step2"/>
                                </xsl:for-each>
                                <xsl:value-of select="$seperator-titles"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                    <!-- end italic tag - regex group 3 -->
                </i>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template name="title-step1-quotation_mark">
        <xsl:analyze-string select="." regex="({$quotation_mark-opening-regex})(.*?)({$quotation_mark-closing-regex})">
            <xsl:matching-substring>
                <!-- opening quotation mark -->
                <xsl:value-of select="regex-group(1)"/>
                <!-- tokenize title and subtitles with parameter separator-titles -->
                <xsl:for-each select="tokenize(regex-group(2),$seperator-titles)">
                    <xsl:choose>
                        <xsl:when test="position() eq last()">
                            <xsl:for-each select=".">
                                <xsl:call-template name="title-step2"/>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select=".">
                                <xsl:call-template name="title-step2"/>
                            </xsl:for-each>
                            <xsl:value-of select="$seperator-titles"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <!-- closing quotation mark -->
                <xsl:value-of select="regex-group(3)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template name="title-step2">
        <!-- first and second subtitle separated with $seperator-subtitles -->
        <xsl:for-each select="tokenize(.,$seperator-subtitles)">
            <xsl:choose>
                <xsl:when test="position() eq last()">
                    <xsl:for-each select=".">
                        <xsl:call-template name="title-step3"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select=".">
                        <xsl:call-template name="title-step3"/>
                    </xsl:for-each>
                    <xsl:value-of select="$seperator-subtitles"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="title-step3">
        <!-- title and subtitle separeted with question mark ? -->
        <xsl:for-each select="tokenize(.,'\?\s')">
            <xsl:choose>
                <xsl:when test="position() eq last()">
                    <xsl:for-each select=".">
                        <xsl:call-template name="title-step4"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="concat(.,'?')">
                        <xsl:call-template name="title-step4"/>
                    </xsl:for-each>
                    <xsl:text> </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="title-step4">
        <!-- title and subtitle separeted with exclamation point ! -->
        <xsl:for-each select="tokenize(.,'!\s')">
            <xsl:choose>
                <xsl:when test="position() eq last()">
                    <title>
                        <xsl:value-of select="."/>
                    </title>
                </xsl:when>
                <xsl:otherwise>
                    <title>
                        <xsl:value-of select="."/>
                        <xsl:text>!</xsl:text>
                    </title>
                    <xsl:text> </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="online-date">
        <xsl:choose>
            <!-- when exist date (Sloveninan date format - only numbers) -->
            <xsl:when test="matches(.,'[1-3]?\d\.\s1?\d\.\s\d{4}')">
                <xsl:analyze-string select="." regex="[1-3]?\d\.\s1?\d\.\s\d{{4}}">
                    <!-- put date in element when -->
                    <xsl:matching-substring>
                        <when>
                            <xsl:value-of select="."/>
                        </when>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <!-- otherwise do nothing -->
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>