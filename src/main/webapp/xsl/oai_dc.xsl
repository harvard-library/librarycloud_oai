<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mods="http://www.loc.gov/mods/v3" 
	xmlns:item="http://api.lib.harvard.edu/v2/item"
	xmlns:sets="http://hul.harvard.edu/ois/xml/ns/sets" 
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:marc="http://www.loc.gov/MARC21/slim" 
	xmlns:HarvardDRS="http://hul.harvard.edu/ois/xml/ns/HarvardDRS" 
	xmlns:librarycloud="http://hul.harvard.edu/ois/xml/ns/librarycloud"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:srw_dc="info:srw/schema/1/dc-schema"
	xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
	xmlns:cdwalite="http://www.getty.edu/research/conducting_research/standards/cdwa/cdwalite"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="mods srw_dc cdwalite item sets">
	<!--<xsl:include href="xsl/pagination.xsl"/>-->
	<xsl:output omit-xml-declaration="yes"/>

<!-- 
	
	Version 2.0		2012/08/12 WS 
	Upgraded stylesheet to XSLT 2.0 
	Upgraded to MODS 3.4
	
	Revision 1.1	2007-05-18 tmee@loc.gov
	Added modsCollection conversion to DC SRU
	Updated introductory documentation
	
	Version 1.0		2007-05-04 tmee@loc.gov
	
	This stylesheet transforms MODS version 3.4 records and collections of records to simple Dublin Core (DC) records, 
	based on the Library of Congress' MODS to simple DC mapping <http://www.loc.gov/standards/mods/mods-dcsimple.html> 
			
	The stylesheet will transform a collection of MODS 3.4 records into simple Dublin Core (DC)
	as expressed by the SRU DC schema <http://www.loc.gov/standards/sru/dc-schema.xsd>
	
	The stylesheet will transform a single MODS 3.4 record into simple Dublin Core (DC)
	as expressed by the OAI DC schema <http://www.openarchives.org/OAI/2.0/oai_dc.xsd>
			
	Because MODS is more granular than DC, transforming a given MODS element or subelement to a DC element frequently results in less precise tagging, 
	and local customizations of the stylesheet may be necessary to achieve desired results. 
	
	This stylesheet makes the following decisions in its interpretation of the MODS to simple DC mapping: 
		
	When the roleTerm value associated with a name is creator, then name maps to dc:creator
	When there is no roleTerm value associated with name, or the roleTerm value associated with name is a value other than creator, then name maps to dc:contributor
	Start and end dates are presented as span dates in dc:date and in dc:coverage
	When the first subelement in a subject wrapper is topic, subject subelements are strung together in dc:subject with hyphens separating them
	Some subject subelements, i.e., geographic, temporal, hierarchicalGeographic, and cartographics, are also parsed into dc:coverage
	The subject subelement geographicCode is dropped in the transform


