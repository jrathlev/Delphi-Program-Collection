object fmExplorerSVG: TfmExplorerSVG
  Left = 0
  Top = 0
  ClientHeight = 598
  ClientWidth = 984
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object spVertical: TSplitter
    Left = 216
    Top = 0
    Width = 4
    Height = 598
    AutoSnap = False
    MinSize = 120
    ExplicitLeft = 185
    ExplicitHeight = 509
  end
  object spRight: TSplitter
    Left = 749
    Top = 0
    Width = 4
    Height = 598
    Align = alRight
    AutoSnap = False
    MinSize = 90
    ExplicitLeft = 980
    ExplicitHeight = 509
  end
  object paDir: TPanel
    Left = 0
    Top = 0
    Width = 216
    Height = 598
    Align = alLeft
    ParentShowHint = False
    ShowHint = False
    TabOrder = 0
    object DirPanel: TPanel
      Left = 1
      Top = 478
      Width = 214
      Height = 31
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        214
        31)
      object cbxSelectedDir: TComboBox
        Left = 2
        Top = 5
        Width = 207
        Height = 21
        Hint = 'Directory'
        Anchors = [akLeft, akTop, akRight]
        DropDownCount = 15
        TabOrder = 0
        OnChange = cbxSelectedDirChange
        OnCloseUp = cbxSelectedDirCloseUp
      end
    end
    object PerformanceStatusBar: TStatusBar
      Left = 1
      Top = 578
      Width = 214
      Height = 19
      Panels = <>
      SimplePanel = True
    end
    object TrackBarPanel: TPanel
      Left = 1
      Top = 509
      Width = 214
      Height = 69
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      DesignSize = (
        214
        69)
      object rgSize: TRadioGroup
        Left = 3
        Top = 5
        Width = 203
        Height = 61
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Icons size:'
        Columns = 3
        ItemIndex = 3
        Items.Strings = (
          '16 px'
          '20 px'
          '24 px'
          '32 px'
          '48 px'
          '64 px')
        TabOrder = 0
        OnClick = rgSizeClick
      end
    end
    object ShellTreeView: TShellTreeView
      Left = 1
      Top = 1
      Width = 214
      Height = 477
      ObjectTypes = [otFolders]
      Root = 'rfDesktop'
      UseShellImages = True
      Align = alClient
      AutoRefresh = True
      HideSelection = False
      Indent = 19
      ParentColor = False
      PopupMenu = pmDirs
      RightClickSelect = True
      ShowRoot = False
      TabOrder = 3
      OnClick = ShellTreeViewClick
    end
  end
  object paList: TPanel
    Left = 220
    Top = 0
    Width = 529
    Height = 598
    Align = alClient
    TabOrder = 1
    object spBottom: TSplitter
      Left = 1
      Top = 453
      Width = 527
      Height = 3
      Cursor = crVSplit
      Align = alBottom
      AutoSnap = False
      MinSize = 100
      ExplicitTop = 346
      ExplicitWidth = 583
    end
    object ImageView: TListView
      Left = 1
      Top = 42
      Width = 527
      Height = 411
      Align = alClient
      Columns = <>
      IconOptions.AutoArrange = True
      LargeImages = SVGIconImageList
      MultiSelect = True
      PopupMenu = pmImages
      SmallImages = SVGIconImageList
      TabOrder = 1
      OnDblClick = OpenActionExecute
      OnKeyDown = ImageViewKeyDown
      OnSelectItem = ImageViewSelectItem
    end
    object paSVGText: TPanel
      Left = 1
      Top = 456
      Width = 527
      Height = 100
      Hint = 'SVG Text content'
      Align = alBottom
      TabOrder = 2
      object SVGMemo: TMemo
        Left = 1
        Top = 1
        Width = 525
        Height = 98
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object paImageList: TPanel
      Left = 1
      Top = 1
      Width = 527
      Height = 41
      Align = alTop
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = True
      ParentFont = False
      TabOrder = 3
      DesignSize = (
        527
        41)
      object ImageListLabel: TLabel
        Left = 5
        Top = 1
        Width = 517
        Height = 16
        Alignment = taCenter
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'SVG images'
        ExplicitWidth = 573
      end
      object laFoldername: TLabel
        Left = 5
        Top = 20
        Width = 3
        Height = 13
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
    end
    object paRicerca: TPanel
      Left = 1
      Top = 556
      Width = 527
      Height = 41
      Align = alBottom
      TabOrder = 0
      DesignSize = (
        527
        41)
      object SearchBox: TSearchBox
        Left = 130
        Top = 10
        Width = 296
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        TextHint = 'Insert filter with wildcards to search icons by name...'
        OnInvokeSearch = SearchBoxInvokeSearch
      end
      object ShowTextCheckBox: TCheckBox
        Left = 6
        Top = 10
        Width = 115
        Height = 17
        Caption = 'Show Text'
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = ShowTextCheckBoxClick
      end
      object btnResetFilter: TButton
        Left = 430
        Top = 8
        Width = 91
        Height = 26
        Anchors = [akTop, akRight]
        Caption = 'Reset'
        TabOrder = 2
        OnClick = btnResetFilterClick
      end
    end
  end
  object paPreview: TPanel
    Left = 753
    Top = 0
    Width = 231
    Height = 598
    Align = alRight
    TabOrder = 2
    OnResize = paPreviewResize
    object SVGIconImage: TPaintBox
      Left = 1
      Top = 1
      Width = 229
      Height = 88
      Cursor = crSizeAll
      Hint = 'Left click to enlarge, right click to shrink'
      Margins.Left = 10
      Margins.Top = 10
      Margins.Right = 10
      Margins.Bottom = 10
      Align = alTop
      OnMouseDown = SVGIconImageMouseDown
      OnPaint = SVGIconImagePaint
      ExplicitWidth = 199
    end
    object grpFactory: TRadioGroup
      Left = 1
      Top = 483
      Width = 229
      Height = 66
      Margins.Left = 10
      Margins.Top = 5
      Margins.Right = 10
      Margins.Bottom = 5
      Align = alBottom
      Caption = 'SVG Factory'
      TabOrder = 0
      OnClick = grpFactoryClick
    end
    object paTools: TPanel
      Left = 1
      Top = 549
      Width = 229
      Height = 48
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      DesignSize = (
        229
        48)
      object btnRefresh: TButton
        Left = 35
        Top = 10
        Width = 91
        Height = 26
        Action = RefreshAction
        Anchors = [akTop, akRight]
        TabOrder = 0
      end
      object btnExit: TButton
        Left = 130
        Top = 10
        Width = 91
        Height = 26
        Action = ExitAction
        Anchors = [akTop, akRight]
        TabOrder = 1
      end
      object bbContext: TBitBtn
        Left = 6
        Top = 10
        Width = 26
        Height = 26
        Glyph.Data = {
          76060000424D7606000000000000360000002800000014000000140000000100
          2000000000004006000000000000000000000000000000000000C0DCC000C0DC
          C000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DABD05C0DC
          C000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DC
          C000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DC
          C000BFA67C74BE733BE2BD652AFFBF986894C0DCC000C0DCC000BFD0B01ABEA3
          787AC0D9BC07C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DC
          C000C0DCC000C0DCC000C0DCC000C0DCC000BD652AFFBFBB9747C0D1B218BD65
          2AFFC0DCC000C0DCC000BD7640DABD662CFCBD652AFFBFB59052C0DCC000C0DC
          C000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DC
          C000BE8652B9BFB48F54C0DCC000BD6D35ECBD652AFFBD652AFFBD7C48CBC0DC
          C000BFA97F6EBD652BFEC0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DC
          C000BFB59052BD652BFEBFBC9745C0C6A52FBD652AFFBFB9944BC0DCC000C0DC
          C000C0D2B315BFBF9C3DBFD7BA0AC0DCC000BD733CE1BFBC9745C0DCC000C0DC
          C000C0DCC000C0DCC000C0DCC000C0D9BC07BD652AFFBFA97F6EBD733CE1BD65
          2AFFBFBC9844C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DC
          C000BD652AFFC0C6A52FC0DCC000C0DCC000C0DCC000C0DCC000C0DCC000BEA3
          787ABD662CFCC0DCC000C0DCC000C0DCC000C0DCC000C0D9BC07BE9C6F8ABD6F
          37E9BD6D35ECBE9B6E8BC0D8BB08C0DCC000BFBC9844BD652AFFBE8652B9BD65
          2AFFBFA67C74C0DCC000C0DCC000BFD0B01ABD7640DABD7C48CBBFD7BA0AC0DC
          C000C0DABD05BD6B31F3BD8C5BACBFC7A52DBFC9A72ABD8A58B0BD6D35EDC0D8
          BB08C0DCC000BFB9944BBFB48F54BFBB9747BE733BE2C0DCC000C0DCC000C0DC
          C000C0DCC000BD652AFFBFBF9C3DC0DCC000BF9E7285BE8A59AFC0DCC000C0DC
          C000C0DCC000C0DCC000BD8A58B0BF9E7285C0DCC000C0DCC000C0DCC000C0D1
          B218BD652AFFC0DABD05C0DCC000C0DCC000C0DCC000BD652AFFC0D2B315C0DC
          C000BD723AE3C0C4A233C0DCC000C0DCC000C0DCC000C0DCC000BFC2A036BE73
          3BE2C0DCC000C0DCC000BD6D35ECBD652AFFBF986894C0DCC000C0DCC000BF98
          6894BD652AFFBD6D35ECC0DCC000C0DCC000BD723AE3C0C4A233C0DCC000C0DC
          C000C0DCC000C0DCC000BFC2A036BE733BE2C0DCC000C0D2B315BD652AFFC0DC
          C000C0DCC000C0DCC000C0DABD05BD652AFFC0D1B218C0DCC000C0DCC000C0DC
          C000BF9E7285BE8A59AFC0DCC000C0DCC000C0DCC000C0DCC000BD8A58B0BF9E
          7285C0DCC000BFBF9C3DBD652AFFC0DCC000C0DCC000C0DCC000C0DCC000BE73
          3BE2BFBB9747BFB48F54BFB9944BC0DCC000C0DABD05BD6B31F3BD8C5BACBFC7
          A52DBFC9A72ABD8A58B0BD6D35EDC0D8BB08C0DCC000BFD7BA0ABD7C48CBBD76
          40DABFD0B01AC0DCC000C0DCC000BFA67C74BD652AFFBE8652B9BD652AFFBFBC
          9844C0DCC000C0D9BC07BE9C6F8ABD6F37E9BD6E36EBBE9B6E8BC0D8BB08C0DC
          C000C0DCC000C0DCC000C0DCC000BD662CFCBEA3787AC0DCC000C0DCC000C0DC
          C000C0DCC000C0DCC000C0C6A52FBD652AFFC0DCC000C0DCC000C0DCC000C0DC
          C000C0DCC000C0DCC000C0DCC000BFBC9844BD652AFFBD733CE1BFA97F6EBD65
          2AFFC0D9BC07C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000BFBC9745BD73
          3CE1C0DCC000BFD7BA0ABFBF9C3DC0D2B315C0DCC000C0DCC000BFB9944BBD65
          2AFFC0C6A52FBFBC9745BD652BFEBFB59052C0DCC000C0DCC000C0DCC000C0DC
          C000C0DCC000C0DCC000BD652BFEBFA97F6EC0DCC000BD7C48CBBD652AFFBD65
          2AFFBD6D35ECC0DCC000BFB48F54BE8652B9C0DCC000C0DCC000C0DCC000C0DC
          C000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000BFB59052BD65
          2AFFBD662CFCBD7640DAC0DCC000C0DCC000BD652AFFC0D1B218BFBB9747BD65
          2AFFC0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DC
          C000C0DCC000C0DCC000C0DCC000C0D9BC07BEA3787ABFD0B01AC0DCC000C0DC
          C000BF986894BD652AFFBE733BE2BFA67C74C0DCC000C0DCC000C0DCC000C0DC
          C000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DC
          C000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DABD05C0DCC000C0DC
          C000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000C0DCC000}
        TabOrder = 2
        OnClick = bbContextClick
      end
    end
    object gbProperties: TGroupBox
      Left = 1
      Top = 89
      Width = 229
      Height = 102
      Align = alTop
      Caption = 'Image file properties'
      TabOrder = 2
      object laImgName: TLabel
        Left = 10
        Top = 20
        Width = 4
        Height = 16
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object laDate: TLabel
        Left = 10
        Top = 40
        Width = 3
        Height = 13
      end
      object laSize: TLabel
        Left = 10
        Top = 60
        Width = 3
        Height = 13
      end
      object laLayout: TLabel
        Left = 10
        Top = 80
        Width = 3
        Height = 13
      end
    end
    object paCenter: TPanel
      Left = 1
      Top = 191
      Width = 229
      Height = 116
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 3
      DesignSize = (
        229
        116)
      object btnOpen: TButton
        Left = 130
        Top = 6
        Width = 91
        Height = 26
        Action = OpenAction
        Anchors = [akTop, akRight]
        Caption = 'Edit'
        TabOrder = 0
      end
    end
    object pcTools: TPageControl
      Left = 1
      Top = 307
      Width = 229
      Height = 176
      ActivePage = tsExport
      Align = alBottom
      TabOrder = 4
      object tsExport: TTabSheet
        Caption = 'Export to PNG'
        ImageIndex = 1
        DesignSize = (
          221
          148)
        object btnPngDir: TSpeedButton
          Left = 190
          Top = 17
          Width = 31
          Height = 31
          Anchors = [akTop, akRight]
          Flat = True
          Glyph.Data = {
            96090000424D9609000000000000360000002800000028000000140000000100
            18000000000060090000120B0000120B00000000000000000000C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0A46534A46534A46534A46534A46534A46534C0DCC0CC9762CC9762CC9762C0
            DCC0CC9762CC9762CC9762C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC06C6C6C
            6C6C6C6C6C6C6C6C6C6C6C6C6C6C6CC0DCC0979797979797979797C0DCC09797
            97979797979797C0DCC0C0DCC0CC9762CC9762CC9762CC9762A4653400CBFF00
            CBFF00CBFF00CBFFA46534C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC09797979797979797979797976C6C6CB3B3B3B3B3B3B3B3
            B3B3B3B36C6C6CC0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0CC9762CC9762CC9762CC9762A4653400CBFF00CBFF00CBFF00CBFF
            A46534C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C09797979797979797979797976C6C6CB3B3B3B3B3B3B3B3B3B3B3B36C6C6CC0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0CC9762
            CC9762C0DCC0C0DCC0A4653400CBFF00CBFFA46534A46534A46534C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0979797979797C0
            DCC0C0DCC06C6C6CB3B3B3B3B3B36C6C6C6C6C6C6C6C6CC0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0CC9762CC9762C0DCC0C0DC
            C0C0DCC0A46534A46534C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0979797979797C0DCC0C0DCC0C0DCC0
            6C6C6C6C6C6CC0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0CC9762CC9762C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0979797979797C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0CC9762CC9762C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0979797979797C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0CC9762
            CC9762C0DCC0C0DCC0A46534A46534A46534A46534A46534A46534C0DCC0CC97
            62CC9762CC9762C0DCC0CC9762CC9762CC9762C0DCC0C0DCC0979797979797C0
            DCC0C0DCC06C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6CC0DCC0979797979797
            979797C0DCC0979797979797979797C0DCC0C0DCC0CC9762CC9762CC9762CC97
            62A4653400CBFF00CBFF00CBFF00CBFFA46534C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC09797979797979797979797976C6C6C
            B3B3B3B3B3B3B3B3B3B3B3B36C6C6CC0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0CC9762CC9762CC9762CC9762A4653400CBFF00
            CBFF00CBFF00CBFFA46534C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC09797979797979797979797976C6C6CB3B3B3B3B3B3B3B3
            B3B3B3B36C6C6CC0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0CC9762CC9762C0DCC0C0DCC0A4653400CBFF00CBFFA46534A46534
            A46534C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0979797979797C0DCC0C0DCC06C6C6CB3B3B3B3B3B36C6C6C6C6C6C6C6C6CC0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0CC9762
            CC9762C0DCC0C0DCC0C0DCC0A46534A46534C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0979797979797C0
            DCC0C0DCC0C0DCC06C6C6C6C6C6CC0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0CC9762CC9762C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0979797979797C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0CC9762CC9762C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0979797979797C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0A46534A46534A46534A46534A46534A46534C0DCC0CC9762CC9762CC9762
            C0DCC0CC9762CC9762CC9762C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC06C6C
            6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6CC0DCC0979797979797979797C0DCC097
            9797979797979797C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0A4653400CBFF
            00CBFF00CBFF00CBFFA46534C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC06C6C6CB3B3B3B3B3B3B3
            B3B3B3B3B36C6C6CC0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0A4653400CBFF00CBFF00CBFF00CB
            FFA46534C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC06C6C6CB3B3B3B3B3B3B3B3B3B3B3B36C6C6C
            C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0A4653400CBFF00CBFFA46534A46534A46534C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC06C6C6CB3B3B3B3B3B36C6C6C6C6C6C6C6C6CC0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0A46534A46534C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C06C6C6C6C6C6CC0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0}
          NumGlyphs = 2
          OnClick = btnPngDirClick
          ExplicitLeft = 160
        end
        object Label2: TLabel
          Left = 5
          Top = 8
          Width = 44
          Height = 13
          Caption = 'Directory'
        end
        object btnExport: TButton
          Left = 125
          Top = 116
          Width = 91
          Height = 26
          Action = ExportAction
          Anchors = [akTop, akRight]
          TabOrder = 0
        end
        object cbAspectRatio: TCheckBox
          Left = 15
          Top = 95
          Width = 166
          Height = 17
          Caption = 'Keep aspect ratio'
          TabOrder = 1
        end
        object cbxExportDir: TComboBox
          Left = 5
          Top = 25
          Width = 184
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 2
          OnCloseUp = cbxExportDirCloseUp
        end
        object rbOrgSize: TRadioButton
          Left = 15
          Top = 55
          Width = 113
          Height = 17
          Caption = 'Original size'
          Checked = True
          TabOrder = 3
          TabStop = True
          OnClick = rbUserSizeClick
        end
        object rbUserSize: TRadioButton
          Left = 15
          Top = 75
          Width = 113
          Height = 17
          Caption = 'User selected size'
          TabOrder = 4
          OnClick = rbUserSizeClick
        end
      end
      object tsOptimize: TTabSheet
        Caption = 'Optimize'
        DesignSize = (
          221
          148)
        object Label1: TLabel
          Left = 5
          Top = 8
          Width = 44
          Height = 13
          Caption = 'Directory'
        end
        object btnOptimizeDir: TSpeedButton
          Left = 190
          Top = 17
          Width = 31
          Height = 31
          Anchors = [akTop, akRight]
          Flat = True
          Glyph.Data = {
            96090000424D9609000000000000360000002800000028000000140000000100
            18000000000060090000120B0000120B00000000000000000000C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0A46534A46534A46534A46534A46534A46534C0DCC0CC9762CC9762CC9762C0
            DCC0CC9762CC9762CC9762C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC06C6C6C
            6C6C6C6C6C6C6C6C6C6C6C6C6C6C6CC0DCC0979797979797979797C0DCC09797
            97979797979797C0DCC0C0DCC0CC9762CC9762CC9762CC9762A4653400CBFF00
            CBFF00CBFF00CBFFA46534C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC09797979797979797979797976C6C6CB3B3B3B3B3B3B3B3
            B3B3B3B36C6C6CC0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0CC9762CC9762CC9762CC9762A4653400CBFF00CBFF00CBFF00CBFF
            A46534C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C09797979797979797979797976C6C6CB3B3B3B3B3B3B3B3B3B3B3B36C6C6CC0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0CC9762
            CC9762C0DCC0C0DCC0A4653400CBFF00CBFFA46534A46534A46534C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0979797979797C0
            DCC0C0DCC06C6C6CB3B3B3B3B3B36C6C6C6C6C6C6C6C6CC0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0CC9762CC9762C0DCC0C0DC
            C0C0DCC0A46534A46534C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0979797979797C0DCC0C0DCC0C0DCC0
            6C6C6C6C6C6CC0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0CC9762CC9762C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0979797979797C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0CC9762CC9762C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0979797979797C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0CC9762
            CC9762C0DCC0C0DCC0A46534A46534A46534A46534A46534A46534C0DCC0CC97
            62CC9762CC9762C0DCC0CC9762CC9762CC9762C0DCC0C0DCC0979797979797C0
            DCC0C0DCC06C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6CC0DCC0979797979797
            979797C0DCC0979797979797979797C0DCC0C0DCC0CC9762CC9762CC9762CC97
            62A4653400CBFF00CBFF00CBFF00CBFFA46534C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC09797979797979797979797976C6C6C
            B3B3B3B3B3B3B3B3B3B3B3B36C6C6CC0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0CC9762CC9762CC9762CC9762A4653400CBFF00
            CBFF00CBFF00CBFFA46534C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC09797979797979797979797976C6C6CB3B3B3B3B3B3B3B3
            B3B3B3B36C6C6CC0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0CC9762CC9762C0DCC0C0DCC0A4653400CBFF00CBFFA46534A46534
            A46534C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0979797979797C0DCC0C0DCC06C6C6CB3B3B3B3B3B36C6C6C6C6C6C6C6C6CC0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0CC9762
            CC9762C0DCC0C0DCC0C0DCC0A46534A46534C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0979797979797C0
            DCC0C0DCC0C0DCC06C6C6C6C6C6CC0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0CC9762CC9762C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0979797979797C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0CC9762CC9762C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0979797979797C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0A46534A46534A46534A46534A46534A46534C0DCC0CC9762CC9762CC9762
            C0DCC0CC9762CC9762CC9762C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC06C6C
            6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6CC0DCC0979797979797979797C0DCC097
            9797979797979797C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0A4653400CBFF
            00CBFF00CBFF00CBFFA46534C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC06C6C6CB3B3B3B3B3B3B3
            B3B3B3B3B36C6C6CC0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0A4653400CBFF00CBFF00CBFF00CB
            FFA46534C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC06C6C6CB3B3B3B3B3B3B3B3B3B3B3B36C6C6C
            C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0A4653400CBFF00CBFFA46534A46534A46534C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC06C6C6CB3B3B3B3B3B36C6C6C6C6C6C6C6C6CC0DCC0C0DCC0C0DC
            C0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0A46534A46534C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0
            C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DC
            C06C6C6C6C6C6CC0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0
            DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0C0DCC0}
          NumGlyphs = 2
          OnClick = btnOptimizeDirClick
          ExplicitLeft = 160
        end
        object cbxOptimizeDir: TComboBox
          Left = 5
          Top = 25
          Width = 184
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          OnCloseUp = cbxExportDirCloseUp
        end
        object btnOptimize: TButton
          Left = 125
          Top = 116
          Width = 91
          Height = 26
          Action = OptimizeAction
          Anchors = [akTop, akRight]
          TabOrder = 1
          ExplicitLeft = 95
        end
        object btnOptProg: TButton
          Left = 0
          Top = 116
          Width = 91
          Height = 26
          Action = ExportAction
          Caption = 'Program'
          TabOrder = 2
          OnClick = btnOptProgClick
        end
        object edOptions: TLabeledEdit
          Left = 5
          Top = 70
          Width = 181
          Height = 21
          EditLabel.Width = 37
          EditLabel.Height = 13
          EditLabel.Caption = 'Options'
          TabOrder = 3
        end
      end
    end
  end
  object SVGIconImageList: TSVGIconImageList
    Size = 48
    SVGIconItems = <>
    Left = 664
    Top = 232
  end
  object pmImages: TPopupMenu
    OnPopup = pmImagesPopup
    Left = 480
    Top = 160
    object pmiOpen: TMenuItem
      Action = OpenAction
      Caption = 'Edit'
    end
    object pmiCopyName: TMenuItem
      Caption = 'Copy name'
      ShortCut = 16462
      OnClick = pmiCopyNameClick
    end
    object pmiRename: TMenuItem
      Action = RenameAction
    end
    object pmiDelete: TMenuItem
      Action = DeleteAction
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object pmiCopyImage: TMenuItem
      Caption = 'Copy image'
      ShortCut = 16451
      OnClick = pmiCopyImageClick
    end
    object pmiPasteImage: TMenuItem
      Caption = 'Paste image'
      ShortCut = 16470
      OnClick = pmiPasteImageClick
    end
  end
  object ActionList: TActionList
    Left = 480
    Top = 240
    object DeleteAction: TAction
      Caption = 'Delete...'
      ShortCut = 16452
      OnExecute = DeleteActionExecute
      OnUpdate = ActionUpdate
    end
    object RenameAction: TAction
      Caption = 'Rename...'
      ShortCut = 16466
      OnExecute = RenameActionExecute
      OnUpdate = ActionUpdate
    end
    object RefreshAction: TAction
      Caption = 'Refresh'
      ShortCut = 4181
      OnExecute = RefreshActionExecute
    end
    object OpenAction: TAction
      Caption = 'Open'
      ShortCut = 16453
      OnExecute = OpenActionExecute
    end
    object ExportAction: TAction
      Caption = 'Export'
      ShortCut = 16472
      OnExecute = ExportActionExecute
    end
    object ExitAction: TAction
      Caption = 'Exit'
      ShortCut = 16465
      OnExecute = ExitActionExecute
    end
    object OptimizeAction: TAction
      Caption = 'Optimize'
      ShortCut = 16463
      OnExecute = OptimizeActionExecute
    end
  end
  object DirOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoForceFileSystem, fdoPathMustExist]
    Left = 665
    Top = 155
  end
  object pmDirs: TPopupMenu
    Left = 306
    Top = 164
    object itmCreate: TMenuItem
      Caption = 'Create folder'
      OnClick = itmCreateClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object itmUpdate: TMenuItem
      Caption = 'Update tree view'
      OnClick = itmUpdateClick
    end
    object pmiCancel: TMenuItem
      Caption = 'Cancel'
    end
  end
  object FileOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileNameLabel = 'SVG Cleaner program'
    FileTypes = <
      item
        DisplayName = 'exe files'
        FileMask = '*.exe'
      end>
    Options = [fdoPathMustExist, fdoFileMustExist, fdoForceShowHidden]
    Left = 665
    Top = 95
  end
end
