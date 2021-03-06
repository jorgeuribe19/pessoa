<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    
    <!-- Authors: Ulrike Henny, Alena Geduldig -->
    
    <xsl:import href="doc.xsl"/>
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    
    <!-- externer Parameter lb: yes|no
    (Zeilenumbrüche anzeigen oder nicht) -->
    <xsl:param name="lb" />
    <!-- externer Parameter abbr: yes|no
    (Abkürzungen anzeigen oder nicht) -->
    <xsl:param name="abbr" />
    

   <!-- Trotz Aufhebung der lb's soll am Rand genug Platz für Notes bleiben --> 
    <xsl:template match="text" mode="#default deletion addition">
       <div class="text">          
               <xsl:if test="@xml:id">
                   <xsl:attribute name="id">
                       <xsl:value-of select="@xml:id"/>
                   </xsl:attribute>
               </xsl:if> 
           <xsl:attribute name="style">
               <xsl:if test="//note[contains(@place,'left')]">
                 padding-left: 150px;  
               </xsl:if>
               <xsl:if test="//note[contains(@place,'right')]">
                   padding-right:150px;
               </xsl:if>
           </xsl:attribute>   
               <xsl:apply-templates/>  
       </div>
        <xsl:apply-templates select="//summary"/>
    </xsl:template>
    
    <!-- Anzeige von Zeilenumbrüchen -->
    <xsl:template match="lb[not(preceding-sibling::*[1][local-name()='pc'])][not(ancestor::note)][not(ancestor::add)]" mode="#default deletion addition">
        <xsl:choose>
            <xsl:when test="$lb = 'yes'">
                <br />
            </xsl:when>
            <xsl:otherwise>
                <xsl:text xml:space="preserve"> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="lb[preceding-sibling::*[1][local-name()='pc']]" mode="#default deletion addition">
        <xsl:if test="$lb = 'yes'">
            <br />
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="pc" mode="#default deletion addition">
        <xsl:if test="$lb = 'yes'">
            <xsl:apply-templates />
        </xsl:if>
    </xsl:template>
     
    <!-- Choices -->
    <!-- Abkürzungen und Auflösungen: Darstellung der aufgelösten Form -->
    <xsl:template match="choice[abbr and expan[ex]]" mode="#default deletion addition">
        <xsl:choose>
            <!-- abbr no -> Abk. sollen nicht aufgelöst werden -->
            <xsl:when test="$abbr = 'no'">
                <xsl:apply-templates select="abbr/text() | abbr/child::*" />
                <xsl:if test="following-sibling::choice[1]">
                    <xsl:text>&#160;</xsl:text>
                </xsl:if>           
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="abbr/metamark[@function='ditto']">
                        <span class="ditto">
                            <xsl:apply-templates select="expan/text() | expan/child::*"/>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="expan/text() | expan/child::*"/> 
                    </xsl:otherwise>
                </xsl:choose>            
            </xsl:otherwise>
        </xsl:choose> 
    </xsl:template>
    
    <xsl:template match="choice[abbr and expan[not(ex)]]" mode="#default deletion addition">
        <span class="expan">[<xsl:apply-templates select="expan/text() | expan/child::*"/>]</span>
    </xsl:template>
    
    <xsl:template match="abbr" mode="#default deletion addition">
        <xsl:choose>
            <xsl:when test="parent::choice"/>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="ex" mode="#default deletion addition">
        <span class="ex">[<xsl:apply-templates />]</span>
    </xsl:template>
    
    
   
   <!-- Einrückungen aufheben wenn lb's entfernt werden-->
    <xsl:template match="seg[@rend='indent']" mode="#default deletion addition">
        <span>
            <xsl:if test="$lb='yes'">
              <xsl:attribute name="class">indent</xsl:attribute>  
            </xsl:if>
            <xsl:apply-templates/>
        </span>   
    </xsl:template>
    
    <xsl:template match="ab[@rend='indent']" mode="#default deletion addition">
        <span class="ab">
            <xsl:if test="$lb='yes'">
                <xsl:attribute name="style">margin-left:2em;</xsl:attribute>  
            </xsl:if>
            <xsl:apply-templates/>
        </span>   
    </xsl:template>
    
<!-- special case 180r -->
    <xsl:template match="text[@xml:id='bnp-e3-180r']//note[@place='margin top right']" mode="#default deletion addition">
        <span class="note addition margin top right" style="right: 0px;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
       
   
</xsl:stylesheet>