<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output indent="yes" omit-xml-declaration="no" media-type="application/xml" encoding="UTF-8" />

  <xsl:key name="docs" match="/response/result/doc" use="*[@name='name']"/>

  <xsl:template match="/">
    <searchresult>
      <!-- Query hint -->
      <query><xsl:value-of select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='q']" /></query>

      <!-- Emit documents. -->
      <xsl:for-each select="/response/result/doc">
        <document id="{count(preceding-sibling::doc)}">
          <url><xsl:value-of select="*[@name='url']" /></url>
          <title><xsl:value-of select="*[@name='title']" /></title>
          <snippet>
            <!-- Collect the snippet from highlighter output. -->
            <xsl:variable name="id" select="*[@name='name']" />
            <xsl:value-of select="$id" />
            <xsl:for-each select="/response/lst[@name='highlighting']/lst[@name=$id]/arr/str">
              ...<xsl:value-of select="." />
            </xsl:for-each>
          </snippet>
        </document>
      </xsl:for-each>

      <!-- Extract Solr-generated clusters if any. -->
      <xsl:if test="/response/arr[@name='clusters']">
        <xsl:comment>Clusters from Solr</xsl:comment>

        <xsl:for-each select="/response/arr[@name = 'clusters']/lst">
          <xsl:call-template name="cluster-adapter" />
        </xsl:for-each>
      </xsl:if>

      <!-- extra attributes -->
      <xsl:if test="/response/result/@numFound">
        <attribute key="results-total">
          <value type="java.lang.Long" value="{/response/result/@numFound}" />
        </attribute>
      </xsl:if>
    </searchresult>
  </xsl:template>

  <!-- Solr to Carrot2 cluster adapter. -->  
  <xsl:template name="cluster-adapter">
    <group>
      <xsl:if test="double[@name = 'score']">
        <xsl:attribute name="score"><xsl:value-of select="double[@name = 'score']"/></xsl:attribute>
      </xsl:if>

      <title>
        <xsl:for-each select="arr[@name = 'labels']/str">
          <phrase><xsl:value-of select="." /></phrase>
        </xsl:for-each>
      </title>
      
      <xsl:if test="bool[@name = 'other-topics'] = 'true'">
        <attribute key="other-topics"><value value="true"/></attribute>
      </xsl:if>

      <xsl:for-each select="arr[@name = 'docs']/str">
        <document refid="{count(key('docs',.)/preceding-sibling::doc)}" />
      </xsl:for-each>

      <!-- sub-clusters? -->
      <xsl:for-each select="arr[@name = 'clusters']/lst">
        <xsl:call-template name="cluster-adapter" />
      </xsl:for-each>
    </group>
  </xsl:template>
</xsl:stylesheet>
