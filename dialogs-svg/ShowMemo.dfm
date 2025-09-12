object ShowTextDialog: TShowTextDialog
  Left = 209
  Top = 221
  Caption = 'ShowTextDialog'
  ClientHeight = 512
  ClientWidth = 973
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnActivate = FormActivate
  OnAfterMonitorDpiChanged = FormAfterMonitorDpiChanged
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnTop: TPanel
    Left = 0
    Top = 0
    Width = 973
    Height = 51
    Align = alTop
    TabOrder = 0
    DesignSize = (
      973
      51)
    object EndeBtn: TJrButton
      Left = 837
      Top = 1
      Width = 131
      Height = 46
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Close'
      Images = imlGlyphs
      ImageIndex = 0
      Layout = blGlyphLeft
      ModalResult = 2
      Spacing = 8
      TabOrder = 10
      OnClick = EndeBtnClick
    end
    object DeleteBtn: TJrButton
      Left = 393
      Top = 2
      Width = 101
      Height = 46
      Caption = '&Delete'
      Images = imlGlyphs
      ImageIndex = 3
      Layout = blGlyphLeft
      TabOrder = 4
      OnClick = DeleteBtnClick
    end
    object PrintBtn: TJrButton
      Left = 292
      Top = 2
      Width = 101
      Height = 46
      Caption = '&Print'
      Images = imlGlyphs
      ImageIndex = 2
      Layout = blGlyphLeft
      TabOrder = 3
      OnClick = PrintBtnClick
    end
    object OpenBtn: TJrButton
      Left = 2
      Top = 2
      Width = 101
      Height = 46
      Caption = '&Open'
      Images = imlGlyphs
      ImageIndex = 1
      Layout = blGlyphLeft
      TabOrder = 0
      OnClick = OpenBtnClick
    end
    object SearchBtn: TJrButton
      Left = 494
      Top = 2
      Width = 101
      Height = 46
      Caption = '&Search'
      Images = imlGlyphs
      ImageIndex = 4
      Layout = blGlyphLeft
      TabOrder = 5
      OnClick = SearchBtnClick
    end
    object UpdateBtn: TJrButton
      Left = 151
      Top = 2
      Width = 46
      Height = 46
      Hint = 'Update'
      Images = imlGlyphs
      ImageIndex = 5
      Layout = blGlyphLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = UpdateBtnClick
    end
    object PrevErrBtn: TJrButton
      Left = 690
      Top = 2
      Width = 46
      Height = 46
      Hint = 'Go to previous error'
      Images = imlGlyphs
      ImageIndex = 8
      Layout = blGlyphLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
      OnClick = PrevErrBtnClick
    end
    object PrevSectBtn: TJrButton
      Left = 596
      Top = 2
      Width = 46
      Height = 46
      Hint = 'Go to previous section'
      Images = imlGlyphs
      ImageIndex = 6
      Layout = blGlyphLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      OnClick = PrevSectBtnClick
    end
    object NextErrBtn: TJrButton
      Left = 737
      Top = 2
      Width = 46
      Height = 46
      Hint = 'Go to next error'
      Images = imlGlyphs
      ImageIndex = 9
      Layout = blGlyphLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 9
      OnClick = NextErrBtnClick
    end
    object NextSectBtn: TJrButton
      Left = 643
      Top = 2
      Width = 46
      Height = 46
      Hint = 'Go to next section'
      Images = imlGlyphs
      ImageIndex = 7
      Layout = blGlyphRight
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
      OnClick = NextSectBtnClick
    end
    object FontBtn: TJrButton
      Left = 198
      Top = 2
      Width = 46
      Height = 46
      Hint = 'Select font'
      Images = imlGlyphs
      ImageIndex = 10
      Layout = blGlyphLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = FontBtnClick
    end
    object EncBtn: TJrButton
      Left = 245
      Top = 2
      Width = 46
      Height = 46
      Hint = 'Select codepage'
      Images = imlGlyphs
      ImageIndex = 11
      Layout = blGlyphLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 11
      OnClick = EncBtnClick
    end
    object ExportBtn: TJrButton
      Left = 104
      Top = 2
      Width = 46
      Height = 46
      Hint = 'Save as zip'
      Images = imlGlyphs
      ImageIndex = 12
      Layout = blGlyphLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 12
      OnClick = ExportBtnClick
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 491
    Width = 973
    Height = 21
    Panels = <
      item
        Width = 200
      end
      item
        Width = 50
      end>
  end
  object Memo: TMemo
    Left = 0
    Top = 51
    Width = 973
    Height = 440
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    HideSelection = False
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
    OnChange = MemoChange
    OnKeyDown = MemoKeyDown
    OnKeyUp = MemoKeyUp
    OnMouseDown = MemoMouseDown
  end
  object PrintDialog: TPrintDialog
    Left = 530
    Top = 50
  end
  object FindDialog: TFindDialog
    OnFind = FindDialogFind
    Left = 565
    Top = 50
  end
  object OpenDialog: TOpenDialog
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 600
    Top = 50
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    MinFontSize = 6
    MaxFontSize = 24
    Options = [fdFixedPitchOnly, fdNoSimulations, fdNoVectorFonts, fdLimitSize]
    Left = 650
    Top = 50
  end
  object imlGlyphs: TSVGIconImageList
    Size = 32
    SVGIconItems = <
      item
        IconName = 'close'
        SVGText = 
          '<svg height="48" width="48" xmlns="http://www.w3.org/2000/svg" x' +
          'mlns:xlink="http://www.w3.org/1999/xlink"><linearGradient id="a"' +
          ' gradientUnits="userSpaceOnUse" x1="27.808342" x2="18.608994" y1' +
          '="43.595886" y2="-.483242"><stop offset="0" stop-color="#098633"' +
          '/><stop offset="1" stop-color="#8efcb3"/></linearGradient><g str' +
          'oke-linejoin="round"><path d="m42.5 35.000459-10.50009-11 10.500' +
          '001-10-7.500001-7.4999988-10.499999 10.4999988-10.499999-10.4999' +
          '988-7.4999987 7.4999988 10.4999977 10-10.4999977 11 7.4999987 7.' +
          '499999 10.499999-10.5 9.5 10.5z" fill="url(#a)" stroke="#00822b"' +
          '/><path d="m41 35.000459-10.50009-11 10.5-10-6-5.9999998-10.4996' +
          '9 10.4999998-10.500308-10.4999998-5.9999997 5.9999998 10.4999987' +
          ' 10-10.4999987 11 5.9999997 6 10.499999-10.5 9.500089 10.499541z' +
          '" fill="none" opacity=".499404" stroke="#fff"/></g></svg>'
      end
      item
        IconName = 'doc-open'
        SVGText = 
          '<svg height="48" width="48" xmlns="http://www.w3.org/2000/svg" x' +
          'mlns:xlink="http://www.w3.org/1999/xlink"><radialGradient id="a"' +
          ' cx="20.706017" cy="37.517986" gradientTransform="matrix(-1.0550' +
          '22 -.02734504 -.177703 1.190929 51.097752 -1.215778)" gradientUn' +
          'its="userSpaceOnUse" r="30.905205"><stop offset="0" stop-color="' +
          '#1f1313"/><stop offset="1" stop-color="#d6b0b0"/></radialGradien' +
          't><linearGradient id="b" gradientTransform="matrix(1.317489 0 0 ' +
          '.816256 -.879573 -1.318166)" gradientUnits="userSpaceOnUse" x1="' +
          '13.035696" x2="12.853771" y1="32.567184" y2="46.689312"><stop of' +
          'fset="0" stop-color="#fff"/><stop offset="1" stop-color="#fff" s' +
          'top-opacity="0"/></linearGradient><linearGradient id="c" gradien' +
          'tTransform="matrix(-1 0 0 1 47.525575 5.909523)" gradientUnits="' +
          'userSpaceOnUse" x1="18.112709" x2="15.514889" y1="31.36775" y2="' +
          '6.18025"><stop offset="0" stop-color="#4e3030"/><stop offset="1"' +
          ' stop-color="#965d5d"/></linearGradient><linearGradient id="d" g' +
          'radientUnits="userSpaceOnUse" x1="22.175976" x2="22.065331" y1="' +
          '36.987999" y2="32.050499"><stop offset="0" stop-color="#f8ce3c"/' +
          '><stop offset="1" stop-color="#f9dc53"/></linearGradient><linear' +
          'Gradient id="e" gradientTransform="matrix(.9754464 0 0 1.0602677' +
          ' 1.262032 .902902)" gradientUnits="userSpaceOnUse" x1="11" x2="1' +
          '1" y1="17" y2="-3"><stop offset="0" stop-color="#f0f0ee"/><stop ' +
          'offset="1" stop-color="#dedede"/></linearGradient><path d="m43.0' +
          '03795 44.596941c-.0218.416304-.459905.832609-.87621.832609h-31.3' +
          '27021c-.416302 0-.8108117-.416305-.789016-.832609l.936443-27.226' +
          '735c.0218-.416303.459897-.832616.876201-.832616h13.270873c.48505' +
          '7 0 1.234473-.315589 1.401644-1.106632l.611391-2.893072c.155469-' +
          '.735673.882214-1.037886 1.298518-1.037886h14.77886c.416313 0 .81' +
          '0821.416304.789025.832608z" fill="url(#a)" stroke="url(#c)" stro' +
          'ke-linecap="round" stroke-linejoin="round"/><g transform="matrix' +
          '(1.4736843 0 0 1.4736843 8.046412 -2.736843)"><rect fill="url(#e' +
          ')" height="16.964285" rx="1.017857" stroke="#888a85" stroke-mite' +
          'rlimit="10.433" stroke-width=".678571" width="15.607142" x="3.70' +
          '0648" y="3.553572"/><rect fill="none" height="15.607142" rx=".33' +
          '9286" stroke="#fff" stroke-miterlimit="10.433" stroke-width=".67' +
          '8571" width="14.129219" x="4.5" y="4.232143"/><path id="f" d="m5' +
          '.890584 5.820617h10.857142v1.002435h-10.857142z" fill="#91938e"/' +
          '><use transform="matrix(1.0340909 0 0 1.6 -.200815 -3.692857)" x' +
          'link:href="#f"/><use transform="matrix(1.0340909 0 0 1.6 -.20081' +
          '6 -.88604)" xlink:href="#f"/><use transform="matrix(1.0340909 0 ' +
          '0 1.6 -.200816 1.920778)" xlink:href="#f"/><use transform="matri' +
          'x(1.0340909 0 0 1.6 -.200816 4.727596)" xlink:href="#f"/><use tr' +
          'ansform="matrix(.73863634 0 0 1.6 1.539584 7.534414)" xlink:href' +
          '="#f"/></g><g transform="matrix(-1 0 0 1 47.525575 5.909523)"><p' +
          'ath d="m39.783532 39.51062c1.143894-.04406 1.963076-1.096299 2.0' +
          '47035-2.321005.791787-11.548687 1.65936-21.231949 1.65936-21.231' +
          '949.07215-.247484-.167911-.494967-.48014-.494967h-34.3711566s-1.' +
          '8503191 21.866892-1.8503191 21.866892c-.1145551.982066-.4660075 ' +
          '1.804718-1.5498358 2.183713z" fill="url(#d)" stroke="#bea41b" st' +
          'roke-linejoin="round"/><path d="m9.6202444 16.463921 32.7910986.' +
          '06481-1.574046 20.001979c-.08432 1.071511-.450678 1.428215-1.872' +
          '656 1.428215-1.871502 0-28.677968-.03241-31.394742-.03241.233598' +
          '3-.320811.3337557-.988623.3350963-1.004612z" fill="none" opacity' +
          '=".465909" stroke="url(#b)" stroke-linecap="round"/><path d="m9.' +
          '6202481 16.223182-1.1666467 15.643271s8.2961546-4.148078 18.6663' +
          '476-4.148078 15.55529-11.495193 15.55529-11.495193z" fill="#fff"' +
          ' fill-opacity=".089286" fill-rule="evenodd"/></g></svg>'
      end
      item
        IconName = 'printer'
        SVGText = 
          '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'#10'<!-- Crea' +
          'ted with Inkscape (http://www.inkscape.org/) -->'#10#10'<svg'#10'   height' +
          '="48px"'#10'   id="svg8681"'#10'   inkscape:output_extension="org.inksca' +
          'pe.output.svg.inkscape"'#10'   inkscape:version="1.4 (86a8ad7, 2024-' +
          '10-11)"'#10'   sodipodi:docname="printer.svg"'#10'   sodipodi:version="0' +
          '.32"'#10'   width="48px"'#10'   version="1.1"'#10'   xmlns:inkscape="http://' +
          'www.inkscape.org/namespaces/inkscape"'#10'   xmlns:sodipodi="http://' +
          'sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"'#10'   xmlns:xlink="htt' +
          'p://www.w3.org/1999/xlink"'#10'   xmlns="http://www.w3.org/2000/svg"' +
          #10'   xmlns:svg="http://www.w3.org/2000/svg">'#10'  <defs'#10'     id="def' +
          's8683">'#10'    <linearGradient'#10'       id="linearGradient2463"'#10'     ' +
          '  inkscape:collect="always">'#10'      <stop'#10'         id="stop2465"'#10 +
          '         offset="0"'#10'         style="stop-color:#ffffff;stop-opac' +
          'ity:1;" />'#10'      <stop'#10'         id="stop2467"'#10'         offset="1' +
          '"'#10'         style="stop-color:#ffffff;stop-opacity:0;" />'#10'    </l' +
          'inearGradient>'#10'    <linearGradient'#10'       gradientTransform="mat' +
          'rix(1.0441567,0,0,0.986366,-0.4737425,0.273967)"'#10'       gradient' +
          'Units="userSpaceOnUse"'#10'       id="linearGradient8678"'#10'       ink' +
          'scape:collect="always"'#10'       x1="11.3125"'#10'       x2="11.3125"'#10' ' +
          '      xlink:href="#linearGradient2463"'#10'       y1="21.6875"'#10'     ' +
          '  y2="33.216167" />'#10'    <linearGradient'#10'       gradientTransform' +
          '="matrix(1.120543,0,0,1.2799981,-3.893311,-12.05992)"'#10'       gra' +
          'dientUnits="userSpaceOnUse"'#10'       id="linearGradient3334"'#10'     ' +
          '  inkscape:collect="always"'#10'       x1="15.916752"'#10'       x2="15.' +
          '916752"'#10'       xlink:href="#linearGradient7434"'#10'       y1="38.72' +
          '0707"'#10'       y2="43.940079" />'#10'    <linearGradient'#10'       id="li' +
          'nearGradient7652">'#10'      <stop'#10'         id="stop7654"'#10'         o' +
          'ffset="0"'#10'         style="stop-color:#555753;stop-opacity:1;" />' +
          #10'      <stop'#10'         id="stop7656"'#10'         offset="1"'#10'        ' +
          ' style="stop-color:#888a85;stop-opacity:1" />'#10'    </linearGradie' +
          'nt>'#10'    <linearGradient'#10'       gradientTransform="matrix(1.12903' +
          '2,0,0,1.3333314,-4.097046,-14.166581)"'#10'       gradientUnits="use' +
          'rSpaceOnUse"'#10'       id="linearGradient3340"'#10'       inkscape:coll' +
          'ect="always"'#10'       x1="10.823892"'#10'       x2="10.602463"'#10'       ' +
          'xlink:href="#linearGradient7652"'#10'       y1="43.8125"'#10'       y2="' +
          '34.705021" />'#10'    <linearGradient'#10'       id="linearGradient7658"' +
          #10'       inkscape:collect="always">'#10'      <stop'#10'         id="stop' +
          '7660"'#10'         offset="0"'#10'         style="stop-color:#d3d7cf" />' +
          #10'      <stop'#10'         id="stop7662"'#10'         offset="1"'#10'        ' +
          ' style="stop-color:#eeeeec" />'#10'    </linearGradient>'#10'    <linear' +
          'Gradient'#10'       gradientTransform="translate(-1.00027,-2.0000068' +
          ')"'#10'       gradientUnits="userSpaceOnUse"'#10'       id="linearGradie' +
          'nt3338"'#10'       inkscape:collect="always"'#10'       x1="40.315235"'#10' ' +
          '      x2="9.8578663"'#10'       xlink:href="#linearGradient7658"'#10'   ' +
          '    y1="60.195492"'#10'       y2="40.000011" />'#10'    <linearGradient'#10 +
          '       id="linearGradient2304">'#10'      <stop'#10'         id="stop230' +
          '6"'#10'         offset="0"'#10'         style="stop-color:#babdb6" />'#10'  ' +
          '    <stop'#10'         id="stop2308"'#10'         offset="1"'#10'         st' +
          'yle="stop-color:#ffffff;stop-opacity:1;" />'#10'    </linearGradient' +
          '>'#10'    <linearGradient'#10'       gradientTransform="matrix(0.8853266' +
          ',0,0,1.499469,5.4879983,-12.734338)"'#10'       gradientUnits="userS' +
          'paceOnUse"'#10'       id="linearGradient2324"'#10'       inkscape:collec' +
          't="always"'#10'       x1="38.742561"'#10'       x2="38.742561"'#10'       xl' +
          'ink:href="#linearGradient2304"'#10'       y1="29.743778"'#10'       y2="' +
          '31.167559" />'#10'    <linearGradient'#10'       id="linearGradient2326"' +
          #10'       inkscape:collect="always">'#10'      <stop'#10'         id="stop' +
          '2328"'#10'         offset="0"'#10'         style="stop-color:#789e2d;sto' +
          'p-opacity:1" />'#10'      <stop'#10'         id="stop2330"'#10'         offs' +
          'et="1"'#10'         style="stop-color:#a7cc5c;stop-opacity:1" />'#10'   ' +
          ' </linearGradient>'#10'    <linearGradient'#10'       gradientTransform=' +
          '"matrix(0.6666666,0,0,1,14.99973,2.9999939)"'#10'       gradientUnit' +
          's="userSpaceOnUse"'#10'       id="linearGradient2322"'#10'       inkscap' +
          'e:collect="always"'#10'       x1="40.791222"'#10'       x2="40.791222"'#10' ' +
          '      xlink:href="#linearGradient2326"'#10'       y1="30.003317"'#10'   ' +
          '    y2="29.084894" />'#10'    <linearGradient'#10'       id="linearGradi' +
          'ent1385">'#10'      <stop'#10'         id="stop1387"'#10'         offset="0"' +
          #10'         style="stop-color:#888a85" />'#10'      <stop'#10'         id=' +
          '"stop1389"'#10'         offset="1"'#10'         style="stop-color:#888a8' +
          '5;stop-opacity:1" />'#10'    </linearGradient>'#10'    <linearGradient'#10' ' +
          '      gradientTransform="matrix(1.079998,0,0,1.003906,-1.920261,' +
          '-12.099611)"'#10'       gradientUnits="userSpaceOnUse"'#10'       id="li' +
          'nearGradient7641"'#10'       inkscape:collect="always"'#10'       x1="36' +
          '.523464"'#10'       x2="36.523464"'#10'       xlink:href="#linearGradien' +
          't1385"'#10'       y1="32.096741"'#10'       y2="13.749178" />'#10'    <linea' +
          'rGradient'#10'       id="linearGradient2248"'#10'       inkscape:collect' +
          '="always">'#10'      <stop'#10'         id="stop2250"'#10'         offset="0' +
          '"'#10'         style="stop-color:#ffffff;stop-opacity:1" />'#10'      <s' +
          'top'#10'         id="stop2252"'#10'         offset="1"'#10'         style="s' +
          'top-color:#babdb6" />'#10'    </linearGradient>'#10'    <linearGradient'#10 +
          '       gradientTransform="matrix(1.079998,0,0,1.003906,-1.920261' +
          ',-8.0839858)"'#10'       gradientUnits="userSpaceOnUse"'#10'       id="l' +
          'inearGradient7587"'#10'       inkscape:collect="always"'#10'       x1="1' +
          '7.409122"'#10'       x2="21.360058"'#10'       xlink:href="#linearGradie' +
          'nt2248"'#10'       y1="33.322712"'#10'       y2="-23.806805" />'#10'    <lin' +
          'earGradient'#10'       id="linearGradient2384"'#10'       inkscape:colle' +
          'ct="always">'#10'      <stop'#10'         id="stop2386"'#10'         offset=' +
          '"0"'#10'         style="stop-color:#505a5e;stop-opacity:1;" />'#10'     ' +
          ' <stop'#10'         id="stop2388"'#10'         offset="1"'#10'         style' +
          '="stop-color:#babdb6" />'#10'    </linearGradient>'#10'    <linearGradie' +
          'nt'#10'       gradientTransform="matrix(1.003915,0,0,0.9841327,0.955' +
          '8078,-0.7030824)"'#10'       gradientUnits="userSpaceOnUse"'#10'       i' +
          'd="linearGradient7852"'#10'       inkscape:collect="always"'#10'       x' +
          '1="17.5"'#10'       x2="17.5"'#10'       xlink:href="#linearGradient2384' +
          '"'#10'       y1="30.755291"'#10'       y2="20.140139" />'#10'    <linearGrad' +
          'ient'#10'       id="linearGradient7434"'#10'       inkscape:collect="alw' +
          'ays">'#10'      <stop'#10'         id="stop7436"'#10'         offset="0"'#10'   ' +
          '      style="stop-color:#ffffff;stop-opacity:1;" />'#10'      <stop'#10 +
          '         id="stop7438"'#10'         offset="1"'#10'         style="stop-' +
          'color:#ffffff;stop-opacity:0;" />'#10'    </linearGradient>'#10'    <lin' +
          'earGradient'#10'       gradientTransform="translate(-2.7080474e-4,-2' +
          '.0000068)"'#10'       gradientUnits="userSpaceOnUse"'#10'       id="line' +
          'arGradient7440"'#10'       inkscape:collect="always"'#10'       x1="5.12' +
          '6524"'#10'       x2="5.126524"'#10'       xlink:href="#linearGradient743' +
          '4"'#10'       y1="25.372583"'#10'       y2="69.140259" />'#10'    <linearGra' +
          'dient'#10'       id="linearGradient2683"'#10'       inkscape:collect="al' +
          'ways">'#10'      <stop'#10'         id="stop2685"'#10'         offset="0"'#10'  ' +
          '       style="stop-color:#8e918d;stop-opacity:1;" />'#10'      <stop' +
          #10'         id="stop2687"'#10'         offset="1"'#10'         style="stop' +
          '-color:#4a5356;stop-opacity:1;" />'#10'    </linearGradient>'#10'    <li' +
          'nearGradient'#10'       gradientTransform="translate(0.9997292,-7.08' +
          '55516e-6)"'#10'       gradientUnits="userSpaceOnUse"'#10'       id="line' +
          'arGradient7820"'#10'       inkscape:collect="always"'#10'       x1="3.26' +
          '40579"'#10'       x2="3.2640579"'#10'       xlink:href="#linearGradient2' +
          '683"'#10'       y1="35.072964"'#10'       y2="41.012157" />'#10'    <linearG' +
          'radient'#10'       id="linearGradient2675"'#10'       inkscape:collect="' +
          'always">'#10'      <stop'#10'         id="stop2677"'#10'         offset="0"'#10 +
          '         style="stop-color:#647175;stop-opacity:1;" />'#10'      <st' +
          'op'#10'         id="stop2679"'#10'         offset="1"'#10'         style="st' +
          'op-color:#9da09c;stop-opacity:1;" />'#10'    </linearGradient>'#10'    <' +
          'linearGradient'#10'       gradientTransform="translate(0.9997292,-7.' +
          '0855516e-6)"'#10'       gradientUnits="userSpaceOnUse"'#10'       id="li' +
          'nearGradient7818"'#10'       inkscape:collect="always"'#10'       x1="5.' +
          '0569911"'#10'       x2="5.0569911"'#10'       xlink:href="#linearGradien' +
          't2675"'#10'       y1="40.414822"'#10'       y2="37.14798" />'#10'    <linear' +
          'Gradient'#10'       id="linearGradient7426">'#10'      <stop'#10'         id' +
          '="stop7428"'#10'         offset="0"'#10'         style="stop-color:#5557' +
          '53;stop-opacity:1;" />'#10'      <stop'#10'         id="stop7430"'#10'      ' +
          '   offset="1"'#10'         style="stop-color:#888a85;stop-opacity:1"' +
          ' />'#10'    </linearGradient>'#10'    <linearGradient'#10'       gradientTra' +
          'nsform="translate(-2.7080474e-4,-2.0000068)"'#10'       gradientUnit' +
          's="userSpaceOnUse"'#10'       id="linearGradient7432"'#10'       inkscap' +
          'e:collect="always"'#10'       x1="0.75"'#10'       x2="0.75"'#10'       xlin' +
          'k:href="#linearGradient7426"'#10'       y1="67.989044"'#10'       y2="24' +
          '.367777" />'#10'    <linearGradient'#10'       id="linearGradient2222"'#10' ' +
          '      inkscape:collect="always">'#10'      <stop'#10'         id="stop22' +
          '24"'#10'         offset="0"'#10'         style="stop-color:#d3d7cf" />'#10' ' +
          '     <stop'#10'         id="stop2226"'#10'         offset="1"'#10'         s' +
          'tyle="stop-color:#eeeeec" />'#10'    </linearGradient>'#10'    <linearGr' +
          'adient'#10'       gradientTransform="matrix(1,0,0,0.921571,-2.708047' +
          '4e-4,4.2781389)"'#10'       gradientUnits="userSpaceOnUse"'#10'       id' +
          '="linearGradient2220"'#10'       inkscape:collect="always"'#10'       x1' +
          '="35.5"'#10'       x2="35.5"'#10'       xlink:href="#linearGradient2222"' +
          #10'       y1="31.190165"'#10'       y2="24.248672" />'#10'  </defs>'#10'  <sod' +
          'ipodi:namedview'#10'     bordercolor="#666666"'#10'     borderopacity="1' +
          '.0"'#10'     id="base"'#10'     inkscape:current-layer="layer1"'#10'     ink' +
          'scape:cx="24.036253"'#10'     inkscape:cy="23.963746"'#10'     inkscape:' +
          'document-units="px"'#10'     inkscape:grid-bbox="true"'#10'     inkscape' +
          ':pageopacity="0.0"'#10'     inkscape:pageshadow="2"'#10'     inkscape:wi' +
          'ndow-height="688"'#10'     inkscape:window-width="641"'#10'     inkscape' +
          ':window-x="193"'#10'     inkscape:window-y="54"'#10'     inkscape:zoom="' +
          '13.791667"'#10'     pagecolor="#ffffff"'#10'     showgrid="true"'#10'     in' +
          'kscape:showpageshadow="2"'#10'     inkscape:pagecheckerboard="0"'#10'   ' +
          '  inkscape:deskcolor="#d1d1d1">'#10'    <inkscape:grid'#10'       id="gr' +
          'id7252"'#10'       type="xygrid"'#10'       originx="0"'#10'       originy="' +
          '0"'#10'       spacingy="1"'#10'       spacingx="1"'#10'       units="px" />'#10 +
          '  </sodipodi:namedview>'#10'  <g'#10'     id="layer1"'#10'     inkscape:grou' +
          'pmode="layer"'#10'     inkscape:label="Layer 1">'#10'    <path'#10'       d=' +
          '"m 6.9997292,19.499992 -2.25,2.74879 c -2.1505939,2.627347 -3.25' +
          ',5.068643 -3.25,8.754929 v 5.496281 H 46.499729 v -5.496281 c 0,' +
          '-3.686286 -1.099407,-6.127583 -3.25,-8.754929 l -2.25,-2.74879 z' +
          '"'#10'       id="rect1314"'#10'       sodipodi:nodetypes="czzcczzcc"'#10'   ' +
          '    style="display:inline;overflow:visible;visibility:visible;op' +
          'acity:1;fill:url(#linearGradient2220);fill-opacity:1;fill-rule:n' +
          'onzero;stroke:url(#linearGradient7432);stroke-width:1;stroke-lin' +
          'ecap:square;stroke-linejoin:round;stroke-miterlimit:4;stroke-das' +
          'harray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none;mar' +
          'ker-start:none;marker-mid:none;marker-end:none" />'#10'    <path'#10'   ' +
          '    d="m 2.4997292,36.499992 v 2.90625 c 0,1.151747 0.942003,2.0' +
          '9375 2.0937499,2.09375 H 43.405979 c 1.151747,0 2.09375,-0.94200' +
          '5 2.09375,-2.09375 v -2.90625 z"'#10'       id="rect2412"'#10'       sod' +
          'ipodi:nodetypes="ccccccc"'#10'       style="display:inline;opacity:1' +
          ';fill:url(#linearGradient7818);fill-opacity:1;stroke:url(#linear' +
          'Gradient7820);stroke-width:1;stroke-linecap:round;stroke-linejoi' +
          'n:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity' +
          ':1;enable-background:new" />'#10'    <path'#10'       d="m 7.5116275,20.' +
          '562492 -1.9121622,2.289256 c -2.0353965,2.436793 -3.0997361,4.48' +
          '6071 -3.0997361,7.85621 v 4.792034 H 45.499724 v -4.792034 c 0,-' +
          '3.370139 -1.072112,-5.413519 -3.099735,-7.85621 l -1.90026,-2.28' +
          '9256 z"'#10'       id="path2231"'#10'       sodipodi:nodetypes="czzcczzc' +
          'c"'#10'       style="display:inline;overflow:visible;visibility:visi' +
          'ble;opacity:1;fill:none;fill-opacity:1;fill-rule:nonzero;stroke:' +
          'url(#linearGradient7440);stroke-width:0.999999;stroke-linecap:sq' +
          'uare;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:' +
          'none;stroke-dashoffset:0;stroke-opacity:1;marker:none;marker-sta' +
          'rt:none;marker-mid:none;marker-end:none" />'#10'    <rect'#10'       hei' +
          'ght="10.000113"'#10'       id="rect2319"'#10'       rx="0.5078125"'#10'     ' +
          '  ry="0.5"'#10'       style="display:inline;opacity:1;fill:url(#line' +
          'arGradient7852);fill-opacity:1;stroke:#454e51;stroke-width:0.999' +
          '777;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit' +
          ':4;stroke-dasharray:none;stroke-opacity:1;enable-background:new"' +
          #10'       width="29.000111"'#10'       x="9.4996176"'#10'       y="20.4998' +
          '8" />'#10'    <path'#10'       d="m 12.119729,5.4999929 h 23.759982 c 0.' +
          '897479,0 1.619999,0.665754 1.619999,1.5 l 2e-6,14.6869111 -26.99' +
          '9981,-0.0039 -2e-6,-14.6830051 c 0,-0.834246 0.72252,-1.5 1.62,-' +
          '1.5 z"'#10'       id="rect2233"'#10'       sodipodi:nodetypes="ccccccc"'#10 +
          '       style="display:inline;overflow:visible;visibility:visible' +
          ';fill:url(#linearGradient7587);fill-opacity:1;fill-rule:nonzero;' +
          'stroke:url(#linearGradient7641);stroke-width:1;stroke-linecap:sq' +
          'uare;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:' +
          'none;stroke-dashoffset:0;stroke-opacity:1;marker:none;marker-sta' +
          'rt:none;marker-mid:none;marker-end:none" />'#10'    <rect'#10'       hei' +
          'ght="15.000061"'#10'       id="rect2256"'#10'       rx="0.62364459"'#10'    ' +
          '   ry="0.52842641"'#10'       style="display:inline;overflow:visible' +
          ';visibility:visible;opacity:1;fill:none;fill-opacity:1;fill-rule' +
          ':nonzero;stroke:#ffffff;stroke-width:0.999876;stroke-linecap:squ' +
          'are;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:n' +
          'one;stroke-dashoffset:0;stroke-opacity:1;marker:none;marker-star' +
          't:none;marker-mid:none;marker-end:none"'#10'       width="25.000061"' +
          #10'       x="11.499729"'#10'       y="6.4999938" />'#10'    <rect'#10'       h' +
          'eight="2"'#10'       id="rect2320"'#10'       rx="0.99999988"'#10'       ry=' +
          '"1"'#10'       style="display:inline;overflow:visible;visibility:vis' +
          'ible;opacity:1;fill:url(#linearGradient2322);fill-opacity:1;fill' +
          '-rule:nonzero;stroke:url(#linearGradient2324);stroke-width:1;str' +
          'oke-linecap:square;stroke-linejoin:miter;stroke-miterlimit:4;str' +
          'oke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:n' +
          'one;marker-start:none;marker-mid:none;marker-end:none"'#10'       wi' +
          'dth="2.9999998"'#10'       x="40.999729"'#10'       y="31.499992" />'#10'   ' +
          ' <path'#10'       d="M 9.1932771,34.499992 H 38.806182 c 0.963685,0 ' +
          '1.693549,0.847638 1.693549,1.733 v 6.266999 l -33.0000019,1.1e-5' +
          ' v -6.26701 c 0,-0.987249 0.7736581,-1.733 1.693548,-1.733 z"'#10'  ' +
          '     id="path3330"'#10'       sodipodi:nodetypes="ccccccc"'#10'       st' +
          'yle="display:inline;overflow:visible;visibility:visible;fill:url' +
          '(#linearGradient3338);fill-opacity:1;fill-rule:nonzero;stroke:ur' +
          'l(#linearGradient3340);stroke-width:1;stroke-linecap:square;stro' +
          'ke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stro' +
          'ke-dashoffset:0;stroke-opacity:1;marker:none;marker-start:none;m' +
          'arker-mid:none;marker-end:none" />'#10'    <path'#10'       d="m 9.30612' +
          '14,35.539992 c -0.4537495,0 -0.8063915,0.296562 -0.8063915,0.81 ' +
          'V 41.49999 H 39.49973 v -5.149998 c 0,-0.393277 -0.349367,-0.81 ' +
          '-0.806391,-0.81 z"'#10'       id="path3336"'#10'       sodipodi:nodetype' +
          's="ccccccc"'#10'       style="display:inline;overflow:visible;visibi' +
          'lity:visible;fill:none;fill-opacity:1;fill-rule:nonzero;stroke:u' +
          'rl(#linearGradient3334);stroke-width:1;stroke-linecap:square;str' +
          'oke-linejoin:miter;stroke-miterlimit:4;stroke-dashoffset:0;strok' +
          'e-opacity:1;marker:none;marker-start:none;marker-mid:none;marker' +
          '-end:none" />'#10'    <rect'#10'       height="6.9996305"'#10'       id="rec' +
          't2459"'#10'       style="display:inline;opacity:0.243137;fill:none;f' +
          'ill-opacity:1;stroke:url(#linearGradient8678);stroke-width:1;str' +
          'oke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stro' +
          'ke-dasharray:none;stroke-opacity:1;enable-background:new"'#10'      ' +
          ' width="26.999687"'#10'       x="10.499913"'#10'       y="22.500362" />'#10 +
          '    <path'#10'       d="M 10.499699,21.500022 H 37.499817"'#10'       id' +
          '="path2259"'#10'       sodipodi:nodetypes="cc"'#10'       style="display' +
          ':inline;fill:#888a85;fill-opacity:0.75;fill-rule:evenodd;stroke:' +
          '#465053;stroke-width:0.999941;stroke-linecap:square;stroke-linej' +
          'oin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opaci' +
          'ty:1;enable-background:new" />'#10'    <path'#10'       d="M 9.9997292,2' +
          '1.999992 H 37.999729 v 2.993392 C 31.538191,23.99008 14.845883,2' +
          '2.986776 9.9997292,26.999992 Z"'#10'       id="rect2440"'#10'       sodi' +
          'podi:nodetypes="ccccc"'#10'       style="display:inline;opacity:0.26' +
          '2745;fill:#ffffff;fill-opacity:1;stroke:none;stroke-width:1;stro' +
          'ke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;strok' +
          'e-opacity:1;enable-background:new" />'#10'  </g>'#10'</svg>'#10
      end
      item
        IconName = 'doc-delete'
        SVGText = 
          '<svg height="48" viewBox="0 0 48 48" width="48" xmlns="http://ww' +
          'w.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><l' +
          'inearGradient id="a" gradientTransform="matrix(.9754464 0 0 1.06' +
          '02677 1.262032 .902902)" gradientUnits="userSpaceOnUse" x1="11" ' +
          'x2="11" y1="17" y2="-3"><stop offset="0" stop-color="#f0f0ee"/><' +
          'stop offset="1" stop-color="#dedede"/></linearGradient><linearGr' +
          'adient id="b" gradientUnits="userSpaceOnUse" x1="13" x2="35.0000' +
          '08" y1="3.947442" y2="42.05257"><stop offset="0" stop-color="#e7' +
          '8181"/><stop offset="1" stop-color="#a40000"/></linearGradient><' +
          'g transform="matrix(2.4939273 0 0 2.4939273 -4.690687 -6.016196)' +
          '"><rect fill="url(#a)" height="16.964285" rx="1.017857" stroke="' +
          '#888a85" stroke-miterlimit="10.433" stroke-width=".678571" width' +
          '="15.607142" x="3.700648" y="3.553572"/><rect fill="none" height' +
          '="15.607142" rx=".339286" stroke="#fff" stroke-miterlimit="10.43' +
          '3" stroke-width=".678571" width="14.129219" x="4.5" y="4.232143"' +
          '/><path id="c" d="m5.890584 5.820617h10.857142v1.002435h-10.8571' +
          '42z" fill="#91938e"/><use transform="matrix(1.0340909 0 0 1.6 -.' +
          '200815 -3.692857)" xlink:href="#c"/><use transform="matrix(1.034' +
          '0909 0 0 1.6 -.200816 -.88604)" xlink:href="#c"/><use transform=' +
          '"matrix(1.0340909 0 0 1.6 -.200816 1.920778)" xlink:href="#c"/><' +
          'use transform="matrix(1.0340909 0 0 1.6 -.200816 4.727596)" xlin' +
          'k:href="#c"/><use transform="matrix(.73863634 0 0 1.6 1.539584 7' +
          '.534414)" xlink:href="#c"/></g><g transform="matrix(.59090911 0 ' +
          '0 .5909091 19.818182 .409091)"><path d="m45.499979 22.999239c0 1' +
          '1.874491-9.626578 21.500741-21.499708 21.500741-11.874218 0-21.5' +
          '002507-9.626359-21.5002507-21.500741 0-11.873949 9.6260327-21.49' +
          '92185 21.5002507-21.4992185 11.87313 0 21.499708 9.6252695 21.49' +
          '9708 21.4992185z" fill="url(#b)" stroke="#b21a1a" stroke-width="' +
          '1.00004"/><path d="m44.49904 22.999272c0 11.32219-9.178617 20.50' +
          '0703-20.499249 20.500703-11.321667 0-20.499766-9.178619-20.49976' +
          '6-20.500703 0-11.321666 9.178099-20.4992465 20.499766-20.4992465' +
          ' 11.320632 0 20.499249 9.1775805 20.499249 20.4992465z" fill="no' +
          'ne" opacity=".6" stroke="#fff" stroke-opacity=".75" stroke-width' +
          '="1.00005"/><path d="m16.471763 12-3.471761 3.471761 7.162792 7.' +
          '126246c.220049.222824.220049.581162 0 .803987l-7.162792 7.126245' +
          ' 3.471761 3.471761 7.126245-7.126246c.222824-.22005.581162-.2200' +
          '5.803987 0l7.126246 7.126246 3.471761-3.471761-7.126246-7.126245' +
          'c-.220051-.222825-.220051-.581163 0-.803987l7.126246-7.126246-3.' +
          '471761-3.471761-7.126246 7.126245c-.222825.220051-.581163.220051' +
          '-.803987 0z" fill="#fff" fill-rule="evenodd"/></g></svg>'
      end
      item
        IconName = 'doc-view'
        SVGText = 
          '<svg height="48" viewBox="0 0 48 48" width="48" xmlns="http://ww' +
          'w.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><l' +
          'inearGradient id="a" gradientTransform="matrix(.9754464 0 0 1.06' +
          '02677 1.262032 .902902)" gradientUnits="userSpaceOnUse" x1="11" ' +
          'x2="11" y1="17" y2="-3"><stop offset="0" stop-color="#f0f0ee"/><' +
          'stop offset="1" stop-color="#dedede"/></linearGradient><linearGr' +
          'adient id="b" gradientUnits="userSpaceOnUse" x1="27.366341" x2="' +
          '31.335964" y1="26.580296" y2="30.557772"><stop offset="0" stop-c' +
          'olor="#8a8a8a"/><stop offset="1" stop-color="#484848"/></linearG' +
          'radient><linearGradient id="c" gradientTransform="matrix(1.33459' +
          '3 0 0 1.291292 -6.973842 -7.460658)" gradientUnits="userSpaceOnU' +
          'se" x1="30.65625" x2="33.21875" y1="34" y2="31.0625"><stop offse' +
          't="0" stop-color="#d03030"/><stop offset=".5" stop-color="#c9373' +
          '7"/><stop offset="1" stop-color="#e38a8a"/></linearGradient><lin' +
          'earGradient id="d" gradientUnits="userSpaceOnUse" x1="18.292673"' +
          ' x2="17.500893" y1="13.602121" y2="25.743469"><stop offset="0" s' +
          'top-color="#fff"/><stop offset=".5" stop-color="#fff" stop-opaci' +
          'ty=".219048"/><stop offset="1" stop-color="#fff"/></linearGradie' +
          'nt><radialGradient id="e" cx="18.240929" cy="21.817987" gradient' +
          'Units="userSpaceOnUse" r="8.308505"><stop offset="0" stop-color=' +
          '"#729fcf" stop-opacity=".207843"/><stop offset="1" stop-color="#' +
          '729fcf" stop-opacity=".676191"/></radialGradient><radialGradient' +
          ' id="f" cx="15.414371" cy="13.078408" gradientTransform="matrix(' +
          '2.592963 0 0 2.252104 -25.05975 -18.941)" gradientUnits="userSpa' +
          'ceOnUse" r="6.65625"><stop offset="0" stop-color="#fff"/><stop o' +
          'ffset="1" stop-color="#fff" stop-opacity=".247619"/></radialGrad' +
          'ient><g transform="matrix(2.4939273 0 0 2.4939273 -4.690687 -6.0' +
          '16196)"><rect fill="url(#a)" height="16.964285" rx="1.017857" st' +
          'roke="#888a85" stroke-miterlimit="10.433" stroke-width=".678571"' +
          ' width="15.607142" x="3.700648" y="3.553572"/><rect fill="none" ' +
          'height="15.607142" rx=".339286" stroke="#fff" stroke-miterlimit=' +
          '"10.433" stroke-width=".678571" width="14.129219" x="4.5" y="4.2' +
          '32143"/><path id="g" d="m5.890584 5.820617h10.857142v1.002435h-1' +
          '0.857142z" fill="#91938e"/><use transform="matrix(1.0340909 0 0 ' +
          '1.6 -.200815 -3.692857)" xlink:href="#g"/><use transform="matrix' +
          '(1.0340909 0 0 1.6 -.200816 -.88604)" xlink:href="#g"/><use tran' +
          'sform="matrix(1.0340909 0 0 1.6 -.200816 1.920778)" xlink:href="' +
          '#g"/><use transform="matrix(1.0340909 0 0 1.6 -.200816 4.727596)' +
          '" xlink:href="#g"/><use transform="matrix(.73863634 0 0 1.6 1.53' +
          '9584 7.534414)" xlink:href="#g"/></g><g transform="matrix(1.0385' +
          '865 0 0 1.0385865 -1.247917 -1.733141)"><g fill-rule="evenodd"><' +
          'path d="m18.627569 3.1435548c-8.13913 0-14.7448008 6.6056711-14.' +
          '7448008 14.7448012 0 8.13913 6.6056708 14.744802 14.7448008 14.7' +
          '44802 3.479555 0 6.551001-1.384393 9.073723-3.402647-.205377 1.0' +
          '06881-.07803 2.035368.756144 2.759925l10.964084 9.52741c1.233416' +
          ' 1.071329 3.087462.93096 4.15879-.302457 1.071328-1.233418.93095' +
          '9-3.087462-.302457-4.15879l-10.964084-9.527411c-.671527-.583279-' +
          '1.492878-.755969-2.306238-.642722 1.9867-2.512422 3.364839-5.548' +
          '803 3.364839-8.99811 0-8.1391301-6.605671-14.7448012-14.744801-1' +
          '4.7448012zm-.07562 1.2261833c7.639459 0 13.291775 4.7889505 13.2' +
          '91775 13.2917749 0 8.675113-5.81669 13.291775-13.291775 13.29177' +
          '5-7.302949 0-13.2917734-5.478092-13.2917734-13.291775 0-7.984106' +
          '9 5.8246384-13.291775 13.2917734-13.2917749z" fill="#dcdcdc" str' +
          'oke="url(#b)" stroke-linecap="round" stroke-miterlimit="10" stro' +
          'ke-width="3.00582" transform="matrix(.665377 0 0 .665377 15.9864' +
          '5 17.90835)"/><path d="m18.602905 3.0803551c-8.16544 0-14.792464' +
          '2 6.627024-14.7924642 14.7924639 0 8.16544 6.6270242 14.792464 1' +
          '4.7924642 14.792464 3.490803 0 6.572177-1.388867 9.103055-3.4136' +
          '45-.206041 1.010136-.07829 2.041947.758587 2.768846l10.999526 9.' +
          '558207c1.237403 1.074792 3.097442.93397 4.172233-.303435 1.07479' +
          '1-1.237404.933968-3.097442-.303435-4.172233l-10.999525-9.558208c' +
          '-.673698-.585164-1.497704-.758413-2.313693-.644799 1.993122-2.52' +
          '0544 3.375716-5.56674 3.375716-9.027197 0-8.1654399-6.627024-14.' +
          '7924639-14.792464-14.7924639zm-.07586 3.1860692c6.281108.0000002' +
          ' 11.378818 5.0977107 11.378818 11.3788187s-5.09771 11.378818-11.' +
          '378818 11.378818-11.3788184-5.09771-11.3788184-11.378818c.000000' +
          '2-6.281108 5.0977104-11.3788187 11.3788184-11.3788187z" fill="#d' +
          'cdcdc" transform="matrix(.665377 0 0 .665377 15.98645 17.90835)"' +
          '/><path d="m39.507004 41.57769c-.478672-2.273187 1.39733-4.81142' +
          '2 3.584053-4.788375 0 0-10.760367-9.258111-10.760367-9.258111-2.' +
          '944791-.05671-4.269502 2.272616-3.776814 4.599922z" fill="url(#c' +
          ')" transform="matrix(.665377 0 0 .665377 15.98645 17.90835)"/></' +
          'g><circle cx="17.500893" cy="18.920233" fill="none" r="11.048544' +
          '" stroke="url(#d)" stroke-linecap="round" stroke-miterlimit="10"' +
          ' stroke-width="1.20643" transform="matrix(.82888874 0 0 .8288887' +
          '4 13.707304 13.798294)"/><rect height="4.440478" rx="3.211203" r' +
          'y="2.837393" style="opacity:.433155;fill:none;stroke:#fff;stroke' +
          '-width:1.50295;stroke-linecap:round;stroke-miterlimit:10" transf' +
          'orm="matrix(.50101957 .43784268 -.43176447 .50626673 15.98645 17' +
          '.90835)" width="19.048439" x="40.373337" y=".140861"/><circle cx' +
          '="17.589281" cy="18.478292" r="8.308505" style="fill-rule:evenod' +
          'd;stroke:#3063a3;stroke-width:1.07457;stroke-linecap:round;strok' +
          'e-miterlimit:10;fill:url(#e)" transform="matrix(.93060559 0 0 .9' +
          '3060559 11.844919 12.386414)"/><path d="m18.156915 7.3966938c-5.' +
          '20759 0-9.4245469 4.2169572-9.4245469 9.4245472 0 1.503975.42030' +
          '72 2.887773 1.0471719 4.149903 1.25238.461613 2.582757.775683 3.' +
          '994767.775683 6.170955 0 11.099282-4.861637 11.480106-10.937129-' +
          '1.730964-2.0455312-4.210039-3.4130042-7.097498-3.4130042z" fill=' +
          '"url(#f)" fill-rule="evenodd" opacity=".834225" transform="matri' +
          'x(.665377 0 0 .665377 15.98645 17.90835)"/></g></svg>'
      end
      item
        IconName = 'refresh'
        SVGText = 
          '<svg height="48" width="48" xmlns="http://www.w3.org/2000/svg" x' +
          'mlns:xlink="http://www.w3.org/1999/xlink"><linearGradient id="a"' +
          ' gradientTransform="matrix(.95419257 0 0 .96222109 .499679 1.718' +
          '761)" gradientUnits="userSpaceOnUse" x1="24.668951" x2="39.68633' +
          '7" y1="42.95816" y2="28.50532"><stop offset="0" stop-color="#fff' +
          '" stop-opacity=".5"/><stop offset=".57424062" stop-color="#7db9e' +
          '8"/><stop offset="1" stop-color="#fff" stop-opacity="0"/></linea' +
          'rGradient><linearGradient id="b" gradientTransform="matrix(1.021' +
          '3968 0 0 1 -.507787 -.999521)" gradientUnits="userSpaceOnUse" x1' +
          '="33.686768" x2="37.039948" y1="35.773647" y2="29.856804"><stop ' +
          'offset="0" stop-color="#14599f"/><stop offset="1" stop-color="#2' +
          '04a87" stop-opacity="0"/></linearGradient><linearGradient id="c"' +
          ' gradientTransform="matrix(1.0213968 0 0 1 -.507787 -.999521)" g' +
          'radientUnits="userSpaceOnUse" x1="31.226292" x2="34.96563" y1="3' +
          '4.600941" y2="26.842505"><stop offset="0" stop-color="#006bbd"/>' +
          '<stop offset="1" stop-color="#3465a4" stop-opacity="0"/></linear' +
          'Gradient><linearGradient id="d" gradientUnits="userSpaceOnUse" x' +
          '1="24.03189188276" x2="35.11537158975" y1="2.995163809" y2="31.9' +
          '0397103798"><stop offset="0" stop-color="#729fcf"/><stop offset=' +
          '"1" stop-color="#006bbd"/></linearGradient><g transform="matrix(' +
          '-1 0 0 1 48.000776 0)"><path d="m24.000386 32.500479c-4.894952-.' +
          '05388-8.553204-4.126736-8.499087-9 .05412-4.873262 4.104132-9.05' +
          '3879 8.999087-9 2.36391.02602 4.43898.509791 6.136756 2.147585l-' +
          '4.136756 4.852415h16v-16.0000003l-4.471103 3.60953c-3.708226-3.6' +
          '439939-7.994745-5.5533785-13.467619-5.6136173-11.133559-.1225452' +
          '-20.013113 8.9469836-20.136204 20.0312096-.123092 11.084225 8.73' +
          '5733 19.753855 19.869292 19.876399" fill="url(#d)" stroke="#1460' +
          '9f" stroke-linejoin="round"/><path d="m23.866941 43.402143c9.509' +
          '325.102473 20.150949-7.091093 20.133835-19.52578l-10.070085-.076' +
          '74c-.185391 5.072466-5.665301 8.889748-10.180305 8.70086" fill="' +
          'url(#c)" stroke="url(#b)" stroke-width="1.01064"/><g fill="none"' +
          '><path d="m24.250386 33.650479c-5.423155-.07929-9.744296-3.86846' +
          '-9.75-10.15-.0049-5.396381 4.672169-10.219134 10.095325-10.13984' +
          '8 2.673075.03908 5.712878.890037 7.726664 3.166851l-3.326033 3.8' +
          '33131 12.383472.02029v-12.4640654l-3.377628 2.8747284c-3.542022-' +
          '3.9509003-7.981015-6.1007985-13.521418-6.1562401-10.597787-.1060' +
          '495-18.806515 8.4013031-18.888409 18.9990571.259072 11.855739 9.' +
          '392781 18.618757 18.702543 18.821492" stroke="#fff" stroke-opaci' +
          'ty=".5" stroke-width="1.193"/><path d="m24.294902 42.455875c7.95' +
          '111 0 18.221834-5.583144 18.322006-18.54338l-8.055423-.207989c.0' +
          '072 5.258838-4.745611 9.805108-10.30785 9.971413" stroke="url(#a' +
          ')" stroke-linejoin="round" stroke-width="1.19775"/></g></g></svg' +
          '>'
      end
      item
        IconName = 'goto-prev-sect'
        SVGText = 
          '<svg height="48" viewBox="0 0 48 48" width="48" xmlns="http://ww' +
          'w.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><l' +
          'inearGradient id="a" gradientTransform="matrix(.9754464 0 0 1.06' +
          '02677 1.262032 .902902)" gradientUnits="userSpaceOnUse" x1="11" ' +
          'x2="11" y1="17" y2="-3"><stop offset="0" stop-color="#f0f0ee"/><' +
          'stop offset="1" stop-color="#dedede"/></linearGradient><linearGr' +
          'adient id="b" gradientUnits="userSpaceOnUse" x1="26.326958" x2="' +
          '38.2808" y1="23.567663" y2="25.128147"><stop offset="0" stop-col' +
          'or="#1298e7"/><stop offset="1" stop-color="#00669f"/></linearGra' +
          'dient><linearGradient id="c" gradientUnits="userSpaceOnUse" x1="' +
          '5.088635" x2="18.320778" y1="-5.62013" y2="-5.62013"><stop offse' +
          't="0" stop-color="#37abef"/><stop offset="1" stop-color="#007bc1' +
          '"/></linearGradient><g transform="matrix(2.4939273 0 0 2.4939273' +
          ' -4.690687 -6.016196)"><rect fill="url(#a)" height="16.964285" r' +
          'x="1.017857" stroke="#888a85" stroke-miterlimit="10.433" stroke-' +
          'width=".678571" width="15.607142" x="3.700648" y="3.553572"/><re' +
          'ct fill="none" height="15.607142" rx=".339286" stroke="#fff" str' +
          'oke-miterlimit="10.433" stroke-width=".678571" width="14.129219"' +
          ' x="4.5" y="4.232143"/><path d="m6.10644-6.190759h10.795361v1.34' +
          '1773h-10.795361z" style="stroke:#2b65ab;stroke-width:.406769;str' +
          'oke-linecap:round;stroke-linejoin:round;stroke-miterlimit:10;fil' +
          'l:url(#c)" transform="scale(1 -1)"/><g transform="matrix(0 .3761' +
          '153 -.3761153 0 20.12497 1.948768)"><path d="m24.5 13.5-11 10 11' +
          ' 10.46875.03125-6.46875h9.375c4.644932-.191207 7.691828 2.156247' +
          ' 7.5625 5v.125 6.8125c10.220318-7.052696 3.633048-20.077177-7.56' +
          '25-19.96875l-9.40625.0625z" style="stroke:#2b65ab;stroke-width:1' +
          '.0815;stroke-linecap:round;stroke-linejoin:round;stroke-miterlim' +
          'it:10;fill:url(#b)"/><path d="m23.46875 15.8125-8.46875 7.6875 8' +
          '.46875 8.0625.03125-4.0625c.000328-.569408.461842-1.030922 1.031' +
          '25-1.03125h9.375c2.505095-.103121 4.601649.454623 6.15625 1.5312' +
          '5 1.545505 1.070327 2.506852 2.710188 2.4375 4.5-.000408.01053.0' +
          '0048.02071 0 .03125v.09375 4.4375c3.124654-3.062309 3.650684-6.6' +
          '81869 2.28125-9.875-1.598769-3.727873-5.679225-6.73782-10.875-6.' +
          '6875l-9.40625.0625c-.569408-.000328-1.030922-.461842-1.03125-1.0' +
          '3125z" fill="none" stroke="#9bc8e6" stroke-width=".999999"/></g>' +
          '</g></svg>'
      end
      item
        IconName = 'goto-next-sect'
        SVGText = 
          '<svg height="48" viewBox="0 0 48 48" width="48" xmlns="http://ww' +
          'w.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><l' +
          'inearGradient id="a" gradientTransform="matrix(.9754464 0 0 1.06' +
          '02677 1.262032 .902902)" gradientUnits="userSpaceOnUse" x1="11" ' +
          'x2="11" y1="17" y2="-3"><stop offset="0" stop-color="#f0f0ee"/><' +
          'stop offset="1" stop-color="#dedede"/></linearGradient><linearGr' +
          'adient id="b" gradientUnits="userSpaceOnUse" x1="26.326958" x2="' +
          '38.2808" y1="23.567663" y2="25.128147"><stop offset="0" stop-col' +
          'or="#1298e7"/><stop offset="1" stop-color="#00669f"/></linearGra' +
          'dient><linearGradient id="c" gradientUnits="userSpaceOnUse" x1="' +
          '5.08863518771" x2="18.32095549843" y1="18.53157869026" y2="18.53' +
          '157869026"><stop offset="0" stop-color="#37abef"/><stop offset="' +
          '1" stop-color="#007bc1"/></linearGradient><g transform="matrix(2' +
          '.4939273 0 0 2.4939273 -4.690687 -6.016196)"><rect fill="url(#a)' +
          '" height="16.964285" rx="1.017857" stroke="#888a85" stroke-miter' +
          'limit="10.433" stroke-width=".678571" width="15.607142" x="3.700' +
          '648" y="3.553572"/><rect fill="none" height="15.607142" rx=".339' +
          '286" stroke="#fff" stroke-miterlimit="10.433" stroke-width=".678' +
          '571" width="14.129219" x="4.5" y="4.232143"/><path d="m6.106454 ' +
          '17.960943h10.795506v1.341791h-10.795506z" style="stroke:#2b65ab;' +
          'stroke-width:.406774;stroke-linecap:round;stroke-linejoin:round;' +
          'stroke-miterlimit:10;fill:url(#c)"/><g transform="matrix(0 -.376' +
          '12036 -.37612036 0 20.125172 22.202991)"><path d="m24.5 13.5-11 ' +
          '10 11 10.46875.03125-6.46875h9.375c4.644932-.191207 7.691828 2.1' +
          '56247 7.5625 5v.125 6.8125c10.220318-7.052696 3.633048-20.077177' +
          '-7.5625-19.96875l-9.40625.0625z" style="stroke:#2b65ab;stroke-wi' +
          'dth:1.0815;stroke-linecap:round;stroke-linejoin:round;stroke-mit' +
          'erlimit:10;fill:url(#b)"/><path d="m23.46875 15.8125-8.46875 7.6' +
          '875 8.46875 8.0625.03125-4.0625c.000328-.569408.461842-1.030922 ' +
          '1.03125-1.03125h9.375c2.505095-.103121 4.601649.454623 6.15625 1' +
          '.53125 1.545505 1.070327 2.506852 2.710188 2.4375 4.5-.000408.01' +
          '053.00048.02071 0 .03125v.09375 4.4375c3.124654-3.062309 3.65068' +
          '4-6.681869 2.28125-9.875-1.598769-3.727873-5.679225-6.73782-10.8' +
          '75-6.6875l-9.40625.0625c-.569408-.000328-1.030922-.461842-1.0312' +
          '5-1.03125z" fill="none" stroke="#9bc8e6" stroke-width=".999999"/' +
          '></g></g></svg>'
      end
      item
        IconName = 'goto-prev-error'
        SVGText = 
          '<svg height="48" viewBox="0 0 48 48" width="48" xmlns="http://ww' +
          'w.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><l' +
          'inearGradient id="a" gradientTransform="matrix(.9754464 0 0 1.06' +
          '02677 1.262032 .902902)" gradientUnits="userSpaceOnUse" x1="11" ' +
          'x2="11" y1="17" y2="-3"><stop offset="0" stop-color="#f0f0ee"/><' +
          'stop offset="1" stop-color="#dedede"/></linearGradient><linearGr' +
          'adient id="b" gradientTransform="matrix(.9943096 0 0 1.3385136 .' +
          '277421 -27.399463)" gradientUnits="userSpaceOnUse" x1="3.148092"' +
          ' x2="19.711403" y1="16.478714" y2="16.446428"><stop offset="0" s' +
          'top-color="#ffc8be"/><stop offset="1" stop-color="#c50f15"/></li' +
          'nearGradient><linearGradient id="c" gradientUnits="userSpaceOnUs' +
          'e" x1="26.326958" x2="38.2808" y1="23.567663" y2="25.128147"><st' +
          'op offset="0" stop-color="#e7121a"/><stop offset="1" stop-color=' +
          '"#c21f00"/></linearGradient><g transform="matrix(2.4939273 0 0 2' +
          '.4939273 -4.690687 -6.016196)"><rect fill="url(#a)" height="16.9' +
          '64285" rx="1.017857" stroke="#888a85" stroke-miterlimit="10.433"' +
          ' stroke-width=".678571" width="15.607142" x="3.700648" y="3.5535' +
          '72"/><rect fill="none" height="15.607142" rx=".339286" stroke="#' +
          'fff" stroke-miterlimit="10.433" stroke-width=".678571" width="14' +
          '.129219" x="4.5" y="4.232143"/><path d="m6.10644-6.190759h10.795' +
          '361v1.341773h-10.795361z" style="stroke:#b42d34;stroke-width:.46' +
          '2582;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimi' +
          't:10;fill:url(#b)" transform="scale(1 -1)"/><g transform="matrix' +
          '(0 .37610949 -.37610949 0 20.124816 1.94891)"><path d="m24.5 13.' +
          '5-11 10 11 10.46875.03125-6.46875h9.375c4.644932-.191207 7.69182' +
          '8 2.156247 7.5625 5v.125 6.8125c10.220318-7.052696 3.633048-20.0' +
          '77177-7.5625-19.96875l-9.40625.0625z" style="stroke:#b42d34;stro' +
          'ke-width:1.0815;stroke-linecap:round;stroke-linejoin:round;strok' +
          'e-miterlimit:10;fill:url(#c)"/><path d="m23.46875 15.8125-8.4687' +
          '5 7.6875 8.46875 8.0625.03125-4.0625c.000328-.569408.461842-1.03' +
          '0922 1.03125-1.03125h9.375c2.505095-.103121 4.601649.454623 6.15' +
          '625 1.53125 1.545505 1.070327 2.506852 2.710188 2.4375 4.5-.0004' +
          '08.01053.00048.02071 0 .03125v.09375 4.4375c3.124654-3.062309 3.' +
          '650684-6.681869 2.28125-9.875-1.598769-3.727873-5.679225-6.73782' +
          '-10.875-6.6875l-9.40625.0625c-.569408-.000328-1.030922-.461842-1' +
          '.03125-1.03125z" fill="none" stroke="#e69b9e" stroke-width=".999' +
          '999"/></g></g></svg>'
      end
      item
        IconName = 'goto-next-error'
        SVGText = 
          '<svg height="48" viewBox="0 0 48 48" width="48" xmlns="http://ww' +
          'w.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><l' +
          'inearGradient id="a" gradientTransform="matrix(.9754464 0 0 1.06' +
          '02677 1.262032 .902902)" gradientUnits="userSpaceOnUse" x1="11" ' +
          'x2="11" y1="17" y2="-3"><stop offset="0" stop-color="#f0f0ee"/><' +
          'stop offset="1" stop-color="#dedede"/></linearGradient><linearGr' +
          'adient id="b" gradientTransform="matrix(.99432495 0 0 1.3385343 ' +
          '.277347 -3.328388)" gradientUnits="userSpaceOnUse" x1="3.148092"' +
          ' x2="19.711403" y1="16.478714" y2="16.446428"><stop offset="0" s' +
          'top-color="#ffc8be"/><stop offset="1" stop-color="#c50f15"/></li' +
          'nearGradient><linearGradient id="c" gradientUnits="userSpaceOnUs' +
          'e" x1="26.326958" x2="38.2808" y1="23.567663" y2="25.128147"><st' +
          'op offset="0" stop-color="#e7121a"/><stop offset="1" stop-color=' +
          '"#c21f00"/></linearGradient><g transform="matrix(2.4939273 0 0 2' +
          '.4939273 -4.690687 -6.016196)"><rect fill="url(#a)" height="16.9' +
          '64285" rx="1.017857" stroke="#888a85" stroke-miterlimit="10.433"' +
          ' stroke-width=".678571" width="15.607142" x="3.700648" y="3.5535' +
          '72"/><rect fill="none" height="15.607142" rx=".339286" stroke="#' +
          'fff" stroke-miterlimit="10.433" stroke-width=".678571" width="14' +
          '.129219" x="4.5" y="4.232143"/><path d="m6.106456 17.880644h10.7' +
          '95527v1.341794h-10.795527z" style="stroke:#b42d34;stroke-width:.' +
          '462589;stroke-linecap:round;stroke-linejoin:round;stroke-miterli' +
          'mit:10;fill:url(#b)"/><g transform="matrix(0 -.3761153 -.3761153' +
          ' 0 20.125048 22.122558)"><path d="m24.5 13.5-11 10 11 10.46875.0' +
          '3125-6.46875h9.375c4.644932-.191207 7.691828 2.156247 7.5625 5v.' +
          '125 6.8125c10.220318-7.052696 3.633048-20.077177-7.5625-19.96875' +
          'l-9.40625.0625z" style="stroke:#b42d34;stroke-width:1.0815;strok' +
          'e-linecap:round;stroke-linejoin:round;stroke-miterlimit:10;fill:' +
          'url(#c)"/><path d="m23.46875 15.8125-8.46875 7.6875 8.46875 8.06' +
          '25.03125-4.0625c.000328-.569408.461842-1.030922 1.03125-1.03125h' +
          '9.375c2.505095-.103121 4.601649.454623 6.15625 1.53125 1.545505 ' +
          '1.070327 2.506852 2.710188 2.4375 4.5-.000408.01053.00048.02071 ' +
          '0 .03125v.09375 4.4375c3.124654-3.062309 3.650684-6.681869 2.281' +
          '25-9.875-1.598769-3.727873-5.679225-6.73782-10.875-6.6875l-9.406' +
          '25.0625c-.569408-.000328-1.030922-.461842-1.03125-1.03125z" fill' +
          '="none" stroke="#e69b9e" stroke-width=".999999"/></g></g></svg>'
      end
      item
        IconName = 'font'
        SVGText = 
          '<svg height="48" viewBox="0 0 48 48" width="48" xmlns="http://ww' +
          'w.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><l' +
          'inearGradient id="a" gradientTransform="matrix(.9754464 0 0 1.06' +
          '02677 1.262032 .902902)" gradientUnits="userSpaceOnUse" x1="11" ' +
          'x2="11" y1="17" y2="-3"><stop offset="0" stop-color="#f0f0ee"/><' +
          'stop offset="1" stop-color="#dedede"/></linearGradient><g transf' +
          'orm="matrix(2.4939273 0 0 2.4939273 -4.690687 -6.016196)"><rect ' +
          'fill="url(#a)" height="16.964285" rx="1.017857" stroke="#888a85"' +
          ' stroke-miterlimit="10.433" stroke-width=".678571" width="15.607' +
          '142" x="3.700648" y="3.553572"/><rect fill="none" height="15.607' +
          '142" rx=".339286" stroke="#fff" stroke-miterlimit="10.433" strok' +
          'e-width=".678571" width="14.129219" x="4.5" y="4.232143"/><path ' +
          'd="m13.610847 16.691101-.416124-2.479405h-3.5717306l-1.213695 2.' +
          '392713q.4334625.398785 1.38708.520155l-.086693.69354h-3.9185003l' +
          '.086692-.69354q.8149099-.069354 1.1443414-.433463l5.3575965-10.4' +
          '377761h1.803204l2.097958 10.2817301q.190723.468139.936279.589509' +
          'l-.06935.69354h-4.785426l.104031-.69354q.849587-.12137 1.144341-' +
          '.433463zm-1.300387-7.7329702-2.132636 4.1612402h2.826176z" fill=' +
          '"#5aacf0" stroke="#346ab3" stroke-width=".464426"/></g></svg>'
      end
      item
        IconName = 'codepage'
        SVGText = 
          '<svg height="48" viewBox="0 0 48 48" width="48" xmlns="http://ww' +
          'w.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><l' +
          'inearGradient id="a" gradientTransform="matrix(.9754464 0 0 1.06' +
          '02677 1.262032 .902902)" gradientUnits="userSpaceOnUse" x1="11" ' +
          'x2="11" y1="17" y2="-3"><stop offset="0" stop-color="#f0f0ee"/><' +
          'stop offset="1" stop-color="#dedede"/></linearGradient><g transf' +
          'orm="matrix(2.4939273 0 0 2.4939273 -4.690687 -6.016196)"><rect ' +
          'fill="url(#a)" height="16.964285" rx="1.017857" stroke="#888a85"' +
          ' stroke-miterlimit="10.433" stroke-width=".678571" width="15.607' +
          '142" x="3.700648" y="3.553572"/><rect fill="none" height="15.607' +
          '142" rx=".339286" stroke="#fff" stroke-miterlimit="10.433" strok' +
          'e-width=".678571" width="14.129219" x="4.5" y="4.232143"/><path ' +
          'd="m6.8011066 17.460519q-.7444089 0-1.1435846-.345233-.3991759-.' +
          '345233-.3991759-1.003334 0-1.434875 2.1253413-1.585915l.949391-.' +
          '06473v-.625735q0-.755198-.1834051-1.046487-.1726165-.291291-.550' +
          '2152-.291291-.3668102 0-.5717924.161828-.1941936.151039-.1941936' +
          '.409965 0 .248135.2373478.43154-.053943.269714-.2589248.431542-.' +
          '2049822.161828-.5286381.161828-.3236561 0-.5610038-.22656-.23734' +
          '77-.226559-.2373477-.561003 0-.571793.5394267-.895448.5502151-.3' +
          '34445 1.5103947-.334445 2.3195348 0 2.3195348 1.704588v2.934482q' +
          '.1834053.204982.6473123.29129l-.04315.377599h-1.9419405l-.107885' +
          '4-.614945q-.6904661.690466-1.6074915.690466zm.9925451-2.42742q-.' +
          '5933694.04315-.8522942.269713-.2589248.226559-.2589248.636524 0 ' +
          '.819928.647312.819928.4962725 0 1.0033337-.59337v-1.17595zm-.194' +
          '1936-4.19674q0 .614946-.7120433.614946-.7012546 0-.7012546-.6149' +
          '46 0-.59337.7012546-.59337.7120433 0 .7120433.59337zm1.7693195 0' +
          'q0 .614946-.7120432.614946-.7120433 0-.7120433-.614946 0-.59337.' +
          '7120433-.59337.7120432 0 .7120432.59337z" fill="#299751"/><path ' +
          'd="m11.790628 9.6669366v.1666385q0 .8748519.249959 1.3018639.249' +
          '958.416596.937342.416596.874852 0 1.437257-.57282l.416597.406181' +
          'q-.427012.427012-.895683.656139-.458256.229129-1.20813.229129-1.' +
          '208128 0-1.822608-.676969-.604065-.687384-.604065-1.8955137 0-1.' +
          '2185444.645724-1.9163433.645724-.7082138 1.833025-.7082138 1.197' +
          '713 0 1.687215.5415753.489501.5415753.55199 1.6143109l-.291618.4' +
          '374262zm.979003-2.0829819q-.947757 0-.979003 1.6663855l1.749706-' +
          '.083319q0-.8331927-.166638-1.2081294-.16664-.3749368-.604065-.37' +
          '49371zm-.468671-2.2496202q.249957-.2812025.562404-.2812025.31244' +
          '8 0 .562406.2812025l.989416 1.1143953-.302033.3853514-1.249789-.' +
          '8644373-1.249789.8644373-.302032-.3853514z" fill="#326bae"/><pat' +
          'h d="m17.56958 19.074333q-1.258754-.01015-2.37539-.01015-1.11663' +
          '7 0-1.644501.0203l-.0406-.446655 2.426146-3.938681h-1.177544q-.1' +
          '21815.223327-.223327.913612-.24363.04061-.456806.04061-.203025 0' +
          '-.477108-.09136l-.09136-1.126787.375596-.304538q.345142.0203 1.7' +
          '05408.0203 1.370417 0 1.949038-.0203l.101513.375596-2.497206 3.9' +
          '89438h1.279057q.192873-.314689.345142-.994822.253781-.06091.4263' +
          '52-.06091.172571 0 .446655.05076zm-1.015124-7.207381q.213176 0 .' +
          '334991.131966.131966.131966.131966.345142 0 .345142-.32484.56847' +
          'l-1.187695.842553-.345142-.334991.812099-1.207998q.223327-.34514' +
          '2.578621-.345142z" fill="#d85826"/></g></svg>'
      end
      item
        IconName = 'doc-save-zip'
        SVGText = 
          '<svg height="48" viewBox="0 0 48 48" width="48" xmlns="http://ww' +
          'w.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><l' +
          'inearGradient id="a" gradientTransform="matrix(.97754193 0 0 1.1' +
          '397756 .56166 -3.270842)" gradientUnits="userSpaceOnUse" x1="40.' +
          '884724" x2="16.879831" y1="71.869133" y2="-.389314"><stop offset' +
          '="0" stop-color="#1e2d69"/><stop offset="1" stop-color="#78a7e0"' +
          '/></linearGradient><linearGradient id="b" gradientTransform="mat' +
          'rix(.985432 0 0 1.148179 .64107 -2.933883)" gradientUnits="userS' +
          'paceOnUse" x1="13.783585" x2="33.074715" y1="-.996729" y2="55.70' +
          '1546"><stop offset="0" stop-color="#fff"/><stop offset="1" stop-' +
          'color="#fff" stop-opacity="0"/></linearGradient><linearGradient ' +
          'id="c" gradientTransform="matrix(1.067698 0 0 1.121532 -1.368937' +
          ' -5.57446)" gradientUnits="userSpaceOnUse" x1="20.125" x2="28.56' +
          '25" y1="21.84375" y2="42.46875"><stop offset="0" stop-color="#85' +
          '8585"/><stop offset=".5" stop-color="#cbcbcb"/><stop offset="1" ' +
          'stop-color="#6b6b6b"/></linearGradient><linearGradient id="d" gr' +
          'adientTransform="matrix(.9754464 0 0 1.0602677 1.262032 .902902)' +
          '" gradientUnits="userSpaceOnUse" x1="11" x2="11" y1="17" y2="-3"' +
          '><stop offset="0" stop-color="#f0f0ee"/><stop offset="1" stop-co' +
          'lor="#dedede"/></linearGradient><g transform="matrix(1.596491299' +
          '64 0 0 1.59649125068 4.63361373441 -4.13157972954)"><rect fill="' +
          'url(#d)" height="16.964285" rx="1.017857" stroke="#888a85" strok' +
          'e-miterlimit="10.433" stroke-width=".678571" width="15.607142" x' +
          '="3.700648" y="3.553572"/><rect fill="none" height="15.607142" r' +
          'x=".339286" stroke="#fff" stroke-miterlimit="10.433" stroke-widt' +
          'h=".678571" width="14.129219" x="4.5" y="4.232143"/><path id="e"' +
          ' d="m5.890584 5.820617h10.857142v1.002435h-10.857142z" fill="#91' +
          '938e"/><use transform="matrix(1.0340909 0 0 1.6 -.200815 -3.6928' +
          '57)" xlink:href="#e"/><use transform="matrix(1.0340909 0 0 1.6 -' +
          '.200816 -.88604)" xlink:href="#e"/><use transform="matrix(1.0340' +
          '909 0 0 1.6 -.200816 1.920778)" xlink:href="#e"/><use transform=' +
          '"matrix(1.0340909 0 0 1.6 -.200816 4.727596)" xlink:href="#e"/><' +
          'use transform="matrix(.73863634 0 0 1.6 1.539584 7.534414)" xlin' +
          'k:href="#e"/></g><g stroke-miterlimit="10" transform="matrix(0 -' +
          '.44116660205 .44116661558 0 27.79450159016 25.46135489599)"><pat' +
          'h d="m14.519136 38.5 18.005029-.0039v-12.991632l7.995366-.0078-1' +
          '7.144722-19.9974545-16.8462505 19.9980705 7.9958815.0038z" fill=' +
          '"#eb4747" fill-rule="evenodd" stroke="#c7000b" stroke-linecap="r' +
          'ound" stroke-linejoin="round"/><path d="m15.520704 37.496094 16.' +
          '001405.003906v-12.99295l6.816811-.015625-14.954276-17.4525854-14' +
          '.7065267 17.4569424 6.8399007.0052z" fill="none" opacity=".48128' +
          '3" stroke="#fff"/></g><g stroke-miterlimit="10" transform="matri' +
          'x(0 .44116660205 -.44116661558 0 18.20549779222 4.70531009372)">' +
          '<path d="m14.519136 38.5 18.005029-.0039v-12.991632l7.995366-.00' +
          '78-17.144722-19.9974545-16.8462505 19.9980705 7.9958815.0038z" f' +
          'ill="#eb4747" fill-rule="evenodd" stroke="#c00" stroke-linecap="' +
          'round" stroke-linejoin="round"/><path d="m15.520704 37.496094 16' +
          '.001405.003906v-12.99295l6.816811-.015625-14.954276-17.4525854-1' +
          '4.7065267 17.4569424 6.8399007.0052z" fill="none" opacity=".4812' +
          '83" stroke="#fff"/></g><g transform="matrix(.57065068 0 0 .58612' +
          '042 21.291444 21.202029)"><path d="m4.5590083 3.5678147h38.92733' +
          '37c.589855 0 1.064721.4744086 1.064721 1.0636961v37.7647652c0 .5' +
          '89288-.474866 1.063696-1.064721 1.063696h-36.9254293s-3.0666258-' +
          '3.063672-3.0666258-3.063672v-35.7647892c0-.5892875.4748658-1.063' +
          '6961 1.0647214-1.0636961z" fill="url(#a)" stroke="#25375f" strok' +
          'e-linecap="round" stroke-linejoin="round" stroke-width="1.00047"' +
          '/><path d="m9 4h30v23h-30z" fill="#fff"/><rect fill="#d31c00" he' +
          'ight="4" rx=".126208" width="30" x="9" y="4"/><rect height="2" o' +
          'pacity=".738636" rx=".126208" width="2" x="6" y="6"/><g stroke="' +
          '#000"><path d="m11 12.5h26" opacity=".130682"/><path d="m11 17.5' +
          'h26" opacity=".130682"/><path d="m11 22.5h26" opacity=".130682"/' +
          '></g><path d="m4.6189226 4.5276647h38.7684814c.06992 0 .126208.0' +
          '56289.126208.1262077v37.6482386c0 .06992-.05629.126208-.126208.1' +
          '26208h-36.4591222s-2.4355669-2.391373-2.4355669-2.391373v-35.383' +
          '0736c0-.069919.056289-.1262077.1262077-.1262077z" fill="none" op' +
          'acity=".596591" stroke="url(#b)" stroke-linecap="round"/><path d' +
          '="m14.113967 28.562183h19.749824c.887971 0 1.602836.75091 1.6028' +
          '36 1.683653v13.201551h-22.955496v-13.201551c0-.932743.714865-1.6' +
          '83653 1.602836-1.683653z" fill="url(#c)" stroke="#525252" stroke' +
          '-width=".999999"/><rect fill="#4967a2" height="10.06597" rx=".75' +
          '1207" ry=".751208" stroke="#525252" width="5.029753" x="16.46427' +
          '9" y="30.4566"/></g></svg>'
      end>
    Left = 70
    Top = 65
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'zip'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 720
    Top = 55
  end
end
