---
title: "Query Syntax Guide"
tags: [getting_started, query]
summary: This page gives an overview of DataWave's JEXL and Lucene query syntax options
---
<h2>Introduction</h2>
<p>DataWave's query logic implementations will typically accept expressions conforming to either JEXL syntax (the default)
   or our modified Lucene syntax. As for JEXL, DataWave supports a subset of the language elements in the Apache Commons JEXL
   grammar, and implements some of its own custom JEXL functions as well. As a convenience, DataWave has also enabled Lucene syntax
   support, which, except where noted, provides equivalent functionality to JEXL
</p>
<h2>JEXL Query Syntax</h2>
<hr />
<h3>Supported JEXL Operators</h3>
<ul>
    <li>==</li>
    <li>!=</li>
    <li>&lt;</li>
    <li>&le;</li>
    <li>&gt;</li>
    <li>&ge;</li>
    <li>=~ (regex)</li>
    <li>!~ (negative regex)</li>
</ul>
<hr />
<h3>Custom JEXL Functions</h3>
<ul>
    <li>Content functions<ul><li>phrase()</li><li>adjacent()</li><li>within()</li></ul></li>
    <li>Geospatial Functions
       <ul>
         <li>within_bounding_box()</li>
         <li>within_circle()</li>
         <li>intersects_bounding_box()</li>
         <li>intersects_radius_km()</li>
         <li>contains()</li>
         <li>covers()</li>
         <li>coveredBy()</li>
         <li>crosses()</li>
         <li>intersects()</li>
         <li>overlaps()</li>
         <li>within()</li>
       </ul>
    </li>
    <li>Utility Functions<ul><li>between()</li><li>length()</li></ul></li>
</ul>
<hr />
<h3>JEXL Unfielded Queries</h3>
<p>
  JEXL is an expression language and not a text-query language per se, so JEXL doesn't natively support the notion of an 
  'unfielded' query, that is, a query expression containing only search terms and no specific field names to search within.
</p>
<p>
  As a convenience, DataWave does provide support for unfielded JEXL queries, at least for the subset of 
  <a href="../development/query-api#query-logic-components">query logic</a> types that are designed to retrieve objects from the 
  <a href="data-model#primary-data-table">primary data table</a>. However, to achieve this with JEXL, the user must add the 
  internally-recognized pseudo field, <b>_ANYFIELD_</b>, to the query in order for it to pass syntax validation.
  See the examples below for usage.
</p>
<hr/>
<h2>Lucene Query Syntax</h2>
<p>DataWave provides a slightly modified Lucene syntax, such that the <b>NOT</b> operator is not unary, <b>AND</b> operators are not
fuzzy, and the implicit operator is <b>AND</b> instead of <b>OR</b>.
</p>
<p>Our Lucene syntax has the following form</p>
<pre>
    ModClause ::= DisjQuery [NOT DisjQuery]*
    DisjQuery ::= ConjQuery [ OR ConjQuery ]*
    ConjQuery ::= Query [ AND Query ]*
    Query ::= Clause [ Clause ]*
    Clause ::= Term | [ ModClause ]
    Term ::=
        field:selector |
        field:selec* |
        field:selec*or |
        field:*lector |
        field:selec?or |
        selector | (can use wildcards)
        field:[begin TO end] |
        field:{begin TO end} |
        "quick brown dog" |
        "quick brown dog"~20 |
        #FUNCTION(ARG1, ARG2)
</pre>
<p>Note that to search for punctuation characters within a term, you need to escape it with a backslash.</p>
<hr/>
<h2>JEXL and Lucene Examples</h2>
<h3>Custom Lucene Functions</h3>
<p>DataWave has augmented Lucene to provide support for several JEXL features that were not supported natively. 
   The table below maps the JEXL operators to the supported Lucene syntax
</p>
<table>
    <tr><th>JEXL Operator</th><th>Lucene Operator</th></tr>
    <tr class="highlight"><td>filter:includeRegex(field, regex)</td><td>#INCLUDE(field, regex)</td></tr>
    <tr><td>filter:excludeRegex(field, regex)</td><td>#EXCLUDE(field, regex)</td></tr>
    <tr class="highlight"><td>filter:includeRegex(field1, regex1) &lt;op&gt; filter:includeRegex(field2, regex2) ...</td><td>#INCLUDE(op, field1, regex1, field2, regex2 ...) where op is 'or' or 'and'</td></tr>
    <tr><td>filter:excludeRegex(field1, regex1) &lt;op&gt; filter:excludeRegex(field2, regex2) ...</td><td>#EXCLUDE(op, field1, regex1, field2, regex2 ...) where op is 'or' or 'and'</td></tr>
    <tr class="highlight"><td>filter:isNull(field)</td><td>#ISNULL(field)</td></tr>
    <tr><td>not(filter:isNull(field))</td><td>#ISNOTNULL(field)</td></tr>
    <tr class="highlight"><td>filter:occurrence(field,operator,count))</td><td>#OCCURRENCE(field,operator,count)</td></tr>
    <tr><td>filter:timeFunction(field1,field2,operator,equivalence,goal)</td><td>#TIME_FUNCTION(field1,field2,operator,equivalence,goal)</td></tr>
