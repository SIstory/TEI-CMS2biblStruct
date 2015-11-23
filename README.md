#TEI-CMS2biblStruct

Regular Expression-based Reference Metadata Extraction from [TEI](http://www.tei-c.org/index.xml) (Text Encoding Initiative) listBibl/bibl. TEI bibl element can only contains reference string and two additional child elements (ref[@target] and hi[@rend='italic']).

Reference string must be 
* Chicago Manual of Style and/or
* Turabian citation style.

For references in Slovene (notes and bibliography documentation system) use notes-bibliography/markup-literature-sl XSL stylesheets. Suitable for markup bibl element with additional bibliographic tags. Processing only references for literature (books, journal articles, part of books, conferance papers). You must save listBibl/bibl TEI elements in separate file. XSLT stylesheets will transform *.xml in *-V2.xml file. Output in intermediate data structure suitable for:
* comparing (and correcting) original bibl string (listBibl/bibl/string/*) with new listBibl/bibl/monogr/*, listBibl/bibl/analysis/*, and listBibl/bibl/online/* elements;
* transforming listBibl/bibl in listBibl/biblStruct (in accordance with TEI Guidelines);
* transforming listBibl/bibl in data format suitable for importing data in SICI (Slovenian Citation Index);
* making training data for mashine (supervised) learning.

XSL stylesheets markup2tei transform listBibl/bibl in listBibl/biblStruct (in accordance with TEI Guidelines).

In folder notes-bibliography/examples:
* markup-lit-sl.xml file contains examples of references - Chicago Manual of Style and Turabian citation style (Slovenian version).
* markup-lit-en.xml file contains examples of references - Chicago Manual of Style and Turabian citation style (English version).
* markup-lit-sl-V2.xml file contains examples trasformed from markup-lit-sl.xml with notes-bibliography/markup-literature-sl/main.xsl;
* markup-lit-sl-V2-TEI.xml file contains examples trasformed from markup-lit-sl-V2.xml with markup2tei/main.xsl


TODO (the sooner the better):
* notes-bibliography/markup-literature-en XSL stylesheets for references in English (and possibly other languages);
* XSL Stylesheets for author-date citation style; 
* XML Schema to validate intermediate data structure (murkup);
* markup2sici XSL Stylesheets.