-->
	<xsl:strip-space elements="*"/>

	<xsl:output method="xml" omit-xml-declaration="yes" version="1.0" encoding="utf-8" indent="yes"/>
	
	<xsl:param name="param1"></xsl:param>
	
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
			<xsl:with-param name="metadataPrefix" select="'oai_dc'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="mods:mods"> 
		<xsl:element name="record">
			<xsl:element name="header">
				<xsl:element name="identifier"><xsl:value-of select="mods:recordInfo/mods:recordIdentifier"/></xsl:element>
                                <!--<xsl:element name="datestamp"><xsl:value-of select="substring(mods:recordInfo/mods:recordChangeDate,1,8)"/></xsl:element>-->
                                <xsl:variable name="year" select="substring(mods:recordInfo/mods:recordChangeDate,1,4)"/>
                                <xsl:variable name="month" select="substring(mods:recordInfo/mods:recordChangeDate,5,2)"/>
                                <xsl:variable name="day" select="substring(mods:recordInfo/mods:recordChangeDate,7,2)"/>
                                <xsl:element name="datestamp"><xsl:value-of select="concat($year,'-',$month,'-',$day)"/></xsl:element>

			</xsl:element>
			<xsl:element name="metadata">
				<oai_dc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
					<xsl:apply-templates/>
					<xsl:if test="//mods:recordIdentifier/@source='MH:OASIS'">
						<xsl:if test="not(mods:originInfo)">
							<xsl:if test="//mods:physicalLocation[@type='repository']">
								<dc:publisher>
									<xsl:value-of select="//mods:physicalLocation[@type='repository']"/>
								</dc:publisher>
							</xsl:if>
						</xsl:if>
						<dc:relation><xsl:apply-templates select="//mods:relatedItem[@displayLabel='collection']" mode="componenthierarchy"/></dc:relation>
					</xsl:if>
				</oai_dc:dc>
			</xsl:element>
		</xsl:element>  
	</xsl:template>

	<xsl:template match="mods:titleInfo">
		<dc:title>
			<xsl:value-of select="mods:nonSort"/>
			<xsl:if test="mods:nonSort">
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:value-of select="mods:title"/>
			<xsl:if test="mods:subTitle">
				<xsl:text>: </xsl:text>
				<xsl:value-of select="mods:subTitle"/>
			</xsl:if>
			<xsl:if test="mods:partNumber">
				<xsl:text>. </xsl:text>
				<xsl:value-of select="mods:partNumber"/>
			</xsl:if>
			<xsl:if test="mods:partName">
				<xsl:text>. </xsl:text>
				<xsl:value-of select="mods:partName"/>
			</xsl:if>
		</dc:title>
	</xsl:template>

	<xsl:template match="mods:name">
		<xsl:choose>
			<!--
			<xsl:when test="mods:role/mods:roleTerm[@type='text']='creator' or mods:role/mods:roleTerm[@type='code']='cre' ">
			-->
			<!-- Harvard - don't require @type='text' -->
			<xsl:when test="mods:role/mods:roleTerm='creator' or mods:role/mods:roleTerm[@type='code']='cre' ">
				<dc:creator>
					<xsl:call-template name="name"/>
				</dc:creator>
			</xsl:when>
			<!-- Harvard - assoc name should be subject -->
			<xsl:when test="mods:role/mods:roleTerm='associated name' and mods:role/mods:roleTerm='subject'">
				<dc:subject>
					<xsl:call-template name="name"/>
				</dc:subject>
			</xsl:when>
			<xsl:otherwise>
				<dc:contributor>
					<xsl:call-template name="name"/>
				</dc:contributor>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="mods:classification">
		<dc:subject>
			<xsl:value-of select="."/>
		</dc:subject>
	</xsl:template>

	<xsl:template match="mods:subject[mods:topic | mods:name | mods:occupation | mods:geographic | mods:hierarchicalGeographic | mods:cartographics | mods:temporal] ">
		<dc:subject>
			<xsl:for-each select="mods:topic | mods:name/* | mods:occupation | mods:geographic | mods:cartographics | mods:temporal">
				<xsl:choose>
					<xsl:when test="mods:name">
						<xsl:if test="../mods:topic">--</xsl:if>
						<xsl:call-template name="name"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="."/>
						<xsl:if test="position()!=last()">--</xsl:if>		
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</dc:subject>
		<!--		<xsl:if test="not(mods:topic and mods:geographic) and not(mods:topic and mods:temporal)">
		<dc:subject>
			<xsl:for-each select="mods:topic | mods:occupation">
				<xsl:value-of select="."/>
				<xsl:if test="position()!=last()">-XX-</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="mods:name"><xsl:if test="../mods:topic">-XX-</xsl:if>
				<xsl:call-template name="name"/>
			</xsl:for-each>
		</dc:subject>
</xsl:if>-->


<!--
		<xsl:for-each select="mods:titleInfo/mods:title">
			<dc:subject>
				<xsl:value-of select="mods:titleInfo/mods:title"/>
			</dc:subject>
		</xsl:for-each>
		-->
<!--
		<xsl:for-each select="mods:geographic">
			<dc:coverage>
				<xsl:value-of select="."/>
			</dc:coverage>
		</xsl:for-each>


		<xsl:for-each select="mods:hierarchicalGeographic">
			<dc:coverage>
				<xsl:for-each select="mods:continent|mods:country|mods:provence|mods:region|mods:state|mods:territory|mods:county|mods:city|mods:island|mods:area">
					<xsl:value-of select="."/>
					<xsl:if test="position()!=last()">-XX-</xsl:if>
				</xsl:for-each>
			</dc:coverage>
		</xsl:for-each>

		<xsl:for-each select="mods:cartographics/*">
			<dc:coverage>
				<xsl:value-of select="."/>
			</dc:coverage>
		</xsl:for-each>

		<xsl:if test="mods:temporal">
			<dc:coverage>
				<xsl:for-each select="mods:temporal">
					<xsl:value-of select="."/>
					<xsl:if test="position()!=last()">-</xsl:if>
				</xsl:for-each>
			</dc:coverage>
		</xsl:if>
