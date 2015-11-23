<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:include href="templates.xsl"/>
    
    <xsl:variable name="document-uri" select="document-uri(.)"/>
    <xsl:variable name="filename" select="(tokenize($document-uri,'/'))[last()]"/>
    <!-- result document named after original document with additional ending string -TEI -->
    <xsl:variable name="document" select="concat(substring-before($filename,'.xml'),'-TEI.xml')"/>
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet" type="stylesheet">
        <desc>
            <p>TEI stylesheet for converting CMS markup to TEI listBibl/biblStruct</p>
            <p>This software is dual-licensed:
                
                1. Distributed under a Creative Commons Attribution-ShareAlike 4.0
                Unported License http://creativecommons.org/licenses/by-sa/4.0/ 
                
                2. http://www.opensource.org/licenses/BSD-2-Clause
                
                All rights reserved.
                
                Redistribution and use in source and binary forms, with or without
                modification, are permitted provided that the following conditions are
                met:
                
                * Redistributions of source code must retain the above copyright
                notice, this list of conditions and the following disclaimer.
                
                * Redistributions in binary form must reproduce the above copyright
                notice, this list of conditions and the following disclaimer in the
                documentation and/or other materials provided with the distribution.
                
                This software is provided by the copyright holders and contributors
                "as is" and any express or implied warranties, including, but not
                limited to, the implied warranties of merchantability and fitness for
                a particular purpose are disclaimed. In no event shall the copyright
                holder or contributors be liable for any direct, indirect, incidental,
                special, exemplary, or consequential damages (including, but not
                limited to, procurement of substitute goods or services; loss of use,
                data, or profits; or business interruption) however caused and on any
                theory of liability, whether in contract, strict liability, or tort
                (including negligence or otherwise) arising in any way out of the use
                of this software, even if advised of the possibility of such damage.
            </p>
            <p xml:lang="en">Andrej Pančur, ICH</p>
            <p xml:lang="sl">Andrej Pančur, INZ</p>
            <p>JINZ 2015-11-02, et</p>
        </desc>
    </doc>
    
    
    <xsl:template match="listBibl">
        <xsl:result-document href="{$document}">
            <listBibl>
                <xsl:apply-templates select="bibl"/>
            </listBibl>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="bibl">
        <xsl:choose>
            <xsl:when test=".[@type='book']">
                <biblStruct type="{@type}">
                    <xsl:for-each select="monogr">
                        <xsl:choose>
                            <!-- Multivolume Work (Citing Only 1 Volume) -->
                            <xsl:when test="vol">
                                <!-- 1 volume of multivolume work -->
                                <monogr>
                                    <!-- author, organization -->
                                    <xsl:call-template name="authors-main"/>
                                    <xsl:for-each select="vol">
                                        <!-- vol/i/title -->
                                        <xsl:call-template name="title-monogr-m"/>
                                    </xsl:for-each>
                                    <!-- date, origDate -->
                                    <xsl:call-template name="imprint-partOfMultivol"/>
                                    <!-- volume -->
                                    <xsl:call-template name="volume"/>
                                </monogr>
                                <!-- multivolume work -->
                                <monogr>
                                    <!-- i/title -->
                                    <xsl:call-template name="title-monogr-m"/>
                                    <!-- addTitle -->
                                    <xsl:call-template name="addTitle-monogr-m"/>
                                    <!-- editor, translator -->
                                    <xsl:call-template name="editors-main"/>
                                    <!-- edition -->
                                    <xsl:call-template name="edition"/>
                                    <!-- pubPlace, publisher -->
                                    <xsl:call-template name="imprint-multivol"/>
                                    <!-- extent -->
                                    <xsl:call-template name="extent"/>
                                </monogr>
                                <!-- series -->
                                <xsl:call-template name="series"/>
                            </xsl:when>
                            <!-- TODO: attempts to combine the top and bottom xsl:when with this one -->
                            <xsl:when test="not(vol) and not(multivol)">
                                <monogr>
                                    <!-- author, organization -->
                                    <xsl:call-template name="authors-main"/>
                                    <!-- i/title -->
                                    <xsl:call-template name="title-monogr-m"/>
                                    <!-- addTitle -->
                                    <xsl:call-template name="addTitle-monogr-m"/>
                                    <!-- editor, translator -->
                                    <xsl:call-template name="editors-main"/>
                                    <!-- edition -->
                                    <xsl:call-template name="edition"/>
                                    <!-- pubPlace, publisher, date, origDate -->
                                    <xsl:call-template name="imprint"/>
                                    <!-- volume -->
                                    <xsl:call-template name="volume"/>
                                    <!-- extent -->
                                    <xsl:call-template name="extent"/>
                                </monogr>
                                <!-- series -->
                                <xsl:call-template name="series"/>
                                <!-- online/ref -->
                                <xsl:call-template name="online"/>
                            </xsl:when>
                            <xsl:when test="multivol">
                                <!-- 1 volume of multivolume work -->
                                <monogr>
                                    <!-- author, organization -->
                                    <xsl:call-template name="authors-main"/>
                                    <!-- i/title -->
                                    <xsl:call-template name="title-monogr-m"/>
                                    <!-- addTitle -->
                                    <xsl:call-template name="addTitle-monogr-m"/>
                                    <!-- uredniki -->
                                    <xsl:for-each select="editor[not(preceding-sibling::volume)]">
                                        <xsl:call-template name="creator"/>
                                    </xsl:for-each>
                                    <xsl:for-each select="translator[not(preceding-sibling::volume)]">
                                        <xsl:call-template name="creator"/>
                                    </xsl:for-each>
                                    <!-- date, origDate -->
                                    <xsl:call-template name="imprint-partOfMultivol"/>
                                </monogr>
                                <!-- multivolume work -->
                                <monogr>
                                    <xsl:for-each select="multivol">
                                        <!-- multivol/i/title -->
                                        <xsl:call-template name="title-monogr-m"/>
                                    </xsl:for-each>
                                    <!-- uredniki -->
                                    <xsl:for-each select="editor[preceding-sibling::volume]">
                                        <xsl:call-template name="creator"/>
                                    </xsl:for-each>
                                    <xsl:for-each select="translator[preceding-sibling::volume]">
                                        <xsl:call-template name="creator"/>
                                    </xsl:for-each>
                                    <!-- pubPlace, publisher -->
                                    <xsl:call-template name="imprint-multivol"/>
                                    <xsl:for-each select="volume">
                                        <biblScope unit="part">
                                            <xsl:value-of select="."/>
                                        </biblScope>
                                    </xsl:for-each>
                                    <!-- extent -->
                                    <xsl:call-template name="extent"/>
                                </monogr>
                                <!-- series -->
                                <xsl:call-template name="series"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message>Something is wrong!?</xsl:message>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </biblStruct>
            </xsl:when>
            <xsl:when test=".[@type='journalArticle']">
                <biblStruct type="{@type}">
                    <xsl:apply-templates select="analytic"/>
                    <xsl:apply-templates select="monogr" mode="j"/>
                </biblStruct>
            </xsl:when>
            <xsl:when test=".[@type='bookChapter']">
                <biblStruct type="{@type}">
                    <xsl:apply-templates select="analytic"/>
                    <xsl:apply-templates select="monogr" mode="bookChapter"/>
                </biblStruct>
            </xsl:when>
            <xsl:otherwise>
                <!-- not processed - temporaly -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="analytic">
        <analytic>
            <!-- author, organization -->
            <xsl:call-template name="authors-main"/>
            <!-- i/title -->
            <xsl:call-template name="title-analytic"/>
            <!-- addTitle -->
            <xsl:call-template name="addTitle-analytic"/>
            <!-- editor, translator -->
            <xsl:call-template name="editors-main"/>
        </analytic>
    </xsl:template>
    
    <xsl:template match="monogr" mode="j">
        <monogr>
            <!-- i/title -->
            <xsl:call-template name="title-monogr-j"/>
            <!-- addTitle -->
            <xsl:call-template name="addTitle-monogr-j"/>
            <imprint>
                <xsl:for-each select="volume">
                    <biblScope unit="volume">
                        <xsl:value-of select="."/>
                    </biblScope>
                </xsl:for-each>
                <xsl:for-each select="issue">
                    <biblScope unit="issue">
                        <xsl:value-of select="."/>
                    </biblScope>
                </xsl:for-each>
                <xsl:call-template name="page"/>
               <xsl:for-each select="date">
                   <xsl:call-template name="date"/>
               </xsl:for-each> 
            </imprint>
        </monogr>
    </xsl:template>
    
    <xsl:template match="monogr" mode="bookChapter">
        <monogr>
            <!-- i/title -->
            <xsl:call-template name="title-monogr-m"/>
            <!-- addTitle -->
            <xsl:call-template name="addTitle-monogr-m"/>
            <!-- editor, translator, author -->
            <xsl:call-template name="editors-additional"/>
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
                <xsl:call-template name="page"/>
                <xsl:for-each select="date">
                    <xsl:call-template name="date"/>
                </xsl:for-each> 
            </imprint>
        </monogr>
    </xsl:template>
    
    
</xsl:stylesheet>