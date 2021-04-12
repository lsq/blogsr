---
title: "vba导出pdf或者png"
date: Wed, 09 Dec 2020 17:09:52 +0800
#description: "vba导出pdf或者png"
author: lsq
avatar: /me/pk.jpg
cover: /images/vba_export_png.jpg
images:
  - /images/vba_export_png.jpg
draft: false
tags: ["vba", "png", "emf"]
categories: ["office"]
---
## Intro
These code are to export a chart from Excel to .png and .pdf extensions. 

## How to proceed
go to **Tools > Macro > Visual Basic Editor**. 

1. In the new window, select **Insert > Module** and copy some from codes available (SaveSelectedChartAsPDF or SaveSelectedChartAsImage) or  in the blank page.
2. Then go to **File > Close > Return to Microsoft Excel**
3. Select a chart that you want to export
4. **Tools > Macro > Macros**, then select *SaveSelectedChartAsPDF* or *SaveSelectedChartAsImage* and press *Execute*.
5. Check the image at the folder (current directory).

### To export chart as PDF
```
Sub SaveSelectedChartAsPDF()
    With ActiveChart.PageSetup
        .Orientation = xlLandscape
        .FitToPagesTall = 1
        .FitToPagesWide = 1
        .LeftMargin = 0
        .RightMargin = 0
        .BottomMargin = 0
        .TopMargin = 0
    End With
    ActiveChart.ExportAsFixedFormat xlTypePDF, ActiveWorkbook.Path + "\figure.pdf", xlQualityStandard, False, False
End Sub
```

### To export chart as PNG
```
Sub SaveSelectedChartAsImage()
    ActiveChart.Export "figure.png"
End Sub```

D:\Program Files\ImageMagick-7.0.10-Q16-HDRI;c:\lua541;D:\Program Files\inkscape\bin;D:\Program Files\AdoptOpenJDK\jdk-11.0.8.10-hotspot\bin;D:\Program Files\gs\gs9.53.3\bin;C:\Program Files\7-Zip;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Program Files (x86)\Microsoft SQL Server\100\Tools\Binn\;C:\Program Files\Microsoft SQL Server\100\Tools\Binn\;C:\Program Files\Microsoft SQL Server\100\DTS\Binn\;C:\Program Files (x86)\Microsoft SQL Server\100\Tools\Binn\VSShell\Common7\IDE\;C:\Program Files (x86)\Microsoft SQL Server\100\DTS\Binn\;C:\Program Files (x86)\航天信息财税平台\newslib;C:\msys;4\mingw64\bin;C:\msys64\usr\bin;C:\Program Files (x86)\税务证书应用客户端;d:\Progr;m Files (x86)\LyX 2.3\Perl\bin;D:\Program Files (x86)\Calibre2\;D:\texlive\2020\bin\win64;D:\texlive\2020\bin\win32;D:\Program Files\qemu;C:\Program Files\pdf2svg;C:\Program Files\Pandoc\;C:\Program Files\dotnet\;C:\Program Files (x86)\dotnet\

gswin64c.exe -dNOPAUSE -sDEVICE=png16m -r600  -sOutputFile=foo.png o.pdf -dBATCH

```