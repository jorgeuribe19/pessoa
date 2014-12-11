xquery version "3.0";

(:module namespace app="http://projects.cceh.uni-koeln.de:8080/apps/pessoa/templates";:)
module namespace app="http://localhost:8080/exist/apps/pessoa/templates";
import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
(:
import module namespace config="http://projects.cceh.uni-koeln.de:8080/apps/pessoa/config" at "config.xqm";
import module namespace lists="http://projects.cceh.uni-koeln.de:8080/apps/pessoa/lists" at "lists.xqm";
import module namespace doc="http://projects.cceh.uni-koeln.de:8080/apps/pessoa/doc" at "doc.xqm";
import module namespace helpers="http://projects.uni-koeln.de:8080/apps/pessoa/helpers" at "helpers.xqm";

:)
import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";
import module namespace lists="http://localhost:8080/exist/apps/pessoa/lists" at "lists.xqm";
import module namespace doc="http://localhost:8080/exist/apps/pessoa/doc" at "doc.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace kwic="http://exist-db.org/xquery/kwic";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace text="http://exist-db.org/xquery/text";

declare namespace request="http://exist-db.org/xquery/request";

declare namespace tei="http://www.tei-c.org/ns/1.0";
(:declare namespace range="http://exist-db.org/xquery/range";:)

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with a class attribute: class="app:test". The function
 : has to take exactly 3 parameters.
 : 
 : @param $node the HTML node with the class attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:test($node as node(), $model as map(*)) {
    <p>Dummy template output generated by function app:test at {current-dateTime()}. The templating
        function was triggered by the class attribute <code>class="app:test"</code>.</p>
};

declare %templates:wrap function app:list($node as node(), $model as map(*), $type as text(), $indikator as xs:string?) as node()*{
    for $item in lists:get-navi-list($node, $model, $type, $indikator)
    return
        if ($item/item)
        then app:submenu($node, $model, $item)
        else if($type = "years")
            then 
            if( lists:get-navi-list($node, $model, $type, concat("0",$indikator))!="") then <div class="divCell"><a href="{$item/@ref/data(.)}">{$item/@label/data(.), $indikator}</a></div>
            else if( lists:get-navi-list($node, $model, $type, concat("1",$indikator))!="") then <div class="divCell"><a href="{$item/@ref/data(.)}">{$item/@label/data(.), $indikator}</a></div>
            else <div class="divCell">Nothin, {$indikator}</div>
            (:<div id="{$item/@id}"><a href="{$item/@ref/data(.)}">{$item/@label/data(.)}</a></div>:)
        else <li><a href="{$item/@ref/data(.)}">{$item/@label/data(.)}</a></li>
};



declare function app:submenu($node as node(), $model as map(*), $item as node()){
    <li class="dropdown-submenu">
        <a href="{$item/@ref/data(.)}">{$item/@label/data(.)}</a>
        <ul class="dropdown-menu">
            {for $subitem in $item/item
            return if ($subitem/item)
                   then app:submenu($node, $model, $subitem)
                   else
                    <li>
                        <a href="{$subitem/@ref/data(.)}">{$subitem/@label/data(.)}</a>
                    </li>}
        </ul>
     </li>
};

declare %templates:wrap function app:sort-years($node as node(), $model as map(*), $type as text(), $indikator as xs:string?) as node()* {
    (: if (exists(lists:get-navi-list($node, $model, $type, $indikator)))
    then      
        <div class="divCell"><a href="{$item/@ref/data(.)}">{$item/@label/data(.), $indikator}</a></div>
        else <div class="divCell" >Nothin {$indikator}</div> :)
        for $sp in (0 to 3)
        let $sort := concat($sp, $indikator)
        let $item := lists:get-navi-list($node, $model, $type, $sort)
        return if($item) then
        <div class="divCell"><a href="{$item/@ref/data(.)}">{$item/@label/data(.)}</a></div>
        else <div class='divCell'>&#x00A0; </div>
};

declare %templates:wrap function app:table ($node as node(), $model as map(*), $type as text()) as node()*{
    for $indikator in (1 to 9)    
          return <td> 
            {if(exists(app:content($node, $model, $type, $indikator))) 
            then app:content($node, $model, $type, $indikator) 
            else ()}
        </td>
};

