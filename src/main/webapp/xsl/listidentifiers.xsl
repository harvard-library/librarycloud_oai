<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="http://www.openarchives.org/OAI/2.0/"
    xmlns:lcloud="http://api.lib.harvard.edu/v2/item"
    xmlns:mods="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="lcloud"
    version="2.0">
    <!--<xsl:include href="xsl/pagination.xsl"/>-->
    <xsl:output indent="yes" omit-xml-declaration="yes"/>
    <xsl:template match="lcloud:results">
        <!--<xsl:element name="OAI-PMH">
            <xsl:attribute name="xsi:schemaLocation">http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd</xsl:attribute>
            <xsl:element name="responseDate"><xsl:value-of select="current-dateTime()"/></xsl:element>
            <xsl:element name="request">http://vcoai.lib.harvard.edu/vcoai/v2</xsl:element>
            <xsl:element name="ListIdentifiers">
                <xsl:apply-templates select="lcloud:items"/>
                <xsl:apply-templates select="lcloud:pagination"/>
            </xsl:element>
        </xsl:element>-->
        <xsl:element name="ListIdentifiers">
            <xsl:choose>
                <xsl:when test="lcloud:pagination/lcloud:numFound =  0">
                    <error code="noRecordsMatch">No records match the request criteria.</error>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="ListRecords">
                        <xsl:apply-templates select="lcloud:items"/>
                        <xsl:apply-templates select="lcloud:pagination"/>
                    </xsl:element>                
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
  
    <xsl:template match="lcloud:items">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="lcloud:pagination">
        <xsl:call-template name="pagination">
            <xsl:with-param name="metadataPrefix" select="'oai_dc'"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="mods:mods">
        <xsl:element name="header">
            <xsl:element name="identifier"><xsl:value-of select="mods:recordInfo/mods:recordIdentifier"/></xsl:element>
            <xsl:element name="datestamp"><xsl:value-of select="substring(mods:recordInfo/mods:recordChangeDate,1,8)"/></xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template name="pagination">
        <xsl:param name="metadataPrefix"></xsl:param>
        <xsl:choose>
            <xsl:when test="lcloud:limit + lcloud:start + 1 &lt; lcloud:numFound">
                <xsl:element name="resumptionToken">
                    <xsl:attribute name="completeListSize">
                        <xsl:value-of select="lcloud:numFound"/>
                    </xsl:attribute>
                    <xsl:value-of select="lcloud:limit + lcloud:start"/>
                    <xsl:choose>
                        <xsl:when test="not(contains(lcloud:query,'setSpec=')) and not(contains(lcloud:query,'source='))">
                            <xsl:text>:0001-01-01:9999-12-31:ALL</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- TO DO: deal with from until -->
                            <xsl:text>:0001-01-01:9999-12-31</xsl:text>
                            <xsl:for-each select="tokenize(lcloud:query,'&amp;')">
                                <xsl:if test="starts-with(.,'setSpec')">
                                    <xsl:text>:</xsl:text><xsl:value-of select="substring-after(.,'=')"/>
                                </xsl:if>
                                <xsl:if test="starts-with(.,'source')">
                                    <xsl:text>:</xsl:text><xsl:value-of select="substring-after(.,':')"/>
                                </xsl:if>
                            </xsl:for-each>                            
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>:</xsl:text><xsl:value-of select="$metadataPrefix"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*"/> 
     
</xsl:stylesheet>
