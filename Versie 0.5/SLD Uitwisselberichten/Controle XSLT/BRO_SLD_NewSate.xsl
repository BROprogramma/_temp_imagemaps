<?xml version="1.0" encoding="utf-8"?>
<!--XSLT LIB_Controle.xsl versie 5.6 (14-12-2021) - SIKB0101 versie 14.7.0-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xdt="http://www.w3.org/2005/xpath-datatypes" xmlns:imsikb0101="http://www.sikb.nl/imsikb0101" xmlns:immetingen="http://www.sikb.nl/immetingen" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gsr="http://www.isotc211.org/2005/gsr" xmlns:gss="http://www.isotc211.org/2005/gss" xmlns:gts="http://www.isotc211.org/2005/gts" xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:om="http://www.opengis.net/om/2.0" xmlns:sam="http://www.opengis.net/sampling/2.0" xmlns:sams="http://www.opengis.net/samplingSpatial/2.0" xmlns:spec="http://www.opengis.net/samplingSpecimen/2.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:sikb="http://xslcontrole.sikb" xsi:schemaLocation="http://www.sikb.nl/imsikb0101 imsikb0101_v14.7.1.xsd">
	<xsl:output method="xml" indent="yes"/>
	<!-- global variables -->
	<xsl:variable name="imsikb0101LookupFile" select="string('imsikb0101 lookup v14.7.0.xml')"/>
	<xsl:variable name="immetingenLookupFile" select="string('immetingen lookup v14.7.0.xml')"/>
	<xsl:template match="/">
		<ArrayOfLogRecord>
		
			<!-- file dataflow check -->
			<xsl:if test="count(//imsikb0101:metaData/imsikb0101:dataflow) &lt; 1">			
				<xsl:copy-of select="sikb:createRecord('WARNING','imsikb0101:metaData/imsikb0101:dataflow','Er zou een metadata/dataflow ingevuld moeten zijn.')"/>		
			</xsl:if>
			<xsl:if test="lower-case(//imsikb0101:metaData/imsikb0101:dataflow) != lower-case('urn:imsikb0101:DatastroomType:id:5')">			
				<xsl:copy-of select="sikb:createRecord('WARNING','imsikb0101:metaData/imsikb0101:dataflow','Het veld metadata/dataflow zou ingevuld moeten zijn met: urn:imsikb0101:DatastroomType:id:5. Als dit geen LIB-xml is, kies dan voor een andere controle xslt.')"/>		
			</xsl:if>		
                
            <!-- Er moet minimaal en maximaal 1 Dossier gekoppeld zijn. -->
            <xsl:if test="count(//imsikb0101:Dossier) != 1">
				<xsl:copy-of select="sikb:createRecord('ERROR','imsikb0101:Dossier','Er moet minimaal en maximaal 1 imsikb0101:Dossier aanwezig zijn.')"/>
			</xsl:if>	
		
			<xsl:apply-templates select="//imsikb0101:metaData"/>
			<xsl:apply-templates select="//imsikb0101:Dossier"/>
			<xsl:apply-templates select="//imsikb0101:featureMember" />
		</ArrayOfLogRecord>
	</xsl:template>
	<!--  lengte /verplichting  van metadata velden -->
	<xsl:template match="imsikb0101:metaData">
		<xsl:copy-of select="sikb:checkLookupId(., '', 'application', 'Applicaties', 'ERROR')"/>
		<xsl:copy-of select="sikb:checkDateBeforeDate(., '', 'date', 'current', 'WARNING')"/>		
		<xsl:copy-of select="sikb:checkExistence(., '','sender','ERROR')"/>
		<xsl:copy-of select="sikb:checkSender(., '', 'WARNING')"/>
		<xsl:copy-of select="sikb:checkLookupId(., '', 'supplier', 'Leveranciers', 'ERROR')"/>
	</xsl:template>
	<xsl:template match="imsikb0101:Dossier">
		<xsl:variable name="prGUID" select="@gml:id"/>
		<xsl:copy-of select="sikb:checkExistence(., $prGUID, 'dataAdministrator', 'ERROR')"/>
		<xsl:copy-of select="sikb:checkLookupId(., $prGUID, 'dataAdministrator', 'Bronhouders', 'ERROR')"/>
        
        <xsl:copy-of select="sikb:checkExistence(., $prGUID, 'followUpWBB', 'ERROR')"/>
		<xsl:copy-of select="sikb:checkLookupId(., $prGUID, 'followUpWBB', 'VervolgWBB', 'ERROR')"/>

		<!-- Check relation statusOnBasisOfInvestigation, pollutionStartedBefore1987 and followUpWbb 
		<xsl:if test="contains('|1|2|15|16|',concat('|',substring-after(./imsikb0101:statusOnBasisOfInvestigation,':id:'),'|')) and ./imsikb0101:pollutionStartedBefore1987 and contains('|20|21|',concat('|',substring-after(./imsikb0101:followUpWBB,':id:'),'|'))">
			<xsl:variable name="message" select="string-join(('followUpWBB bij', string(./local-name()), $prGUID, 'mag niet waarde ', substring-after(./imsikb0101:followUpWBB,':id:'), 'hebben als statusOnBasisOfInvestigation waarde',substring-after(./imsikb0101:statusOnBasisOfInvestigation,':id:'), 'heeft en pollutionStartedBefore1987 waarde', string(./imsikb0101:pollutionStartedBefore1987), 'heeft.'),' ')"/>
			<xsl:copy-of select="sikb:createRecord('WARNING',string(./name()), $message)"/>
		</xsl:if>
		 Check relation statusOnBasisOfInvestigation 
		<xsl:if test="count(.[imsikb0101:statusOnBasisOfInvestigation]) != 0 and count(//imsikb0101:Project/imsikb0101:dossiers[@xlink:href=string-join(('#',$prGUID),'')]|//imsikb0101:addressLocations|.//imsikb0101:Activity)=0">
			<xsl:variable name="message" select="replace(string-join(('Bij', string(./local-name()), $prGUID, 'is het element statusOnBasisOfInvestigation gevuld terwijl er geen Project, AddressLocation, Activity aanwezig is.'), ' '), '  ', ' ')"/>
			<xsl:copy-of select="sikb:createRecord('WARNING', string(./name()), $message)"/>
		</xsl:if>-->
		
			
	</xsl:template>
	
