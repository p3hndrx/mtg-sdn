$path = "C:\Users\Richard\Google Drive\mtg\mtgo.decks.edh"
$decks = gci $path

foreach($list in $decks)
{

    $file = gc $list.fullname
    
    #strip head
    $file = $file -replace ('(?=<\?xml).*(?>\?>)','')
    $file = $file -replace ('(?=<Deck).*(?>>)','')
    $file = $file -replace ('(?=<NetDeckID).*(?>NetDeckID>)','')
    $file = $file -replace ('(?=<PreconstructedDeckID).*(?>ID>)','')
    #keep quantity
    $file = $file -replace ('(?=<Cards).*(?>Quantity=")','')
    $file = $file -replace ('(?=").*(?>Name=")','x ')
    $file = $file -replace ('" />','')
    $file = $file -replace ('</Deck>','')
    
    #outfile
    $save = $list.fullname -replace('.dek','.txt')
    $save = $save -replace ('Google Drive\\mtg\\mtgo.decks.edh\\','Desktop\tapped-out-export\')
    $save
    $file.TrimStart() > $save
}
