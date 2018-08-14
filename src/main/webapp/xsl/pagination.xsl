<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:lcloud="http://api.lib.harvard.edu/v2/item"
    exclude-result-prefixes="xs"
    version="2.0">
    
    
    
    <xsl:template name="pagination">
        <xsl:param name="metadataPrefix"></xsl:param>
        <xsl:choose>
            <xsl:when test="lcloud:limit + lcloud:start + 1 &lt; lcloud:numFound">
                <xsl:element name="resumptionToken">
                    <xsl:attribute name="completeListSize">
                        <xsl:value-of select="lcloud:numFound"/>
                    </xsl:attribute>
                    <xsl:value-of select="lcloud:limit + lcloud:start"/>
                    <xsl:for-each select="tokenize(lcloud:query,'&amp;')">
                        <xsl:choose>
                            <xsl:when test="starts-with(.,'from')">
                                <xsl:text>:</xsl:text><xsl:value-of select="substring-after(.,'=')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>:0001-01-01</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="starts-with(.,'until')">
                                <xsl:text>:</xsl:text><xsl:value-of select="substring-after(.,'=')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>:9999-12-31</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="starts-with(.,'setSpec')">
                            <xsl:text>:</xsl:text><xsl:value-of select="substring-after(.,'=')"/>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:text>:</xsl:text><xsl:value-of select="$metadataPrefix"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>