<xsl:template match="imsikb0101:featureMember">
	<xsl:variable name="GmlId" select="substring-after(./*/@gml:id,'_')"/>
	<xsl:variable name="IdentificationImmetingen" select="./*/immetingen:identification/immetingen:NEN3610ID/immetingen:lokaalID"/>
	<xsl:variable name="IdentificationImSikb" select="./*/imsikb0101:identification/immetingen:NEN3610ID/immetingen:lokaalID"/>
	<xsl:variable name="ElementName" select="name(./*)"/>
	<xsl:choose>	
		<xsl:when test="$IdentificationImmetingen != ''">
			<xsl:if test="$IdentificationImmetingen != $GmlId">
			   <xsl:copy-of select="sikb:createRecord('ERROR',$ElementName,string-join(($ElementName,'met gml:id (',$GmlId,') heeft een afwijkend lokaalId (',$IdentificationImmetingen,').' ),' '))" />
			</xsl:if>			
		</xsl:when>		
		<xsl:otherwise>
			<xsl:if test="$IdentificationImSikb != $GmlId">
				<xsl:copy-of select="sikb:createRecord('ERROR',$ElementName,string-join(($ElementName,'met gml:id (',$GmlId,') heeft een afwijkend lokaalId (',$IdentificationImSikb,').' ),' '))" />
			</xsl:if>
		</xsl:otherwise>              
	</xsl:choose>
