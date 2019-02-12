<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:functx="http://www.functx.com"
    exclude-result-prefixes="xs functx"
    version="2.0">
    
    <!-- pattern: Surname, Forename, Forename Surname, Forename Surname in Forename Surname -->
    <xsl:template name="main_creators-step1">
        <!-- different element names for different creator types -->
        <xsl:variable name="creator-element-name">
            <xsl:choose>
                <!-- when matches abbreviation for editor ur. -->
                <xsl:when test="matches(.,',\sur')">editor</xsl:when>
                <!-- when matches abbreviation for translator prev. -->
                <xsl:when test="matches(.,',\sprev')">translator</xsl:when>
                <!-- all others are authors -->
                <xsl:otherwise>author</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <!-- when exist editor abbreviation -->
            <xsl:when test="matches(.,'(,\sur)$','m')">
                <!-- remove abbreviation from creator element content -->
                <xsl:analyze-string select="." regex="^(.*?)(,\sur)$" flags="m">
                    <xsl:matching-substring>
                        <!-- processing only names -->
                        <xsl:for-each select="regex-group(1)">
                            <xsl:call-template name="main_creators-step2">
                                <xsl:with-param name="creator-element-name" select="$creator-element-name"/>
                            </xsl:call-template>
                        </xsl:for-each>
                        <!-- editor abbreviation -->
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <!-- when exist translator abbreviation -->
            <xsl:when test="matches(.,'(,\sprev)$','m')">
                <!-- remove translator abbreviation from creator element content -->
                <xsl:analyze-string select="." regex="^(.*?)(,\sprev)$" flags="m">
                    <xsl:matching-substring>
                        <!-- processing only names -->
                        <xsl:for-each select="regex-group(1)">
                            <xsl:call-template name="main_creators-step2">
                                <xsl:with-param name="creator-element-name" select="$creator-element-name"/>
                            </xsl:call-template>
                        </xsl:for-each>
                        <!-- translator abbreviation -->
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <!-- otherwise creators are authors -->
            <xsl:otherwise>
                <xsl:call-template name="main_creators-step2">
                    <xsl:with-param name="creator-element-name" select="$creator-element-name"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="main_creators-step2">
        <!-- parameter value inherited from variable creator-element-name in template_pass1-main_creators -->
        <xsl:param name="creator-element-name"/>
        <xsl:choose>
            <!-- when more than two creators -->
            <xsl:when test="matches(.,'^(.*?)(,\s)(.*?)(,)','m') 
                and matches(.,'\sin\s')">
                <xsl:variable name="first_craetors" select="substring-before(.,' in ')"/>
                <xsl:variable name="last_creator" select="substring-after(.,' in ')"/>
                <xsl:analyze-string select="$first_craetors" regex="^(.*?)(,\s)(.*?)(,\s)" flags="m">
                    <!-- first creator -->
                    <xsl:matching-substring>
                        <xsl:element name="{$creator-element-name}">
                            <xsl:value-of select="concat(regex-group(1),regex-group(2),regex-group(3))"/>
                        </xsl:element>
                        <xsl:value-of select="regex-group(4)"/>
                    </xsl:matching-substring>
                    <!-- other authors before in -->
                    <xsl:non-matching-substring>
                        <xsl:choose>
                            <xsl:when test="contains(.,', ')">
                                <xsl:for-each select="tokenize(.,', ')">
                                    <xsl:choose>
                                        <xsl:when test="position() eq last()">
                                            <xsl:element name="{$creator-element-name}">
                                                <xsl:value-of select="."/>
                                            </xsl:element>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:element name="{$creator-element-name}">
                                                <xsl:value-of select="."/>
                                            </xsl:element>
                                            <xsl:text>, </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:element name="{$creator-element-name}">
                                    <xsl:value-of select="."/>
                                </xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
                <!-- creator after in -->
                <xsl:text> in </xsl:text>
                <xsl:element name="{$creator-element-name}">
                    <xsl:value-of select="$last_creator"/>
                </xsl:element>
            </xsl:when>
            <!-- when two creators -->
            <xsl:when test="not(matches(.,'^(.*?)(,\s)(.*?)(,)','m')) and matches(.,'\sin\s')">
                <xsl:element name="{$creator-element-name}">
                    <xsl:value-of select="substring-before(.,' in ')"/>
                </xsl:element>
                <xsl:text> in </xsl:text>
                <xsl:element name="{$creator-element-name}">
                    <xsl:value-of select="substring-after(.,' in ')"/>
                </xsl:element>
            </xsl:when>
            <!-- otherwise is only one creator -->
            <xsl:otherwise>
                <xsl:choose>
                    <!-- When exist comma is creator person with Surname, Forename.
                         Posible exception: when pseudonym can only be one name wothout commma  -->
                    <xsl:when test="matches(.,',\s') or matches(.,'psevd\.')">
                        <xsl:element name="{$creator-element-name}">
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:when>
                    <!-- otherwise is creator organization -->
                    <xsl:otherwise>
                        <organization>
                            <xsl:value-of select="."/>
                        </organization>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="book_step2-additional_creators">
        <!-- when string begins with abbreviation for creator (editor, translator, author) -->
        <!-- processing text to period (as separator): suitable only for monographic publication (not for books with chapters) -->
        <!-- [^A-Z]beware: period as separator may not be immediately after the capital leter (abbreviation for personal name) -->
        <xsl:analyze-string select="." regex="^([Pp]rev\.\s|[Uu]r\.\s|[Aa]vt\.\s)(.*?)([^A-Z])(\.\s)(.*?)$" flags="m">
            <xsl:matching-substring>
                <xsl:for-each select="concat(regex-group(1),regex-group(2),regex-group(3))">
                    <xsl:call-template name="additional_creators"/>
                </xsl:for-each>
                <!-- pika in prazen prostor -->
                <xsl:value-of select="regex-group(4)"/>
                <!-- the remainder of the text processing once again with template_step1 -->
                <xsl:for-each select="regex-group(5)">
                    <xsl:call-template name="book_step1-other_metadata"/>
                </xsl:for-each>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template name="additional_creators">
        <!-- additional creators: translators, editors, authors -->
        <xsl:analyze-string select="." regex="^([Uu]r\.\s|[Aa]vt\.\s|[Pp]rev\.\s)(.*?)$" flags="m">
            <xsl:matching-substring>
                <xsl:variable name="creator-element-name">
                    <xsl:choose>
                        <!-- when matches abbreviation for editor ur. -->
                        <xsl:when test="matches(regex-group(1),'^[Uu]r\.','m')">
                            <xsl:text>editor</xsl:text>
                        </xsl:when>
                        <!-- when matches abbreviation for author avt. -->
                        <xsl:when test="matches(regex-group(1),'^[Aa]vt\.','m')">
                            <xsl:text>author</xsl:text>
                        </xsl:when>
                        <!-- otherwise translator -->
                        <xsl:otherwise>
                            <xsl:text>translator</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <!-- abbreviation Ur., Avt. or Prev. -->
                <xsl:value-of select="regex-group(1)"/>
                <!-- creators -->
                <xsl:choose>
                    <xsl:when test="matches(regex-group(2),'\sin\s')">
                        <xsl:choose>
                            <xsl:when test="matches(regex-group(2),',\s')">
                                <xsl:for-each select="tokenize(regex-group(2),',\s')">
                                    <xsl:choose>
                                        <xsl:when test="position() eq last()">
                                            <xsl:for-each select="tokenize(.,'\sin\s')">
                                                <xsl:choose>
                                                    <xsl:when test="position() eq last()">
                                                        <xsl:element name="{$creator-element-name}">
                                                            <xsl:value-of select="."/>
                                                        </xsl:element>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:element name="{$creator-element-name}">
                                                            <xsl:value-of select="."/>
                                                        </xsl:element>
                                                        <xsl:text> in </xsl:text>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:element name="{$creator-element-name}">
                                                <xsl:value-of select="."/>
                                            </xsl:element>
                                            <xsl:text>, </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="tokenize(regex-group(2),'\sin\s')">
                                    <xsl:choose>
                                        <xsl:when test="position() eq last()">
                                            <xsl:element name="{$creator-element-name}">
                                                <xsl:value-of select="."/>
                                            </xsl:element>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:element name="{$creator-element-name}">
                                                <xsl:value-of select="."/>
                                            </xsl:element>
                                            <xsl:text> in </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="{$creator-element-name}">
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
</xsl:stylesheet>
