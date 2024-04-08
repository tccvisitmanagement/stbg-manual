Add-Type -AssemblyName System.Web
$baseURL = "https://github.com/tccvisitmanagement/stbg-manual/blob/main/"
$scriptPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$htmlFilePath = Join-Path -Path $scriptPath -ChildPath "docs/repository-viewer.html"

function Create-Tree($path, $baseURL, $scriptPath) {
  $children = Get-ChildItem -Path $path
  $htmlTree = ""

  foreach ($child in $children) {
    if ($child.PSIsContainer) {
      $htmlTree += "<li><i class='fas fa-folder'></i> $($child.Name)"
      $htmlTree += "<ul>"
      $htmlTree += Create-Tree $child.FullName $baseURL $scriptPath
      $htmlTree += "</ul></li>"
    }
    else {
      $relativePath = $child.FullName.Substring($scriptPath.length + 1).Replace('\', '/')
      $encodedPath = [System.Web.HttpUtility]::UrlEncode($relativePath)
      $fullURL = "${baseURL}${encodedPath}?raw=true"
      $fileIcon = if ($child.Extension -match '\.(jpg|jpeg|png|gif)$') { 'far fa-file-image' } else { 'far fa-file-alt' }
      $htmlTree += "<li><i class='$fileIcon'></i> "
      $htmlTree += "<a href='$fullURL' target='_blank'>$($child.Name)</a> "
      $htmlTree += "<button class='btn btn-outline-secondary btn-sm' onclick='copyLink(`"$fullURL`", `"$($child.Name)`")'>"
      $htmlTree += "<i class='fas fa-clipboard'></i></button></li>"
    }
  }

  return $htmlTree
}

$htmlContent = @"
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="robots" content="noindex">
    <title>Repository Viewer</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <style>
        .tree, .tree ul {
            list-style: none;
            margin: 0;
            padding: 0;
        }
        .tree ul {
            margin-left: 20px;
        }
        .tree li {
            margin: 0;
            padding: 0 7px;
            line-height: 35px;
            color: #369;
            font-weight: bold;
            border-left: 1px solid #ddd;
        }
        .tree li:last-child {
            border-left: none;
        }
        .tree li:before {
            position: relative;
            top: -0.3em;
            height: 1em;
            width: 12px;
            color: white;
            border-bottom: 1px solid #ddd;
            content: '';
            display: inline-block;
            left: -7px;
        }
        .tree li:last-child:before {
            border-left: 1px solid #fff;
        }
        .copy-btn {
            margin-left: 5px;
        }
    </style>
    <script>
    function copyLink(url, filename) {
        navigator.clipboard.writeText(url);
        let snackbar = document.createElement('div');
        snackbar.textContent = 'Copied: ' + filename;
        snackbar.style.position = 'fixed';
        snackbar.style.bottom = '20px';
        snackbar.style.left = '50%';
        snackbar.style.transform = 'translateX(-50%)';
        snackbar.style.backgroundColor = '#333';
        snackbar.style.color = 'white';
        snackbar.style.padding = '10px';
        snackbar.style.borderRadius = '5px';
        snackbar.style.zIndex = '1000';
        document.body.appendChild(snackbar);
        setTimeout(function() {
            document.body.removeChild(snackbar);
        }, 3000);
    }
    </script>
</head>
<body>
    <div class='container mt-4'>
        <h1>Repository Viewer</h1>
        <ul class='tree'>
            $(Create-Tree $scriptPath $baseURL $scriptPath)
        </ul>
    </div>
</body>
</html>
"@

$htmlContent | Out-File -FilePath $htmlFilePath -Encoding utf8