-->
		<!--<xsl:if test="*[1][local-name()='topic'] and *[local-name()!='topic']">
			<dc:subject>
				<xsl:for-each select="*[local-name()!='cartographics' and local-name()!='geographicCode' and local-name()!='hierarchicalGeographic'] ">
					<xsl:value-of select="."/>
					<xsl:if test="position()!=last()">-XX-</xsl:if>
				</xsl:for-each>
			</dc:subject>
		</xsl:if>-->
	</xsl:template>

	<xsl:template match="mods:abstract | mods:tableOfContents | mods:note">
		<dc:description>
			<xsl:value-of select="."/>
		</dc:description>
	</xsl:template>

	<xsl:template match="mods:originInfo">
		<xsl:apply-templates select="*[@point='start']"/>
		<xsl:for-each
			select="mods:dateIssued[@point!='start' and @point!='end'] |mods:dateCreated[@point!='start' and @point!='end'] | mods:dateCaptured[@point!='start' and @point!='end'] | mods:dateOther[@point!='start' and @point!='end']">
			<dc:date>
				<xsl:value-of select="."/>
			</dc:date>
		</xsl:for-each>
		<xsl:apply-templates select="*[not(@point)]"/>

		<xsl:if test="//mods:physicalLocation[not(@type='repository') and not(.='Networked Resource')]">
			<dc:publisher> 
				<xsl:value-of select="//mods:physicalLocation[not(@type='repository') and not(.='Networked Resource')]"/>
			</dc:publisher>
	        </xsl:if>
		<xsl:if test="//mods:physicalLocation[@type='repository']">
			<dc:publisher>
				<xsl:value-of select="//mods:physicalLocation[@type='repository']"/>
			</dc:publisher>
	    </xsl:if>
	
		<xsl:for-each select="mods:publisher"> 
			<dc:publisher>
				<xsl:value-of select="."/>
			</dc:publisher>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="mods:dateIssued | mods:dateCreated | mods:dateCaptured">
		<dc:date>
			<xsl:choose>
				<xsl:when test="@point='start'">
					<xsl:value-of select="."/>
					<xsl:text> - </xsl:text>
				</xsl:when>
				<xsl:when test="@point='end'">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</dc:date>
	</xsl:template>
	
	<xsl:template match="mods:dateIssued[@point='start'] | mods:dateCreated[@point='start'] | mods:dateCaptured[@point='start'] | mods:dateOther[@point='start'] ">
		<xsl:variable name="dateName" select="local-name()"/>
		<dc:date>
			<xsl:value-of select="."/>-<xsl:value-of select="../*[local-name()=$dateName][@point='end']"/>
		</dc:date>
	</xsl:template>
	
	<xsl:template match="mods:temporal[@point='start']  ">
		<xsl:value-of select="."/>-<xsl:value-of select="../mods:temporal[@point='end']"/>
	</xsl:template>
	
	<xsl:template match="mods:temporal[@point!='start' and @point!='end']">
		<xsl:value-of select="."/>
	</xsl:template>
	<xsl:template match="mods:genre">
<!--mjv - 2014-01-24, added test below to dedupe mods genres -->
<xsl:if test="not(node()) or not(preceding-sibling::node()[.=string(current())])"> 
		<xsl:choose>
			<xsl:when test="@authority='dct'">
				<dc:type>
					<xsl:value-of select="."/>
				</dc:type>
			</xsl:when>
			<xsl:otherwise>
				<dc:type>
					<xsl:value-of select="."/>
				</dc:type>
				<xsl:apply-templates select="mods:typeOfResource"/>
			</xsl:otherwise>
		</xsl:choose>
