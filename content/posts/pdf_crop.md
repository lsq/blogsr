---
title: "pdf去除空白边及转为png"
date: Wed, 09 Dec 2020 17:09:52 +0800
# description: "pdf去除空白边及转为png"
author: lsq
avatar: /me/pk.jpg
cover: /images/pdf_crop.jpg
images:
  - /images/pdf_crop.jpg
draft: false
tags: ["tex","pdf"]
categories: ["office"]
---
### Crop white space of pdf and using `gs` convert to png
1. PDFCROP takes a PDF file as input, calculates the BoundingBox for each page by the help of ghostscript and generates a output PDF file with removed margins.[pdfcrop](https://github.com/ho-tex/pdfcrop)
2. Normally pdfcrop will be installed by the TeX system.
3. https://superuser.com/questions/415707/export-excel-graphs-as-vector-graphics-files-e-g-svgs
4. [briss/xltoolbox](https://tex.stackexchange.com/questions/17716/excel-chart-pdf-latex-but-need-to-remove-white-space)
```
pdfcrop foo.pdf f.pdf
gswin64c.exe -dNOPAUSE -sDEVICE=png16m -r600  -sOutputFile=foo.png o.pdf -dBATCH

```
```vbscript
Sub SaveSelectedChartAsPng()
Dim tmpdir As String, outputPdf As String, outputPng As String, cropPdf As String
Dim wshell As Object

    Set wshell = CreateObject("WScript.Shell")
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    Application.EnableEvents = False
    Application.DisplayAlerts = False
    
    tmpdir = VBA.Environ("temp")
    outputPdf = tmpdir & "\" & "figure.pdf"
    outputPng = ActiveWorkbook.Path & "\" & "outputValue.png"
    cropPdf = tmpdir & "\" & "figure_crop.pdf"
    
    With ActiveChart.PageSetup
        .Orientation = xlLandscape
        .FitToPagesWide = 1
        .FitToPagesTall = 1
        .LeftMargin = Application.InchesToPoints(0)
        .RightMargin = Application.InchesToPoints(0)
        .TopMargin = Application.InchesToPoints(0)
        .BottomMargin = Application.InchesToPoints(0)
        .HeaderMargin = Application.InchesToPoints(0)
        .FooterMargin = Application.InchesToPoints(0)
    End With
    ActiveChart.ExportAsFixedFormat xlTypePDF, outputPdf, Quality:=xlQualityStandard, IncludeDocProperties:=True, _
                IgnorePrintAreas:=False, OpenAfterPublish:=False
    
    wshell.Run "pdfcrop " & outputPdf & " " & cropPdf, 0, True
    wshell.Run "gswin64c.exe -dBATCH -dNOPAUSE -sDEVICE=png16m -r1200  -sOutputFile=" & outputPng & " " & cropPdf, 0, True
    wshell.Run "rm -rf " & outputPdf & " " & cropPdf, 0, True
    ' 需要安装texlive，其已经包含了pdfcrop程序
    'Shell ("pdfcrop " & outputPdf & " " & cropPdf & " && " & "gswin64c.exe -dBATCH -dNOPAUSE -sDEVICE=png16m -r600  -sOutputFile=" & outputPng & " " & cropPdf & " && " & "rm -rf " & outputPdf & " " & cropPdf)
    '需要安装ghostscript
    'Shell ("gswin64c.exe -dBATCH -dNOPAUSE -sDEVICE=png16m -r600  -sOutputFile=" & outputPng & " " & cropPdf)
    '需要安装msys2, rm命令是linux 下命令
    'Shell ("rm -rf " & outputPdf & " " & cropPdf)
    
    Set wshell = Nothing
    Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
    Application.EnableEvents = True
    Application.DisplayAlerts = True
    
End Sub
```