</table>
<p>Notes:</p>
<ol>
   <li>None of these filter functions can be applied against index-only fields.</li>
   <li>The occurrence function is used to count the number of instances of a field in the event.  Valid operators are '==' (or '='),'>','>=','<','<=', and '!='. </li>
</ol>
<h3>Basic Geospatial Functions</h3>
<p>
Some geo functions are supplied as well that may prove useful although the within_bounding_box function may be done with a simple range comparison (i.e. LAT_LON_USER &lt;= &lt;lat1&gt;_&lt;lon1&gt; and LAT_LON_USER &gt;= &lt;lat2&gt;_&lt;lon2&gt;.
</p>
<table>
    <tr><th>JEXL Operator</th><th>Lucene Operator</th></tr>
    <tr class="highlight"><td>geo:within_bounding_box(latLonField, lowerLeft, upperRight)</td><td>#GEO(bounding_box, latLonField, 'lowerLeft', 'upperRight')</td></tr>
    <tr><td>geo:within_bounding_box(lonField, latField, minLon, minLat, maxLon, maxLat)</td><td>#GEO(bounding_box, lonField, latField, minLon, minLat, maxLon, maxLat)</td></tr>
    <tr class="highlight"><td>geo:within_circle(latLonField, center, radius)</td><td>#GEO(circle, latLonField, center, radius)</td></tr>
</table>
<p>Notes:</p>
<ol>
   <li>All lat and lon values are in decimal.</li>
   <li>The lowerLeft, upperRight, and center are of the form &lt;lat&gt;_&lt;lon&gt; and must be surrounded by single quotes.</li>
   <li>The radius is in decimal degrees as well.</li>
</ol>
<h3>GeoWave Functions</h3>
<a href="https://locationtech.github.io/geowave" target="_blank">GeoWave</a> is an optional component that provides the following
functions when enabled
<table>
    <tr><th>JEXL Operator</th><th>Lucene Operator</th></tr>
    <tr class="highlight"><td>geowave:intersects_bounding_box(geometryField, westLon, eastLon, southLat, northLat)</td><td>#INTERSECTS_BOUNDING_BOX(geometryField, westLon, eastLon, southLat, northLat)</td></tr><tr>
    <td>geowave:intersects_radius_km(geometryField, centerLon, centerLat, radiusKm)</td><td>#INTERSECTS_RADIUS_KM(geometryField, centerLon, centerLat, radiusKm)</td></tr>
    <tr class="highlight"><td>geowave:contains(geometryField, Well-Known Text)</td><td>#CONTAINS(geometryField, centerLon, centerLat, radiusDegrees)</td></tr>
    <tr><td>geowave:covers(geometryField, Well-Known Text)</td><td>#COVERS(geometryField, Well-Known Text)</td></tr>
    <tr class="highlight"><td>geowave:coveredBy(geometryField, Well-Known Text)</td><td>#COVERED_BY(geometryField, Well-Known Text)</td></tr>
    <tr><td>geowave:crosses(geometryField, Well-Known Text)</td><td>#CROSSES(geometryField, Well-Known Text)</td></tr>
    <tr class="highlight"><td>geowave:intersects(geometryField, Well-Known Text)</td><td>#INTERSECTS(geometryField, Well-Known Text)</td></tr>
    <tr><td>geowave:overlaps(geometryField, Well-Known Text)</td><td>#OVERLAPS(geometryField, Well-Known Text)</td></tr>
    <tr class="highlight"><td>geowave:within(geometryField, Well-Known Text)</td><td>#WITHIN(geometryField, Well-Known Text)</td></tr>
</table>
<p>Notes:</p>
<ol>
    <li>All lat and lon values are in decimal degrees.</li>
    <li>The lowerLeft, upperRight, and center are of the form &lt;lat&gt;_&lt;lon&gt; and must be surrounded by single quotes.</li>
    <li>Geometry is represented according to the Open Geospatial Consortium standard for Well-Known Text. It is in decimal degrees longitude for x, amd latitude for y.  For example, a point at New York can be represented as 'POINT (-74.01 40.71)' and a box at New York can be repesented as 'POLYGON(( -74.1 40.75, -74.1 40.69, -73.9 40.69, -73.9 40.75, -74.1 40.75)); </li>
</ol>
<h3>Date Functions</h3>
<p>There are some additional functions that are supplied to handle dates more smoothly.  It is intended that the need for these functions
    may go away in future versions (<b>bolded</b> parameters are literal, other parameters are substituted with appropriate values):
</p>
<table>
    <tr><th>JEXL Operator</th><th>Lucene Operator</th></tr>
    <tr class="highlight"><td>filter:betweenDates(field, start date, end date)</td><td>#DATE(field, start date, end date) or #DATE(field, <b>between</b>, start date, end date)</td></tr>
    <tr><td>filter:betweenDates(field, start date, end date, start/end date format)</td><td>#DATE(field, start date, end date, start/end date format) or #DATE(field, <b>between</b>, start date, end date, start/end date format)</td></tr>
    <tr class="highlight"><td>filter:betweenDates(field, field date format, start date, end date, start/end date format)</td><td>#DATE(field, field date format, start date, end date, start/end date format) or #DATE(field, <b>between</b>, field date format, start date, end date, start/end date format)</td></tr>
    <tr><td>filter:afterDate(field, date)</td><td>#DATE(field, <b>after</b>, date)</td></tr>
    <tr class="highlight"><td>filter:afterDate(field, date, date format)</td><td>#DATE(field, <b>after</b>, date, date format)</td></tr>
    <tr><td>filter:afterDate(field, field date format, date, date format)</td><td>#DATE(field, <b>after</b>, field date format, date, date format)</td></tr>
    <tr class="highlight"><td>filter:beforeDate(field, date)</td><td>#DATE(field, <b>before</b>, date)</td></tr>
    <tr><td>filter:beforeDate(field, date, date format)</td><td>#DATE(field, <b>before</b>, date, date format)</td></tr>
    <tr class="highlight"><td>filter:beforeDate(field, field date format, date, date format)</td><td>#DATE(field, <b>before</b>, field date format, date, date format)</td></tr>
    <tr><td>filter:betweenLoadDates(<b>LOAD_DATE</b>, start date, end date)</td><td>#LOADED(start date, end date) or #LOADED(<b>between</b>, start date, end date)</td></tr>
    <tr class="highlight"><td>filter:betweenLoadDates(<b>LOAD_DATE</b>, start date, end date, start/end date format)</td><td>#LOADED(start date, end date, start/end date format) or #LOADED(<b>between</b>, start date, end date, start/end date format)</td></tr>
    <tr><td>filter:afterLoadDate(<b>LOAD_DATE</b>, date)</td><td>#LOADED(<b>after</b>, date)</td></tr>
    <tr class="highlight"><td>filter:afterLoadDate(<b>LOAD_DATE</b>, date, date format)</td><td>#LOADED(<b>after</b>, date, date format)</td></tr>
    <tr><td>filter:beforeLoadDate(<b>LOAD_DATE</b>, date)</td><td>#LOADED(<b>before</b>, date)</td></tr>
    <tr class="highlight"><td>filter:beforeLoadDate(<b>LOAD_DATE</b>, date, date format)</td><td>#LOADED(<b>before</b>, date, date format)</td></tr>
    <tr><td>filter:timeFunction(<b>DOWNTIME</b>, <b>UPTIME</b>, '-', '>', 2522880000000L)</td><td>#TIME_FUNCTION(<b>DOWNTIME</b>, <b>UPTIME</b>, '-', '>', '2522880000000L')</td></tr>
</table>
<p>Notes:</p>
<ol>
    <li>None of these filter functions can be applied against index-only fields.</li>
    <li>Between functions are inclusive, and the other functions are exclusive of the entered dates.</li>
    <li>Date formats must be entered in the Java SimpleDateFormat object format.</li>
    <li>If the entered date format is not specified, then the following list of date formats will be tried:</li>
    <ul>
        <li>yyyyMMdd:HH:mm:ss:SSSZ</li>
        <li>yyyyMMdd:HH:mm:ss:SSS</li>
        <li>EEE MMM dd HH:mm:ss zzz yyyy</li>
        <li>d MMM yyyy HH:mm:ss 'GMT'</li>
        <li>yyyy-MM-dd HH:mm:ss.SSS Z</li>
        <li>yyyy-MM-dd HH:mm:ss.SSS</li>
        <li>yyyy-MM-dd HH:mm:ss.S Z</li>
        <li>yyyy-MM-dd HH:mm:ss.S</li>
        <li>yyyy-MM-dd HH:mm:ss Z</li>
        <li>yyyy-MM-dd HH:mm:ssz</li>
        <li>yyyy-MM-dd HH:mm:ss</li>
        <li>yyyyMMdd HHmmss</li>
        <li>yyyy-MM-dd'T'HH'|'mm</li>
        <li>yyyy-MM-dd'T'HH':'mm':'ss'.'SSS'Z'</li>
        <li>yyyy-MM-dd'T'HH':'mm':'ss'Z'</li>
        <li>MM'/'dd'/'yyyy HH':'mm':'ss</li>
        <li>E MMM d HH:mm:ss z yyyy</li>
        <li>E MMM d HH:mm:ss Z yyyy</li>
        <li>yyyyMMdd_HHmmss</li>
        <li>yyyy-MM-dd</li>
        <li>MM/dd/yyyy</li>
        <li>yyyy-MMMM</li>
        <li>yyyy-MMM</li>
        <li>yyyyMMddHHmmss</li>
        <li>yyyyMMddHHmm</li>
        <li>yyyyMMddHH</li>
        <li>yyyyMMdd</li>
    </ul>
    <li>A special date format of 'e' can be supplied to mean milliseconds since epoch.</li>
</ol>