declare %templates:wrap function app:table2($node as node(), $model as map(*), $type as text(), $indikator as xs:string?) as node()*{
    <td>{
    for $item in lists:get-navi-list($node, $model, $type, $indikator)
    return <div><a href="{$item/@ref/data(.)}">{$item/@label/data(.)}</a></div>
    }</td>
};



declare %templates:wrap function app:content ($node as node(), $model as map(*), $type as text(), $indikator as xs:string) as node()*{
for $item in lists:get-navi-list($node, $model, $type, $indikator)        
      return <div ><a href="{$item/@ref/data(.)}" id="{$item/@label/data(.)}">{$item/@label/data(.)}</a></div>
};

(: Such Funktion :)
declare %templates:wrap function app:search( $node as node(), $model as map(*), $term as xs:string?) as map(*) {
   
   (:
   for $m in collection("/db/apps/pessoa/data/doc")//tei:origDate[ft:query(.,$q)]
order by ft:score($m) descending
:)
    if(exists($term) and $term !=" ")
    then
        let $result-text := collection("/db/apps/pessoa/data/doc")//tei:text[ft:query(.,$term)]
        let $result-head := collection("/db/apps/pessoa/data/doc")//tei:msItemStruct[ft:query(.,$term)]
        let $result := ($result-text, $result-head)
        return map{
        "result" := $result,
        "result-text" := $result-text,
        "result-head" := $result-head,
        "query" := $term
        }
        else map{
        "resilt-text":=(),
        "result-head":=(),
        "query" := '"..."'
        }
};
(:Profi Suche:)
declare  %templates:wrap function app:search-profi( $node as node(), $model as map(*), $term as xs:string?) as map(*) {

   (:
   for $m in collection("/db/apps/pessoa/data/doc")//tei:origDate[ft:query(.,$q)]
order by ft:score($m) descending
:)
    if(exists($term) and $term !="")
    then
        (:
        let $lang := if($parameters ="lang") then app:search-value($parameters,"language") else ""
        let $date := if($parameters ="date") then app:search-value($parameters,"date") else ""
        :)
        let $collect := collection("/db/apps/pessoa/data/doc")
        (:
        let $filter-lang := if($lang !="") then $collect//range:field-eq(("mainLang"),$lang)  else if($collect//range:field-eq(("mainLang"),$lang)= "") then $collect//range:field-eq(("otherLang"),$lang)  else $collect
        let $filter-date := if($date != "") then $collect//range:field-eq(("date_when"),"1915") else $collect
        :)      
             
        let $query:= <query><bool><term occur="must">{$term}</term></bool></query>
        let $result-text := $collect//tei:text[ft:query(.,$query)] 
        let $result-head := $collect//tei:msItemStruct[ft:query(.,$query)] 
        
       
       
       (: let $result-lang := collection("/db/apps/pessoa/data/doc")//tei:msItemStruct/tei:textLang[ft:query(@mainLang,'pt')]/@mainLang/data(.) :)

        (:collection("/db/apps/pessoa/data/doc")//tei:msItemStruct/tei:textLang/range:field-eq(("mainLang"),$lang):)
        
        (: //range:field-eq( ( %para1%, %para2%),%search1%,%search2%) :)
     (:   let $db := "/db/apps/pessoa/data/doc"
        let $filter-att := app:filter-att_build()
        let $filter-para := app:filter-para_build()
        let $filter-connect := concat('("',$filter-para,'"),"',$filter-att,'"')
        let $filter-search := concat("//range:field-eq(",$filter-connect,")")
        let $filter-build := concat("collection($db)",$filter-search)
       
       let $result-filter := $filter-build  :) (:util:eval($filter-build):)
       
        (:       let $result-filter := ($filter-para ,$filter-att) :)

        let $result-filter := "Nothin"
        
        let $result := ($result-text, $result-head, $result-filter)
        return map{
        "result" := $result,
        "result-text" := $result-text,
        "result-head" := $result-head,    
        "result-filter" := $result-filter,
        "query" := $term
        
        }
        else map{
        "result-text":=(),
        "result-head":=(),
        "result-filter" := (),
        "query" := '"..."'
        }
        
};

(: Neu Entstehung der Profi Suche :)
(: Alten Funtkionen rausgelöscht, gespeichert im Drive :)

declare %templates:wrap function app:profisearch($node as node(), $model as map(*), $term as xs:string?) as map(*) {
    if(exists($term) and $term != "")
    then
        (: Erstellung der Kollektion, soriert ob "Publiziert" oder "Nicht Publiziert" :)
        for $match in app:set_db()
            let $db := $match
        
        (: Unterscheidung nach den Sprachen, ob "Und" oder "ODER" :)
        let $r_lang := if(app:get-parameters("lang_ao") = "or") 
                       then app:get_lang($db)
                       else ()
        (: Sortierung nach Genre :)
        let $r_genre := if(app:get-parameters("genre")!="") then app:filter-query("genre",$r_lang)
                        else ()
                        
        (:Suche nach "Erwähnten" Rollen:)
        let $r_mention := if(app:get-parameters("notional")="mentioned") then app:author_build($r_lang)
                        else ()
        
        let $r_all := ($r_lang,$r_genre,$r_mention)
        
        return map{
            "r_all"     := $r_all,
            "r_lang"    := $r_lang,
            "r_genre"   := $r_genre,
            "r_mention" := $r_mention
        
        }
        else map {
            "r_all"     := (),
            "r_lang"    := (),
            "r_genre"   := (),
            "r_mention" := ()
        }

};

declare function app:set_db() as xs:string+ {
        let $result :=    if(app:get-parameters("release") = "non_public")  then "/db/apps/pessoa/data/doc"
                   else if(app:get-parameters("release") = "public" ) then "/db/apps/pessoa/data/pub"
                   else ("/db/apps/pessoa/data/doc","/db/apps/pessoa/data/pub")
                   return $result
};

(: Funtkion um die Parameter rauszufiltern:)
declare function app:get-parameters($key as xs:string) as xs:string* {
    for $hit in request:get-parameter-names()
        return if($hit=$key) then request:get-parameter($hit,'')
                else ()
};
(: ODER FUNTKION : Filter die Sprache :) 
declare function app:get_lang($db as xs:string) as node()* {
    for $hit in app:get-parameters("lang")
        let $para := ("mainLang","otherLang")
        for $match in $para
        let $search_terms := concat('("',$match,'"),"',$hit,'"')
        let $search_funk := concat("//range:field-eq(",$search_terms,")")
        let $search_build := concat("collection($db)",$search_funk)
        let $result :=  util:eval($search_build)
        return $result
};




declare function app:filter-query($para as xs:string, $db as node()*) as node()* {
    for $hit in app:get-parameters($para)
        let $hit := if($para = "genre") then replace($hit, "_", " ")
                    else $hit
        
            let $query := <query><bool><term occur="must">{$hit}</term></bool></query>
            let $search_funk := "[ft:query(.,$query)]"
            let $search_build := concat("collection($db)//tei:msItemStruct",$search_funk) 
            let $result := util:eval($search_build)
            return $result
};

declare function app:get-result($para as xs:string, $db as node()*) as node()* {
    for $hit in app:get-parameters($para)    
        let $para := if($para = "author") then replace($para, "author","key")
            else $para
        let $search_terms := concat('("',$para,'"),"',$hit,'"')
        let $search_funk := concat("//range:field-eq(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        let $r_search :=  util:eval($search_build)
        let $result := $r_search
        return $result
};


declare function app:author_build($db as node()*) as node()* {
        for $person in app:get-parameters("person")
           for $term in app:get-parameters("role")
                let $merge := concat('("key","role"),','"',$person,'","',$term,'"')
                let $build_range :=concat("//range:field-eq(",$merge,")")
                let $build_search := concat("collection($db)",$build_range)
                let $result := util:eval($build_search)
            return $result
           
};


declare function app:profiresult($node as node(), $model as map(*), $sel as xs:string) as node()+ {
   if(exists($sel) and $sel=("lang","genre","mention","all"))
   then
   if(exists($model(concat("r_",$sel)))) 
    then 
        for $hit in $model(concat("r_",$sel))
        (:
        return <p> Exist, {$model("profi_result")}</p>
        else <p>Dos Not Exist </p>
        :)
        let $file-name := root($hit)/util:document-name(.)            
        return <p>Exist,{$file-name}</p>            
        else <p> Dos Not exist,{$model("r_all")}</p>
        
        (:
        return <p>Exist,{$model("profi_result"),$file-name}</p>            
        else <p> Dos Not exist,{$model("profi_result")}</p>
        :)
        else <p>Error</p>
};      

(: Ende der Neuen Funktionen :)

declare  function app:result-filter ($node as node(), $model as map(*), $sel as xs:string) as node()+ {
    if(exists($sel) and $sel = ("filter"))
    then
        if(exists($model(concat("r_",$sel))))  
        then 
        
            for $hit in $model("result-filter")
            return <p>Exist, {$model("result-filter")}</p>
            else <p>Dos Not exist</p>
            
            (:
        for $hit in $model("result-filter")
            let $file-name := root($hit)/util:document-name(.)            
            return <p>Exist,{$sel,$model("result-filter"),$file-name}</p>            
        else <p> Dos Not exist,{$sel,$model("result-filter")}</p>
        :)
    else $sel
};

declare function app:result-list ($node as node(), $model as map(*), $sel as xs:string) as node()+ {
    if (exists($sel) and $sel = ("text", "head"))
    then
        if (exists($model(concat("result-",$sel))))
        then
        let $term := $model("query") 
            for $hit in $model(concat("result-", $sel))
            let $file-name := root($hit)/util:document-name(.)
            let $title := 
            if(doc(concat("/db/apps/pessoa/data/doc/",$file-name))//tei:sourceDesc/tei:msDesc) 
                then doc(concat("/db/apps/pessoa/data/doc/",$file-name))//tei:msDesc/tei:msIdentifier/tei:idno[1]/data(.)
                else doc(concat("/db/apps/pessoa/data/doc/",$file-name))//tei:biblStruct/tei:analytic/tei:title[1]/data(.)
            let $expanded := kwic:expand($hit)
        return if($sel != "head")
            then 
            <li>
            <a href="data/doc/{concat(substring-before($file-name, ".xml"),'?term=',$model("query"), '&amp;file=', $file-name)}">{$title}</a>
            {kwic:get-summary($expanded,($expanded//exist:match)[1], <config width ="40"/>)}
            </li>
            else 
            <li> 
            <a href="data/doc/{concat(substring-before($file-name, ".xml"),'?term=',$model("query"), '&amp;file=', $file-name)}">{$title}</a>
            {kwic:get-summary($expanded,($expanded//exist:match)[1], <config width ="0" />)}</li>
        else <p> Keine Treffer </p>
        else $sel
};


declare function app:highlight-matches($node as node(), $model as map(*), $term as xs:string?, $sel as xs:string, $file as xs:string?) as node() {
if($term and $file and $sel and $sel="text","head","lang") 
    then
        let $result := if ($sel = "text")
        then doc(concat("/db/apps/pessoa/data/doc/",$file))//tei:text[ft:query(.,$term)]
        else ()
        let $css := doc("/db/apps/pessoa/highlight-matches.xsl")
        let $exp := if (exists($result)) then kwic:expand($result[1]) else ()
        let $exptrans := if (exists($exp))
                         then transform:transform($exp, $css, ())
                         else ()
        return
            if (exists($exptrans))
            then $exptrans
            else $node
    else $node
};

(:
declare function app:highlight-matches($node as node(), $model as map(*), $q as xs:string?, $f as xs:string?, $c as xs:string) as node(){
    if($q and $f and $c and $c = ("tcrit", "tp1", "tca", "mss", "aux"))
    then
        let $result := if ($c = "tcrit" or $c = "tp1")
                        then doc(concat("/db/apps/guillelmus/data/", $c ,"/", $f))//xhtml:div[@id='content'][ft:query(., $q)]
                        else if ($c = "tca")
                        then doc(concat("/db/apps/guillelmus/data/", $c ,"/", $f))//xhtml:table[contains(@class, 'MsoTableGrid')][ft:query(., $q)]
                        else doc(concat("/db/apps/guillelmus/data/", $c ,"/", $f))//xhtml:div[@id='staticcontent'][ft:query(., $q)]
        let $exp := if (exists($result)) then kwic:expand($result[1]) else ()
        let $stylesheet := doc("/db/apps/guillelmus/highlight-matches.xsl") 
        let $exptrans := if (exists($exp))
                         then transform:transform($exp, $stylesheet, ())
                         else ()
        return
            if (exists($exptrans))
            then $exptrans
            else $node
    else $node
};
:)





