<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Rendering of a list of items (e.g. in a search or
    browse results page)

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util confman">
    <xsl:import href="item-view-general-templates.xsl" />

    <xsl:output indent="yes"/>

    <!--these templates are modfied to support the 2 different item list views that
    can be configured with the property 'xmlui.theme.mirage.item-list.emphasis' in dspace.cfg-->

    <xsl:template name="itemSummaryList-DIM">
        <xsl:variable name="itemWithdrawn" select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/@withdrawn" />

        <xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="$itemWithdrawn">
                    <xsl:value-of select="@OBJEDIT"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@OBJID"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="emphasis" select="confman:getProperty('xmlui.theme.mirage.item-list.emphasis')"/>
        <xsl:choose>
            <xsl:when test="'file' = $emphasis">


                <div class="item-wrapper row">
                    <div class="col-sm-3 hidden-xs">
                        <xsl:apply-templates select="./mets:fileSec" mode="artifact-preview">
                            <xsl:with-param name="href" select="$href"/>
                        </xsl:apply-templates>
                    </div>

                    <div class="col-sm-9">
                        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                             mode="itemSummaryList-DIM-metadata">
                            <xsl:with-param name="href" select="$href"/>
                        </xsl:apply-templates>
                    </div>

                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                     mode="itemSummaryList-DIM-metadata"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--handles the rendering of a single item in a list in file mode-->
    <!--handles the rendering of a single item in a list in metadata mode-->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM-metadata">
        <xsl:param name="href"/>
        <div class="artifact-description">
            <h4 class="artifact-title">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$href"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title']">
                            <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <span class="Z3988">
                    <xsl:attribute name="title">
                        <xsl:call-template name="renderCOinS"/>
                    </xsl:attribute>
                    &#xFEFF; <!-- non-breaking space to force separating the end tag -->
                </span>
            </h4>
            <div class="artifact-info">
                <span class="author h4">
                    <small>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                <span>
                                  <xsl:if test="@authority">
                                    <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                  </xsl:if>
                                  <xsl:copy-of select="node()"/>
                                </span>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='creator']">
                            <xsl:for-each select="dim:field[@element='creator']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='contributor']">
                            <xsl:for-each select="dim:field[@element='contributor']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    </small>
                </span>
                <xsl:text> </xsl:text>
                <xsl:if test="dim:field[@element='date' and @qualifier='issued']">
	                <span class="publisher-date h4">  <small>
	                    <xsl:text>(</xsl:text>
	                    <xsl:if test="dim:field[@element='publisher']">
	                        <span class="publisher">
	                            <xsl:copy-of select="dim:field[@element='publisher' and not(@qualifier='place')]/node()"/>
	                        </span>
	                        <xsl:text>, </xsl:text>
	                    </xsl:if>
                        <xsl:if test="dim:field[@element='publisher' and @qualifier='place']">
                            <span class="publication-place">
                                <xsl:copy-of select="dim:field[@element='publisher' and @qualifier='place']"/>
                            </span>
                            <xsl:text>, </xsl:text>
                        </xsl:if>
	                    <span class="date">
	                        <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
	                    </span>
	                    <xsl:text>)</xsl:text>
                        </small></span>
                </xsl:if>
	</div>
		<xsl:if test="dim:field[@element='dateAccepted'][not (@qualifier)]">
			<div class="artifact-defence-date">
            		<span class="defence-date h4"> 
				<small>
                			<i18n:text>xmlui.dri2xhtml.METS-1.0.item-acceptance-date-item-view</i18n:text><xsl:text>: </xsl:text>
				</small>
                	</span>
			<span class="date h4">
				<small>
                    			<xsl:choose>
                        			<xsl:when test="substring(dim:field[@element='dateAccepted'][not (@qualifier)],9,1) = 0">
                            				<xsl:value-of select="substring(dim:field[@element='dateAccepted'][not (@qualifier)],10,1)"/>
                        			</xsl:when>
                        			<xsl:otherwise>
                            				<xsl:value-of select="substring(dim:field[@element='dateAccepted'][not (@qualifier)],9,2)"/>
                        			</xsl:otherwise>
                    			</xsl:choose>
                    			<xsl:text>. </xsl:text>
                    			<xsl:choose>
                        			<xsl:when test="substring(dim:field[@element='dateAccepted'][not (@qualifier)],6,1) = 0">
                            				<xsl:value-of select="substring(dim:field[@element='dateAccepted'][not (@qualifier)],7,1)"/>
                        			</xsl:when>
                        			<xsl:otherwise>
                            				<xsl:value-of select="substring(dim:field[@element='dateAccepted'][not (@qualifier)],6,2)"/>
                        			</xsl:otherwise>
                    			</xsl:choose>
                    			<xsl:text>. </xsl:text>
                    			<xsl:value-of select="substring(dim:field[@element='dateAccepted'][not (@qualifier)],1,4)"/>
                    			<!--<xsl:call-template name="formatdate">-->
                        			<!--<xsl:with-param name="DateTimeStr" select="dim:field[@element='dateAccepted']/text()"/>-->
                    			<!--</xsl:call-template>-->
                		</small>
            		</span>
			</div>
        	</xsl:if>
            <xsl:if test="dim:field[@element = 'description' and @qualifier='abstract']">
                <xsl:variable name="abstract" select="dim:field[@element = 'description' and @qualifier='abstract']/node()"/>
                <div class="artifact-abstract">
                    <xsl:value-of select="util:shortenString($abstract, 220, 10)"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template name="itemDetailList-DIM">
        <xsl:call-template name="itemSummaryList-DIM"/>
    </xsl:template>


    <xsl:template match="mets:fileSec" mode="artifact-preview">
        <xsl:param name="href"/>
        <div class="thumbnail artifact-preview">
            <a class="image-link" href="{$href}">
                <xsl:choose>
                    <xsl:when test="mets:fileGrp[@USE='THUMBNAIL']">
                        <xsl:choose>
                            <xsl:when test="$active-locale='cs'">
                                <xsl:choose>
                                    
                                    <xsl:when test="mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@xlink:title = 'thmb_private_cs.png']">
                                        <!-- Call custom thumbnail template -->
                                        <xsl:variable name="link" select="mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@xlink:title = 'thmb_private_cs.png']/@xlink:href"/>
                                        <xsl:call-template name="itemSummaryView-DIM-thumbnail-custom">
                                            <xsl:with-param name="url" select="$link"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- Call default thumbnail template -->
                                        <xsl:call-template name="itemSummaryView-DIM-thumbnail-default"/>
                                    </xsl:otherwise>

                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$active-locale='en'">
                                <xsl:choose>
                                    
                                    <xsl:when test="mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@xlink:title = 'thmb_private_en.png']">
                                        <!-- Call custom thumbnail template -->
                                        <xsl:variable name="link" select="mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@xlink:title = 'thmb_private_en.png']/@xlink:href"/>
                                        <xsl:call-template name="itemSummaryView-DIM-thumbnail-custom">
                                            <xsl:with-param name="url" select="$link"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- Call default thumbnail template -->
                                        <xsl:call-template name="itemSummaryView-DIM-thumbnail-default"/>
                                    </xsl:otherwise>

                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="itemSummaryView-DIM-thumbnail-default"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- FIXME: THIS SHOULD BE DONE SOMEHOW BETTER, CONSIDER USING BETTER PLACEHOLDER SCRIPT-->
                        <xsl:variable name="no-thumbnail-text"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-thumbnail</i18n:text></xsl:variable>
                        <img alt="xmlui.mirage2.item-list.thumbnail" i18n:attr="alt">
                            <xsl:attribute name="data-src">
                                <xsl:text>holder.js/100%x</xsl:text>
                                <xsl:value-of select="$thumbnail.maxheight"/>
                                <xsl:text>/text:No thumbnail available \n \n Náhled není k dispozici</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="class">
                                <xsl:text>no-thubnail</xsl:text>
                            </xsl:attribute>
                        </img>
                    </xsl:otherwise>
                </xsl:choose>
            </a>
        </div>
    </xsl:template>




    <!--
        Rendering of a list of items (e.g. in a search or
        browse results page)

        Author: art.lowel at atmire.com
        Author: lieven.droogmans at atmire.com
        Author: ben at atmire.com
        Author: Alexey Maslov

    -->



        <!-- Generate the info about the item from the metadata section -->
        <xsl:template match="dim:dim" mode="itemSummaryList-DIM">
            <xsl:variable name="itemWithdrawn" select="@withdrawn" />
            <div class="artifact-description">
                <div class="artifact-title">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:choose>
                                <xsl:when test="$itemWithdrawn">
                                    <xsl:value-of select="ancestor::mets:METS/@OBJEDIT" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="ancestor::mets:METS/@OBJID" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="dim:field[@element='title']">
                                <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </div>
                <span class="Z3988">
                    <xsl:attribute name="title">
                        <xsl:call-template name="renderCOinS"/>
                    </xsl:attribute>
                    &#xFEFF; <!-- non-breaking space to force separating the end tag -->
                </span>
                <div class="artifact-info">
                    <span class="author">
                        <xsl:choose>
                            <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                                <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                    <span>
                                        <xsl:if test="@authority">
                                            <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                        </xsl:if>
                                        <xsl:copy-of select="node()"/>
                                    </span>
                                    <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="dim:field[@element='creator']">
                                <xsl:for-each select="dim:field[@element='creator']">
                                    <xsl:copy-of select="node()"/>
                                    <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="dim:field[@element='contributor']">
                                <xsl:for-each select="dim:field[@element='contributor']">
                                    <xsl:copy-of select="node()"/>
                                    <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                    <xsl:text> </xsl:text>
                    <xsl:if test="dim:field[@element='date' and @qualifier='issued'] or dim:field[@element='publisher']">
                        <span class="publisher-date">
                            <xsl:text>(</xsl:text>
                            <xsl:if test="dim:field[@element='publisher' and not(@qualifier='place')]">
                                <span class="publisher">
                                    <xsl:copy-of select="dim:field[@element='publisher']/node()"/>
                                </span>
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <xsl:if test="dim:field[@element='publisher' and @qualifier='place']">
                                <span class="publication-place">
                                    <xsl:copy-of select="dim:field[@element='publisher' and @qualifier='place']"/>
                                </span>
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <span class="date">
                                <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                            </span>
                            <xsl:text>)</xsl:text>
                        </span>
                    </xsl:if>
                </div>
            </div>
        </xsl:template>

</xsl:stylesheet>
