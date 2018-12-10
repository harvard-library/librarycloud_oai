<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="http://www.openarchives.org/OAI/2.0/"
    xmlns:item="http://api.lib.harvard.edu/v2/item"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:sets="http://hul.harvard.edu/ois/xml/ns/sets" 
     xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:marc="http://www.loc.gov/MARC21/slim" 
    xmlns:HarvardDRS="http://hul.harvard.edu/ois/xml/ns/HarvardDRS" 
    xmlns:librarycloud="http://hul.harvard.edu/ois/xml/ns/librarycloud"
    exclude-result-prefixes="item"
    version="2.0">
    <!--<xsl:include href="pagination.xsl"/>-->
    <xsl:output indent="yes" omit-xml-declaration="yes" />
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="error">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="item:results">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="GetRecord">
                    <xsl:apply-templates/>
                </xsl:element>               
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="error">
        <error/>
    </xsl:template>
    
    <xsl:template match="item:results">
        <!--<xsl:element name="OAI-PMH">
            <xsl:attribute name="xsi:schemaLocation">http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd</xsl:attribute>
            <xsl:element name="responseDate"><xsl:value-of select="current-dateTime()"/></xsl:element>
            <xsl:element name="request">http://vcoai.lib.harvard.edu/vcoai/v2</xsl:element>
            <xsl:element name="ListRecords">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:element>-->
        <xsl:choose>
            <xsl:when test="item:pagination/item:numFound =  0">
                <error code="noRecordsMatch">No records match the request criteria.</error>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="ListRecords">
                    <!--<xsl:apply-templates/>-->
                    <xsl:apply-templates select="item:items"/>
                    <xsl:apply-templates select="item:pagination"/>
                </xsl:element>                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
  
    <xsl:template match="item:items">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="item:pagination">
        <xsl:call-template name="pagination">
            <xsl:with-param name="metadataPrefix" select="'mods'"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="mods:mods">
        <xsl:element name="record">
            <xsl:element name="header">
                <xsl:element name="identifier"><xsl:value-of select="mods:recordInfo/mods:recordIdentifier"/></xsl:element>
                <xsl:element name="datestamp"><xsl:value-of select="substring(mods:recordInfo/mods:recordChangeDate,1,8)"/></xsl:element>
            </xsl:element>
            <xsl:element name="metadata">
                <mods:mods xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-6.xsd" version="3.6">
                    <xsl:copy-of select="*" copy-namespaces="no"/>              
                </mods:mods>
            </xsl:element>
        </xsl:element>    
    </xsl:template>
 
    <xsl:template match="@xmlns"/>
 
    <xsl:template name="pagination">
        <xsl:param name="metadataPrefix"></xsl:param>
        <xsl:choose>
            <xsl:when test="item:limit + item:start + 1 &lt;= item:numFound">
                <xsl:element name="resumptionToken">
                    <xsl:attribute name="completeListSize">
                        <xsl:value-of select="item:numFound"/>
                    </xsl:attribute>
                    <xsl:value-of select="item:limit + item:start"/>
                    <xsl:choose>
                        <xsl:when test="not(contains(item:query,'setSpec_exact=')) and not(contains(item:query,'source='))">
                            <xsl:text>:0001-01-01:9999-12-31:ALL</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- TO DO: deal with from until -->
                            <xsl:text>:0001-01-01:9999-12-31</xsl:text>
                            <xsl:for-each select="tokenize(item:query,'&amp;')">
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
