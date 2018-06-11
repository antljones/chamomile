Get-ChildItem -Recurse | Select-String "advo" | Select-Object Filename | Out-File contain_advo.txt

Get-ChildItem -Recurse | Select-String -Pattern "find_me" | group path | select name
