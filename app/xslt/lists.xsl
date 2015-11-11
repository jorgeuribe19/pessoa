<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://localhost"
    version="2.0">
    
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    <xsl:param name="lang">pt</xsl:param>
    
    <xsl:template match="/">
        <xsl:apply-templates select=".//body"/>
    </xsl:template>
    
    <xsl:template match="body">
        <div>
            <script type="text/javascript">
                function highlight(key){
                    els = document.getElementsByClassName(key);
                    for (var i=0; i &lt; els.length; i++){
                        els[i].style.color="#009999";
                    }
                }
                function clearH(key){
                    els = document.getElementsByClassName(key);
                    for (var i=0; i &lt; els.length; i++){
                        els[i].style.color="";
                    }
                }
            </script>
            <style type="text/css">
                #index h2 {
                    margin-top: 30px;
                    text-align: left;
                    }
                .indexImg {
                    width: 16px;
                    height: auto;
                    vertical-align: bottom;
                    position: relative;
                    bottom: 2px;
                    margin-left: 5px;
                    }
                .typeB {
                    width: 12px;
                    margin-left: 7px;
                }
            </style>
            <xsl:if test=".//rs[@type='person']">
                <xsl:variable name="title">
                    <xsl:choose>
                        <xsl:when test="$lang='en'">person index</xsl:when>
                        <xsl:otherwise>índice de pessoas</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <h2><xsl:choose>
                    <xsl:when test="$lang='en'">Persons</xsl:when>
                    <xsl:otherwise>Pessoas</xsl:otherwise>
                </xsl:choose></h2>
                <ul>
                    <xsl:for-each-group select=".//rs[@type='person']" group-by="@key">
                        <xsl:sort select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//listPerson/person[@xml:id=current-grouping-key()]/persName[1]"/>
                        <xsl:variable name="key" select="current-grouping-key()"/>
                        <xsl:choose>
                            <xsl:when test="@style">
                                <xsl:for-each-group select="current-group()" group-by="@style">
                                    <xsl:variable name="name" select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//listPerson/person[@xml:id=$key or substring-after(@corresp,'#')=$key]/persName[@type=current-grouping-key()]"/>
                                    <li onmouseenter="highlight('person {$key}');" onmouseleave="clearH('{$key}');"><xsl:value-of select="$name"/> <a href="../../page/persons#{$name}" title="{$title}"><img class="indexImg" src="../../resources/images/glyphicons-35-old-man.png"/></a></li>
                                </xsl:for-each-group>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="name" select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//listPerson/person[@xml:id=$key]/persName"/>
                                <li onmouseenter="highlight('person {$key}');" onmouseleave="clearH('{$key}');"><xsl:value-of select="$name"/> <a href="../../page/persons#{$name}" title="{$title}"><img class="indexImg" src="../../resources/images/glyphicons-35-old-man.png"/></a></li>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </ul>
            </xsl:if>
            <xsl:if test=".//rs[@type='text']">
                <xsl:variable name="title">
                    <xsl:choose>
                        <xsl:when test="$lang='en'">index of texts</xsl:when>
                        <xsl:otherwise>índice de textos</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <h2><xsl:choose>
                    <xsl:when test="$lang='en'">Texts</xsl:when>
                    <xsl:otherwise>Textos</xsl:otherwise>
                </xsl:choose></h2>
                <ul>
                    <xsl:for-each select=".//rs[@type='text']">
                        <xsl:sort select="replace(.,'[“”]','')"/>
                        <xsl:variable name="key" select="replace(.,'[“”.\s]','')"/>
                        <li onmouseenter="highlight('text {$key}');" onmouseleave="clearH('{$key}');"><xsl:apply-templates /> <a href="../../page/texts#{.}" title="{$title}"><img class="indexImg typeB" src="../../resources/images/glyphicons-40-notes.png"/></a></li>
                    </xsl:for-each>
                </ul>
            </xsl:if>
            <xsl:if test=".//rs[@type='journal']">
                <xsl:variable name="title">
                    <xsl:choose>
                        <xsl:when test="$lang='en'">journal index</xsl:when>
                        <xsl:otherwise>índice de jornais</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <h2><xsl:choose>
                    <xsl:when test="$lang='en'">Journals</xsl:when>
                    <xsl:otherwise>Jornais</xsl:otherwise>
                </xsl:choose></h2>
                <ul>
                    <xsl:for-each-group select=".//rs[@type='journal']" group-by="@key">
                        <xsl:sort select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type='journals']/item[@xml:id=current-grouping-key()]"/>
                        <xsl:variable name="name"  select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type='journals']/item[@xml:id=current-grouping-key()]"/>
                        <li onmouseenter="highlight('journal {current-grouping-key()}');" onmouseleave="clearH('{current-grouping-key()}');"><xsl:value-of select="$name"/> <a href="../../page/journals#{$name}" title="{$title}"><img class="indexImg" src="../../resources/images/glyphicons-609-newspaper.png"/></a></li>
                    </xsl:for-each-group>
                </ul>
            </xsl:if>
        </div>
    </xsl:template>
    
    <xsl:template match="choice[abbr][expan]">
        <xsl:apply-templates select="expan"/>
    </xsl:template>
    
    <xsl:template match="lb">
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="replace(.,'[“”.]','')"/>
    </xsl:template>
    
</xsl:stylesheet>