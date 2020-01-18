<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei xsl"
    version="2.0">

    <xsl:output method="xml"/>
<!--    <xsl:strip-space elements="p div head titlePart hi damage unclear"/>-->
    <xsl:strip-space elements="tei:choice tei:abbr tei:expan tei:orig tei:reg tei:sic tei:corr tei:g tei:damage tei:unclear"/>


    <!-- IdentityTransform -->
    <xsl:template mode="#all" match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <!-- Differentiate between note and general transformation -->
    <xsl:template mode="#all" match="tei:note">
        <xsl:text>[</xsl:text><xsl:apply-templates mode="note"/><xsl:text>]</xsl:text>
    </xsl:template>


    <!-- In "note" mode, we do the following differently: -->
    <!-- a) replace periods in text nodes with non-sentence boundary characters. -->
    <xsl:template mode="note" match="text()">
        <xsl:value-of select="translate(., '.', '_')"/>
    </xsl:template>
    <!-- b) eliminate p wrappings -->
    <xsl:template mode="note" match="tei:p"><xsl:apply-templates mode="note"/></xsl:template>


    <!-- The rest is done in all modes. -->
    <!-- a) replace special character with standardized ones. -->
    <xsl:template mode="#all" match="tei:g">
        <xsl:choose>
            <xsl:when test="//tei:char[@xml:id=substring(current()/@ref, 2)]/tei:mapping[@type='precomposed']">
                <xsl:value-of select="(//tei:char[@xml:id=substring(current()/@ref, 2)]/tei:mapping[@type='precomposed']/text())[1]"/>
            </xsl:when>
            <xsl:when test="//tei:char[@xml:id=substring(current()/@ref, 2)]/tei:mapping[@type='composed']">
                <xsl:value-of select="(//tei:char[@xml:id=substring(current()/@ref, 2)]/tei:mapping[@type='composed']/text())[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="./text()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- b) only use abbr/orig/sic if no alternatives are available -->
    <xsl:template mode="#all" match="tei:abbr|tei:orig|tei:sic">
        <xsl:if test="not(parent::tei:choice[tei:expan|tei:reg|tei:corr])"><xsl:apply-templates mode="#current"/></xsl:if>
    </xsl:template>

    <!-- c) for breaks, insert a space if the break is not in a hyphenated word, otherwise insert nothing at all. -->
    <xsl:template mode="#all" match="tei:lb[not(@break='no')]|tei:cb[not(@break='no')]|tei:pb[not(@break='no')]"><xsl:text> </xsl:text></xsl:template>
    <xsl:template mode="#all" match="tei:lb[@break='no']|tei:cb[@break='no']|tei:pb[@break='no']"/>

    <!-- d) eliminate wrapping elements: hi/choice/expan/reg/corr/damage/unclear/foreign -->
    <xsl:template mode="#all" match="tei:hi|tei:choice|tei:expan|tei:reg|tei:corr|tei:damage|tei:unclear|tei:foreign"><xsl:apply-templates mode="#current"/></xsl:template>

    <!-- e) define list types (everything that is not 'contents' or 'index' will be 'summaries') -->
    <xsl:template mode="#all" match="tei:list[not(@type='contents') and not(@type='index')]">
        <xsl:element name="list" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="@*[not(self::attribute(type))]">
                <xsl:copy/>
            </xsl:for-each>
            <xsl:attribute name="type">summaries</xsl:attribute>
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
    </xsl:template>

    <!-- f) define milestone renditions ('#unanchored' if not set otherwise) -->
    <xsl:template mode="#all" match="tei:milestone[not(@rendition)]">
        <xsl:element name="milestone" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="@*[not(self::attribute(rendition))]">
                <xsl:copy/>
            </xsl:for-each>
            <xsl:attribute name="rendition">#unanchored</xsl:attribute>
        </xsl:element>
    </xsl:template>

    <!-- g) eliminate completely, i.e. also remove the element's content: ref, processing-instructions -->
    <xsl:template mode="#all" match="tei:ref[@type='note-anchor']" />
    <xsl:template mode="#all" match="//processing-instruction()" />

</xsl:stylesheet>
