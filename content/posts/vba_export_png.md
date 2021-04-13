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
End Sub

D:\Program Files\ImageMagick-7.0.10-Q16-HDRI;c:\lua541;D:\Program Files\inkscape\bin;D:\Program Files\AdoptOpenJDK\jdk-11.0.8.10-hotspot\bin;D:\Program Files\gs\gs9.53.3\bin;C:\Program Files\7-Zip;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Program Files (x86)\Microsoft SQL Server\100\Tools\Binn\;C:\Program Files\Microsoft SQL Server\100\Tools\Binn\;C:\Program Files\Microsoft SQL Server\100\DTS\Binn\;C:\Program Files (x86)\Microsoft SQL Server\100\Tools\Binn\VSShell\Common7\IDE\;C:\Program Files (x86)\Microsoft SQL Server\100\DTS\Binn\;C:\Program Files (x86)\航天信息财税平台\newslib;C:\msys;4\mingw64\bin;C:\msys64\usr\bin;C:\Program Files (x86)\税务证书应用客户端;d:\Progr;m Files (x86)\LyX 2.3\Perl\bin;D:\Program Files (x86)\Calibre2\;D:\texlive\2020\bin\win64;D:\texlive\2020\bin\win32;D:\Program Files\qemu;C:\Program Files\pdf2svg;C:\Program Files\Pandoc\;C:\Program Files\dotnet\;C:\Program Files (x86)\dotnet\

gswin64c.exe -dNOPAUSE -sDEVICE=png16m -r600  -sOutputFile=foo.png o.pdf -dBATCH

```

### 另一种方案是把chart复制到powerpoint中，然后在powerpoint中另存为emf文件

1. Select your Microsoft Excel plots.
2. Copy.
3. Open Microsoft PowerPoint.
4. Paste-special as enhanced metafile (EMF) into an otherwise empty slide.
5. Save your PowerPoint slide as an "other format" file, and choose "EMF" (Enhanced Windows Metafile).
6. Import your EMF file into [InkScape](http://inkscape.org/) and ungroup the object.
7. Delete all the A4-sized crappy blank space from the image and enjoy.

```vb
Dim ppt As Object, pr As Object
Dim sl As Object
Selection.Copy
...
With CreateObject("PowerPoint.Application")
    Set pr = .Presentations.Add
    Set sl = pr.Slides.Add(1, 11)
    sl.Shapes.PasteSpecial DataType:=2
    sl.Shapes(sl.Shapes.Count).Export "C:\Test\Test.emf", 5
    pr.Close
    .Quit
End With
End Sub
```

### 还有一种是用windows api函数直接导出emf文件
1. [参考链接](https://stackoverflow.com/questions/1791369/excel-export-chart-to-wmf-or-emf)
2. [参考链接](https://stackoverflow.com/questions/60706703/export-excel-graphs-as-emf)

```vba
Option Explicit
#If VBA7 Then
Private Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Private Declare PtrSafe Function OpenClipboard Lib "user32" (ByVal hwnd As LongPtr) As Long
Private Declare PtrSafe Function CloseClipboard Lib "user32" () As Long
Private Declare PtrSafe Function GetClipboardData Lib "user32" (ByVal wFormat As Long) As Long
Private Declare PtrSafe Function EmptyClipboard Lib "user32" () As Long
Private Declare PtrSafe Function CopyEnhMetaFileA Lib "gdi32" (ByVal hENHSrc As LongPtr, ByVal lpszFile As String) As Long
Private Declare PtrSafe Function DeleteEnhMetaFile Lib "gdi32" (ByVal hemf As LongPtr) As Long
#Else
Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Private Declare Function OpenClipboard Lib "user32" (ByVal hwnd As Long) As Long
Private Declare Function CloseClipboard Lib "user32" () As Long
Private Declare Function GetClipboardData Lib "user32" (ByVal wFormat As Long) As Long
Private Declare Function EmptyClipboard Lib "user32" () As Long
Private Declare Function CopyEnhMetaFileA Lib "gdi32" (ByVal hENHSrc As Long, ByVal lpszFile As String) As Long
Private Declare Function DeleteEnhMetaFile Lib "gdi32" (ByVal hemf As Long) As Long
#End If

Public Function fnSaveAsEMF(strFileName As String) As Boolean
Const CF_ENHMETAFILE As Long = 14

Dim ReturnValue As Long

  OpenClipboard 0

  ReturnValue = CopyEnhMetaFileA(GetClipboardData(CF_ENHMETAFILE), strFileName)

  EmptyClipboard

  CloseClipboard

  '// Release resources to it eg You can now delete it if required
  '// or write over it. This is a MUST
  DeleteEnhMetaFile ReturnValue

  fnSaveAsEMF = (ReturnValue <> 0)

End Function

Sub SaveItToEMF()
  Dim sFileName As String
  Dim sCellCharacter As String
  Dim x As Integer

  ActiveChart.ChartArea.Select.Copy
 
  sFileName = InputBox("Enter filename for export:", "Export object", sFileName)
 
  For x = 1 To Len(sFileName)
  sCellCharacter = Mid(sFileName, x, 1)
  If sCellCharacter Like "[</*\?%??ü?]" Then
  sFileName = Replace(sFileName, sCellCharacter, "_", 1) ', Replaces all illegal filename characters with "_"
  End If
 
  If Asc(sCellCharacter) <= 32 Then
  sFileName = Replace(sFileName, sCellCharacter, "_", 1) ' Replaces all non printable characters with "_"
  End If
  Next

  sFileName = ActiveWorkbook.Path & "\" & sFileName & ".emf"
 
  If fnSaveAsEMF(sFileName) Then
  MsgBox "Saved", vbInformation
  Else
  MsgBox "NOT Saved!", vbCritical
  End If

End Sub

```



### emf转可调整分辨率图片暂时没有好的解决方案

```bash
identify -verbose ex1.emf

identify -units PixelsPerinch -format "%xx%y by %[printsize.x]x%[printsize.y] by %wx%h by %U" outPutValue2020-12-10.png
convert -units PixelsPerinch -density 300 -size 800x800 ex1.emf ff.png

# png256 png16 pnggray pngmono
gswin64c.exe -dNOPAUSE -q -sDEVICE=pnggray -r500 -dBATCH -dFirstPage=2 -dLastPage=2 -sOutputFile=test.png test.pdf

```

