package oai

import javax.xml.transform.stream.StreamResult

class OaiController {

    def oaiService

    def index () {
      // if we get here, it's because there was no verb param (see UrlMappings.groovy)
      // or verb param value != one of the six oai verbs
      def xml = new File(oaiService.getXslDir() + '/BadVerb.xml').text
      def badVerbXml = oaiService.buildOai(params, xml, null)
      render(text: badVerbXml, contentType: "text/xml", encoding: "UTF-8")
    }

    def identify () {
      def requiredParams = null
      def allowedParams = null
      def errors = oaiService.validateArguments(params, requiredParams, allowedParams)
      if (!errors.equals('')) {
        render(text: errors, contentType: "text/xml", encoding: "UTF-8")
        return
      }
      def xml = new File(oaiService.getXslDir() + '/Identify.xml').text
      def identifyOai = oaiService.buildOai(params, xml, allowedParams)
      render(text: identifyOai, contentType: "text/xml", encoding: "UTF-8")
    }

    def listMetadataFormats () {
      def requiredParams = null
      def allowedParams = ['identifier']
      def errors = oaiService.validateArguments(params, requiredParams, allowedParams)
      if (!errors.equals('')) {
        render(text: errors, contentType: "text/xml", encoding: "UTF-8")
        return
      }
      def xml = new File(oaiService.getXslDir() + '/ListMetadataFormats.xml').text;
      def metadataOai = oaiService.buildOai(params, xml, allowedParams)
      render(text: metadataOai, contentType: "text/xml", encoding: "UTF-8")
    }

    def listSets () {
      def requiredParams = null //params.resumptionToken == null ? null : ['resumptionToken']
      def allowedParams = null //params.resumptionToken == null ? null : requiredParams
      def errors = oaiService.validateArguments(params, requiredParams, allowedParams)
      if (!errors.equals('')) {
        render(text: errors, contentType: "text/xml", encoding: "UTF-8")
        return
      }
      def xmlUrl = oaiService.getCollectionsUrl() + '.xml?limit=250'
      def xslName = oaiService.getXslDir() + '/listsets.xsl'
      def listSetsXml = oaiService.transformApiXml(xmlUrl, xslName)
      def listSetsOai = oaiService.buildOai(params, listSetsXml, allowedParams)
      render(text: listSetsOai, contentType: "text/xml", encoding: "UTF-8")
    }

    def getRecord () {
      def requiredParams = ['identifier','metadataPrefix']
      def allowedParams = requiredParams
      def errors = oaiService.validateArguments(params, requiredParams, allowedParams)
      if (!errors.equals('')) {
        render(text: errors, contentType: "text/xml", encoding: "UTF-8")
        return
      }
      def identifier = params.identifier
      def metadataPrefix = params.metadataPrefix
      def cannotDisseminateFormatError = oaiService.cannotDisseminateFormat(params,allowedParams)
      if (!cannotDisseminateFormatError.equals('')) {
        render(text: cannotDisseminateFormatError, contentType: "text/xml", encoding: "UTF-8")
        return
      }
      def xmlUrl = oaiService.getItemsUrl() + "/" + identifier
      def errorcode = xmlUrl.toURL().openConnection().getResponseCode()
      if (errorcode == 404) {
        def idDoesNotExistOai = oaiService.idDoesNotExist(params, allowedParams)
        render(text: idDoesNotExistOai, contentType: "text/xml", encoding: "UTF-8")
        return
      }
      def xslName = oaiService.getXslDir() + "/" + metadataPrefix + '.xsl'
      def getRecordXml = oaiService.transformApiXml(xmlUrl, xslName)
      def getRecordOai = oaiService.buildOai(params, getRecordXml, allowedParams)
      render(text: getRecordOai, contentType: "text/xml", encoding: "UTF-8")
    }

    def listRecords () {
      def requiredParams = params.resumptionToken == null ? ['metadataPrefix','set'] : ['resumptionToken']
      def allowedParams = params.resumptionToken == null ? requiredParams + ['from','until'] : requiredParams
      def errors = oaiService.validateArguments(params, requiredParams, allowedParams)
      if (!errors.equals('')) {
        render(text: errors, contentType: "text/xml", encoding: "UTF-8")
        return
      }
      def metadataPrefix = params.resumptionToken == null ? params.metadataPrefix : params.resumptionToken.split(":")[3]
      def start = params.resumptionToken == null ? 10 : (params.resumptionToken.split(":")[2] as Integer) + 10
      def cannotDisseminateFormatError = oaiService.cannotDisseminateFormat(params,allowedParams)
      if (!cannotDisseminateFormatError.equals('')) {
        render(text: cannotDisseminateFormatError, contentType: "text/xml", encoding: "UTF-8")
        return
      }
      def queryString = oaiService.getQueryString(params)
      def xmlUrl = oaiService.getItemsUrl() + "?" + queryString
      def xslName = oaiService.getXslDir() + "/" + metadataPrefix + '.xsl'
      def listRecordsXml = oaiService.transformApiXml(xmlUrl, xslName, start)
      def listRecordsOai = oaiService.buildOai(params, listRecordsXml, allowedParams)
      render(text: listRecordsOai, contentType: "text/xml", encoding: "UTF-8")
    }

    def listIdentifiers () {

      def requiredParams = params.resumptionToken == null ? ['metadataPrefix','set'] : ['resumptionToken']
      def allowedParams = params.resumptionToken == null ? requiredParams + ['from','until'] : requiredParams

      def errors = oaiService.validateArguments(params, requiredParams, allowedParams)
      if (!errors.equals('')) {
        render(text: errors, contentType: "text/xml", encoding: "UTF-8")
        return
      }
      def metadataPrefix = params.resumptionToken == null ? params.metadataPrefix : params.resumptionToken.split(":")[3]
      def start = params.resumptionToken == null ? 10 : (params.resumptionToken.split(":")[2] as Integer) + 10
      def cannotDisseminateFormatError = oaiService.cannotDisseminateFormat(params,allowedParams)
      if (!cannotDisseminateFormatError.equals('')) {
        render(text: cannotDisseminateFormatError, contentType: "text/xml", encoding: "UTF-8")
        return
      }

      def queryString = oaiService.getQueryString(params)
      def xmlUrl = oaiService.getItemsUrl() + "?" + queryString
      def xslName = oaiService.getXslDir() + '/listidentifiers.xsl'
      def listIdentifiersXml = oaiService.transformApiXml(xmlUrl, xslName, start)
      def listIdentifiersOai = oaiService.buildOai(params, listIdentifiersXml, "resumptionToken")
      render(text: listIdentifiersOai, contentType: "text/xml", encoding: "UTF-8")
    }

}
