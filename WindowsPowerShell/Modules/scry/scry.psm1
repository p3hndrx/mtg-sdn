function scry {
  
    param (
        [string]$n = "", 
        [string]$q = "",
        [string]$o = "name", #by default
        [string]$help = "",
        [string]$topic = "Cards",
        [string]$f = "json"

    )
    

    #confirm params:
        if($n){Write-Host "`tName:" $n -ForegroundColor Green}
        if($q){Write-Host "`tQuery:" $q -ForegroundColor Cyan}
        

    #API calls
    $rootSearch = "https://api.scryfall.com/cards/search?"
    $rootNamed  = "https://api.scryfall.com/cards/named?fuzzy="
    $readme = "$home\Documents\WindowsPowerShell\Modules\scry\help.txt"

    #helper text
    if($help -ne "")
      {
       Write-Host "Usage:  scry -q <syntax> -f <json/csv> -o <sort>"
       Write-Host "`nExamples:"
       gc $readme | sls $help
      }
       

        #conduct a named search
        if($n -ne "")
            {
            #constructor
            $n = "`""+$n+"`""
            $url = $rootNamed+$n+"&format="+$f  
                  

                    #fetch
                    Write-Host "`nAPI Call:  $url"

                    switch($f)
                    {
                    "text"{
                            $card = wget $url
                            $converted = $card.content
                            $converted
                          }
                    "json" {
                            $card = wget $url
                            $converted = $card.content | ConvertFrom-Json
                            $converted  
                          }
                    "image" {
                            #slightly different request
                            $url = $rootNamed+$n+"&format="+$f+"&version=png"
                            
                            #check for save paths
                            if(!$scrypath) {
                                    Write-Host "You do not have a save path, please select one. --e.g.`$scrypath = `"$home\Desktop`""
                                    Write-Host "Your home: $home"
                                    $scrypath = Read-Host -Prompt 'Save Location::' 
                                    $scrypath = [string]$scrypath
                                       }

                            #get file
                            $req = [System.Net.HttpWebRequest]::Create($url)
                            $req.Method = "HEAD"
                            $response = $req.GetResponse()
                            $fUri = $response.ResponseUri
                            $filename = [System.IO.Path]::GetFileName($fUri.LocalPath); 
                            $response.Close()

                            $target = "$scrypath\$filename"
                            wget $url -outfile $target
                            $ren = "$scrypath\$n.png"
                            
                            #rename
                            mv $target $ren.Replace('"','')

                          }
                    default {}

                    
                    }
            }

        #conduct a card search
        if($q -ne "")
            {
           # $q = "`""+$q+"`""
                    $o = "order=$o&"
                    #construct
                    $q = [System.Web.HttpUtility]::UrlEncode($q)
                    $url = $rootSearch+$o+"q="+$q+"&format="+$f
                    
                    #fetch
                    Write-Host "`nAPI Call:  $url"
                    
                    if($f -eq "json"){
                    $card = wget $url
                    $converted = $card.content | ConvertFrom-Json
                    $converted.data
                    $converted.count       
                    }
                    if($f -eq "csv"){
                    $card = wget $url
                    $converted = $card.content | ConvertFrom-Csv
                    $converted
                    }             
            }
     
        
}
Write-Host Imported...
