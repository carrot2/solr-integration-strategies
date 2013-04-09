<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output indent="yes" omit-xml-declaration="no" media-type="application/xml" encoding="UTF-8" />

  <xsl:key name="docs" match="/response/result/doc" use="*[@name='name']"/>

  <xsl:template match="/">
    <searchresult>
      <!-- query hint -->
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

      <!-- Emit clusters, if present. -->
      <xsl:comment>Clusters from Solr</xsl:comment>

      <xsl:for-each select="/response/arr[@name = 'clusters']/lst">
        <group>
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
        </group>
      </xsl:for-each>

      <!-- extra attributes -->
      <xsl:if test="/response/result/@numFound">
        <attribute key="results-total">
          <value type="java.lang.Long" value="{/response/result/@numFound}" />
        </attribute>
      </xsl:if>
    </searchresult>
  </xsl:template>
</xsl:stylesheet>