</xsl:if>
	</xsl:template>

	<xsl:template match="mods:typeOfResource">
		<xsl:if test="@collection='yes'">
			<dc:type>Collection</dc:type>
		</xsl:if>
		<xsl:if test=". ='software' and ../mods:genre='database'">
			<dc:type>Dataset</dc:type>
		</xsl:if>
		<xsl:if test=".='software' and ../mods:genre='online system or service'">
			<dc:type>Service</dc:type>
		</xsl:if>
		<xsl:if test=".='software'">
			<dc:type>Software</dc:type>
		</xsl:if>
		<xsl:if test=".='cartographic material'">
			<dc:type>Image</dc:type>
		</xsl:if>
		<xsl:if test=".='multimedia'">
			<dc:type>InteractiveResource</dc:type>
		</xsl:if>
		<xsl:if test=".='moving image'">
			<dc:type>MovingImage</dc:type>
		</xsl:if>
		<xsl:if test=".='three dimensional object'">
			<dc:type>PhysicalObject</dc:type>
		</xsl:if>
		<xsl:if test="starts-with(.,'sound recording')">
			<dc:type>Sound</dc:type>
		</xsl:if>
		<xsl:if test=".='still image'">
			<dc:type>StillImage</dc:type>
		</xsl:if>
		<xsl:if test=". ='text'">
			<dc:type>Text</dc:type>
		</xsl:if>
		<xsl:if test=".='notated music'">
			<dc:type>Text</dc:type>
		</xsl:if>
	</xsl:template>

	<xsl:template match="mods:physicalDescription">
		<xsl:for-each select="mods:extent | mods:form | mods:internetMediaType">
			<dc:format>
				<xsl:value-of select="."/>
			</dc:format>
		</xsl:for-each>
	</xsl:template>

<!-- Harvard - map cdwalite:termMaterialsTech to dc:format -->

	<xsl:template match="mods:extension">
		<xsl:apply-templates select="mods:indexingMaterialsTechSet"/>
	</xsl:template>

	<xsl:template match="mods:indexingMaterialsTechSet">
		<!-- why doesnt this work? TO DO -->
		<xsl:apply-templates select="cdwalite:termMaterialsTech"/>
		<dc:format>
			<xsl:value-of select="normalize-space(.)"/>
		</dc:format>
	</xsl:template>

	<xsl:template match="cdwalite:termMaterialsTech">
		<dc:format>
			<xsl:value-of select="."/>
		</dc:format>
	</xsl:template>

<!--
	<xsl:template match="mods:mimeType">
		<dc:format>
			<xsl:value-of select="."/>
		</dc:format>
	</xsl:template>
-->
	<xsl:template match="mods:identifier">
		<dc:identifier>
			<xsl:choose>
				<!-- 2.0: added identifier type attribute to output, if it is present-->
				<xsl:when test="contains(.,':')">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:when test="@type">
					<xsl:value-of select="@type"/>:<xsl:value-of select="."/>
				</xsl:when>
				<xsl:when test="contains('isbn issn uri doi lccn uri', .)">
						<xsl:value-of select="."/>:<xsl:value-of select="."/>
				</xsl:when>
				<xsl:otherwise>
						<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</dc:identifier>
	</xsl:template>
	<xsl:template match="mods:location">
	    <xsl:if test="mods:url[@usage='primary display']">
		<xsl:apply-templates select="mods:url[@usage='primary display']"/>
	    </xsl:if>

	    <xsl:if test="mods:url[not(@usage='primary display')]">
		<xsl:for-each select="mods:url">
			<dc:identifier>	
				<xsl:value-of select="."/>
			</dc:identifier>
		</xsl:for-each>
	    </xsl:if>
	</xsl:template>

	<xsl:template match="mods:language">
		<dc:language>
			<xsl:value-of select="child::*"/>
		</dc:language>
	</xsl:template>

	<xsl:template match="mods:relatedItem[not(//mods:recordIdentifier/@source='MH:OASIS')][mods:titleInfo | mods:name | mods:identifier | mods:location]">
		<xsl:choose>
			<xsl:when test="@type='original'">
				<dc:source>
					<xsl:for-each
						select="mods:titleInfo/mods:title | mods:identifier | mods:location/mods:url">
						<xsl:if test="normalize-space(.)!= ''">
							<xsl:value-of select="."/>
							<xsl:if test="position()!=last()">--</xsl:if>
						</xsl:if>
					</xsl:for-each>
				</dc:source>
			</xsl:when>
			<xsl:when test="@type='series'"/>

			<xsl:otherwise>
				<dc:relation>
					<xsl:for-each
						select="mods:titleInfo/mods:title | mods:identifier | mods:location/mods:url">
						<xsl:if test="normalize-space(.)!= ''">
							<xsl:value-of select="."/>
							<xsl:if test="position()!=last()">--</xsl:if>
						</xsl:if>
					</xsl:for-each>
				</dc:relation>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


