<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    <xsl:preserve-space elements="*"/>
    <xsl:include href="http://papyri.uni-koeln.de:8080/rest/db/apps/pessoa/xslt/common.xsl"/>
    
    
    <!-- hier nicht weiter zu berücksichtigen -->
    <xsl:template match="expan"/>
    <xsl:template match="add[@resp]"/>
    <xsl:template match="supplied"/>
    
   <!-- <xsl:template match="text()">
        <xsl:choose>
            <xsl:when test="matches(., '^\s+$')"><xsl:text xml:space="preserve"> </xsl:text></xsl:when>
            <xsl:otherwise><xsl:value-of select="." /></xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->
</xsl:stylesheet>