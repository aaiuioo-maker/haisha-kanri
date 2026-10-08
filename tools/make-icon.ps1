# 配車管理ツールのアイコンを作る（元の車の絵＋左上に Claude Code のキャラクター）
# 使い方: powershell -ExecutionPolicy Bypass -File make-icon.ps1 <元画像.png> <出力フォルダ>
param([string]$src, [string]$outDir)
Add-Type -AssemblyName System.Drawing

function New-Icon([int]$size, [string]$path, [bool]$mascot = $true) {
  $img = [System.Drawing.Image]::FromFile($src)
  $bmp = New-Object System.Drawing.Bitmap $size, $size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = 'HighQualityBicubic'; $g.PixelOffsetMode = 'HighQuality'
  $g.DrawImage($img, 0, 0, $size, $size)
  $img.Dispose()
  $s = $size / 180.0

  # 左上に Claude Code のキャラクター（御神書索引と同じ 12×8 ドット）
  # 32px のタブ用アイコンでは潰れて見えないので描かない
  if ($mascot) {
    $g.SmoothingMode = 'None'; $g.PixelOffsetMode = 'Half'
    $dot = [Math]::Max(1, [Math]::Round(2 * $s))   # 1ドットの大きさ（180px では 2px）
    # iPhoneはアイコンの角を丸く切り取るので、角から少し内側に置いて全部見えるようにする
    $ox = [Math]::Round(11 * $s); $oy = [Math]::Round(21 * $s)
    $orange = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(0xd9,0x77,0x57))
    $dark   = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(0x1a,0x16,0x12))
    # [x, y, 幅, 高さ]（ドット単位）
    $parts = @(@(2,0,8,6), @(0,2,2,2), @(10,2,2,2), @(2,6,1,2), @(4,6,1,2), @(7,6,1,2), @(9,6,1,2))
    foreach ($p in $parts) { $g.FillRectangle($orange, $ox + $p[0]*$dot, $oy + $p[1]*$dot, $p[2]*$dot, $p[3]*$dot) }
    foreach ($e in @(@(3,1), @(8,1))) { $g.FillRectangle($dark, $ox + $e[0]*$dot, $oy + $e[1]*$dot, $dot, $dot) }
  }

  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
}

New-Icon 512 (Join-Path $outDir 'icon-512.png')
New-Icon 180 (Join-Path $outDir 'apple-touch-icon.png')
New-Icon 32  (Join-Path $outDir 'favicon-32.png') $false
