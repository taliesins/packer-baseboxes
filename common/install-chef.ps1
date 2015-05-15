$download_url = 'https://opscode-omnibus-packages.s3.amazonaws.com/windows/2008r2/x86_64/chef-client-12.3.0-1.msi'

(New-Object System.Net.WebClient).DownloadFile($download_url, 'C:\\Windows\\Temp\\chef.msi')
Start-Process 'msiexec' -ArgumentList '/qb /i C:\\Windows\\Temp\\chef.msi' -NoNewWindow -Wait