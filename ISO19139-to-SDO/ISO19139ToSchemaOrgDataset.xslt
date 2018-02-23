<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:gmi="http://www.isotc211.org/2005/gmi" xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
    xmlns:gml="http://www.opengis.net/gml" xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="xs" version="1.0">

    <!-- 
  xsl transform to map content from ISO19139 XML formats to 
  Schema.org JSON-LD for @type=Dataset. The design uses a set of 
  xsl variables and templates to do the mapping from the xml document
  to the appropriate JSON-LD content. 
 The template includes root element xpath for ISO19139.
    
    Preliminar version for test and review
  Stephen M. Richard
    2018-02-22
 -->

    <xsl:output method="text" indent="yes" encoding="UTF-8"/>
    <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

    <xsl:template match="gmd:CI_ResponsibleParty">
        <xsl:param name="role"/>

        <!-- input is a gmd:CI_ResponsibleParty element; should be filtered for role = -->
        <!-- because of silly way that schema.org is handling roles, have to pass in the name
        of the sdo element that contains this role because it gets repeated inside the content-->
        <!-- returns JSON array of schema.org Role objects -->

        <xsl:variable name="agentID">
            <xsl:if test="@xlink:href">
                <xsl:value-of select="@xlink:href"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="personName">
            <xsl:if test="string-length(gmd:individualName/gco:CharacterString) > 0">
                <xsl:value-of
                    select="normalize-space(string(gmd:individualName/gco:CharacterString))"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="organisationName">
            <xsl:if test="string-length(gmd:organisationName/gco:CharacterString) > 0">
                <xsl:value-of
                    select="normalize-space(string(gmd:organisationName/gco:CharacterString))"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="agentRole">
            <xsl:if test="string-length(normalize-space(gmd:positionName/gco:CharacterString)) > 0">
                <xsl:value-of select="normalize-space(string(gmd:positionName/gco:CharacterString))"/>
                <xsl:text>; </xsl:text>
            </xsl:if>
            <xsl:if test="string-length(gmd:role/gmd:CI_RoleCode/@codeListValue) > 0">
                <xsl:value-of select="string(gmd:role/gmd:CI_RoleCode/@codeListValue)"/>
            </xsl:if>
            <xsl:if
                test="
                    string-length(gmd:role/gmd:CI_RoleCode/text()) > 0 and
                    (translate(normalize-space(gmd:role/gmd:CI_RoleCode/text()), $uppercase, $smallcase) != normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue))">
                <xsl:text>; </xsl:text>
                <xsl:value-of select="normalize-space(gmd:role/gmd:CI_RoleCode/text())"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="agentemail">
            <xsl:if test="count(gmd:contactInfo//gmd:electronicMailAddress/gco:CharacterString) > 0"
                > [ </xsl:if>
            <xsl:for-each select="gmd:contactInfo//gmd:electronicMailAddress">
                <xsl:if test="string-length(gco:CharacterString) > 0">
                    <xsl:text>"</xsl:text>
                    <xsl:value-of select="normalize-space(string(.))"/>
                    <xsl:text>"</xsl:text>
                    <xsl:if test="following-sibling::gmd:electronicMailAddress">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
            <xsl:if test="count(gmd:contactInfo//gmd:electronicMailAddress/gco:CharacterString) > 0"
                > ] </xsl:if>
        </xsl:variable>


        <xsl:text>{&#10;    "@type":"Role",&#10;</xsl:text>
        <xsl:text>      "roleName": "</xsl:text>
        <xsl:value-of select="string($agentRole)"/>
        <xsl:text>",&#10;</xsl:text>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="string($role)"/>
        <xsl:text>": {&#10;</xsl:text>

        <xsl:choose>
            <xsl:when test="string-length($personName) > 0 and string-length($organisationName) = 0">
                <xsl:text>    "@type":"Person",&#10;      "additionalType": "geolink:Person",&#10;</xsl:text>
                <xsl:if test="string-length($agentID) > 0">
                    <xsl:text>      "@id": "</xsl:text>
                    <xsl:value-of select="string($agentID)"/>
                    <xsl:text>",&#10;</xsl:text>
                </xsl:if>
                <xsl:text>      "name": "</xsl:text>
                <xsl:value-of select="string($personName)"/>
                <xsl:text>"</xsl:text>
                <!-- email address -->
                <xsl:if test="string-length($agentemail) > 0">
                    <xsl:text>,&#10;      "email": </xsl:text>
                    <xsl:value-of select="normalize-space(string($agentemail))"/>
                </xsl:if>
                <xsl:text>&#10;      }</xsl:text>

            </xsl:when>
            <xsl:when test="string-length($organisationName) > 0 and string-length($personName) = 0">
                <xsl:text>&#10;  "@type":"Organization",&#10;</xsl:text>
                <xsl:if test="string-length($agentID) > 0">
                    <xsl:text>      "@id": "</xsl:text>
                    <xsl:value-of select="string($agentID)"/>
                    <xsl:text>",&#10;</xsl:text>
                </xsl:if>
                <xsl:text>      "name": "</xsl:text>
                <xsl:value-of select="string($organisationName)"/>
                <xsl:text>"</xsl:text>
                <!-- email address -->
                <xsl:if test="string-length($agentemail) > 0">
                    <xsl:text>,&#10;      "email": </xsl:text>
                    <xsl:value-of select="normalize-space(string($agentemail))"/>
                </xsl:if>
                <xsl:text>&#10;      }</xsl:text>

            </xsl:when>
            <xsl:when test="string-length($organisationName) > 0 and string-length($personName) > 0">
                <xsl:text>&#10;  "@type":"Person",&#10;</xsl:text>
                <xsl:if test="string-length($agentID) > 0">
                    <xsl:text>      "@id": "</xsl:text>
                    <xsl:value-of select="string($agentID)"/>
                    <xsl:text>",&#10;</xsl:text>
                </xsl:if>
                <xsl:text>      "name": "</xsl:text>
                <xsl:value-of select="string($personName)"/>
                <xsl:text>"</xsl:text>
                <!-- email address -->
                <xsl:if test="string-length($agentemail) > 0">
                    <xsl:text>,&#10;      "email": </xsl:text>
                    <xsl:value-of select="normalize-space(string($agentemail))"/>
                </xsl:if>
                <xsl:text>,&#10;     "affiliation": {&#10;</xsl:text>
                <xsl:text>&#10;  "@type":"Organization",&#10;</xsl:text>
                <xsl:text>      "name": "</xsl:text>
                <xsl:value-of select="string($organisationName)"/>
                <xsl:text>"}&#10;      }</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#10;  "@type": "Role",&#10;</xsl:text>
                <xsl:text>      "roleName": "</xsl:text>
                <xsl:value-of select="string($agentRole)"/>
                <xsl:text>"&#10;</xsl:text>
                <xsl:text>}&#10;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template name="distributions">
        <!-- this template generates content for a DataDownload element -->
        <xsl:param name="por"/>
        <!-- CI_OnlineResource -->
        <xsl:param name="pfor"/>
        <!-- MD_Format -->
        <xsl:param name="prp"/>
        <!-- CI_ResponsibleParty -->
        <!--distributorContacts map to provider. 
            Formats to fileFormat,
        CI_onlineResurce.linkage.URL to URL, except if the CI_OnLineFunctionCode is 'download' then it maps to contentURL. -->
        <xsl:variable name="accessURL" select="$por/gmd:linkage/gmd:URL"/>
        <xsl:variable name="distFormat">
            <xsl:if test="count($pfor/gmd:name) > 1">
                <xsl:text>[&#10;</xsl:text>
            </xsl:if>
            <xsl:for-each select="$pfor/gmd:name">
                <xsl:text>"</xsl:text>
                <xsl:if test="string-length(normalize-space(child::node()/text())) > 0">
                    <xsl:value-of select="normalize-space(child::node()/text())"/>
                </xsl:if>
                <xsl:if
                    test="string-length(following-sibling::gmd:version/child::node()/text()) > 0">
                    <xsl:value-of
                        select="concat(' v.', normalize-space(following-sibling::gmd:version/child::node()/text()))"
                    />
                </xsl:if>
                <xsl:if
                    test="string-length(following-sibling::gmd:amendmentNumber/child::node()/text()) > 0">
                    <xsl:value-of
                        select="concat(' amendment:', normalize-space(following-sibling::gmd:amendmentNumber/child::node()/text()))"
                    />
                </xsl:if>
                <xsl:text>"</xsl:text>

                <!-- comma if there are more formats -->
                <xsl:if
                    test="parent::node()/parent::node()/following-sibling::node()/child::gmd:MD_Format/gmd:name"
                    >, </xsl:if>
            </xsl:for-each>

            <xsl:if test="count($pfor/gmd:name) > 1">
                <xsl:text>]</xsl:text>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="distPublishDate" select="''"/>
        <xsl:variable name="distIdentifier" select="$por/gmd:linkage/gmd:URL"/>
        <xsl:variable name="distProvider">
            <xsl:if test="count($prp/gmd:role) > 1">
                <xsl:text>[&#10;</xsl:text>
            </xsl:if>
            <xsl:for-each select="$prp/self::node()">
                <xsl:apply-templates select=".">
                    <xsl:with-param name="role" select="'provider'"/>
                </xsl:apply-templates>
                <xsl:if
                    test="not($por/ancestor::gmd:distributorTransferOptions) and ancestor::gmd:distributor/following-sibling::gmd:distributor//gmd:CI_ResponsibleParty">
                    <xsl:text>,&#10;</xsl:text>
                </xsl:if>
            </xsl:for-each>

            <xsl:if test="count($prp/gmd:role) > 1">
                <xsl:text>]</xsl:text>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="distName" select="$por/gmd:name/gco:CharacterString"/>
        <xsl:variable name="distSize"
            select="
                concat($por/parent::node()/preceding-sibling::gmd:transferSize/gco:Real, ' ',
                normalize-space($por/parent::node()/preceding-sibling::gmd:unitsOfDistribution/gco:CharacterString))"/>
        <xsl:variable name="distDescription">
            <!-- gather other useful content from the CI_OnlineResource element -->
            <xsl:text>"</xsl:text>
            <xsl:if
                test="string-length(normalize-space($por/gmd:description/gco:CharacterString)) > 0">
                <xsl:value-of select="normalize-space($por/gmd:description/gco:CharacterString)"/>
                <xsl:text>.   </xsl:text>
            </xsl:if>
            <xsl:if test="string-length(normalize-space($por/gmd:protocol/gco:CharacterString)) > 0">
                <xsl:text>Service Protocol: </xsl:text>
                <xsl:value-of select="normalize-space($por/gmd:description/gco:CharacterString)"/>
                <xsl:text>.   </xsl:text>
            </xsl:if>
            <xsl:if
                test="string-length(normalize-space($por/gmd:applicationProfile/gco:CharacterString)) > 0">
                <xsl:text>Application Profile: </xsl:text>
                <xsl:value-of
                    select="normalize-space($por/gmd:applicationProfile/gco:CharacterString)"/>
                <xsl:text>.   </xsl:text>
            </xsl:if>
            <xsl:if test="string-length(normalize-space($por/gmd:function//@codeListValue)) > 0">
                <xsl:text>Link Function: </xsl:text>
                <xsl:value-of select="normalize-space($por/gmd:function//@codeListValue)"/>
            </xsl:if>
            <xsl:if
                test="string-length(normalize-space($por/gmd:function/child::node()/text())) > 0
                and (normalize-space($por/gmd:function/child::node()/text()) != normalize-space($por/gmd:function//@codeListValue))">
                <xsl:text>--   </xsl:text>
                <xsl:value-of select="normalize-space($por/gmd:function/child::node()/text())"/>
                <xsl:text>.   </xsl:text>
            </xsl:if>
            <xsl:text>"</xsl:text>
        </xsl:variable>

        <xsl:text>{&#10;</xsl:text>

        <xsl:if test="$distIdentifier">
            <xsl:text>      "@id": "</xsl:text>
            <xsl:value-of select="$distIdentifier"/>
            <xsl:text>",&#10;</xsl:text>
        </xsl:if>

        <xsl:text>    "@type": "DataDownload",&#10;    "additionalType": "dcat:distribution",&#10;</xsl:text>

        <xsl:text>      "dcat:accessURL": "</xsl:text>
        <xsl:value-of select="$accessURL"/>
        <xsl:text>",&#10;</xsl:text>

        <xsl:text>      "url": "</xsl:text>
        <xsl:value-of select="$accessURL"/>
        <xsl:text>"</xsl:text>

        <xsl:if test="string-length($distName) > 0">
            <xsl:text>,&#10;      "name": "</xsl:text>
            <xsl:value-of select="$distName"/>
            <xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:if test="string-length($distDescription) > 0">
            <xsl:text>,&#10;      "description": </xsl:text>
            <xsl:value-of select="$distDescription"/>
        </xsl:if>

        <xsl:if test="string-length(string($distProvider)) > 0">
            <xsl:text>,&#10;      "provider": </xsl:text>
            <xsl:value-of select="$distProvider"/>
        </xsl:if>


        <xsl:if test="string-length($distFormat) > 0">
            <xsl:text>,&#10;      "fileFormat": </xsl:text>
            <xsl:value-of select="$distFormat"/>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($distSize)) > 0">
            <xsl:text>,&#10;      "contentSize": "</xsl:text>
            <xsl:value-of select="$distSize"/>
            <xsl:text>"</xsl:text>
        </xsl:if>

        <xsl:if test="string-length($distPublishDate) > 0">
            <xsl:text>,&#10;      "datePublished": "</xsl:text>
            <xsl:value-of select="$distPublishDate"/>
            <xsl:text>"</xsl:text>
        </xsl:if>

        <!-- more content might be available; insert here -->

        <xsl:text>}&#10;</xsl:text>

    </xsl:template>

    <xsl:template match="gmd:geographicElement">
        <!-- geographicElement can be boundingBox, 'polygon' which can have any geometry, or 
        geographicDescription, which means there is a place identifier code
        for now only handle point geometry in gmd:polygon element, other options get too complicated-->
        <!-- returns JSON-LD Schema.org Place -->

        <xsl:variable name="CRSvalue" select="''"/>
        <xsl:variable name="placeName" select="*//gmd:geographicIdentifier//gmd:code"/>
        <xsl:variable name="geoShapeBox">
            <xsl:if test="gmd:EX_GeographicBoundingBox">
                <xsl:value-of
                    select="gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal/text()"/>
                <xsl:text>, </xsl:text>
                <xsl:value-of
                    select="gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal/text()"/>
                <xsl:text> </xsl:text>
                <xsl:value-of
                    select="gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal/text()"/>
                <xsl:text>, </xsl:text>
                <xsl:value-of
                    select="gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal/text()"
                />
            </xsl:if>
        </xsl:variable>
        <!-- gml representation of polygons too complex to deal with; not used much in metadata -->
        <xsl:variable name="geoShapePolygon"/>
        <xsl:variable name="geoPoint">
            <!-- schema.org geoShape does not include a point element -->
            <xsl:if test="*//gmd:polygon/gml:Point/gml:coordinates">
                <xsl:text>      "longitude":"</xsl:text>
                <xsl:value-of
                    select="substring-after(string(//gmd:polygon/gml:Point/gml:coordinates), ' ')"/>
                <xsl:text>",&#10;</xsl:text>
                <xsl:text>      "latitude":"</xsl:text>
                <xsl:value-of
                    select="substring-before(string(//gmd:polygon/gml:Point/gml:coordinates), ' ')"/>
                <xsl:text>"</xsl:text>
            </xsl:if>
        </xsl:variable>

        <xsl:if test="string-length(concat($placeName, $geoPoint, $geoShapeBox)) > 0">
            <xsl:text>{&#10;</xsl:text>
            <xsl:text>"@type": "Place",&#10;</xsl:text>
            <!-- if the Spatial referenc system is available... -->
            <xsl:if test="$CRSvalue">
                <xsl:text>     "additionalProperty": [{&#10;
            "@type": "PropertyValue",&#10;
            "alternateName": "CRS",&#10;
            "name": "Coordinate Reference System", &#10;</xsl:text>
                <xsl:text>"value": "</xsl:text>
                <xsl:value-of select="$CRSvalue"/>
                <xsl:text>"&#10;}],&#10;</xsl:text>
            </xsl:if>
            <!-- if there's a place name  -->
            <xsl:if test="string-length($placeName) > 0">
                <xsl:text>      "name": "</xsl:text>
                <xsl:value-of select="normalize-space($placeName)"/>
                <xsl:text>"</xsl:text>
            </xsl:if>
            <xsl:if
                test="
                    (string-length($geoPoint) + string-length($geoShapeBox) > 0) and
                    string-length($placeName) > 0">
                <xsl:text>,&#10;</xsl:text>
            </xsl:if>
            <!-- if there are coordinates... -->
            <xsl:if test="string-length($geoPoint) + string-length($geoShapeBox) > 0">
                <xsl:text>      "geo":{&#10;</xsl:text>
                <xsl:if test="string-length(string($geoShapeBox)) > 0">
                    <xsl:text> 			"@type": "GeoShape",&#10;</xsl:text>
                    <xsl:text>      "box": "</xsl:text>
                    <xsl:value-of select="$geoShapeBox"/>
                    <xsl:text>"&#10;</xsl:text>
                </xsl:if>

                <xsl:if test="string-length($geoPoint) > 0">
                    <xsl:text> 			"@type": "GeoCoordinates",&#10;</xsl:text>
                    <xsl:text>      </xsl:text>
                    <xsl:value-of select="$geoPoint"/>
                </xsl:if>
                <xsl:text>}&#10;</xsl:text>
            </xsl:if>
            <!-- more content might be available; insert here -->
            <xsl:text>}&#10;</xsl:text>
        </xsl:if>

    </xsl:template>

    <xsl:template name="variableMeasured">
        <xsl:param name="variableList"/>
        <!-- returns JSON array of schema.org Person objects -->

        <xsl:text>[</xsl:text>
        <xsl:for-each select="$variableList/child::node()">
            <!-- handle each person in the list -->
            <xsl:variable name="variableID" select="'variableID'"/>
            <xsl:variable name="varDescription" select="'distFormat'"/>
            <xsl:variable name="varUnitsText" select="'distPublishDate'"/>
            <xsl:variable name="varURL" select="'distIdentifier'"/>
            <xsl:variable name="varName" select="'distIdentifier'"/>
            <xsl:variable name="varValue" select="'distIdentifier'"/>

            <xsl:text>{&#10;</xsl:text>

            <xsl:if test="$variableID">
                <xsl:text>      "@id": "</xsl:text>
                <xsl:value-of select="$variableID"/>
                <xsl:text>",&#10;</xsl:text>
            </xsl:if>

            <xsl:text>    "@type": "PropertyValue",&#10;    "additionalType": "earthcollab:Parameter",&#10;</xsl:text>

            <xsl:if test="$varDescription">
                <xsl:text>      "description": "</xsl:text>
                <xsl:value-of select="$varDescription"/>
                <xsl:text>",&#10;</xsl:text>
            </xsl:if>

            <xsl:text>      "unitText": "</xsl:text>
            <xsl:value-of select="$varUnitsText"/>
            <xsl:text>",&#10;</xsl:text>

            <xsl:if test="$varURL">
                <xsl:text>      "url": "</xsl:text>
                <xsl:value-of select="$varURL"/>
                <xsl:text>",&#10;</xsl:text>
            </xsl:if>

            <xsl:if test="$varValue">
                <xsl:text>      "value": "</xsl:text>
                <xsl:value-of select="$varValue"/>
                <xsl:text>"&#10;</xsl:text>
            </xsl:if>

            <!-- more content might be available; insert here -->

            <xsl:text>}&#10;</xsl:text>
        </xsl:for-each>

        <xsl:text>],&#10;</xsl:text>
    </xsl:template>


    <!--############################################################-->
    <!--## Template to replace strings                           ##-->
    <!--############################################################-->
    <!-- template from https://stackoverflow.com/questions/3067113/xslt-string-replace/3067130 -->
    <xsl:template name="string-replace-all">
        <xsl:param name="text"/>
        <xsl:param name="replace"/>
        <xsl:param name="by"/>
        <xsl:choose>
            <xsl:when test="$text = '' or $replace = '' or not($replace)">
                <!-- Prevent this routine from hanging -->
                <xsl:value-of select="$text"/>
            </xsl:when>
            <xsl:when test="contains($text, $replace)">
                <xsl:value-of select="substring-before($text, $replace)"/>
                <xsl:value-of select="$by"/>
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text" select="substring-after($text, $replace)"/>
                    <xsl:with-param name="replace" select="$replace"/>
                    <xsl:with-param name="by" select="$by"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="//gmd:MD_Metadata | gmi:MI_Metadata">
        <!-- Define variables for content elements -->
        <xsl:variable name="additionalContexts">
            <xsl:text>"datacite": "http://purl.org/spar/datacite/",
                "earthcollab": "https://library.ucar.edu/earthcollab/schema#",
                "geolink": "http://schema.geolink.org/1.0/base/main#",
                "vivo": "http://vivoweb.org/ontology/core#",
                "dcat":"http://www.w3.org/ns/dcat#"&#10;
                </xsl:text>
        </xsl:variable>
        <xsl:variable name="datasetURI">
            <!-- single unique identifier string for @id property -->
            <xsl:choose>
                <!-- if there's a datasetURI (apiso only...) use that -->
                <xsl:when
                    test="string-length(normalize-space(//gmd:dataSetURI/gco:CharacterString)) > 0">
                    <xsl:value-of select="normalize-space(//gmd:dataSetURI/gco:CharacterString)"/>
                </xsl:when>
                <!-- then look for identifier in citation section -->
                <xsl:when test="//gmd:citation//gmd:identifier">
                    <xsl:choose>
                        <!-- if an http URI is provided as a citation identifier, use that (take the first if there is > 1) -->
                        <xsl:when
                            test="
                                starts-with(//gmd:citation//gmd:identifier//gmd:code/gco:CharacterString, 'http') or
                                starts-with(//gmd:citation//gmd:identifier//gmd:code/gco:CharacterString, 'HTTP')">
                            <xsl:value-of
                                select="normalize-space((//gmd:citation//gmd:identifier//gmd:code[starts-with(translate(gco:CharacterString, 'HTTP', 'http'), 'http')]/gco:CharacterString)[1])"
                            />
                        </xsl:when>
                        <xsl:when
                            test="starts-with(//gmd:citation//gmd:identifier//gmd:code/gco:CharacterString, 'DOI:')">
                            <xsl:variable name="id1">
                                <xsl:value-of
                                    select="(//gmd:citation//gmd:identifier//gmd:code[starts-with(gco:CharacterString, 'DOI:')]/gco:CharacterString)[1]"
                                />
                            </xsl:variable>
                            <xsl:value-of
                                select="concat(string('http://doi.org/'), normalize-space(substring-after($id1, 'DOI:')))"
                            />
                        </xsl:when>
                        <xsl:when
                            test="starts-with(//gmd:citation//gmd:identifier//gmd:code/gco:CharacterString, 'doi:')">
                            <!-- identifier is a doi (lower-case prefix), not as an HTTP URI -->
                            <xsl:variable name="id2">
                                <xsl:value-of
                                    select="(//gmd:citation//gmd:identifier//gmd:code[starts-with(gco:CharacterString, 'doi:')]/gco:CharacterString)[1]"
                                />
                            </xsl:variable>
                            <xsl:value-of
                                select="concat(string('http://doi.org/'), normalize-space(substring-after($id2, 'doi:')))"
                            />
                        </xsl:when>
                        <xsl:when
                            test="
                                contains(//gmd:citation//gmd:identifier//gmd:codespace/gco:CharacterString, 'DOI') or
                                contains(//gmd:citation//gmd:identifier//gmd:codespace/gco:CharacterString, 'doi')">
                            <!-- get the code that goes with the codespace -->
                            <xsl:variable name="part2">
                                <xsl:value-of
                                    select="(//gmd:citation//gmd:identifier//gmd:codeSpace[contains(translate(gco:CharacterString, 'DOI', 'doi'), 'doi')])[1]/preceding-sibling::gmd:code/gco:CharacterString"
                                />
                            </xsl:variable>
                            <!-- if code has doi: prefix strip it off -->
                            <xsl:variable name="part3">
                                <xsl:choose>
                                    <xsl:when test="starts-with($part2, 'DOI:')">
                                        <xsl:value-of select="substring-after($part2, 'DOI:')"/>
                                    </xsl:when>
                                    <xsl:when test="starts-with($part2, 'doi:')">
                                        <xsl:value-of select="substring-after($part2, 'doi:')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="normalize-space($part2)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:value-of select="concat(string('http://doi.org/'), $part3)"/>
                        </xsl:when>
                        <xsl:when
                            test="
                                starts-with(//gmd:citation//gmd:identifier//gmd:codespace/gco:CharacterString, 'http') or
                                starts-with(//gmd:citation//gmd:identifier//gmd:codespace/gco:CharacterString, 'HTTP')">
                            <xsl:variable name="part4">
                                <xsl:value-of
                                    select="(//gmd:citation//gmd:identifier//gmd:codeSpace[starts-with(translate(gco:CharacterString, 'HTTP', 'http'), 'http')])[1]/gco:CharacterString"
                                />
                            </xsl:variable>
                            <xsl:variable name="part5">
                                <xsl:value-of
                                    select="(//gmd:citation//gmd:identifier//gmd:codeSpace[starts-with(translate(gco:CharacterString, 'HTTP', 'http'), 'http')])[1]/preceding-sibling::gmd:code/gco:CharacterString"
                                />
                            </xsl:variable>
                            <!-- construct http uri from codespace and code -->
                            <xsl:choose>
                                <xsl:when test="substring($part4, string-length($part4)) = '/'">
                                    <!-- tests the last character of the string -->
                                    <xsl:value-of select="concat($part4, $part5)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat($part4, '/', $part5)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- concatenate the first codespace and code -->
                            <xsl:variable name="part6">
                                <xsl:value-of
                                    select="(//gmd:citation//gmd:identifier)[1]//gmd:codeSpace/gco:CharacterString"
                                />
                            </xsl:variable>
                            <xsl:variable name="part7">
                                <xsl:value-of
                                    select="(//gmd:citation//gmd:identifier[1])//gmd:code/gco:CharacterString"
                                />
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="string-length($part6) > 0">
                                    <xsl:value-of select="concat($part6, '::', $part7)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$part7"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="string-length(//gmd:fileIdentifier/gco:CharacterString) > 0">
                    <!-- take the fileIdentifier -->
                    <xsl:value-of select="//gmd:fileIdentifier/gco:CharacterString"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- use the title... -->
                    <xsl:value-of
                        select="translate(//gmd:citation//gmd:title/gco:CharacterString, ' ', '')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="datasetIdentifiers">
            <xsl:text> [&#10;</xsl:text>
            <xsl:if test="string-length(normalize-space(//gmd:dataSetURI/gco:CharacterString)) > 0">
                <xsl:text> {&#10;            "@type": "PropertyValue",&#10;            "propertyID": </xsl:text>
                <xsl:text>"gmd:datasetURI",&#10;            "value": "</xsl:text>
                <xsl:value-of select="normalize-space(//gmd:dataSetURI/gco:CharacterString)"/>
                <xsl:if test="contains(//gmd:dataSetURI/gco:CharacterString, 'http')">
                    <xsl:text>",&#10;            "url": "</xsl:text>
                    <xsl:value-of select="normalize-space(//gmd:dataSetURI/gco:CharacterString)"/>
                </xsl:if>
                <xsl:text>"&#10;}</xsl:text>
                <xsl:if test="//gmd:citation//gmd:identifier">
                    <xsl:text>,&#10;</xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:if test="//gmd:citation//gmd:identifier">
                <xsl:for-each select="//gmd:citation//gmd:identifier">
                    <xsl:text> {&#10;            "@type": "PropertyValue",&#10;            "propertyID": </xsl:text>
                    <xsl:text>"</xsl:text>
                    <xsl:choose>
                        <!-- figure out what kind of identifier we have to put in the propertyID -->
                        <xsl:when
                            test="string-length(normalize-space(*//gmd:codespace/gco:CharacterString)) > 0">
                            <xsl:value-of
                                select="normalize-space(*//gmd:codespace/gco:CharacterString)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>dataset identifier</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- close braces if no more identifier -->
                    <xsl:text>",&#10;            "value": "</xsl:text>
                    <xsl:value-of select="normalize-space(*//gmd:code/gco:CharacterString)"/>
                    <xsl:if test="contains(*//gmd:code/gco:CharacterString, 'http')">
                        <xsl:text>",&#10;            "url": "</xsl:text>
                        <xsl:value-of select="normalize-space(*//gmd:code/gco:CharacterString)"/>
                    </xsl:if>
                    <xsl:text>"&#10;}</xsl:text>
                    <xsl:if test="following-sibling::gmd:identifier">
                        <xsl:text>,&#10;      </xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="//gmd:citation//gmd:ISBN or //gmd:citation//gmd:ISSN">
                    <xsl:text>,&#10;      </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:if test="string-length(//gmd:citation//gmd:ISBN/gco:CharacterString) > 0">
                <xsl:text> {
                    "@type": "PropertyValue",
                    "propertyID": "ISBN",
                    "value": "</xsl:text>
                <xsl:value-of select="normalize-space(//gmd:citation//gmd:ISBN/gco:CharacterString)"/>
                <xsl:text>"}</xsl:text>
                <xsl:if test="string-length(//gmd:citation//gmd:ISSN/gco:CharacterString) > 0">
                    <xsl:text>,&#10;      </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:if test="string-length(//gmd:citation//gmd:ISSN/gco:CharacterString) > 0">
                <xsl:text> {
                    "@type": "PropertyValue",
                    "propertyID": "ISSN",
                    "value": "</xsl:text>
                <xsl:value-of select="normalize-space(//gmd:citation//gmd:ISSN/gco:CharacterString)"/>
                <xsl:text>"}</xsl:text>
            </xsl:if>
            <xsl:text>]</xsl:text>
        </xsl:variable>
        <xsl:variable name="name" select="//gmd:citation//gmd:title/gco:CharacterString"/>
        <xsl:variable name="alternateName">
            <xsl:if test="count(//gmd:citation//gmd:alternateTitle) > 1">
                <xsl:text>[&#10;</xsl:text>
            </xsl:if>
            <xsl:for-each select="//gmd:citation//gmd:alternateTitle">
                <xsl:text>"</xsl:text>
                <xsl:value-of select="normalize-space(gco:CharacterString)"/>
                <xsl:text>"</xsl:text>
                <xsl:if test="following-sibling::gmd:alternateTitle">
                    <xsl:text>,&#10;</xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:if test="count(//gmd:citation//gmd:alternateTitle) > 1">
                <xsl:text>]</xsl:text>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="publisher">
            <xsl:if
                test="//gmd:identificationInfo/gmd:citedResponsibleParty[translate(*//@codeListValue, $uppercase, $smallcase) = 'publisher']">
                <xsl:value-of disable-output-escaping="yes"
                    select="normalize-space((//gmd:identificationInfo/gmd:citedResponsibleParty[translate(*//@codeListValue, $uppercase, $smallcase) = 'publisher']//gmd:organisationName/gco:CharacterString)[1])"
                />
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="citation">
            <!-- ISO19115 only allows one citation per gmd:MD_DataIdentification;  -->
            <!-- ignore MD_DataIdentification in  -->
            <xsl:for-each
                select="(//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation)[1]">
                <!-- this is just to set the context and make xpaths easier -->
                <xsl:for-each
                    select="gmd:citedResponsibleParty[(*//@codeListValue = 'author') or (*//@codeListValue = 'originator')]/gmd:CI_ResponsibleParty">
                    <xsl:choose>
                        <xsl:when
                            test="string-length(normalize-space(gmd:individualName/gco:CharacterString)) > 0">
                            <xsl:value-of
                                select="normalize-space(gmd:individualName/gco:CharacterString)"/>
                        </xsl:when>
                        <xsl:when
                            test="string-length(normalize-space(gmd:organisationName/gco:CharacterString)) > 0">
                            <xsl:value-of
                                select="normalize-space(gmd:organisationName/gco:CharacterString)"/>
                        </xsl:when>
                        <xsl:when
                            test="string-length(normalize-space(gmd:positionName/gco:CharacterString)) > 0">
                            <xsl:value-of
                                select="normalize-space(gmd:positionName/gco:CharacterString)"/>
                        </xsl:when>
                        <xsl:otherwise>anonymous</xsl:otherwise>
                    </xsl:choose>

                    <xsl:value-of select="normalize-space(gmd:individualName/gco:CharacterString)"/>
                    <xsl:if test="following::gmd:citedResponsibleParty">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:text> (</xsl:text>
                <xsl:choose>
                    <!-- deal with ISO DateTypeCodes; publication revision-->
                    <xsl:when
                        test="string-length(*//gmd:CI_Date[translate(*//@codeListValue, $uppercase, $smallcase) = 'publication']/gmd:date/child::node()/text()) > 0">
                        <xsl:value-of
                            select="*//gmd:CI_Date[translate(*//@codeListValue, $uppercase, $smallcase) = 'publication']/gmd:date/child::node()/text()"
                        />
                    </xsl:when>
                    <xsl:when
                        test="string-length(*//gmd:CI_Date[translate(*//@codeListValue, $uppercase, $smallcase) = 'revision']/gmd:date/child::node()/text()) > 0">
                        <xsl:value-of
                            select="*//gmd:CI_Date[translate(*//@codeListValue, $uppercase, $smallcase) = 'revision']/gmd:date/child::node()/text()"
                        />
                    </xsl:when>
                    <xsl:when
                        test="string-length(*//gmd:CI_Date[translate(*//@codeListValue, $uppercase, $smallcase) = 'creation']/gmd:date/child::node()/text()) > 0">
                        <xsl:value-of
                            select="*//gmd:CI_Date[translate(*//@codeListValue, $uppercase, $smallcase) = 'creation']/gmd:date/child::node()/text()"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="
                                concat(*//gmd:CI_Date[1]/gmd:date/child::node()/text(),
                                '-', *//gmd:CI_Date[1]//@codeListValue)"
                        />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>), </xsl:text>
                <!-- will potentially have problems here if there are multiple titles; this just takes the first one -->
                <xsl:value-of disable-output-escaping="yes"
                    select="//gmd:citation//gmd:title/gco:CharacterString"/>
                <xsl:text>, </xsl:text>
                <!-- get the publisher -->
                <xsl:if test="$publisher">
                    <xsl:value-of select="$publisher"/>
                    <xsl:text>: </xsl:text>
                </xsl:if>
                <xsl:text> Identifier:</xsl:text>
                <xsl:value-of select="$datasetURI"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="datePublished">
            <xsl:for-each
                select="(//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation)[1]">
                <!-- for-each is just to set the context and make xpaths easier -->
                <xsl:choose>
                    <xsl:when
                        test="string-length(*//gmd:CI_Date[translate(*//@codeListValue, $uppercase, $smallcase) = 'publication']/gmd:date/child::node()/text()) > 0">
                        <xsl:value-of
                            select="*//gmd:CI_Date[translate(*//@codeListValue, $uppercase, $smallcase) = 'publication']/gmd:date/child::node()/text()"
                        />
                    </xsl:when>
                    <xsl:when
                        test="string-length(*//gmd:CI_Date[translate(*//@codeListValue, $uppercase, $smallcase) = 'revision']/gmd:date/child::node()/text()) > 0">
                        <xsl:value-of
                            select="*//gmd:CI_Date[translate(*//@codeListValue, $uppercase, $smallcase) = 'revision']/gmd:date/child::node()/text()"
                        />
                    </xsl:when>
                    <xsl:when
                        test="string-length(*//gmd:CI_Date[translate(*//@codeListValue, $uppercase, $smallcase) = 'creation']/gmd:date/child::node()/text()) > 0">
                        <xsl:value-of
                            select="*//gmd:CI_Date[translate(*//@codeListValue, $uppercase, $smallcase) = 'creation']/gmd:date/child::node()/text()"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="
                                concat(*//gmd:CI_Date[1]/gmd:date/child::node()/text(),
                                '-', *//gmd:CI_Date[1]//@codeListValue)"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="description" select="//gmd:abstract[1]/gco:CharacterString"/>
        <xsl:variable name="DataCatalogName" select="'CINERGI geoscience resource catalog'"/>
        <xsl:variable name="DataCatalogURL" select="'not defined yet'"/>

        <xsl:variable name="contributors">
            <xsl:if
                test="
                    (count(//gmd:identificationInfo//gmd:credit/gco:CharacterString) +
                    count(//gmd:CI_ResponsibleParty[*//@codeListValue = 'sponsor' or *//@codeListValue = 'funder'])) > 1">
                <xsl:text>[</xsl:text>
            </xsl:if>

            <xsl:for-each select="//gmd:identificationInfo//gmd:credit">
                <xsl:text>{&#10;    "@type":"Role",&#10;</xsl:text>
                <xsl:text>"roleName":"credit",&#10;    "description":"</xsl:text>
                <xsl:value-of select="child::node()/text()"/>
                <!-- allow for Anchor or CharacterString -->
                <xsl:text>"</xsl:text>
                <xsl:if test="string-length(gmx:Anchor/@xlink:href) > 0">
                    <xsl:text>,&#10;    "URL":"</xsl:text>
                    <xsl:value-of select="gmx:Anchor/@xlink:href"/>
                    <xsl:text>"}</xsl:text>
                </xsl:if>
                <xsl:text>}</xsl:text>

                <xsl:if test="following-sibling::gmd:credit">
                    <xsl:text>,&#10;      </xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:if
                test="(//gmd:identificationInfo//gmd:credit) and (//gmd:CI_ResponsibleParty[*//@codeListValue = 'sponsor' or *//@codeListValue = 'funder'])">
                <xsl:text>,&#10;     </xsl:text>
            </xsl:if>
            <xsl:for-each
                select="//gmd:CI_ResponsibleParty[*//@codeListValue = 'sponsor' or *//@codeListValue = 'funder']">
                <!--<xsl:text>,&#10;     {"@type":"Role",&#10;</xsl:text>
                <xsl:text>       "roleName":"</xsl:text>
                <xsl:value-of select="*//@codeListValue"/><xsl:text>",&#10;</xsl:text>-->
                <xsl:apply-templates select=".">
                    <!-- invoke gmd:CI_ResponsibleParty template -->
                    <xsl:with-param name="role" select="'contributor'"/>
                </xsl:apply-templates>

                <xsl:if test="following-sibling::gmd:CI_ResponsibleParty">
                    <xsl:text>,&#10;</xsl:text>
                </xsl:if>
            </xsl:for-each>


            <xsl:if
                test="
                    (count(//gmd:identificationInfo//gmd:credit/gco:CharacterString) +
                    count(//gmd:CI_ResponsibleParty[*//@codeListValue = 'sponsor' or *//@codeListValue = 'funder'])) > 1">
                <xsl:text>]</xsl:text>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="awardID" select="''"/>
        <xsl:variable name="awardname" select="''"/>
        <xsl:variable name="awardURL" select="''"/>
        <xsl:variable name="keywords">
            <xsl:for-each select="//gmd:descriptiveKeywords">
                <!-- extract one or more keywords from each keywords group -->
                <!-- use child::node() to catch CharacterString and Anchor -->
                <xsl:for-each select="gmd:MD_Keywords/gmd:keyword">
                    <xsl:text>"</xsl:text>
                    <xsl:value-of select="child::node()/text()"/>
                    <xsl:text>"</xsl:text>
                    <xsl:if test="following-sibling::gmd:keyword">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="following-sibling::gmd:descriptiveKeywords">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>

            <xsl:variable name="subjectsString">
                <xsl:for-each select="//gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword">
                    <xsl:value-of select="child::node()/text()"/>
                </xsl:for-each>
            </xsl:variable>

            <xsl:for-each
                select="//gmd:extent//gmd:geographicIdentifier//gmd:code/gco:CharacterString">
                <xsl:if test="not(contains($subjectsString, text()))">
                    <xsl:text>,&#10;"</xsl:text>
                    <xsl:value-of select="text()"/>
                    <xsl:text>"</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <!-- schema.org license is CreativeWork or URL -->
        <xsl:variable name="license">
            <!-- mine information from gmd:resourceConstraints. Each resource constraint will be a separte licence entry
               so could be an array -->
            <!-- xlink:href on gmd:resourceConstraints would provide a URL -->
            <!-- text from gmd:useLimitation or inside of  -->
            <xsl:if test="count(//gmd:resourceConstraints) > 1">
                <xsl:text>[</xsl:text>
            </xsl:if>
            <xsl:for-each select="//gmd:resourceConstraints">
                <xsl:text>{&#10;     </xsl:text>
                <xsl:text>"@type": "DigitalDocument",</xsl:text>
                <xsl:if test="string-length(normalize-space(@xlink:href)) > 0">
                    <xsl:text>"URL": "</xsl:text>
                    <xsl:value-of select="normalize-space(@xlink:href)"/>
                    <xsl:text>"</xsl:text>
                    <xsl:if test="child::*">
                        <xsl:text>,&#10;       </xsl:text>
                    </xsl:if>
                </xsl:if>
                <xsl:for-each select="child::*">
                    <!-- there should be only one -->
                    <xsl:text>"name": "</xsl:text>
                    <xsl:value-of select="local-name()"/>
                    <xsl:text>"</xsl:text>
                    <xsl:if test="child::*/child::*">
                        <xsl:text>,&#10;        </xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:text>"description": "</xsl:text>
                <xsl:for-each select="child::*/child::*">
                    <xsl:value-of select="concat(local-name(), ': ')"/>
                    <xsl:choose>
                        <xsl:when test="gmd:MD_RestrictionCode">
                            <xsl:value-of select="gmd:MD_RestrictionCode/@codeListValue"/>
                            <xsl:if test="string-length(gmd:MD_RestrictionCode) > 0">
                                <xsl:text>: </xsl:text>
                                <xsl:value-of select="normalize-space(gmd:MD_RestrictionCode)"/>

                            </xsl:if>
                            <xsl:text>.    </xsl:text>
                        </xsl:when>
                        <xsl:when test="string-length(gco:CharacterString) > 0">
                            <xsl:value-of select="concat(gco:CharacterString, '.   ')"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
                <xsl:text>"}</xsl:text>
                <xsl:if test="following-sibling::gmd:resourceConstraints">
                    <xsl:text>,&#10;       </xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:if test="count(//gmd:resourceConstraints) > 1">
                <xsl:text>]</xsl:text>
            </xsl:if>
        </xsl:variable>
        <!-- default values to use in lieu of extracted provider; customize
      logic in format/profile-specific implementations to decide which to use-->
        <xsl:variable name="providerDefault" select="'default provider'"/>
        <xsl:variable name="publisherDefault" select="'default publisher'"/>
        <xsl:variable name="publishingPrinciplesDefault" select="'not defined yet'"/>
        <xsl:variable name="provider" select="''"/>
        <xsl:variable name="publshingPrinciples" select="''"/>

        <xsl:variable name="hasSpatial"
            select="//gmd:extent//gmd:description or //gmd:geographicElement"/>
        <xsl:variable name="hasVariables" select="false()"/>

        <!-- construct the JSON with xsl text elements. &#10; is carriage return -->
        <xsl:text>{&#10;  "@context": {&#10;</xsl:text>
        <xsl:text> "@vocab": "http://schema.org/"</xsl:text>
        <xsl:if test="$additionalContexts and string-length($additionalContexts) > 0">
            <xsl:text>, &#10;</xsl:text>
            <xsl:value-of select="$additionalContexts"/>
        </xsl:if>
        <xsl:text>  },&#10; </xsl:text>

        <xsl:text>"@id": "</xsl:text>
        <xsl:value-of select="$datasetURI"/>
        <xsl:text>",&#10;</xsl:text>
        <xsl:text>  "@type": "Dataset",&#10;</xsl:text>
        <xsl:text>  "additionalType": [&#10;    "geolink:Dataset",&#10;    "vivo:Dataset"&#10;  ],&#10;</xsl:text>

        <xsl:text>  "name": "</xsl:text>
        <xsl:value-of select="$name"/>
        <xsl:text>",&#10;</xsl:text>

        <xsl:if test="string-length($alternateName) > 0">
            <xsl:text>  "alternateName": </xsl:text>
            <xsl:value-of select="$alternateName"/>
            <xsl:text>,&#10;</xsl:text>
        </xsl:if>

        <xsl:text>  "citation": "</xsl:text>
        <xsl:value-of select="$citation"/>
        <xsl:text>",&#10;</xsl:text>

        <xsl:text>  "creator":&#10;</xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:for-each select="//gmd:citation//gmd:citedResponsibleParty">
            <xsl:apply-templates select="gmd:CI_ResponsibleParty">
                <xsl:with-param name="role">
                    <xsl:value-of select="'creator'"/>
                </xsl:with-param>
            </xsl:apply-templates>
            <xsl:if test="following-sibling::gmd:citedResponsibleParty">
                <xsl:text>,&#10;</xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>],&#10;</xsl:text>


        <xsl:text>  "datePublished": "</xsl:text>
        <xsl:value-of select="$datePublished"/>
        <xsl:text>",&#10;</xsl:text>

        <xsl:text>  "description": "</xsl:text>
        <xsl:value-of select="$description"/>
        <xsl:text>",&#10;</xsl:text>

        <xsl:text>  "distribution": [&#10;</xsl:text>
        <!-- logic here is very messy because of the convoluted distribution model in ISO19115; there is no explicit binding 
        between a transfer option and a format. assume two kinds of distribution tuples binding a distributor, format and transfer options:
        
        A collection of formats, distributors, and transfer options, all formats and options available from all distributors:
                {MD_distributionFormat (0..*;), MD_distributorContact (1 per distributor), MD_transferOptions (0..*)}; 
                ignore distributorFormat and distributorTransferOptions
        
        each set of formats and transfer options is bound to one distributor and to each other
                {MD_distributorFormat (0..*); MD_distributorContact (1 per distributor); MD_distributorTransferOptions}; 
                
        In schema.org, distribution is represented using a DataDownload object, which inherits from MediaObject and Creative Work, so there
        are LOTS of possible properties, but not much to describe service distributions. distributorContacts map to provider. Formats to fileFormat,
        CI_onlineResurce.linkage.URL to URL, except if the CI_OnLineFunctionCode is 'download' then it maps to contentURL. The mapping we'll try
        here maps each distribution CI_OnlineResource to a DataDownload object; distributorContact and format information will be repeated as necessary.
        
        The formatting template will take a single CI_OnlineResource node, a set of MD_Format nodes, and a set of CI_ResponsibleParty nodes
        -->
        <xsl:for-each select="//gmd:transferOptions//gmd:onLine/gmd:CI_OnlineResource">
            <xsl:variable name="onlineResource" select="."/>
            <xsl:variable name="format"
                select="*/ancestor::node()/preceding-sibling::gmd:distributionFormat/gmd:MD_Format"/>
            <xsl:variable name="distributorContact"
                select="*/ancestor::node()/preceding-sibling::gmd:distributor//gmd:CI_ResponsibleParty"/>

            <xsl:call-template name="distributions">
                <xsl:with-param name="por" select="$onlineResource"/>
                <xsl:with-param name="pfor" select="$format"/>
                <xsl:with-param name="prp" select="$distributorContact"/>
            </xsl:call-template>
            <xsl:if test="following::gmd:onLine">
                <xsl:text>,&#10;</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <xsl:if
            test="
                //gmd:transferOptions//gmd:onLine/gmd:CI_OnlineResource and
                //gmd:distributorTransferOptions//gmd:onLine/gmd:CI_OnlineResource">
            <xsl:text>,  </xsl:text>
        </xsl:if>

        <xsl:for-each select="//gmd:distributorTransferOptions//gmd:onLine/gmd:CI_OnlineResource">
            <xsl:variable name="onlineResource" select="."/>
            <xsl:variable name="format"
                select="*/ancestor::gmd:distributorTransferOptions/preceding-sibling::gmd:distributorFormat/gmd:MD_Format"/>
            <xsl:variable name="distributorContact"
                select="*/ancestor::gmd:distributorTransferOptions/preceding-sibling::gmd:distributorContact/gmd:CI_ResponsibleParty"/>

            <xsl:call-template name="distributions">
                <xsl:with-param name="por" select="$onlineResource"/>
                <xsl:with-param name="pfor" select="$format"/>
                <xsl:with-param name="prp" select="$distributorContact"/>
            </xsl:call-template>
            <xsl:if
                test="following::gmd:distributorTransferOptions//gmd:onLine or parent::node()/following-sibling::gmd:onLine">
                <xsl:text>,&#10;</xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>  ],&#10;</xsl:text>

        <xsl:if test="string-length(string($datasetIdentifiers)) > 0">
            <xsl:text>  "identifier": &#10;</xsl:text>
            <xsl:value-of select="$datasetIdentifiers"/>
            <xsl:text>,&#10;</xsl:text>
        </xsl:if>

        <xsl:if test="string-length($DataCatalogName) > 0 or string-length($DataCatalogURL) > 0">
            <xsl:text>  "includedInDataCatalog": {&#10; 
    "@type":"DataCatalog",&#10;</xsl:text>
            <xsl:if test="$DataCatalogName">
                <xsl:text>  "name":"</xsl:text>
                <xsl:value-of select="$DataCatalogName"/>
                <xsl:text>",&#10;</xsl:text>
            </xsl:if>
            <xsl:if test="$DataCatalogURL">
                <xsl:text>  "url": "</xsl:text>
                <xsl:value-of select="$DataCatalogURL"/>
                <xsl:text>"&#10;</xsl:text>
            </xsl:if>
            <xsl:text>},&#10;</xsl:text>
        </xsl:if>

        <!-- put award information in contributor...  -->
        <xsl:if test="string-length(string($contributors)) > 0">
            <xsl:text>  "contributor": </xsl:text>
            <xsl:value-of select="$contributors"/>
            <xsl:text>,&#10;</xsl:text>
        </xsl:if>

        <xsl:text>  "keywords": [</xsl:text>
        <xsl:value-of select="$keywords"/>
        <xsl:text>],&#10;</xsl:text>

        <xsl:if test="string-length(string($license)) > 0">
            <xsl:text>  "license": </xsl:text>
            <xsl:value-of select="$license"/>
            <xsl:text>,&#10;</xsl:text>
        </xsl:if>
        <!--        <xsl:text>  "provider": </xsl:text>
        <xsl:choose>
            <xsl:when test="$provider">
                <xsl:value-of select="$provider"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>"</xsl:text>
                <xsl:value-of select="$providerDefault"/><xsl:text>"</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>,&#10;</xsl:text>-->

        <xsl:if test="string-length(normalize-space(concat($publisherDefault, $publisher))) > 0">
            <xsl:text>  "publisher": </xsl:text>
            <xsl:choose>
                <xsl:when test="string-length($publisher) > 0">
                    <xsl:text>"</xsl:text>
                    <xsl:value-of select="$publisher"/>
                    <xsl:text>"</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>"</xsl:text>
                    <xsl:value-of select="$publisherDefault"/>
                    <xsl:text>"</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>

        <xsl:if test="$hasSpatial or $hasVariables">
            <xsl:text>,&#10;</xsl:text>
        </xsl:if>

        <xsl:if test="$hasSpatial">
            <xsl:text>  "spatialCoverage": </xsl:text>
            <xsl:if test="count(//gmd:geographicElement) + count(gmd:extent//gmd:description) > 1">
                <xsl:text>[&#10;</xsl:text>
            </xsl:if>
            <xsl:for-each select="//gmd:extent//gmd:description/gco:CharacterString">
                <xsl:if test="string-length(//gmd:extent//gmd:description/gco:CharacterString) > 0">
                    <xsl:text>{"@type": "Place",&#10;    "description":"</xsl:text>
                    <xsl:value-of select="normalize-space(.)"/>
                    <xsl:text>"}</xsl:text>
                    <xsl:if test="following::gmd:extent//gmd:description">
                        <xsl:text>,&#10;</xsl:text>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
            <xsl:if test="//gmd:geographicElement">
                <xsl:text>,&#10;</xsl:text>
            </xsl:if>

            <xsl:for-each select="//gmd:geographicElement">
                <xsl:variable name="thisElement">
                    <xsl:apply-templates select="."/>
                </xsl:variable>
                <xsl:value-of select="$thisElement"/>
                <xsl:if
                    test="
                        string-length(string($thisElement)) > 0 and following::gmd:geographicElement">
                    <xsl:text>,&#10;</xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:if test="count(//gmd:geographicElement) > 1">
                <xsl:text>]</xsl:text>
            </xsl:if>
            <xsl:if test="$hasVariables">
                <xsl:text>,&#10;</xsl:text>
            </xsl:if>
        </xsl:if>


        <xsl:if test="$hasVariables">
            <xsl:text>  "variableMeasured": [</xsl:text>
            <xsl:call-template name="variableMeasured">
                <xsl:with-param name="variableList"> </xsl:with-param>
            </xsl:call-template>
            <xsl:text>]</xsl:text>
        </xsl:if>
        <xsl:text>}</xsl:text>

    </xsl:template>
</xsl:stylesheet>