</xsl:template>			
	<!-- FUNCTIONS -->
	<xsl:function name="sikb:createRecord">
		<!-- function for creating LOG-records -->
		<xsl:param name="type"/>
		<xsl:param name="title"/>
		<xsl:param name="message"/>
		<xsl:element name="LogRecord">
			<xsl:element name="Type">
				<xsl:copy-of select="$type"/>
			</xsl:element>
			<xsl:element name="Title">
				<xsl:copy-of select="$title"/>
			</xsl:element>
			<xsl:element name="Message">
				<xsl:copy-of select="replace($message, '  ', ' ')"/>
			</xsl:element>
		</xsl:element>
	</xsl:function>
	<xsl:function name="sikb:checkExistence">
		<!-- function to check existence in xml-file -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="message" select="replace(string-join(('Het element', $field, 'bij', $elementLocalName, $prGUID, 'moet aanwezig zijn.'), ' '), '  ', ' ')"/>
		<xsl:if test="not($context/*[local-name()=$field])">
			<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkExistenceEither">
		<!-- function to check existence of at least on of two fields in xml-file -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="fieldEither"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="message" select="replace(string-join(('Het element', $field, 'en het element', $fieldEither, 'bij', $elementLocalName, $prGUID, 'mogen niet allebei ontbreken.'), ' '), '  ', ' ')"/>
		<xsl:if test="not($context/*[local-name()=$field]) and not($context/*[local-name()=$fieldEither])">
			<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkExistenceCountOtherContext">
		<!-- function to check existence in xml-file -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="otherContext"/>
		<xsl:param name="field"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="message" select="replace(string-join(('Het element', $field, 'bij', $elementLocalName, $prGUID, 'moet aanwezig zijn.'), ' '), '  ', ' ')"/>
		<xsl:if test="count($otherContext/*[local-name()=$field])&gt;0">
			<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkFilled">
		<!-- function to check length of value -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="message" select="string-join(('Het element', $field, 'bij', $elementLocalName, $prGUID, 'moet gevuld zijn'), ' ')"/>
		<xsl:if test="count($context/*[local-name()=$field]) &gt;0">
			<xsl:if test="string-length(string($context/*[local-name()=$field])) = 0">
				<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
			</xsl:if>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkUnique">
		<!-- function to check uniqueness of value -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="searchContext"/>
		<xsl:param name="field"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="message" select="replace(string-join(('Waarde van het element', $field, 'bij', $elementLocalName, $prGUID, 'is niet uniek.'), ' '), '  ', ' ')"/>
		<xsl:variable name="value" select="string($context/*[local-name()=$field])"/>
		<xsl:if test="count($searchContext//*[local-name()=$field][text()=$value]) &gt;1">
			<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkDateBeforeDate">
		<!-- function to check date is less then or equal to specified date -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="date"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="messageBase" select="replace(string-join(( 'Datum in het element', $field, 'bij', $elementLocalName, $prGUID, 'ligt niet voor'), ' '), '  ', ' ')"/>
		<xsl:variable name="value" select="string($context/*[local-name()=$field])"/>
		<xsl:variable name="checkDate">
			<xsl:choose>
				<xsl:when test="$date='current'">
					<xsl:value-of select="number(format-date(current-date(), '[Y0001][M01][D01]'))"/>
				</xsl:when>
				<xsl:when test="contains($date,'-')">
					<xsl:copy-of select="number(replace($date,'-',''))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="number(replace(string($context/*[local-name()=$date]),'-',''))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="message">
			<xsl:choose>
				<xsl:when test="$date='current'">
					<xsl:value-of select="string-join(($messageBase,'heden.'),' ')"/>
				</xsl:when>
				<xsl:when test="contains($date,'-')">
					<xsl:value-of select="string-join(($messageBase,$date),' ')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="string-join(($messageBase,'datum', string($context/*[local-name()=$date]), 'in element',$date),' ')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="number(replace($value, '-', '')) &gt;$checkDate">
			<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkDateAfterDate">
		<!-- function to check date is greater then or equal to speficied date -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="date"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="message" select="replace(string-join(( 'Datum in het element', $field, 'bij', $elementLocalName, $prGUID, 'ligt niet na',string($date)), ' '), '  ', ' ')"/>
		<xsl:variable name="value" select="string($context/*[local-name()=$field])"/>
		<xsl:variable name="checkDate" select="number(replace($date,'-',''))"/>
		<xsl:if test="number(replace($value, '-', '')) &lt; $checkDate">
			<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkLength">
		<!-- function to check length of value -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="max"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="message" select="replace(string-join(( 'Lengte van de waarde in het element', $field, 'bij', $elementLocalName, $prGUID, 'is meer dan', string($max), 'karakters.'), ' '), '  ', ' ')"/>
		<xsl:if test="count($context/*[local-name()=$field]) &gt;0">
			<xsl:variable name="value" select="string($context/*[local-name()=$field])"/>
			<xsl:if test="string-length($value) &gt; $max">
				<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
			</xsl:if>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkExactLength">
		<!-- function to check exact length of value -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="length"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="message" select="replace(string-join(( 'Lengte van de waarde in het element', $field, 'bij', $elementLocalName, $prGUID, 'is niet gelijk aan', string($length), 'karakters.'), ' '), '  ', ' ')"/>
		<xsl:if test="count($context/*[local-name()=$field]) &gt;0">
			<xsl:variable name="value" select="string($context/*[local-name()=$field])"/>
			<xsl:if test="string-length($value) != $length">
				<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
			</xsl:if>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkNumberLength">
		<!-- function to check length of value with/without decimal -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="max"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="value" select="string($context/*[local-name()=$field])"/>
		<xsl:choose>
			<xsl:when test="contains($value, '.')">
				<xsl:copy-of select="sikb:checkLength($context, $prGUID, $field, $max + 1, $errorType)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="sikb:checkLength($context, $prGUID, $field, $max, $errorType)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="sikb:checkNumberLengthBeforeDecMark">
		<!-- function to check length of value before decimal mark -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="max"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="message" select="replace(string-join(( 'Lengte van de waarde in het element', $field, 'bij', $elementLocalName, $prGUID, 'is meer dan', string($max), 'karakters voor het decimaalteken.'), ' '), '  ', ' ')"/>
		<xsl:variable name="value" select="substring-before(string($context/*[local-name()=$field]),'.')"/>
		<xsl:if test="count($context/*[local-name()=$field]) &gt;0">
			<xsl:if test="string-length($value) &gt; $max">
				<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
			</xsl:if>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkLengthExact">
		<!-- function to check exact length of value -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="length"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="message" select="replace(string-join(( 'Lengte van de waarde in het element', $field, 'bij', $elementLocalName, $prGUID, 'is niet exact', string($length), 'karakters.'), ' '), '  ', ' ')"/>
		<xsl:if test="count($context/*[local-name()=$field]) &gt;0">
			<xsl:variable name="value" select="string($context/*[local-name()=$field])"/>
			<xsl:if test="string-length($value) != $length">
				<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
			</xsl:if>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkLookupId">
		<!-- function to check whether lookupID exists and status != 'Vervallen' -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="lookupItem"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="lookupValueFromElement" select="$context/*[local-name()=$field]/text()"/>
		<xsl:variable name="lookupValueFromHref" select="$context/*[local-name()=$field]/@xlink:href"/>
		<xsl:variable name="lookupValueFromPhysicalProperty" select="$context/*[local-name()='physicalProperty']/*[local-name()='PhysicalProperty']/*[local-name()=$field]/text()"/>
		<xsl:variable name="lookupValue">
			<xsl:choose>
				<xsl:when test="$lookupValueFromElement != ''">
					<xsl:value-of select="$lookupValueFromElement"/>
				</xsl:when>
				<xsl:when test="$lookupValueFromHref != ''">
					<xsl:value-of select="$lookupValueFromHref"/>
				</xsl:when>
				<xsl:when test="$lookupValueFromPhysicalProperty != ''">
					<xsl:value-of select="$lookupValueFromPhysicalProperty"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="lookupId" select="substring-after($lookupValue, ':id:')"/>
		<xsl:variable name="lookupType" select="substring-before(substring-after($lookupValue,'urn:'),':')"/>
		<xsl:variable name="lookupFile" select="sikb:getLookupFile($lookupType)"/>
		<xsl:variable name="lookupRecord" select="document($lookupFile)//*[@categorie=$lookupItem]/*[ID|id=$lookupId]"/>
		<xsl:variable name="checkLookupRecord">
			<!--			<xsl:choose>
				<xsl:when test="($lookupRecord != '' and $lookupRecord/@status = 'Vervallen')">
					<xsl:copy-of select="'vervallen'"/>
				</xsl:when>
				<xsl:when test="not($lookupRecord != '') and count($context/*[local-name()=$field]) &gt;0">
					<xsl:copy-of select="'niet gevonden'"/>
				</xsl:when>
			</xsl:choose>
-->
			<xsl:if test="($lookupRecord != '' and $lookupRecord/@status = 'Vervallen')">
			  <xsl:copy-of select="'vervallen'"/>
			</xsl:if>
			<xsl:if test="not($lookupRecord != '') and $lookupValue != ''">
			  <xsl:copy-of select="'niet gevonden'"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="message" select="replace(string-join(('Waarde', $lookupId, 'van het element', $field, 'bij', $elementLocalName, $prGUID, 'is', $checkLookupRecord, 'in lookup-tabel.'), ' '), '  ', ' ')"/>
		<xsl:if test="string-length($checkLookupRecord)!=0">
			<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:getLookupFile">
		<!-- Function to determin lookupFile -->
		<xsl:param name="lookupType"/>
		<xsl:choose>
			<xsl:when test="$lookupType='imsikb0101'">
				<xsl:copy-of select="$imsikb0101LookupFile"/>
			</xsl:when>
			<xsl:when test="$lookupType='immetingen'">
				<xsl:copy-of select="$immetingenLookupFile"/>
			</xsl:when>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="sikb:checkActivityYear">
		<!-- Function to check whether startTime or endTime of Activity has proper values -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="value" select="string($context/*[local-name()=$field])"/>
		<xsl:variable name="currentYear" select="year-from-date(current-date())"/>
		<xsl:variable name="messageBase" select="replace(string-join(('Waarde van het element', $field, 'bij', $elementLocalName, $prGUID, 'ligt niet tussen 1450 en huidig jaartal'), ' '), '  ', ' ')"/>
		<xsl:if test="not(number($value) &gt;=1450 and number($value) &lt;=$currentYear)">
			<xsl:choose>
				<xsl:when test="contains($field, 'end')">
					<xsl:if test="number($value) != 8888 and number($value) != 9999">
						<xsl:variable name="message" select="string-join(($messageBase, 'en is niet 8888 of 9999'), ' ')"/>
						<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
					</xsl:if>
				</xsl:when>
				<xsl:when test="number($value) != 9999">
					<xsl:variable name="message" select="string-join(($messageBase, 'en is niet 9999'), ' ')"/>
					<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkValueGreaterZero">
		<!-- Function to check if value is greater then zero (0) -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="value" select="string($context/*[local-name()=$field])"/>
		<xsl:variable name="message" select="replace(string-join(('Waarde van het element', $field, 'bij', $elementLocalName, $prGUID, 'moet groter zijn dan nul'), ' '), '  ', ' ')"/>
		<xsl:if test="count($context/*[local-name()=$field]) !=0">
			<xsl:if test="not(number($value) &gt;0)">
				<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
			</xsl:if>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkValueGreaterEqualZero">
		<!-- Function to check if value is greater then or equal to zero (0) -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="value" select="string($context/*[local-name()=$field])"/>
		<xsl:variable name="message" select="replace(string-join(('Waarde van het element', $field, 'bij', $elementLocalName, $prGUID, 'moet gelijk zijn aan of groter zijn dan nul'), ' '), '  ', ' ')"/>
		<xsl:if test="count($context/*[local-name()=$field]) !=0">
			<xsl:if test="not(number($value) &gt;=0)">
				<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
			</xsl:if>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkValueBetweenWithUnit">
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="min"/>
		<xsl:param name="max"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="lookupId" select="substring-after(string($context/*[local-name()=$field]/@uom),':id:')"/>
		<xsl:variable name="factor" select="document($immetingenLookupFile)//*[@categorie='Eenheid']/*[ID|id=$lookupId]/Omrekenfactor"/>
		<xsl:variable name="minFactor" select="$min*number($factor)"/>
		<xsl:variable name="maxFactor" select="$max*number($factor)"/>
		<xsl:copy-of select="sikb:checkValueBetween($context, $prGUID, $field, $minFactor, $maxFactor, $errorType)"/>
	</xsl:function>
	<xsl:function name="sikb:checkValueBetween">
		<!-- Function to check if value is between given min and max -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="min"/>
		<xsl:param name="max"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="message" select="replace(string-join(( 'Het element', $field, 'bij', $elementLocalName, $prGUID, 'moet een waarde tussen', string($min), 'en', string($max), 'hebben.'), ' '), '  ', ' ')"/>
		<xsl:if test="count($context/*[local-name()=$field]) &gt;0">
			<xsl:variable name="value">
				<xsl:choose>
					<xsl:when test="contains(string($context/*[local-name()=$field]),':id:')">
						<xsl:copy-of select="number(substring-after(string($context/*[local-name()=$field]),':id:'))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="number($context/*[local-name()=$field])"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="not($value &gt;= $min and $value &lt;= $max)">
				<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
			</xsl:if>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkSender">
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="errorType"/>
		<xsl:if test="(sikb:checkValueBetween($context, $prGUID, 'sender', 9999, 10111, $errorType))">
			<!-- Als waarde niet tussen 9999 en 10111 (waarden gebruikt voor test doeleinden) dan controle of waarde voorkomt in lookup-tabellen-->
			<xsl:copy-of select="sikb:checkLookupId($context, $prGUID, 'sender', 'Bronhouders', $errorType)"/>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkDependancyFields">
		<!-- Function to check if field depending on another field exists -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="checkField"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="message" select="replace(string-join(('Bij', $elementLocalName, $prGUID, 'is wel het element', $field, 'aanwezig maar het element', $checkField, 'ontbreekt.'), ' '), '  ', ' ')"/>
		<xsl:if test="count($context/*[local-name()=$field]) != 0 and count($context/*[local-name()=$checkField]) = 0">
			<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkDependancyFieldsConditional">
		<!-- Function to check if field depending on another field exists -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="condition"/>
		<xsl:param name="checkField"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="message" select="replace(string-join(('Het element', $checkField, 'bij', $elementLocalName, $prGUID, 'moet aanwezig zijn als het element', $field, 'waarde', $condition, 'heeft.'), ' '), '  ', ' ')"/>
		<xsl:if test="substring-after($context/*[local-name()=$field],':id:') = $condition and string-length(string($context/*[local-name()=$checkField])) = 0">
			<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkDependancyDecisionProject">
		<!-- Function to check if field depending on another field exists -->
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="decisionTypeValue"/>
		<xsl:param name="projectType"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="decisionTypeValue" select="document($imsikb0101LookupFile)//*[@categorie='Besluit']/*[id = $decisionTypeValue]/waarde"/>
		<xsl:variable name="projectTypeValue" select="document($imsikb0101LookupFile)//*[@categorie='OnderzoekType']/*[id = $projectType]/waarde"/>
		<xsl:variable name="dossierGmlId" select="$context/ancestor::imsikb0101:Dossier/@gml:id"/>
		<xsl:variable name="decisions" select="$context[imsikb0101:decisionType=string-join(('urn:imsikb0101:Besluit:id:',$decisionTypeValue),'')]"/>
		<xsl:variable name="projects" select="$context/ancestor::node()//imsikb0101:Project[imsikb0101:dossiers/@xlink:href=string-join(('#',$dossierGmlId),'') and imsikb0101:projectType=string-join(('urn:imsikb0101:OnderzoekType:id:',$projectType),'')]"/>
		<xsl:variable name="message" select="replace(string-join(($elementLocalName, $prGUID, 'betreft een', $decisionTypeValue, 'maar een Project van het type', $projectTypeValue, 'ontbreekt.'), ' '), '  ', ' ')"/>
		<xsl:if test="count($decisions)!=0 and count($projects)=0">
			<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
		</xsl:if>
	</xsl:function>
<xsl:function name="sikb:checkCoordinates">
		<!-- Function to check if coordinates are correct -->
		<xsl:param name="context" />
		<xsl:param name="prGUID" />
		<xsl:param name="errorType" />
		<xsl:variable name="elementName" select="string($context/name())" />
		<xsl:variable name="elementLocalName" select="string($context/local-name())" />
		<xsl:variable name="messageBase" select="string-join(('bij',$elementLocalName,$prGUID,'bevat niet een waarde tussen'), ' ')" />
		<xsl:for-each select="$context//gml:posList">
			<xsl:variable name="srsName" select="string(./ancestor-or-self::gml:*[@srsName][1]/@srsName)" />
			<xsl:variable name="bounds">
				<xsl:choose>
					<xsl:when test="$srsName = 'urn:ogc:def:crs:EPSG::28992'">
						X-Coordinaat 12000 282000 Y-Coordinaat 306000 620000
					</xsl:when>
					<xsl:when test="$srsName = 'urn:ogc:def:crs:EPSG::4326'">
						Y-Coordinaat 50.7262037562 53.5508232262 X-Coordinaat 3.36194787844 7.30338214307
					</xsl:when>
					<xsl:when test="$srsName = 'urn:ogc:def:crs:EPSG::4258'">
						Y-Coordinaat 50.7262037571 53.5508232271 X-Coordinaat 3.36194787844 7.30338214307
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="$bounds = ''">
				<xsl:variable name="message" select="string-join(('Coordinaten van', $elementLocalName, $prGUID, 'zijn uitgedrukt in ongeldig of onbekend coordinatenssysteem', $srsName), ' ')" />
				<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)" />
			</xsl:if>
			<xsl:if test="$bounds != ''">
				<xsl:variable name="firstName" select="tokenize(normalize-space($bounds), '\s')[1]" />
				<xsl:variable name="firstMin" select="number(tokenize(normalize-space($bounds), '\s')[2])" />
				<xsl:variable name="firstMax" select="number(tokenize(normalize-space($bounds), '\s')[3])" />
				<xsl:variable name="secondName" select="tokenize(normalize-space($bounds), '\s')[4]" />
				<xsl:variable name="secondMin" select="number(tokenize(normalize-space($bounds), '\s')[5])" />
				<xsl:variable name="secondMax" select="number(tokenize(normalize-space($bounds), '\s')[6])" />
				<xsl:variable name="posListValues" select="tokenize(string(.), '\s')" />
				<xsl:for-each select="$posListValues">
					<xsl:if test="position() mod 2=1">
						<!-- Check if position is odd to determin x-coördinate -->
						<xsl:if test="not(number(string(.)) &gt; $firstMin and number(string(.)) &lt; $firstMax)">
							<xsl:variable name="message" select="string-join(($firstName, string-join(('(', string(.), ')'), ''), $messageBase, string($firstMin), 'en', string($firstMax)), ' ')" />
							<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)" />
						</xsl:if>
					</xsl:if>
					<xsl:if test="not(position() mod 2=1)">
						<!-- Check if position is even to determin y-coördinate -->
						<xsl:if test="not(number(string(.)) &gt; $secondMin and number(string(.)) &lt; $secondMax)">
							<xsl:variable name="message" select="string-join(($secondName, string-join(('(', string(.), ')'), ''), $messageBase, string($secondMin), 'en', string($secondMax)), ' ')" />
							<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)" />
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</xsl:for-each>
	</xsl:function>
	<xsl:function name="sikb:checkRiskOthers">
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="searchContext"/>
		<xsl:param name="searchNode"/>
		<xsl:param name="searchField"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="parentGUID" select="$context/../../@gml:id"/>
		<xsl:variable name="parentLocalName" select="string($context/../../local-name())"/>
		<xsl:variable name="riskTypeValue" select="substring-after($context//imsikb0101:riskType,':id:')"/>
		<xsl:variable name="message" select="string-join(('Het element riskType bij', $elementLocalName, $prGUID, 'heeft waarde', $riskTypeValue, 'maar een waarde in het element', $searchField, 'van', $searchNode, 'bij', $parentLocalName, $parentGUID, 'ontbreekt.'), ' ')"/>
		<xsl:if test="contains('|1|2|3|',concat('|',$riskTypeValue,'|')) and not($searchContext//*[local-name()=$searchField])">
			<xsl:copy-of select="sikb:createRecord($errorType, $elementLocalName, $message)"/>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkDecisionProjectGt7">
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="parentGUID" select="$context/../../@gml:id"/>
		<xsl:variable name="parentLocalName" select="string($context/../../local-name())"/>
		<xsl:if test="string-length($context/imsikb0101:decisionType)&gt;0">
			<xsl:variable name="decisionTypeValue" select="number(substring-after($context/imsikb0101:decisionType,':id:'))"/>
			<xsl:variable name="message" select="string-join(($elementLocalName, $prGUID, 'heeft decisionTypeValue', string($decisionTypeValue), 'dan moet aan', $parentLocalName, $parentGUID, 'een Project met projectType 7 of hoger gekoppeld zijn.'),' ')"/>
			<xsl:if test="(($decisionTypeValue &gt;= 26 and $decisionTypeValue &lt;= 30) or $decisionTypeValue=56 or $decisionTypeValue=64 or $decisionTypeValue=65 or $decisionTypeValue=66 or $decisionTypeValue=69 or $decisionTypeValue=70)">
				<xsl:for-each select="root($context)//imsikb0101:Project/imsikb0101:dossiers[@xlink:href=string-join(('#',$parentGUID),'')]/..">
					<xsl:sort select="substring-after(./imsikb0101:projectType,':id:')" data-type="number"/>
					<xsl:if test="position()=last() and number(substring-after(./imsikb0101:projectType,':id:')) &lt;7">
						<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkFormatDossierIdLocalAuthority">
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="dossierIdLocalAuthorityValue" select="string($context/imsikb0101:dossierIdLocalAuthority)"/>
		<xsl:variable name="checkFormatCodeLocalAuthority" select="matches(substring($dossierIdLocalAuthorityValue,1,2),'[A-Z]{2}')"/>
		<xsl:variable name="checkFormatDistrictCode" select="matches(substring($dossierIdLocalAuthorityValue,3,4),'[0-9]{4}')"/>
		<xsl:variable name="checkFormatUniqueNumber" select="matches(substring($dossierIdLocalAuthorityValue,7,5),'[0-9]{5}')"/>
		<xsl:variable name="message" select="string-join(('De waarde van het element dossierIdLocalAuthority bij', $elementLocalName, $prGUID, 'heeft niet de opmaak code bevoegde overheid (2 letters) + geografische aanduiding (4) (gem_code) + uniek volgnummer binnen beheersgebied (5)'), ' ')"/>
		<xsl:if test="count($context/imsikb0101:dossierIdLocalAuthority) &gt;0">
			<xsl:if test="not($checkFormatCodeLocalAuthority and $checkFormatDistrictCode and $checkFormatUniqueNumber)">
				<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
			</xsl:if>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkDependancyProjectSubElements">
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="condition"/>
		<xsl:param name="searchElement"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="message" select="replace(string-join(('Bij',string($context/local-name()), $prGUID, 'moet een', $searchElement, 'zijn opgenomen.'), ' '), '  ', ' ')"/>
		<xsl:if test="not($context/*[local-name()=$searchElement]) and contains($condition,concat('|',substring-after($context//*[local-name()=$field],':id:'),'|'))">
			<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkSourceSystem">
		<xsl:param name="context"/>
		<xsl:param name="SourceSystems"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="bronhouder" select="string($context)"/>
		<xsl:variable name="message" select="replace(string-join(('Bij',string($context/local-name()), $bronhouder, 'moet als SourceSystem zijn opgenomen.'), ' '), '  ', ' ')"/>
		<xsl:variable name="SourceSystem" select="$SourceSystems/imsikb0101:SourceSystem[imsikb0101:organisation = $bronhouder]"/>
		<xsl:if test="count($SourceSystem) &lt; 1">
			<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkGeometryElement">
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="elementType"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="message" select="replace(string-join(('Geometry bij',$elementLocalName,$prGUID,'moet een',$elementType,'zijn, geen andere types zijn toegestaan. Let op, dat de srsName het juiste coordinaten stelsel heeft, in de vorm van een URN.'), ' '), '  ',' ')"/>
		<xsl:if test="count($context/*[local-name()='geometry']) &gt;0">
			<xsl:if test="name($context/*[local-name()='geometry']/element()) != '' and name($context/*[local-name()='geometry']/element()) != $elementType">
				<xsl:copy-of select="sikb:createRecord($errorType,$elementName,$message)"/>
			</xsl:if>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkGeometryElements">
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="elementType1"/>
		<xsl:param name="elementType2"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="message" select="replace(string-join(('Geometry bij',$elementLocalName,$prGUID,'moet een',$elementType1,'of een',$elementType2,'zijn, andere types zijn niet toegestaan. Let op, dat de srsName het juiste coordinaten stelsel heeft, in de vorm van een URN.'), ' '), '  ',' ')"/>
		<xsl:if test="count($context/*[local-name()='geometry']) &gt;0">
			<xsl:if test="name($context/*[local-name()='geometry']/element()) != '' and name($context/*[local-name()='geometry']/element()) != $elementType1 and name($context/*[local-name()='geometry']/element()) != $elementType2">
				<xsl:copy-of select="sikb:createRecord($errorType,$elementName,$message)"/>
			</xsl:if>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkSamplingFeatureRelation">
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="id"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="attrValue" select="string-join(('urn:immetingen:RelatedSamplingFeatureRollen:id:', $id), '')"/>
		<xsl:variable name="message" select="replace(string-join(('Het element', $field, 'bij', $elementLocalName, $prGUID, 'moet role met id', $id, 'hebben.'), ' '), '  ', ' ')"/>
		<xsl:variable name="hasId" select="$context/sam:relatedSamplingFeature/sam:SamplingFeatureComplex/sam:role[@xlink:href = $attrValue]"/>
		<xsl:if test="count($hasId) = 0">
			<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
		</xsl:if>
	</xsl:function>
	<xsl:function name="sikb:checkEenheidId">
		<xsl:param name="context"/>
		<xsl:param name="prGUID"/>
		<xsl:param name="field"/>
		<xsl:param name="eenheidId"/>
		<xsl:param name="errorType"/>
		<xsl:variable name="checkEenheidId" select="concat('urn:immetingen:Eenheid:id:', $eenheidId)"/>
		<xsl:variable name="elementName" select="string($context/name())"/>
		<xsl:variable name="elementLocalName" select="string($context/local-name())"/>
		<xsl:variable name="message" select="replace(string-join(('Het element', $field, 'bij', $elementLocalName, $prGUID, 'moet uom Eenheid:id', $eenheidId, ' hebben.'), ' '), '  ', ' ')"/>
		<xsl:if test="not(lower-case(string($context/*[local-name()=$field]/@uom)) = lower-case($checkEenheidId))">
			<xsl:copy-of select="sikb:createRecord($errorType, $elementName, $message)"/>
		</xsl:if>
	</xsl:function>
</xsl:stylesheet>
