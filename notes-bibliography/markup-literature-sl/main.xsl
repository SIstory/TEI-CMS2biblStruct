<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:functx="http://www.functx.com"
    exclude-result-prefixes="xs functx"
    version="2.0">
    
    <xsl:include href="param.xsl"/>
    <xsl:include href="regex-param.xsl"/>
    <xsl:include href="regex-variable.xsl"/>
    <xsl:include href="templates.xsl"/>
    <xsl:include href="creators.xsl"/>
    
    <xsl:output method="xml"/>
    <xsl:preserve-space elements="*"/>
    
    <xsl:variable name="document-uri" select="document-uri(.)"/>
    <xsl:variable name="filename" select="(tokenize($document-uri,'/'))[last()]"/>
    <!-- result document named after original document with additional ending string -V2 -->
    <xsl:variable name="document" select="concat(substring-before($filename,'.xml'),'-V2.xml')"/>
    
    <xsl:function name="functx:substring-before-last-match" as="xs:string?"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="regex" as="xs:string"/>
        <xsl:sequence select="
            replace($arg,concat('^(.*)',$regex,'.*'),'$1')
            "/>
    </xsl:function>
    
    <!-- For ease of further string processing convert element name and atribut name and value:
         - hi/@rend='italic' in string [[italic]] [/[italic]] and
         - ref/@target in string [[ref]] [/[ref]] -->
    <xsl:template match="listBibl" mode="pass1">
        <listBibl>
            <xsl:for-each select="bibl">
                <bibl>
                    <xsl:apply-templates mode="pass1"/>
                </bibl>
            </xsl:for-each>
        </listBibl>
    </xsl:template>
    <xsl:template match="hi[@rend='italic']" mode="pass1">
        <xsl:text>[[italic]]</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>[/[italic]]</xsl:text>
    </xsl:template>
    <xsl:template match="ref" mode="pass1">
        <xsl:text>[[ref]]</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>[/[ref]]</xsl:text>
    </xsl:template>
    
    <!-- normalize spice and remove the last period at the end of string (for ease of processing) 
        - in the next pass add the periods again -->
    <xsl:template match="listBibl" mode="pass2">
        <listBibl>
            <xsl:for-each select="bibl">
                <bibl>
                    <xsl:choose>
                        <xsl:when test="matches(.,'\.$','m')">
                            <xsl:value-of select="normalize-space(functx:substring-before-last-match(normalize-space(.),'.'))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="normalize-space(.)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </bibl>
            </xsl:for-each>
        </listBibl>
    </xsl:template>
    
    <xsl:template match="listBibl" mode="pass3">
        <listBibl>
            <xsl:for-each select="bibl">
                <bibl>
                    <xsl:attribute name="string">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                    <xsl:choose>
                        <!-- when 
                               data about part of the book and
                               data about whole book 
                               separated with separator-part_of_monogr-regex (example \sV:\s)
                             then
                               chapter or part of book -->
                        <xsl:when test="matches(.,$separator-part_of_monogr-regex)">
                            <xsl:analyze-string select="." regex="^(.*?)({$quotation_mark-closing-regex})({$separator-part_of_monogr-regex})(\[\[italic\]\])(.*)$" flags="m">
                                <xsl:matching-substring>
                                    <!-- text before (regex group 1) closing quotation mark (regex group 2) -->
                                    <analytic><xsl:value-of select="concat(regex-group(1),regex-group(2))"/></analytic>
                                    <!-- separator (regex group 3) -->
                                    <xsl:value-of select="regex-group(3)"/>
                                    <!-- opening italic string (regex group 4) and text to end (regex group 5) -->
                                    <monogr><xsl:value-of select="concat(regex-group(4),regex-group(5))"/></monogr>
                                </xsl:matching-substring>
                                <xsl:non-matching-substring>
                                    <xsl:value-of select="."/>
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </xsl:when>
                        <!-- when 
                               not find separator-part_of_monogr-regex and
                               find journal article with regex:
                                 - article title in quotation mark;
                                 - journal title in italic;
                                 - date of publication in parenthesis
                             then 
                               journal article -->
                        <xsl:when test="not(matches(.,$separator-part_of_monogr-regex)) and matches(.,$regex-journal_article)">
                            <xsl:analyze-string select="." regex="{$regex-journal_article}">
                                <xsl:matching-substring>
                                    <analytic>
                                        <xsl:value-of select="regex-group(1)"/>
                                    </analytic>
                                    <xsl:value-of select="regex-group(2)"/>
                                    <monogr>
                                        <xsl:value-of select="regex-group(3)"/>
                                    </monogr>
                                </xsl:matching-substring>
                                <xsl:non-matching-substring>
                                    <xsl:value-of select="."/>
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </xsl:when>
                        <!-- otherwise
                               monographic publication (book, thesis, dissertation, conference paper, ...)  -->
                        <xsl:otherwise>
                            <monogr>
                                <xsl:value-of select="."/>
                            </monogr>
                        </xsl:otherwise>
                    </xsl:choose>
                </bibl>
            </xsl:for-each>
        </listBibl>
    </xsl:template>
    
    <!-- finding online sources in monogr element -->
    <xsl:template match="listBibl" mode="pass4">
        <listBibl>
            <xsl:for-each select="bibl">
                <bibl string="{@string}">
                    <xsl:apply-templates mode="pass4"/>
                </bibl>
            </xsl:for-each>
        </listBibl>
    </xsl:template>
    
    <xsl:template match="analytic" mode="pass4" >
        <analytic>
            <xsl:value-of select="."/>
        </analytic>
    </xsl:template>
    
    <xsl:template match="monogr" mode="pass4">
        <xsl:choose>
            <!-- when
                   find ref start tag string
                 then
                   online source -->
            <xsl:when test="matches(.,'\[\[ref\]\]')">
                <xsl:choose>
                    <!-- when
                           find string
                             Pridobljeno
                             Spremenjeno
                           and find date
                           and find start and end ref tag string
                         then
                           begin online element with finding string Pridobljeno or Spremenjeno -->
                    <xsl:when test="matches(.,'(Pridobljeno\s|Spremenjeno\s)([1-3]?\d\.\s1?\d\.\s\d{4})(\.\s)(\[\[ref\]\])')">
                        <xsl:analyze-string select="." regex="^(.*?)(\.\s)(Pridobljeno\s|Spremenjeno\s)(.+)$" flags="m">
                            <xsl:matching-substring>
                                <monogr>
                                    <xsl:value-of select="regex-group(1)"/><!-- ungreedy to -->
                                </monogr>
                                <xsl:value-of select="regex-group(2)"/><!-- period and space before -->
                                <online>
                                    <xsl:value-of select="regex-group(3)"/><!-- string Pridobljeno or Spremenjeno -->
                                    <xsl:value-of select="regex-group(4)"/><!-- and then greedy to end  -->
                                </online>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <!-- otherwise
                           begin online element with ref -->
                    <xsl:otherwise>
                        <xsl:analyze-string select="." regex="^(.*?)(\.\s)(\[\[ref\]\].+)$" flags="m">
                            <xsl:matching-substring>
                                <monogr>
                                    <xsl:value-of select="regex-group(1)"/><!-- ungreedy to -->
                                </monogr>
                                <xsl:value-of select="regex-group(2)"/><!-- period and space before start ref tag -->
                                <online>
                                    <xsl:value-of select="regex-group(3)"/><!-- and then greedy to end -->
                                </online>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- otherwise monography without online sources -->
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="listBibl" mode="pass5">
        <listBibl>
            <xsl:for-each select="bibl">
                <!-- for easier reeding and string comparations indent bibl element with new line before and after element -->
                <xsl:text>&#xA;</xsl:text>
                <bibl>
                    <!-- indent string element (contains original string) with new line and space -->
                    <xsl:text>&#xA; </xsl:text>
                    <string>
                        <xsl:value-of select="@string"/>
                        <!-- giving back ending period (removed in pass2) -->
                        <xsl:text>.</xsl:text>
                    </string>
                    <!-- indent new line and space before analytic and/or monogr and/or online element -->
                    <xsl:text>&#xA; </xsl:text>
                    <xsl:apply-templates mode="pass5"/>
                    <!-- indent new line after analytic and/or monogr and/or online element -->
                    <xsl:text>&#xA;</xsl:text>
                </bibl>
                <xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
        </listBibl>
    </xsl:template>
    
    <xsl:template match="analytic" mode="pass5">
        <analytic>
            <!-- Split string in 2 groups: 
                 - before and
                 - after
                      separator constructed (concat) with 3 parts (NOT regex) (see variable separator_construction):
                      - separator between authors and titles (parameter separator-authors_titles)
                      - space
                      - opening quotation mark (paramenter quotation_mark-opening) of articel or chapter title
                      (example . »)
                 Put
                 - 1. group in variable authors (don't forget to put space at the end of authors variable) and
                 - 2. group in variable titles. -->
            <xsl:variable name="separator_construction" select="concat($separator-authors_titles,' ',$quotation_mark-opening)"/>
            <xsl:variable name="authors" select="concat(substring-before(.,$separator_construction),$separator-authors_titles,' ')"/>
            <xsl:variable name="titles" select="concat($quotation_mark-opening,substring-after(.,$separator_construction))"/>
            <!-- procesing 1. group - authors -->
            <xsl:analyze-string select="$authors" regex="^(.+)({$separator-authors_titles-regex}.*)$" flags="m">
                <xsl:matching-substring>
                    <xsl:for-each select="regex-group(1)">
                        <xsl:call-template name="main_creators-step1"/>
                    </xsl:for-each>
                    <xsl:value-of select="regex-group(2)"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
            <!-- procesing 2. group - title and subtitles -->
            <xsl:analyze-string select="$titles" regex="({$quotation_mark-opening-regex}.*?{$quotation_mark-closing-regex})(\s?)(.*?)$" flags="m">
                <xsl:matching-substring>
                    <xsl:for-each select="regex-group(1)">
                        <xsl:call-template name="title-step1-quotation_mark"/>
                    </xsl:for-each>
                    <!-- space (posible) betweeen main and additional title -->
                    <xsl:value-of select="regex-group(2)"/>
                    <!-- when after main title exist additional tile (translation of original title) in square brackets  -->
                    <xsl:for-each select="regex-group(3)">
                        <xsl:call-template name="addTitle"/>
                    </xsl:for-each>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </analytic>
    </xsl:template>
    
    <xsl:template match="monogr" mode="pass5">
        <xsl:choose>
            <!--  -->
            <xsl:when test="../analytic">
                <!-- if parent element bibl has child element analytic 
                     then is:
                       - book with separate chapters or
                       - journal with articles -->
                <monogr>
                    <xsl:choose>
                        <!-- book with separate chapters matches parameter separator-part_of_monogr-regex in parent element bibl -->
                        <xsl:when test="../(matches(.,$separator-part_of_monogr-regex))">
                            <xsl:attribute name="type">bookChapter</xsl:attribute>
                            <xsl:call-template name="book_chs-step1"/>
                        </xsl:when>
                        <!-- others are journals -->
                        <xsl:otherwise>
                            <xsl:attribute name="type">journalArticle</xsl:attribute>
                            <xsl:call-template name="journal"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- giving back ending period (removed in pass2) -->
                    <xsl:if test="ancestor::bibl[not(online)]">
                        <xsl:text>.</xsl:text>
                    </xsl:if>
                </monogr>
            </xsl:when>
            <!-- otherwise is monographic publication -->
            <xsl:otherwise>
                <monogr>
                    <!-- regex for finding book -->
                    <xsl:analyze-string select="." regex="^(.*?)(\.\s)(\[\[italic\]\].*?\[/\[italic\]\])([\.,]?\s)(.*?)(,\s)(\d{{4}}[-––−/]?\d*)$" flags="m">
                        <xsl:matching-substring>
                            <xsl:attribute name="type">book</xsl:attribute>
                            <!-- regex group 1: main creators -->
                            <xsl:for-each select="regex-group(1)">
                                <xsl:call-template name="main_creators-step1"/>
                            </xsl:for-each>
                            <!-- period and space between creators and titles -->
                            <xsl:value-of select="regex-group(2)"/>
                            <!-- title and subtitles in italic -->
                            <xsl:for-each select="regex-group(3)">
                                <xsl:call-template name="title-step1-italic"/>
                            </xsl:for-each>
                            <!-- posible period and space after title in italic -->
                            <xsl:value-of select="regex-group(4)"/>
                            <!-- any other information about book (except date) -->
                            <xsl:for-each select="regex-group(5)">
                                <xsl:call-template name="book_step1-other_metadata"/>
                            </xsl:for-each>
                            <!-- comma and space before date -->
                            <xsl:value-of select="regex-group(6)"/>
                            <!-- date -->
                            <date>
                                <xsl:value-of select="regex-group(7)"/>
                            </date>
                        </xsl:matching-substring>
                        <!-- if regex don't match book  -->
                        <xsl:non-matching-substring>
                            <!-- then find regex for: thesis or dissertation or conference paper -->
                            <xsl:analyze-string select="." regex="^(.*?)(\.\s)({$quotation_mark-opening-regex}.*?{$quotation_mark-closing-regex})(\.?\s)(.*?)(,\s)([1-3]?\d?\.?[-––−/]?[1-3]?\d?\.?\s?1?\d?\.?\s?\d{{4}})$" flags="m">
                                <xsl:matching-substring>
                                    <xsl:attribute name="type">
                                        <xsl:choose>
                                            <xsl:when test="matches(.,'([Dd]iplom)(a\s|sko\s)')">thesis</xsl:when>
                                            <xsl:when test="matches(.,'disertacija')">dissertation</xsl:when>
                                            <xsl:when test="matches(.,'konferenc[ai]|simpozij')">conference</xsl:when>
                                            <xsl:otherwise>unknown</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                    <!-- regex group 1: creators -->
                                    <xsl:for-each select="regex-group(1)">
                                        <xsl:call-template name="main_creators-step1"/>
                                    </xsl:for-each>
                                    <!-- period and space between creators and titles -->
                                    <xsl:value-of select="regex-group(2)"/>
                                    <!-- titles and subtitles in quotation mark -->
                                    <xsl:for-each select="regex-group(3)">
                                        <xsl:call-template name="title-step1-quotation_mark"/>
                                    </xsl:for-each>
                                    <!-- period (posible) and space after closing quotation mark -->
                                    <xsl:value-of select="regex-group(4)"/>
                                    <!-- unknown data (they cannot be reliably classified) - posible elements: title, pubPlace, publisher etc. -->
                                    <xsl:if test="string-length(regex-group(5)) gt 0">
                                        <unknown>
                                            <xsl:value-of select="regex-group(5)"/>
                                        </unknown>
                                    </xsl:if>
                                    <!-- comma and space before date -->
                                    <xsl:value-of select="regex-group(6)"/>
                                    <!-- date (not only year, for example also 21.–24. 11. 2009 -->
                                    <date>
                                        <xsl:value-of select="regex-group(7)"/>
                                    </date>
                                </xsl:matching-substring>
                                <!-- if regex don't match
                                       book, 
                                       thesis or dissertation or conference paper -->
                                <xsl:non-matching-substring>
                                    <!-- then find regex for monographic publication without data about creator (no author) -->
                                    <xsl:analyze-string select="." regex="^(\[\[italic\]\].*?\[/\[italic\]\])(\.?\s)(.*?)(,?\s?)(\d{{4}})$" flags="m">
                                        <xsl:matching-substring>
                                            <xsl:attribute name="type">book</xsl:attribute>
                                            <!-- title and subtitle in italic -->
                                            <xsl:for-each select="regex-group(1)">
                                                <xsl:call-template name="title-step1-italic"/>
                                            </xsl:for-each>
                                            <!-- posible period and space after title in italic -->
                                            <xsl:value-of select="regex-group(2)"/>
                                            <!-- any other information about book (except date) -->
                                            <xsl:for-each select="regex-group(3)">
                                                <xsl:call-template name="book_step1-other_metadata"/>
                                            </xsl:for-each>
                                            <!-- comma (posible) and space (posible) before date -->
                                            <xsl:value-of select="regex-group(4)"/>
                                            <!-- date -->
                                            <date>
                                                <xsl:value-of select="regex-group(5)"/>
                                            </date>
                                        </xsl:matching-substring>
                                        <xsl:non-matching-substring>
                                            <!-- if regex don't match
                                                   book, 
                                                   thesis or dissertation or conference paper
                                                   monographic publication without data about creator (no author) -->
                                            <xsl:analyze-string select="." regex="^(.*?)(\.\s)(Uvod.*?|Predgovor.*?|Spremna.*?)(\s)(\[\[italic\]\].*?\[/\[italic\]\])([\.,]?\s)(.*?)(,\s)(\d{{4}}[-––−/]?\d*)$">
                                                <xsl:matching-substring>
                                                    <xsl:attribute name="type">
                                                        <xsl:choose>
                                                            <xsl:when test="matches(.,'Uvod\s')">bookIntroduction</xsl:when>
                                                            <xsl:when test="matches(.,'Spremna\s')">bookAfterword</xsl:when>
                                                            <xsl:otherwise>bookForeword</xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:attribute>
                                                    <!-- regex group 1: main creators -->
                                                    <xsl:for-each select="regex-group(1)">
                                                        <xsl:call-template name="main_creators-step1"/>
                                                    </xsl:for-each>
                                                    <!-- period and space between creators and Uvod, Predgovor or Spremna beseda title -->
                                                    <xsl:value-of select="regex-group(2)"/>
                                                    <!-- Uvod, Predgovor or Spremna beseda title -->
                                                    <title>
                                                        <xsl:value-of select="regex-group(3)"/>
                                                    </title>
                                                    <!-- space before book title -->
                                                    <xsl:value-of select="regex-group(4)"/>
                                                    <!-- title and subtitles in italic -->
                                                    <xsl:for-each select="regex-group(5)">
                                                        <xsl:call-template name="title-step1-italic"/>
                                                    </xsl:for-each>
                                                    <!-- posible period and space after title in italic -->
                                                    <xsl:value-of select="regex-group(6)"/>
                                                    <!-- any other information about book (except date) -->
                                                    <xsl:for-each select="regex-group(7)">
                                                        <xsl:call-template name="book_step1-other_metadata"/>
                                                    </xsl:for-each>
                                                    <!-- comma and space before date -->
                                                    <xsl:value-of select="regex-group(8)"/>
                                                    <!-- date -->
                                                    <date>
                                                        <xsl:value-of select="regex-group(9)"/>
                                                    </date>
                                                </xsl:matching-substring>
                                                <!-- TODO: when you will find others types of monographic publication, write new regex -->
                                                <xsl:non-matching-substring>
                                                    <xsl:value-of select="."/>
                                                </xsl:non-matching-substring>
                                            </xsl:analyze-string>
                                        </xsl:non-matching-substring>
                                    </xsl:analyze-string>
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                    <!-- giving back ending period (removed in pass2) -->
                    <xsl:if test=" ancestor::bibl[not(online)]">
                        <xsl:text>.</xsl:text>
                    </xsl:if>
                </monogr>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="online" mode="pass5">
        <online>
            <xsl:analyze-string select="." regex="^(.*?)(\[\[ref\]\])(.*?)(\[/\[ref\]\])(.*?)$" flags="m">
                <xsl:matching-substring>
                    <!-- find and markup posible date in string -->
                    <xsl:for-each select="regex-group(1)">
                        <xsl:call-template name="online-date"/>
                    </xsl:for-each>
                    <!-- convert start and end ref string in ref tags -->
                    <ref>
                        <xsl:value-of select="regex-group(3)"/>
                    </ref>
                    <!-- find and markup posible date in string -->
                    <xsl:for-each select="regex-group(5)">
                        <xsl:call-template name="online-date"></xsl:call-template>
                    </xsl:for-each>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
            <!-- giving back ending period (removed in pass2) -->
            <xsl:text>.</xsl:text>
        </online>
    </xsl:template>
    
    <!-- in last pass 6 you can do minor corrections -->
    <xsl:template match="listBibl" mode="pass6">
        <xsl:result-document href="{$document}">
            <listBibl>
                <xsl:apply-templates mode="pass6"/>
            </listBibl>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="@* | node()" mode="pass6">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="pass6"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- add type atribute -->
    <xsl:template match="bibl" mode="pass6">
        <bibl>
            <xsl:attribute name="type">
                <xsl:value-of select="monogr/@type"/>
            </xsl:attribute>
            <xsl:apply-templates mode="pass6"/>
        </bibl>
    </xsl:template>
    <!-- remove type atribute -->
    <xsl:template match="monogr" mode="pass6">
        <monogr>
            <xsl:apply-templates mode="pass6"/>
        </monogr>
    </xsl:template>
    
    <xsl:template match="title" mode="pass6">
        <!-- remove posible ending period from title element (unless title ends with abbreviation zv.) -->
        <xsl:analyze-string select="." regex="^(.*?[^z][^v])(\.)$" flags="m">
            <xsl:matching-substring>
                <title>
                    <xsl:value-of select="regex-group(1)"/>
                </title>
                <xsl:value-of select="regex-group(2)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <title>
                    <xsl:value-of select="."/>
                </title>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!-- convert opening and closing ref and italic element string in appropriate ref and i element -->
    <xsl:template match="string" mode="pass6">
        <string>
            <xsl:analyze-string select="." regex="(\[\[italic\]\])(.*?)(\[/\[italic\]\])(.*?)(\[\[italic\]\])?(.*?)(\[/\[italic\]\])?">
                <xsl:matching-substring>
                    <!-- start italic tag -->
                    <i>
                        <!-- text in italic -->
                        <xsl:value-of select="regex-group(2)"></xsl:value-of>
                        <!-- end italic tag -->
                    </i>
                    <!-- text after end italic tag -->
                    <xsl:value-of select="regex-group(4)"/>
                    <!-- posible second start italic tag string -->
                    <xsl:if test="string-length(regex-group(5)) gt 0">
                        <xsl:text disable-output-escaping="yes"><![CDATA[<i>]]></xsl:text>
                    </xsl:if>
                    <!-- posible text in italic -->
                    <xsl:value-of select="regex-group(6)"/>
                    <!-- posible second end italic tag string -->
                    <xsl:if test="string-length(regex-group(7)) gt 0">
                        <xsl:text disable-output-escaping="yes"><![CDATA[</i>]]></xsl:text>
                    </xsl:if>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:analyze-string select="." regex="(\[\[ref\]\])(.*?)(\[/\[ref\]\])">
                        <xsl:matching-substring>
                            <!-- start ref tag -->
                            <ref>
                                <!-- link -->
                                <xsl:value-of select="regex-group(2)"></xsl:value-of>
                                <!-- end ref tag -->
                            </ref>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:value-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </string>
    </xsl:template>
    
    <xsl:variable name="v-pass1">
        <xsl:apply-templates mode="pass1" select="listBibl"/>
    </xsl:variable>
    <xsl:variable name="v-pass2">
        <xsl:apply-templates mode="pass2" select="$v-pass1"/>
    </xsl:variable>
    <xsl:variable name="v-pass3">
        <xsl:apply-templates mode="pass3" select="$v-pass2"/>
    </xsl:variable>
    <xsl:variable name="v-pass4">
        <xsl:apply-templates mode="pass4" select="$v-pass3"/>
    </xsl:variable>
    <xsl:variable name="v-pass5">
        <xsl:apply-templates mode="pass5" select="$v-pass4"/>
    </xsl:variable>
    
    <xsl:template match="listBibl">
        <xsl:apply-templates mode="pass6" select="$v-pass5"/>
    </xsl:template>
    
    
</xsl:stylesheet>