xquery version "3.0";

module namespace lists="http://projects.cceh.uni-koeln.de:8080/apps/pessoa/lists";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace helpers="http://projects.uni-koeln.de:8080/apps/pessoa/helpers" at "helpers.xqm";

declare function lists:get-navi-list($node as node(), $model as map(*), $type as text()) as item()*{
    if ($type = "authors")
    then for $pers in doc("/db/apps/pessoa/data/lists.xml")//tei:listPerson[@type="authors"]/tei:person/tei:persName/data(.)
         order by $pers collation "?lang=pt"
         return <item label="{$pers}" ref="#" />
    else if ($type = "genres")
    then for $genre in doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="genres"][@n="2"]/tei:item   
        let $label :=$genre/data(.)
        let $ref := $genre/attribute() 
         order by $genre collation "?lang=pt" 
         return <item label="{$label}"  ref="{$helpers:app-root}/page/genre_{$ref}.html" />      
    else if ($type = "doc")
    then for $res in xmldb:get-child-resources("/db/apps/pessoa/data/doc")
         let $label := substring-after(replace(substring-before($res, ".xml"), "_", " "), "BNP E3 ")
         let $ref := concat($helpers:app-root, "/doc/", substring-before($res, ".xml"))
         order by $res collation "?lang=pt" 
         return if(doc(concat("/db/apps/pessoa/data/doc/",$res))//tei:sourceDesc/tei:msDesc) then (<item label="{$label}" ref="{$ref}" />) else()
    else if ($type = "pub")
    then for $item in doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"][@n="2"]/tei:item
         let $ref := concat($helpers:app-root, "/doc/", lists:get-doc-uri($item))
         order by $item/tei:title
         return <item label="{$item/tei:title}" ref="{$ref}">
                    {if ($item/tei:list)
                    then lists:get-sub-list($node, $model, $item)
                    else ()}
                </item>
    else if($type ="years")
    then for $years in doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="years"]/tei:item 
         order by $years collation "?lang=pt"
        return <item label="{$years}" ref="{$helpers:app-root}/page/year_{$years}.html" />
    else for $item in doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type=$type]/tei:item/data(.)
         order by $item collation "?lang=pt"
         return <item label="{$item}" ref="#" />
};

declare function lists:get-sub-list($node as node(), $model as map(*), $item as node()){
    for $subitem in $item/tei:list/tei:item
    let $ref := lists:get-doc-uri($subitem)
    return <item label="{$subitem/tei:title}" ref="{$ref}">
              {if ($subitem/tei:list) then lists:get-sub-list($node, $model, $subitem) else()}
           </item>
};

declare function lists:get-doc-uri($item){
    if (collection("/db/apps/pessoa/data/doc")//tei:titleStmt/tei:title[normalize-space(.) = normalize-space($item/tei:title)])
    then substring-before(util:document-name(root(collection("/db/apps/pessoa/data/doc")//tei:titleStmt/tei:title[. = $item/tei:title])), ".xml")
    else "#"
};