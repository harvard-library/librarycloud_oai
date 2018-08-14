<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="http://www.openarchives.org/OAI/2.0/"
    xmlns:mods="http://www.loc.gov/mods/v3"
    version="2.0">
    <xsl:output indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>
    <xsl:template match="mods:mods">
        <xsl:element name="GetRecord">
            <xsl:element name="record">
                <xsl:element name="header">
                    <xsl:element name="identifier"><xsl:value-of select="mods:recordInfo/mods:recordIdentifier"/></xsl:element>
                    <xsl:element name="datestamp"><xsl:value-of select="substring(mods:recordInfo/mods:recordChangeDate,1,8)"/></xsl:element>
                </xsl:element>
            </xsl:element>  
            <xsl:element name="metadata">
                <mods xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd" version="3.4">
                    <xsl:copy-of select="*"/>              
                </mods>
            </xsl:element>
        </xsl:element>
            <!--<<xsl:element name="OAI-PMH">
            <xsl:attribute name="xsi:schemaLocation">http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd</xsl:attribute>
            <xsl:element name="responseDate"><xsl:value-of select="current-dateTime()"/></xsl:element>
            <xsl:element name="request">http://vcoai.lib.harvard.edu/vcoai/v2</xsl:element>
            <xsl:element name="GetRecord">
                <xsl:element name="record">
                    <xsl:element name="header">
                        <xsl:element name="identifier"><xsl:value-of select="mods:recordInfo/mods:recordIdentifier"/></xsl:element>
                        <xsl:element name="datestamp">TO DO</xsl:element>
                    </xsl:element>
                </xsl:element>  
                <xsl:element name="metadata">
                    <mods xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd" version="3.4">
                        <xsl:copy-of select="*"/>              
                    </mods>
                </xsl:element>
            </xsl:element>
        </xsl:element>-->
    </xsl:template>

    <xsl:template match="*"/> 
     
</xsl:stylesheet>
