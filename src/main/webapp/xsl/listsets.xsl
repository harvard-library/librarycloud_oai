<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="http://www.openarchives.org/OAI/2.0/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:lcloud="http://api.lib.harvard.edu/v2/collection/"
    exclude-result-prefixes="dcterms lcloud"
    version="2.0">
    <xsl:output indent="yes" omit-xml-declaration="yes"/>
    <xsl:param name="date">current-dateTime()</xsl:param>
    <xsl:template match="collections">
        <!--<xsl:element name="OAI-PMH">
            <xsl:attribute name="xsi:schemaLocation">http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd</xsl:attribute>
            <xsl:element name="responseDate"><xsl:value-of select="current-dateTime()"/></xsl:element>
            <xsl:element name="request">http://vcoai.lib.harvard.edu/vcoai/v2</xsl:element>
            <xsl:element name="ListSets">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:element>-->
        <xsl:element name="ListSets">
            <xsl:apply-templates/>
        </xsl:element>  
    </xsl:template>
    
    <xsl:template match="lcloud:collection">
        <xsl:element name="set">
            <xsl:element name="setSpec">
                <xsl:value-of select="lcloud:setSpec"/>
            </xsl:element>
            <xsl:element name="setName">
                <xsl:value-of select="lcloud:setName"/>
            </xsl:element>
            <xsl:element name="setDescription">
                <oai_dc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
                    <xsl:element name="dc:creator">Harvard University Library</xsl:element>
                    <xsl:apply-templates select="lcloud:setDescription[not(.='')]"/>
                </oai_dc:dc>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="lcloud:setDescription">
        <xsl:element name="dc:description"><xsl:value-of select="."/></xsl:element>
    </xsl:template>
  
    <xsl:template match="*"/> 
     
</xsl:stylesheet>
