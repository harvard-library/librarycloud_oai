package oai

import javax.xml.transform.TransformerFactory
import javax.xml.transform.stream.StreamResult
import javax.xml.transform.stream.StreamSource
import java.text.SimpleDateFormat
import groovy.xml.StreamingMarkupBuilder;
import groovy.xml.XmlUtil;
import grails.core.GrailsApplication
class OaiService {

    GrailsApplication grailsApplication

    def getCollectionsUrl() {
      return  grailsApplication.config.getProperty('collectionsUrl') //collectionUrl
    }

    def getItemsUrl() {
      return grailsApplication.config.getProperty('itemsUrl') //itemsUrl
    }

    def getXslDir() {
      return grailsApplication.mainContext.getResource("xsl").file.absolutePath
    }

    def validateArguments(params, requiredParams, allowedParams ) {
      def errors = ""

      def baseParams = ['verb','action','controller']
      def allParams = allowedParams == null ? baseParams : baseParams + allowedParams
      //println(baseParams)
      requiredParams.each {
        errors +=  ! params.containsKey(it) ? '<error code="badArgument">Missing required argument - ' + it + '</error>' : ''
      }

      def extraArgsQuery = {! allParams.contains(it.key)}
      params.findAll(extraArgsQuery).each {name,value ->
        errors += '<error code="badArgument">' + name + '</error>'
      }

      if (!errors.equals(''))
        errors = buildOai(params,errors,allowedParams)
      return errors
    }

    def cannotDisseminateFormat(params, allowedParams) {
      def error = ''
      def metadataPrefix = params.resumptionToken == null ? params.metadataPrefix : params.resumptionToken.split(":")[3]
      def allowedPrefixes = ['oai_dc', 'mods']
      if (! (metadataPrefix in allowedPrefixes)) {
        error = '<error code="cannotDisseminateFormat">' + metadataPrefix +  ' is not supported by the item or by the repository</error>'
        error = buildOai(params, error, allowedParams)
      }
      return error
    }

    def idDoesNotExist(params, allowedParams) {
      def identifier = params.identifier
      def errors = '<error code="idDoesNotExist">' + identifier +  ' is unknown or illegal in this repository</error>'
      return buildOai(params,errors,allowedParams)
    }

    def getQueryString(params) {
      def rt = params.resumptionToken
      def qs = "";
      if (rt == null) {
        qs = params.set == null ? "" : params.set in ['ALMA','VIA','OASIS'] ? "source=MH:" + params.set : "setSpec_exact=" + params.set + "&cursor=*"
        //turn off from/until for now (2016-01-11), won't work until date range searching implemented in solr/librarycloud api
        if (params.from != null)
          qs += "&processed.after=" + params.from
        if (params.until != null)
          qs += "&processed.before=" + params.until
        qs += "&sort=recordIdentifier"
      }
      else {
        //println(rt)
        //qs = "start=" + rt.split(':')[0] // + "&setSpec=" + rt.split(':')[3]
        qs = "cursor=" + rt.split(":")[0] + "&setSpec_exact=" + rt.split(':')[1]
        //qs += rt.split(':')[3] in ['ALMA','VIA','OASIS'] ? "&source=MH:" + rt.split(':')[3] : rt.split(':')[3] == 'ALL' ? "" : "&setSpec_exact=" + rt.split(':')[3]
        //turn off from/until for now (2016-01-11), won't work until date range searching implemented in solr/librarycloud api
        //if (!rt.split(':')[1].equals('0001-01-01'))
        //  qs += "&processed.after=" + rt.split(':')[1]
        //if (!rt.split(':')[2].equals('9999-12-31'))
        //  qs += "&processed.before=" + rt.split(':')[2]
      }
      //qs += "&sort=recordIdentifier"
      return qs
    }
    def buildOai (params, xml, allowedParams) {
      allowedParams = allowedParams == null ? ['verb'] : allowedParams + ['verb']
      def reqAttrQuery = {allowedParams.contains(it.key)}

      def fmt = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
      def now = fmt.format(new Date())
      def markupBuilder = new StreamingMarkupBuilder()
      def oaiXml = markupBuilder.bind {
        mkp.xmlDeclaration()
        namespaces << ['':'http://www.openarchives.org/OAI/2.0/',
                       'xsi':'http://www.w3.org/2001/XMLSchema-instance'
                       ]
        'OAI-PMH' ('xsi:schemaLocation':'http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd'){
          responseDate now
          request (
            params.findAll(reqAttrQuery).each {name,value ->
              [ (name):value ]
            }, 'https://api.lib.harvard.edu/oai/'
          )
        mkp.yieldUnescaped xml
        }
      }
      return oaiXml //XmlUtil.serialize(oaiXml)
    }

    def transformApiXml(xmlUrl, xslName) {
        return transformApiXml(xmlUrl, xslName, null)
    }

    def transformApiXml(xmlUrl, xslName, start) {
//System.out.println(start);
      def xml = xmlUrl.toURL().newReader('utf-8')
      def xsl = new File(xslName).text;
      def transformer = TransformerFactory.newInstance("net.sf.saxon.TransformerFactoryImpl", null).newTransformer(new StreamSource(new StringReader(xsl)))
        if (start == null)
            System.out.println();
        else
            transformer.setParameter("param1", start);
      def StreamResult result=new StreamResult(new StringWriter());
      transformer.transform(new StreamSource(xml), result)
      def transformedXml=result.getWriter();
      return transformedXml
    }
}