<xsl:template match="mods:relatedItem" mode="componenthierarchy">
            <xsl:if test="./@displayLabel='collection' and ./mods:location/mods:physicalLocation[@type='repository']">
		<xsl:value-of select="./mods:location/mods:physicalLocation[@type='repository']"/><xsl:text>: </xsl:text>
            </xsl:if>
            <xsl:if test="not(./@displayLabel='collection')">
	    <xsl:text>--&gt;</xsl:text>	
            </xsl:if>
            <xsl:value-of select="mods:titleInfo/mods:title"/>
            <xsl:if test="not(contains(mods:titleInfo/mods:title,normalize-space(originInfo/dateCreated[not(@point)])))">
                <xsl:value-of select="mods:originInfo/mods:dateCreated[not(@point)]"/>
            </xsl:if>
    <xsl:apply-templates select="parent::mods:relatedItem" mode="componenthierarchy"/>
</xsl:template>

	<xsl:template match="mods:accessCondition">
		<dc:rights>
			<xsl:value-of select="."/>
		</dc:rights>
	</xsl:template>

    <xsl:template match="mods:url[@usage='primary display']">
        <xsl:choose>
            <xsl:when test="contains(.,'http://')">
                <dc:identifier><xsl:value-of select="."/></dc:identifier>
            </xsl:when>
            <xsl:otherwise>
                <dc:identifier>
                <xsl:choose>
                    <xsl:when test="//mods:recordIdentifier/@source='MH:ALMA'">
                        <xsl:text>http://hollisclassic.harvard.edu/F?func=find-c&amp;CCL_TERM=sys=</xsl:text><xsl:value-of select="."/>
                    </xsl:when>
                    <xsl:when test="../../mods:recordInfo/mods:recordIdentifier/@source='MH:OASIS'">
                        <xsl:text>http://oasis.lib.harvard.edu/oasis/component/</xsl:text><xsl:value-of select="."/><xsl:text>.html</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
                </dc:identifier>
            </xsl:otherwise>
        </xsl:choose>
	</xsl:template>

	<xsl:template name="name">
		<xsl:variable name="name">
			<xsl:for-each select="mods:namePart[not(@type)]">
				<xsl:value-of select="."/>
				<xsl:text> </xsl:text>
			</xsl:for-each>
			<xsl:value-of select="mods:namePart[@type='family']"/>
			<xsl:if test="mods:namePart[@type='given']">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="mods:namePart[@type='given']"/>
			</xsl:if>
			<xsl:if test="mods:namePart[@type='date']">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="mods:namePart[@type='date']"/>
				<xsl:text/>
			</xsl:if>
			<xsl:if test="mods:displayForm">
				<xsl:text> (</xsl:text>
				<xsl:value-of select="mods:displayForm"/>
				<xsl:text>) </xsl:text>
			</xsl:if>
			<xsl:for-each select="mods:role[mods:roleTerm[@type='text']!='creator']">
				<xsl:text> (</xsl:text>
				<xsl:value-of select="normalize-space(child::*)"/>
				<xsl:text>) </xsl:text>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="normalize-space($name)"/>
	</xsl:template>
	
	<xsl:template name="pagination">
		<xsl:param name="metadataPrefix"></xsl:param>
		<xsl:if test="$param1 &lt; item:numFound">
			<xsl:element name="resumptionToken">
				<xsl:attribute name="completeListSize">
					<xsl:value-of select="item:numFound"/>
				</xsl:attribute>
				<xsl:value-of select="item:nextCursor"/>
				<xsl:for-each select="tokenize(item:query,'&amp;')">
					<xsl:if test="starts-with(.,'setSpec')">
						<xsl:text>:</xsl:text><xsl:value-of select="substring-after(.,'=')"/>
					</xsl:if>
					<!--<xsl:if test=".='cursor=*'">
                        <xsl:text>:10</xsl:text>
                    </xsl:if>-->
				</xsl:for-each>
				<xsl:text>:</xsl:text><xsl:value-of select="$param1"/>
				<xsl:text>:</xsl:text><xsl:value-of select="$metadataPrefix"/>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<!-- suppress all else:-->
	<xsl:template match="*"/>
		
	
</xsl:stylesheet>

