[CmdletBinding()]
param ()

if ([String]::IsNullOrWhiteSpace($IsWindows))
{
    $IsWindows = ($Env:OS -like "*windows*")
}

$JsonObject = @{
    spec = @{
        selector = @{
            int   = -4
            null  = $null
            word  = "fee"
            space = "foo bar"
            utf16 = ('"\u1361"' | ConvertFrom-Json)
        }
    }
}
$JsonObjectString = (ConvertTo-Json $JsonObject -Depth 5 -Compress)

$Arguments = @(
    'trippe slash at the end \\\',
    '4 slash at the end \\\\',
    '\\servername\path\',
    'path=\\servername\path\',
    'key="\\servername\pa th\"',
    '5 slash at the end \\\\\',
    '\\" double slashed double quote',
    'simple',
    'white space',
    'slash at the end \',
    'double slash at the end \\',
    'trippe slash at the end \\\',
    'trippe slash at the end with space \\\ ',
    '\\" double slashed double quote',
    'double slashed double quote at the end \\"',
    '\\\" triple slashed double quote',
    'triple slashed double quote at the end \\\"',
    # slash
    'single slashes \a ^ \: \"',
    'path="C:\Program Files (x86)\test\"'
    # quotes
    'double quote " and single quote ''',
    # windows env var syntax
    "env var OS: %OS%",
    # utf16
    ('"utf16 ETHIOPIC WORDSPACE: \u1361"' | ConvertFrom-Json),
    # special chars
    "newLine`newLine"
    "tab`tab"
    "backspace`bbackspace"
    "carriage`rafter",
    "formFeed`fformFeed",
    $JsonObjectString,
    # JSON Strings
    @"
[{"_id":"5cdab57e4853ea7b5a707070","index":0,"guid":"25319946-950e-4fe8-9586-ddd031cbb0fc","isActive":false,"balance":"`$2,841.15","picture":"http://placehold.it/32x32","age":39,"eyeColor":"blue","name":{"first":"Leach","last":"Campbell"},"company":"EMOLTRA","email":"leach.campbell@emoltra.biz","phone":"+1 (864) 412-3166","address":"127 Beadel Street, Vivian, Vermont, 1991","about":"Ex labore non enim consectetur id ullamco nulla veniam Lorem velit cillum aliqua amet nostrud. Occaecat ipsum do est qui sint aliquip anim culpa laboris tempor amet. Aute sint anim est sint elit amet nisi veniam culpa commodo nostrud cupidatat in ex.","registered":"Monday, August 25, 2014 4:04 AM","latitude":"-12.814443","longitude":"75.880149","tags":["pariatur","voluptate","sint","Lorem","eiusmod"],"range":[0,1,2,3,4,5,6,7,8,9],"friends":[{"id":0,"name":"Lester Bender"},{"id":1,"name":"Concepcion Jarvis"},{"id":2,"name":"Elsie Whitfield"}],"greeting":"Hello, Leach! You have 10 unread messages.","favoriteFruit":"strawberry"},{"_id":"5cdab57e8cd0ac577ab534a4","index":1,"guid":"0be10c87-6ce7-46c4-8dd6-23b1d9827538","isActive":false,"balance":"`$1,049.56","picture":"http://placehold.it/32x32","age":33,"eyeColor":"green","name":{"first":"Lacey","last":"Terrell"},"company":"XSPORTS","email":"lacey.terrell@xsports.tv","phone":"+1 (858) 511-2896","address":"850 Franklin Street, Gordon, Virginia, 4968","about":"Eiusmod nostrud mollit occaecat Lorem consectetur enim pariatur qui eu. Proident aliqua sunt incididunt Lorem adipisicing ea esse do ullamco excepteur duis qui. Irure labore cillum aliqua officia commodo incididunt esse ad duis ea. Occaecat officia officia laboris veniam id dolor minim magna ut sit. Aute quis occaecat eu veniam. Quis exercitation mollit consectetur magna officia sit. Irure ullamco laborum cillum dolore mollit culpa deserunt veniam minim sunt.","registered":"Monday, February 3, 2014 9:19 PM","latitude":"-82.240949","longitude":"2.361739","tags":["nostrud","et","non","eiusmod","qui"],"range":[0,1,2,3,4,5,6,7,8,9],"friends":[{"id":0,"name":"Meyers Dillard"},{"id":1,"name":"Jacobson Franco"},{"id":2,"name":"Hunt Hernandez"}],"greeting":"Hello, Lacey! You have 8 unread messages.","favoriteFruit":"apple"},{"_id":"5cdab57eae2f9bc5184f1768","index":2,"guid":"3c0de017-1c2a-470e-87dc-5a6257e8d9d9","isActive":true,"balance":"`$3,349.49","picture":"http://placehold.it/32x32","age":20,"eyeColor":"green","name":{"first":"Knowles","last":"Farrell"},"company":"DAYCORE","email":"knowles.farrell@daycore.io","phone":"+1 (971) 586-2740","address":"150 Bath Avenue, Marion, Oregon, 991","about":"Eiusmod sint commodo eu id sunt. Labore esse id veniam ea et laborum. Dolor ad cupidatat Lorem amet. Labore ut commodo amet commodo. Ipsum reprehenderit voluptate non exercitation anim nostrud do. Aute incididunt ad aliquip aute mollit id eu ea. Voluptate ex consequat velit commodo anim proident ea anim magna amet nisi dolore.","registered":"Friday, September 28, 2018 7:51 PM","latitude":"-11.475201","longitude":"-115.967191","tags":["laborum","dolor","dolor","magna","mollit"],"range":[0,1,2,3,4,5,6,7,8,9],"friends":[{"id":0,"name":"Roxanne Griffith"},{"id":1,"name":"Walls Moore"},{"id":2,"name":"Mattie Carney"}],"greeting":"Hello, Knowles! You have 8 unread messages.","favoriteFruit":"strawberry"},{"_id":"5cdab57e80ff4c4085cd63ef","index":3,"guid":"dca20009-f606-4b99-af94-ded6cfbbfa38","isActive":true,"balance":"`$2,742.32","picture":"http://placehold.it/32x32","age":26,"eyeColor":"brown","name":{"first":"Ila","last":"Hardy"},"company":"OBLIQ","email":"ila.hardy@obliq.ca","phone":"+1 (996) 556-2855","address":"605 Hillel Place, Herald, Delaware, 9670","about":"Enim eiusmod laboris amet ex laborum do dolor qui occaecat ex do labore quis sunt. Veniam magna non nisi ipsum occaecat anim ipsum consectetur ex laboris aute ut consectetur. Do eiusmod tempor dolore eu in dolore qui anim non et. Minim amet exercitation in in velit proident sint aliqua Lorem reprehenderit labore exercitation.","registered":"Friday, April 21, 2017 6:33 AM","latitude":"64.864232","longitude":"-163.200794","tags":["tempor","eiusmod","mollit","aliquip","aute"],"range":[0,1,2,3,4,5,6,7,8,9],"friends":[{"id":0,"name":"Duncan Guy"},{"id":1,"name":"Jami Maxwell"},{"id":2,"name":"Gale Hutchinson"}],"greeting":"Hello, Ila! You have 7 unread messages.","favoriteFruit":"banana"},{"_id":"5cdab57ef1556326f77730f0","index":4,"guid":"f2b3bf60-652f-414c-a5cf-094678eb319f","isActive":true,"balance":"`$2,603.20","picture":"http://placehold.it/32x32","age":27,"eyeColor":"brown","name":{"first":"Turner","last":"King"},"company":"DADABASE","email":"turner.king@dadabase.co.uk","phone":"+1 (803) 506-2511","address":"915 Quay Street, Hinsdale, Texas, 9573","about":"Consequat sunt labore tempor anim duis pariatur ad tempor minim sint. Nulla non aliqua veniam elit officia. Ullamco et irure mollit nulla do eiusmod ullamco. Aute officia elit irure in adipisicing et cupidatat dolor in sint elit dolore labore. Id esse velit nisi culpa velit adipisicing tempor sunt. Eu sunt occaecat ex pariatur esse.","registered":"Thursday, May 21, 2015 7:44 PM","latitude":"88.502961","longitude":"-119.654437","tags":["Lorem","culpa","labore","et","nisi"],"range":[0,1,2,3,4,5,6,7,8,9],"friends":[{"id":0,"name":"Leanne Lawson"},{"id":1,"name":"Jo Shepard"},{"id":2,"name":"Effie Barnes"}],"greeting":"Hello, Turner! You have 6 unread messages.","favoriteFruit":"apple"},{"_id":"5cdab57e248f8196e1a60d05","index":5,"guid":"875a12f0-d36a-4e7b-aaf1-73f67aba83f8","isActive":false,"balance":"`$1,001.89","picture":"http://placehold.it/32x32","age":38,"eyeColor":"blue","name":{"first":"Petty","last":"Langley"},"company":"NETUR","email":"petty.langley@netur.net","phone":"+1 (875) 505-2277","address":"677 Leonard Street, Ticonderoga, Utah, 1152","about":"Nisi do quis sunt nisi cillum pariatur elit dolore commodo aliqua esse est aute esse. Laboris esse mollit mollit dolor excepteur consequat duis aute eu minim tempor occaecat. Deserunt amet amet quis adipisicing exercitation consequat deserunt sunt voluptate amet. Ad magna quis nostrud esse ullamco incididunt laboris consectetur.","registered":"Thursday, July 31, 2014 5:16 PM","latitude":"-57.612396","longitude":"103.91364","tags":["id","labore","deserunt","cillum","culpa"],"range":[0,1,2,3,4,5,6,7,8,9],"friends":[{"id":0,"name":"Colette Mullen"},{"id":1,"name":"Lynnette Tanner"},{"id":2,"name":"Vickie Hardin"}],"greeting":"Hello, Petty! You have 9 unread messages.","favoriteFruit":"banana"},{"_id":"5cdab57e4df76cbb0db9be43","index":6,"guid":"ee3852fe-c597-4cb6-a336-1466e8978080","isActive":true,"balance":"`$3,087.87","picture":"http://placehold.it/32x32","age":33,"eyeColor":"brown","name":{"first":"Salas","last":"Young"},"company":"PLAYCE","email":"salas.young@playce.org","phone":"+1 (976) 473-2919","address":"927 Elm Place, Terlingua, North Carolina, 2150","about":"Laborum laboris ullamco aliquip occaecat fugiat sit ex laboris veniam tempor tempor. Anim quis veniam ad commodo culpa irure est esse laboris. Fugiat nostrud elit mollit minim. Velit est laborum ut quis anim velit aute enim culpa amet ipsum.","registered":"Thursday, October 1, 2015 10:59 AM","latitude":"-57.861212","longitude":"69.823065","tags":["eu","est","et","proident","nisi"],"range":[0,1,2,3,4,5,6,7,8,9],"friends":[{"id":0,"name":"Day Solomon"},{"id":1,"name":"Stevens Boyd"},{"id":2,"name":"Erika Mayer"}],"greeting":"Hello, Salas! You have 10 unread messages.","favoriteFruit":"apple"},{"_id":"5cdab57ed3c91292d30e141d","index":7,"guid":"ef7c0beb-8413-4f39-987f-022c4e8ec482","isActive":false,"balance":"`$2,612.45","picture":"http://placehold.it/32x32","age":36,"eyeColor":"brown","name":{"first":"Gloria","last":"Black"},"company":"PULZE","email":"gloria.black@pulze.me","phone":"+1 (872) 513-2364","address":"311 Guernsey Street, Hatteras, New Mexico, 2241","about":"Laborum sunt exercitation ea labore ullamco dolor pariatur laborum deserunt adipisicing pariatur. Officia velit duis cupidatat eu officia magna magna deserunt do. Aliquip cupidatat commodo duis aliquip in aute dolore occaecat esse ad. Incididunt est magna in pariatur ut do ex sit minim cupidatat culpa. Voluptate eu veniam cupidatat exercitation.","registered":"Friday, June 26, 2015 7:59 AM","latitude":"38.644208","longitude":"-45.481555","tags":["sint","ea","anim","voluptate","elit"],"range":[0,1,2,3,4,5,6,7,8,9],"friends":[{"id":0,"name":"Abby Walton"},{"id":1,"name":"Elsa Miranda"},{"id":2,"name":"Carr Abbott"}],"greeting":"Hello, Gloria! You have 5 unread messages.","favoriteFruit":"strawberry"},{"_id":"5cdab57edc91491fb70b705d","index":8,"guid":"631ff8a0-ce4c-4111-b1e4-1d112f4ecdc7","isActive":false,"balance":"`$2,550.70","picture":"http://placehold.it/32x32","age":25,"eyeColor":"brown","name":{"first":"Deirdre","last":"Huber"},"company":"VERBUS","email":"deirdre.huber@verbus.info","phone":"+1 (871) 468-3420","address":"814 Coles Street, Bartonsville, Tennessee, 7313","about":"Ipsum ex est culpa veniam voluptate officia consectetur quis et irure proident pariatur non. In excepteur est aliqua duis duis. Veniam consectetur cupidatat reprehenderit qui qui aliqua.","registered":"Monday, April 1, 2019 2:33 AM","latitude":"-75.702323","longitude":"45.165458","tags":["labore","aute","nisi","laborum","laborum"],"range":[0,1,2,3,4,5,6,7,8,9],"friends":[{"id":0,"name":"Genevieve Clarke"},{"id":1,"name":"Black Sykes"},{"id":2,"name":"Watson Hudson"}],"greeting":"Hello, Deirdre! You have 8 unread messages.","favoriteFruit":"strawberry"}]
"@
)

# GO UTF8 supported
Invoke-ExternalCommand -Command "$PSScriptRoot/goecho/echo.exe" -Arguments $Arguments

# Windows Binary - no UTF8
if ($IsWindows)
{
    Invoke-ExternalCommand -Command "$PSScriptRoot/echoargs/EchoArgs" -Arguments $Arguments -DontEscapeArguments @(7)
}

# Java Jar - no UTF8
Invoke-ExternalCommand -Command "java" -Arguments (@("-cp" , "$PSScriptRoot/javaecho/Echo.jar", "Echo") + $Arguments)