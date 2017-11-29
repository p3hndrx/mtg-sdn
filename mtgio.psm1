function get-mtgcard {

    param (
        [string]$n = "", 
        [string]$t = "",        
        [string]$c = "",
        [string]$r = "",
        [string]$s = "",
        [string]$i = "",
        [string]$text = "",
        [string]$f = "0",         #format table by default, accepts anything
        [string]$o = "cmc"        #order by CMC by default, accepts returned variables
    )
    #confirm params:
        Write-Host "Query:"
        if($n){Write-Host "`tName:" $n -ForegroundColor Green}
        if($i){Write-Host "`tMultiverseID:" $i -ForegroundColor Yellow}
        if($t){Write-Host "`tType(s):" $t.replace(","," -and ").replace("|"," -or ")}
        if($c){Write-Host "`tColor(s):" $c.replace(","," -and ").replace("|"," -or ")}
        if($r){Write-Host "`tRarity:" $r.replace(","," -and ").replace("|"," -or ")}
        if($s){Write-Host "`tSet(s):" $s.replace(","," -and ").replace("|"," -or ")}
        if($text){Write-Host "`tText Contains:" $text}

    #API call
    $root = "https://api.magicthegathering.io/v1/cards?"

    #convert params
        if($n -ne ""){$n = "`&name="+$n}
        if($t -ne ""){$t = "`&type="+$t}   #e.g. Angel, Dwarf
        if($c -ne ""){$c = "`&colors="+$c} #e.g. Red, White, Green, multi-allowed
        if($r -ne ""){$r = "`&rarity="+$r}
        if($s -ne ""){$s = "`&set="+$s}
        if($i -ne ""){$i = "`&multiverseid="+$i}
        if($text -ne ""){
            #$text = "`&text=`""+$text+"`""
            $text = "`&text="+$text.Replace("+","&#43")
            }

    #construct
    $url = $root+$n+$i+$t+$c+$r+$s+$text

    #fetch
    $card = wget $url
    $converted = $card.Content | ConvertFrom-Json | Select-Object -Expand Cards
       

    #format
        if($converted.count -eq 0)  #Results based on count..
                {
                    $f = "x"
                    $result = "Results: 0"
                } elseif($card.Headers.'Total-Count' -eq 1) 
                {
                    $f = "x"
                    $result = "Result: 1"
                } else { $result = "Results: "+$converted.count}
        if($f -eq "0")
            {
                $converted | select name, manaCost, type, set, rarity, multiverseid, text, cmc | sort-object -property $o | FT
                Write-Host $result "of" $card.Headers.'Total-Count'
               
            }
        if($f -ne "0")
            {
                $converted | sort-object -property name 
                Write-Host $result "of" $card.Headers.'Total-Count'
                
            }

    #Display Count Warning
    if($converted.count -ge 100) {Write-Host "Please filter your selection... `n Hint: `n`t-s <set(s)> `n`t-t <type(s)> `n`t-c <color(s)> `n`t-text <keyword search>" -ForegroundColor Gray}
    Write-Host "`nAPI Call:  $url"
}
Write-Host Imported...
