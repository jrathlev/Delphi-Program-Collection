{******************************************************************************}
{                                                                              }
{       SVG Explorer: Utility to explore SVG Icons on disk                     }
{       to simplify use of Icons (resize, colors and more...)                  }
{                                                                              }
{       Copyright (c) 2019-2024 (Ethea S.r.l.)                                 }
{       Author: Nicola Tambascia                                               }
{       Contributors:                                                          }
{         Carlo Barazzetta                                                     }
{                                                                              }
{       https://github.com/EtheaDev/SVGIconImageList                           }
{                                                                              }
{******************************************************************************}
{                                                                              }
{  Licensed under the Apache License, Version 2.0 (the "License");             }
{  you may not use this file except in compliance with the License.            }
{  You may obtain a copy of the License at                                     }
{                                                                              }
{      http://www.apache.org/licenses/LICENSE-2.0                              }
{                                                                              }
{  Unless required by applicable law or agreed to in writing, software         }
{  distributed under the License is distributed on an "AS IS" BASIS,           }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    }
{  See the License for the specific language governing permissions and         }
{  limitations under the License.                                              }
{                                                                              }
{******************************************************************************}

// Changes: June 2025, J. Rathlev (kontakt(a)rathlev-home.de)

// Skia support removed, some features added
// Export to PNG function implemented
// Calling of external program SvgCleaner implemented
// ShellTreeView component implemented
// TIconImage in preview replaced by TPaintBox for improved rendering
// German localization added
// Optional entry in Windows folder context menu

//  last modified: December 2025

unit FExplorerSVG;

{$INCLUDE SVGIconImageList.inc}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.ImageList, Vcl.ImgList,
  SVGIconImageList, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.ClipBrd,
  SVGIconImage, Vcl.WinXCtrls, System.Actions, Vcl.ActnList, Vcl.Menus,
  SVGIconImageListBase, Vcl.Shell.ShellCtrls, Vcl.Buttons, SVGInterfaces;

const
  ProgName = 'Svg Explorer';
  Version = '2.1.6';
  CopRgt1 = '© 2020-2024 Ethea';
  CopRgt2 = '© 2025-2026 J. Rathlev';
  EmailAdr = 'kontakt(a)rathlev-home.de';

resourcestring
  rsConfDelFile = 'Do you really want to delete %u selected files?';
  rsLoadTime = 'Load %u images in %u ms';
  rsDirErr = 'Error creating directory "%s"!';
  rsOptDir = 'Directory for optimized images';
  rsPngDir = 'Directory for PNG images';
  rsIconDir = 'Directory for icons';
  rsModified = 'Modified: ';
  rsSize = 'Size: ';
  rsLayout = 'Layout: ';
  rsListPreview = 'SVG Image List preview: %u images';
  rsSubDir = 'New subdirectory:';
  rsCreateErr = 'Could not create directory:'+sLineBreak+'%s!';
  rsRename = 'Rename image';
  rsNewFile = 'New filename:';
  rsRenameErr = 'Cannot rename: file "%s" already exists!';
  rsImgSize = 'Image size';
  rsWdtHgt = 'Width/Height';
  rsWidth = 'Width';
  rsHeight = 'Height';
  rsConverted = '%u SVG image(s) converted to PNG';
  rsIconCreated = '%u icon(s) were created from SVG image(s)';
  rsIconError = 'Error creating icon from %s';
  rsExecErr = 'Exit code %u reported!';
  rsError = 'Error';
  rsOptimized = '%u SVG images optimized!';
  rsSvgPaste = '%u SVG image(s) copied!';
  rsNotFound = 'No SVG image in the clipboard!';
  rsSamePath = 'An image cannot be copied to the same path!';
  rsFileExists = 'The image file "%s" already exists!';
  rsOverwrite = 'Overwrite image';
  rsAddCtx = 'Add Svg Explorer to folder context menu';
  rsRemCtx = 'Remove Svg Explorer from folder context menu';
  rsOpenDirWith = 'Open this folder with Svg Explorer';
  rsPrgNote = 'Based on SVG Icon Explorer (%s)';

type
  TSVGFactory = (svgImage32, svgDirect2D);
  //TSVGFactory = (svgImage32, svgSkia);
const
  ASVGFactoryNames: Array[TSVGFactory] of string =
    //('Native Image32', 'Skia4Delphi');
    ('Native Image32', 'Direct2D');

type
  TfmExplorerSVG = class(TForm)
    paDir: TPanel;
    spVertical: TSplitter;
    paList: TPanel;
    SVGIconImageList: TSVGIconImageList;
    paRicerca: TPanel;
    paPreview: TPanel;
    spRight: TSplitter;
    ImageView: TListView;
    DirPanel: TPanel;
    SearchBox: TSearchBox;
    pmImages: TPopupMenu;
    ActionList: TActionList;
    DeleteAction: TAction;
    RenameAction: TAction;
    pmiDelete: TMenuItem;
    pmiRename: TMenuItem;
    paSVGText: TPanel;
    SVGMemo: TMemo;
    spBottom: TSplitter;
    ShowTextCheckBox: TCheckBox;
    PerformanceStatusBar: TStatusBar;
    TrackBarPanel: TPanel;
    btnRefresh: TButton;
    RefreshAction: TAction;
    pmiOpen: TMenuItem;
    OpenAction: TAction;
    paTools: TPanel;
    gbProperties: TGroupBox;
    laImgName: TLabel;
    laDate: TLabel;
    laSize: TLabel;
    laFoldername: TLabel;
    paImageList: TPanel;
    ImageListLabel: TLabel;
    laLayout: TLabel;
    rgSize: TRadioGroup;
    btnOpen: TButton;
    paCenter: TPanel;
    btnExport: TButton;
    ExportAction: TAction;
    cbSelectedDir: TComboBox;
    ShellTreeView: TShellTreeView;
    DirOpenDialog: TFileOpenDialog;
    Label2: TLabel;
    cbPngDir: TComboBox;
    btnPngDir: TSpeedButton;
    btnExit: TButton;
    ExitAction: TAction;
    pmDirs: TPopupMenu;
    itmCreate: TMenuItem;
    N1: TMenuItem;
    itmUpdate: TMenuItem;
    pmiCancel: TMenuItem;
    pmiCopyName: TMenuItem;
    rbOrgSize: TRadioButton;
    rbUserSize: TRadioButton;
    cbAspectRatio: TCheckBox;
    btnResetFilter: TButton;
    SVGIconImage: TPaintBox;
    pcTools: TPageControl;
    tsOptimize: TTabSheet;
    tsExport: TTabSheet;
    Label1: TLabel;
    cbOptimizeDir: TComboBox;
    btnOptimizeDir: TSpeedButton;
    FileOpenDialog: TFileOpenDialog;
    btnOptimize: TButton;
    btnOptProg: TButton;
    edOptions: TLabeledEdit;
    OptimizeAction: TAction;
    N2: TMenuItem;
    pmiCopyImages: TMenuItem;
    pmiPasteImages: TMenuItem;
    bbContext: TBitBtn;
    bbInfo: TBitBtn;
    tsIcon: TTabSheet;
    gbSizes: TGroupBox;
    cb032: TCheckBox;
    cb064: TCheckBox;
    cb128: TCheckBox;
    cb256: TCheckBox;
    cb048: TCheckBox;
    Label3: TLabel;
    cbIconDir: TComboBox;
    btnIconDir: TSpeedButton;
    cb016: TCheckBox;
    btnCreateIcon: TButton;
    grpFactory: TRadioGroup;
    paFactory: TPanel;
    IconAction: TAction;
    procedure ImageViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure paPreviewResize(Sender: TObject);
    procedure ImageViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure SearchBoxInvokeSearch(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SVGIconImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DeleteActionExecute(Sender: TObject);
    procedure RenameActionExecute(Sender: TObject);
    procedure ActionUpdate(Sender: TObject);
    procedure ShowTextCheckBoxClick(Sender: TObject);
    procedure grpFactoryClick(Sender: TObject);
    procedure RefreshActionExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OpenActionExecute(Sender: TObject);
    procedure rgSizeClick(Sender: TObject);
    procedure ExportActionExecute(Sender: TObject);
    procedure cbSelectedDirChange(Sender: TObject);
    procedure cbSelectedDirCloseUp(Sender: TObject);
    procedure ShellTreeViewClick(Sender: TObject);
    procedure cbPngDirCloseUp(Sender: TObject);
    procedure btnPngDirClick(Sender: TObject);
    procedure ExitActionExecute(Sender: TObject);
    procedure itmCreateClick(Sender: TObject);
    procedure itmUpdateClick(Sender: TObject);
    procedure pmiCopyNameClick(Sender: TObject);
    procedure rbUserSizeClick(Sender: TObject);
    procedure btnResetFilterClick(Sender: TObject);
    procedure SVGIconImagePaint(Sender: TObject);
    procedure btnOptimizeDirClick(Sender: TObject);
    procedure btnOptProgClick(Sender: TObject);
    procedure OptimizeActionExecute(Sender: TObject);
    procedure pmImagesPopup(Sender: TObject);
    procedure pmiCopyImagesClick(Sender: TObject);
    procedure pmiPasteImagesClick(Sender: TObject);
    procedure bbContextClick(Sender: TObject);
    procedure bbInfoClick(Sender: TObject);
    procedure btnIconDirClick(Sender: TObject);
    procedure cbIconDirCloseUp(Sender: TObject);
    procedure IconActionExecute(Sender: TObject);
    procedure spRightMoved(Sender: TObject);
    procedure spRightCanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
  private
    fpaPreviewSize: Integer;
    AppPath,IniName,
    CmdImg,OptProg : string;
    SelectedIndex,
    ExpWidth,ExpHeight,
    ToolHeight     : integer;
    OldContext     : boolean;
    IconSvg : ISVG;
    procedure SetFactory(AFactory: TSVGFactory);
    procedure LoadFilesDir(const APath: string; const AFilter: string = '');
    procedure SelectImage (const ImgName : string);
    procedure ReloadImages (const ImgName : string);
    procedure UpdateHeader;
    procedure UpdateView(Index: Integer);
    procedure ShowSelectedItem(Index : integer = -1);
    procedure SelectDir (const ADir : string);
    procedure SelectOptimizer;
  protected
    procedure Loaded; override;
  public
    { Public declarations }
  end;

var
  fmExplorerSVG: TfmExplorerSVG;

implementation

uses
  System.IniFiles,
  System.Types,
  System.StrUtils,
  System.Win.Registry,
  WinApi.ActiveX,
  WinApi.KnownFolders,
  WinApi.ShellApi,
  WinApi.ShlObj,
  Vcl.Imaging.PngImage,
  GnuGetText,
  ListUtils,
  PathUtils,
  StringUtils,
  NumberUtils,
  MsgDialogs,
  NumDlg,
  WinShell,
  WinExecute,
  ClipboardUtils,
  FileUtils,
  SelectDlg,
  GraphUtils,
  Image32SVGFactory,
  D2DSVGFactory,
//  SkiaSVGFactory,
  SVGIconUtils,
  UITypes;

{$R *.dfm}

const
  CfGSekt = 'Config';
  DirSekt = 'Directories';
  ExpSekt = 'Export';
  PngSekt = 'PngDirs';
  OptSekt = 'OptDirs';
  IconSekt = 'IconDirs';

  iniLeft = 'Left';
  iniTop  = 'Top';
  iniWdt  = 'Width';
  iniHgt  = 'Height';
  iniSize = 'Size';
  iniDWdt = 'DirWidth';
  iniPrev = 'PreviewWidth';
  iniSource = 'SourceText';
  iniLast = 'LastDir';
  iniExp  = 'LastExpDir';
  iniOpt  = 'LastOptDir';
  iniIcon = 'LastIconDir';
  iniOptPrg = 'OptimizeProg';
  iniOptOpt = 'OptimizeOptions';
  iniSizes  = 'IconSizes';

  IniExt = '.ini';
  SvgExt = '.svg';
  PngExt = '.png';
  IconExt = '.ico';
  SvgClean = 'svgcleaner-cli.exe';
  DirOpt = 'optimized';


  DirContextKey = 'Software\Classes\Folder\shell\SvgExplorer';

  NumSizes = 6;
  IconSizes : array [0..NumSizes-1] of integer = (16,32,48,64,128,256);
  BitMask : array [0..NumSizes-1] of integer = (1,2,4,8,16,32);

procedure TfmExplorerSVG.FormCreate(Sender: TObject);
var
  LFactory: TSVGFactory;
  IniFile : TMemIniFile;
  LastDir,LastExp,LastOpt,LastIcon : string;
  i,w,h,sz : integer;

  function CheckGlobalContext : boolean;
  begin
    Result:=false;
    with TRegistry.Create(KEY_READ) do begin
      try
        RootKey := HKEY_LOCAL_MACHINE;
        Result:=KeyExists(DirContextKey);
      finally
        Free;
        end;
      end;
    end;

  function CheckUserFolderContext : boolean;
  begin
    Result:=false;
    with TRegistry.Create(KEY_READ) do begin
      try
        Result:=KeyExists(DirContextKey);
      finally
        Free;
        end;
      end;
    end;

begin
  TranslateComponent(self);
  Application.Title:=Progname+' ('+Version+')';
  AppPath:=GetAppDataFolder;
  fpaPreviewSize := paPreview.Width; LastDir:=''; CmdImg:='';
  if ParamCount>0 then for i:=1 to ParamCount do if not IsOption(ParamStr(i)) then begin
    if LastDir.IsEmpty then LastDir:=ExpandFileName(ParamStr(i));
    end;
  if AnsiEndsText(SvgExt,LastDir) then begin
    CmdImg:=ExtractFileName(LastDir); LastDir:=ExtractFilePath(LastDir);
    end;
  IniName:=IncludeTrailingPathDelimiter(AppPath)+ChangeFileExt(ExtractFilename(Application.ExeName),IniExt);
  IniFile:=TMemIniFile.Create(IniName);
  with IniFile do begin
    Left:=ReadInteger(CfgSekt,iniLeft,Left);
    Top:=ReadInteger(CfgSekt,iniTop,Top);
    ClientWidth:=ReadInteger(CfgSekt,iniWdt,ClientWidth);
    ClientHeight:=ReadInteger(CfgSekt,iniHgt,ClientHeight);
    with paDir do Width:=ReadInteger(CfgSekt,iniDWdt,Width);
    w:=ReadInteger(CfgSekt,iniPrev,Width);
    rgSize.ItemIndex:=ReadInteger(CfgSekt,iniSize,3);
    if LastDir.IsEmpty then LastDir:=ReadString(CfgSekt,iniLast,'');
    LastExp:=ReadString(CfgSekt,iniExp,'png');
    ExpWidth:=ReadInteger(ExpSekt,iniWdt,64);
    ExpHeight:=ReadInteger(ExpSekt,iniHgt,64);
    LastOpt:=ReadString(CfgSekt,iniOpt,DirOpt);
    OptProg:=AddPath(ExtractFilePath(Application.ExeName),SvgClean);
    OptProg:=ReadString(CfgSekt,iniOptPrg,OptProg);
    edOptions.Text:=ReadString(CfgSekt,iniOptOpt,'');
    LastIcon:=ReadString(CfgSekt,iniIcon,'icons');
    sz:=ReadInteger(CfgSekt,iniSizes,62);
    ShowTextCheckBox.Checked:=ReadBool(CfgSekt,iniSource,true);
    end;
  LoadHistory(IniFile,DirSekt,cbSelectedDir);
  LoadHistory(IniFile,PngSekt,cbPngDir);
  LoadHistory(IniFile,OptSekt,cbOptimizeDir);
  LoadHistory(IniFile,IconSekt,cbIconDir);
  IniFile.Free;
  with gbSizes do for i:=0 to ControlCount-1  do if Controls[i] is TCheckBox then begin
    with (Controls[i] as TCheckBox) do Checked:=sz and BitMask[Tag] <>0;
    end;
  if w<fpaPreviewSize then w:=fpaPreviewSize;
  paPreview.Width:=w;
  with pcTools do begin
    ToolHeight:=Height;
    with TabRect(0) do if Top>TabRect(1).Top then h:=Height else h:=0;
    Height:=Height+h;
    end;
//  h:=ClientHeight-gbProperties.Height-pcTools.Height-pcTools.Height-paTools.Height-MulDiv(btnOpen.Height,15,10);
//  if h<=w then
//  else paPreview.Width:=h; //ClientHeight-h;
  for LFactory := Low(TSVGFactory) to high(TSVGFactory) do
    grpFactory.Items.Add(ASVGFactoryNames[LFactory]);
  grpFactory.ItemIndex := integer(Low(TSVGFactory));
  SetFactory(Low(TSVGFactory));
  LastDir:=GetExistingParentPath(LastDir,GetPersonalFolder);
  AddToHistory(cbSelectedDir,LastDir);
  AddToHistory(cbPngDir,LastExp);
  AddToHistory(cbOptimizeDir,LastOpt);
  AddToHistory(cbIconDir,LastIcon);
  cbAspectRatio.Enabled:=false;
  SelectedIndex:=-1;
  bbContext.Visible:=not CheckGlobalContext;
  OldContext:=CheckUserFolderContext;
  with bbContext do if OldContext then Hint:=rsRemCtx else Hint:=rsAddCtx;
  end;

procedure TfmExplorerSVG.FormDestroy(Sender: TObject);
var
  IniFile : TMemIniFile;
  i,sz : integer;
begin
  IniFile:=TMemIniFile.Create(IniName);
  with IniFile do begin
    WriteInteger(CfgSekt,iniLeft,Left);
    WriteInteger(CfgSekt,iniTop,Top);
    WriteInteger(CfgSekt,iniWdt,ClientWidth);
    WriteInteger(CfgSekt,iniHgt,ClientHeight);
    WriteInteger(CfgSekt,iniDWdt,paDir.Width);
    WriteInteger(CfgSekt,iniPrev,paPreview.Width);
    WriteInteger(CfgSekt,iniSize,rgSize.ItemIndex);
    WriteString(CfgSekt,iniLast,cbSelectedDir.Text);
    WriteString(CfgSekt,iniExp,cbPngDir.Text);
    WriteInteger(ExpSekt,iniWdt,ExpWidth);
    WriteInteger(ExpSekt,iniHgt,ExpHeight);
    WriteString(CfgSekt,iniOpt,cbOptimizeDir.Text);
    WriteString(CfgSekt,iniOptPrg,OptProg);
    WriteString(CfgSekt,iniOptOpt,edOptions.Text);
    WriteString(CfgSekt,iniIcon,cbIconDir.Text);
    sz:=0;
    with gbSizes do for i:=0 to ControlCount-1  do if Controls[i] is TCheckBox then begin
      with (Controls[i] as TCheckBox) do if Checked then sz:=sz or BitMask[Tag];
      end;
    WriteInteger(CfgSekt,iniSizes,sz);
    WriteBool(CfgSekt,iniSource,ShowTextCheckBox.Checked);
    end;
  SaveHistory(IniFile,DirSekt,cbSelectedDir);
  SaveHistory(IniFile,PngSekt,cbPngDir);
  SaveHistory(IniFile,OptSekt,cbOptimizeDir);
  SaveHistory(IniFile,IconSekt,cbIconDir);
  with IniFile do begin
    UpdateFile;
    Free;
    end;
  end;

procedure TfmExplorerSVG.FormShow(Sender: TObject);
begin
  if not FileExists(OptProg) then SelectOptimizer;
  btnOptimize.Enabled:=FileExists(OptProg);
  pcTools.ActivePageIndex:=0;
  rgSizeClick(Sender);
  SelectDir(cbSelectedDir.Text);
  if length(CmdImg)>0 then SelectImage(ChangeFileExt(CmdImg,''));
  SVGIconImage.Height := SVGIconImage.Width;
  end;

procedure TfmExplorerSVG.spRightCanResize(Sender: TObject; var NewSize: Integer;
  var Accept: Boolean);
begin
  Accept:=NewSize>=fpaPreviewSize;
  end;

procedure TfmExplorerSVG.spRightMoved(Sender: TObject);
var
  h : integer;
begin
  with pcTools do begin
    with TabRect(0) do if Top>TabRect(PageCount-1).Top then h:=Height else h:=0;
    Height:=ToolHeight+h;
    end;
  end;

procedure TfmExplorerSVG.bbInfoClick(Sender: TObject);
begin
  InfoDialog(ProgName+' '+Version+' - '
    +' ('+DateToStr(FileDateToDateTime(FileAge(Application.ExeName)))+')'+sLineBreak
    +Format(rsPrgNote,[CopRgt1])+sLineBreak
    +CopRgt2+' ('+EMailAdr+')');
  end;

procedure TfmExplorerSVG.SelectOptimizer;
begin
  with FileOpenDialog do begin
    if ExtractFileDir(OptProg).IsEmpty then DefaultFolder:=GetProgramFolder(pfProgramFiles64);
    Filename:=SvgClean;
    if Execute then OptProg:=Filename;
    end;
  end;

procedure TfmExplorerSVG.SelectDir (const ADir : string);
begin
  with ShellTreeView do begin
    Path:=GetExistingParentPath(ADir,GetPersonalFolder);
    if assigned(Selected) then begin
      try Selected.Expand(false); except end;
      Selected.MakeVisible;
      end;
    AddToHistory(cbSelectedDir,Path);
    end;
  LoadFilesDir(cbSelectedDir.Text,SearchBox.Text);
  end;

procedure TfmExplorerSVG.ExitActionExecute(Sender: TObject);
begin
  Close;
  end;

procedure TfmExplorerSVG.ActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := ImageView.Selected <> nil;
end;

procedure TfmExplorerSVG.bbContextClick(Sender: TObject);
var
  s : string;
begin
  if OldContext then s:=rsRemCtx else s:=rsAddCtx;
  if MessageDlg(s,mtConfirmation,mbYesNo,0,mbYes)=mrYes then
      with TRegistry.Create do begin  // HKEY_CURRENT_USER = default
    try
      if OldContext then begin  // remove key
        DeleteKey(DirContextKey+'\command');
        DeleteKey(DirContextKey);
        bbContext.Hint:=rsAddCtx;
        OldContext:=false;
        end
      else begin   // create new key
        if OpenKey(DirContextKey,true) then begin    // directory
          WriteString('',rsOpenDirWith);
          WriteString('Icon',AnsiQuotedStr(Application.ExeName,Quote)+',0');
          CloseKey;
          if OpenKey(DirContextKey+'\command',true) then begin
            WriteString('',AnsiQuotedStr(Application.ExeName,Quote)+'"%1"');
            CloseKey;
            bbContext.Hint:=rsRemCtx;
            OldContext:=true;
            end;
          end;
        end;
    finally
      Free;
      end;
    end;
  end;

procedure TfmExplorerSVG.btnOptimizeDirClick(Sender: TObject);
var
  s : string;
begin
  s:=cbOptimizeDir.Text;
  if not ContainsFullPath(s) then s:=AddPath(cbSelectedDir.Text,s);
  s:=GetExistingParentPath(s,IncludeTrailingPathDelimiter(cbSelectedDir.Text)+DirOpt);
  with DirOpenDialog do begin
    Title:=rsOptDir;
    DefaultFolder:=s;
    FileName:=s;
    if Execute then begin
      s:=MakeRelativePath(cbSelectedDir.Text,Filename);
      AddToHistory(cbOptimizeDir,s);
      end;
    end;
  end;

procedure TfmExplorerSVG.btnOptProgClick(Sender: TObject);
begin
  SelectOptimizer;
  btnOptimize.Enabled:=FileExists(OptProg);
  end;

procedure TfmExplorerSVG.btnPngDirClick(Sender: TObject);
var
  s : string;
begin
  s:=cbPngDir.Text;
  if not ContainsFullPath(s) then s:=AddPath(cbSelectedDir.Text,s);
  s:=GetExistingParentPath(s,IncludeTrailingPathDelimiter(cbSelectedDir.Text)+PngExt);
  with DirOpenDialog do begin
    Title:=rsPngDir;
    DefaultFolder:=s;
    FileName:=s;
    if Execute then begin
      s:=MakeRelativePath(cbSelectedDir.Text,Filename);
      AddToHistory(cbPngDir,s);
      end;
    end;
  end;

procedure TfmExplorerSVG.btnIconDirClick(Sender: TObject);
var
  s : string;
begin
  s:=cbIconDir.Text;
  if not ContainsFullPath(s) then s:=AddPath(cbSelectedDir.Text,s);
  s:=GetExistingParentPath(s,IncludeTrailingPathDelimiter(cbSelectedDir.Text)+IconExt);
  with DirOpenDialog do begin
    Title:=rsIconDir;
    DefaultFolder:=s;
    FileName:=s;
    if Execute then begin
      s:=MakeRelativePath(cbSelectedDir.Text,Filename);
      AddToHistory(cbIconDir,s);
      end;
    end;
  end;

procedure TfmExplorerSVG.btnResetFilterClick(Sender: TObject);
begin
  SearchBox.Text:='';
  LoadFilesDir(cbSelectedDir.Text, SearchBox.Text);
end;

procedure TfmExplorerSVG.cbIconDirCloseUp(Sender: TObject);
begin
  UpdateHistory(cbIconDir);
  end;

procedure TfmExplorerSVG.cbPngDirCloseUp(Sender: TObject);
begin
  UpdateHistory(cbPngDir);
  end;

procedure TfmExplorerSVG.cbSelectedDirChange(Sender: TObject);
begin
  SelectDir(cbSelectedDir.Text);
  end;

procedure TfmExplorerSVG.cbSelectedDirCloseUp(Sender: TObject);
begin
  with cbSelectedDir do SelectDir(Items[ItemIndex]);
  end;

procedure TfmExplorerSVG.DeleteActionExecute(Sender: TObject);
var
  LFileName: string;
  i,n,
  LOldImageIndex: Integer;
begin
  if MessageDlg(Format(rsConfDelFile,[ImageView.SelCount]),mtWarning,[mbNo, mbYes],0,mbNo)=mrYes then begin
    try
      Screen.Cursor := crHourGlass; LOldImageIndex:=-1;
      with ImageView do begin
        for i:=0 to Items.Count-1 do if Items[i].Selected then begin
          n:=Items[i].ImageIndex;
          if LOldImageIndex<0 then LOldImageIndex:=n;
          LFileName := IncludeTrailingPathDelimiter(cbSelectedDir.Text)+
                       SVGIconImageList.SVGIconItems[n].Name+SvgExt;
          DeleteFile(LFileName);
          SVGIconImageList.Delete(n);
          end;
        LoadFilesDir(cbSelectedDir.Text,SearchBox.Text);
        ShowSelectedItem(LOldImageIndex);
        SelectedIndex:=ItemIndex;
        end;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TfmExplorerSVG.SetFactory(AFactory: TSVGFactory);
begin
  case AFactory of
    svgDirect2D:
      SetGlobalSvgFactory(GetD2DSVGFactory);
    svgImage32:
      SetGlobalSvgFactory(GetImage32SVGFactory);
//    svgSkia:
//      SetGlobalSvgFactory(GetSkiaSVGFactory);
  end;
  IconSvg:=GlobalSvgFactory.NewSvg;
  Caption := Application.Title+' - '+ASVGFactoryNames[AFactory];
end;

procedure TfmExplorerSVG.grpFactoryClick(Sender: TObject);
begin
  if Visible then begin
    SetFactory(TSVGFactory(grpFactory.ItemIndex));
    RefreshActionExecute(Sender);
    end;
end;

procedure TfmExplorerSVG.ImageViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) then DeleteActionExecute(Sender);
end;

procedure TfmExplorerSVG.SVGIconImagePaint(Sender: TObject);
var
  LFileName,s: string;
  dt : TDateTime;

  function GetFileSize (const FileName : string) : int64;
  var
    FileData : TWin32FileAttributeData;
  begin
    FillChar(FileData,SizeOf(FileData),0);
    if GetFileAttributesEx(PChar(FileName),GetFileExInfoStandard,@FileData) then begin
      Int64Rec(Result).Lo:=FileData.nFileSizeLow;
      Int64Rec(Result).Hi:=FileData.nFileSizeHigh;
      end
    else Result:=0;
    end;

  function IntToDecimal(Value : int64) : string;
  var
    i : integer;
  begin
    Result:=IntToStr(Value);
    i:=length(Result);
    while (i>3) do begin
      dec(i,3); Insert(FormatSettings.ThousandSeparator,Result,i+1);
      end;
    end;

begin
  if SelectedIndex>= 0 then begin
    with SVGIconImageList.SVGIconItems[SelectedIndex] do begin
      LFileName:=IconName+SvgExt;
      SVGMemo.Text := AdjustLineBreaks(SVGText,tlbsCRLF);
      laImgName.Caption:=LFileName;
      LFileName:=IncludeTrailingPathDelimiter(cbSelectedDir.Text)+LFileName;
      if FileAge(LFileName,dt) then laDate.Caption:=rsModified+DateTimeToStr(dt)
      else laDate.Caption:='';
      laSize.Caption:=rsSize+SizeToStr(GetFileSize(LFileName),true);
      laLayout.Caption:=rsLayout+IntToStr(round(SVG.Width))+'x'+IntToStr(round(SVG.Height));
      s:=SVG.Source;
      end;
    with IconSvg do begin
      Source:=s;
//      Width:=SVGIconImage.Width; Height:=SVGIconImage.Height;
//      Invert:=true;
      PaintTo(SVGIconImage.Canvas.Handle,
        TRectF.Create(0, 0, SVGIconImage.Width, SVGIconImage.Height), true);
      end;
    end
  else begin
    SVGMemo.Text := '';
    laImgName.Caption:='';
    laDate.Caption:='';
    laSize.Caption:='';
  end;
end;

procedure TfmExplorerSVG.ShellTreeViewClick(Sender: TObject);
begin
  cbSelectedDir.Text:=ShellTreeView.SelectedFolder.PathName;
  LoadFilesDir(cbSelectedDir.Text, SearchBox.Text);
  AddToHistory(cbSelectedDir);
  end;

procedure TfmExplorerSVG.ShowTextCheckBoxClick(Sender: TObject);
begin
  paSVGText.Visible := ShowTextCheckBox.Checked;
  spBottom.Visible := paSVGText.Visible;
  spBottom.Top := paSVGText.Top -1;
end;

procedure TfmExplorerSVG.UpdateHeader;
var
  LItemsCount: Integer;
begin
  LItemsCount := UpdateSVGIconListView(ImageView, '', False);
  ImageListLabel.Caption := Format(rsListPreview,[LItemsCount]);
  laFoldername.Caption:=cbSelectedDir.Text;
end;

procedure TfmExplorerSVG.UpdateView(Index: Integer);
begin
  SelectedIndex:=Index;
  SVGIconImage.Invalidate;
end;

procedure TfmExplorerSVG.ImageViewSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  UpdateView(Item.Index);
end;

procedure TfmExplorerSVG.ShowSelectedItem(Index : integer);
var
  r  : TRect;
begin
  with ImageView do begin
    ClearSelection;
    if Index<0 then Index:=ItemIndex;
    if Index<0 then Exit;
    if Index<Items.Count then Items[Index].Selected:=true
    else Items[Items.Count-1].Selected:=true;
    if assigned(Selected) then begin
      R:=Selected.DisplayRect(drBounds);
      Scroll(0,R.Top-ClientHeight div 2);
      ItemFocused:=Selected;
      end;
    end;
  end;

procedure TfmExplorerSVG.itmCreateClick(Sender: TObject);
var
  s : string;
begin
  s:='';
  if InputQuery (ShellTreeView.Path,rsSubDir,s) then begin
    s:=IncludeTrailingPathDelimiter(ShellTreeView.Path)+s;
    if not ForceDirectories(s) then
      MessageDlg(Format(rsCreateErr,[s]),mtError,[mbOk],0)
    else with ShellTreeView do begin
      Root:='rfDesktop';
      try Path:=s; except end;
      Selected.MakeVisible;
      end;
    end;
  ShellTreeView.SetFocus;
  end;

procedure TfmExplorerSVG.itmUpdateClick(Sender: TObject);
begin
  with ShellTreeView do Refresh(Selected);
  end;

procedure TfmExplorerSVG.Loaded;
begin
  inherited;
  Font.Assign(Screen.IconFont);
end;

procedure TfmExplorerSVG.LoadFilesDir(const APath, AFilter: string);
var
  SR: TSearchRec;
  LFiles: TStringList;
  LFilter, LTime: string;
  LStart, LStop: cardinal;
  LErrors: string;
begin
  if not DirectoryExists(APath) then Exit;
  LFiles := TStringList.Create;
  Screen.Cursor := crHourGlass;
  Try
    LErrors := '';
    LFilter:=AFilter;
    if length(LFilter)=0 then LFilter:='*';
    LFilter:=IncludeTrailingPathDelimiter(APath)+ChangeFileExt(LFilter,SvgExt);
//    LFilter := Format('%s%s.svg', [IncludeTrailingPathDelimiter(APath), AFilter]);
    {$WARN SYMBOL_PLATFORM OFF}
    if FindFirst(LFilter, faArchive, SR) = 0 then
    begin
      repeat
        LFiles.Add(IncludeTrailingPathDelimiter(APath)+SR.Name); //Fill the list
      until FindNext(SR) <> 0;
      FindClose(SR);
    end;
    LStart := GetTickCount;
    try
      SVGIconImageList.LoadFromFiles(LFiles, False);
    except
      on E:Exception do MessageDlg(E.Message,mtError,[mbOk],0)
      end;
    UpdateHeader;
    LStop := GetTickCount;
    LTime := Format(rsLoadTime, [LFiles.Count, LStop - LStart]);
    PerformanceStatusBar.SimpleText := LTime;
    if LFiles.Count > 0 then
    begin
      ImageView.ItemIndex := 0;
      UpdateView(0);
    end
    else
      UpdateView(-1);
  Finally
    LFiles.Free;
    Screen.Cursor := crDefault;
  End;
end;

procedure TfmExplorerSVG.paPreviewResize(Sender: TObject);
begin
  SVGIconImage.Height := SVGIconImage.Width;
end;

procedure TfmExplorerSVG.pmImagesPopup(Sender: TObject);
begin
  with pmiOpen do begin
    Enabled:=ImageView.SelCount=1;
    pmiCopyname.Enabled:=Enabled;
    pmiRename.Enabled:=Enabled;
    end;
  pmiCopyImages.Enabled:=ImageView.SelCount>0;
  pmiPasteImages.Enabled:=Clipboard.HasFormat(CF_HDROP);
  end;

procedure TfmExplorerSVG.rbUserSizeClick(Sender: TObject);
begin
  cbAspectRatio.Enabled:=rbUserSize.Checked;
  if rbUserSize.Checked then cbAspectRatio.Checked:=false;
  end;

procedure TfmExplorerSVG.ExportActionExecute(Sender: TObject);
var
  si : TSVGIconItem;
  se : string;
  i,w,h,n : integer;

const
  MinSize = 16;
  MaxSize = 1024;

  function TopLeftPos (AControl : TControl) : TPoint;
  begin
    with AControl do if assigned(Parent) then Result:=Parent.ClientToScreen(Point(Left,Top))
    else Result:=Point(Left,Top);
    end;

begin
  se:=cbPngDir.Text;
  if not ContainsFullPath(se) then se:=AddPath(cbSelectedDir.Text,se);
  if rbUserSize.Checked then begin
    if cbAspectRatio.Checked then begin
      if not NumDialog(TopLeftPos(rbOrgSize),rsImgSize,rsWdtHgt,MinSize,MaxSize,8,imBinAuto,ExpWidth) then Exit;
      ExpHeight:=ExpWidth;
      end
    else begin
      if not DNumDialog(TopLeftPos(rbOrgSize),rsImgSize,rsWidth,rsHeight,MinSize,MaxSize,8,imBinAuto,
        MinSize,MaxSize,8,imBinAuto,ExpWidth,ExpHeight) then Exit;
      end;
    end;
  if ForceDirectories(se) then begin
    n:=0;
    with ImageView do for i:=0 to Items.Count-1 do if Items[i].Selected then begin
      si:=SVGIconImageList.SVGIconItems[Items[i].ImageIndex];
      if rbUserSize.Checked then begin
        w:=ExpWidth; h:=ExpHeight;
        end
      else begin
        w:=round(si.SVG.Width); h:=round(si.SVG.Height);
        end;
//      IconSvg.Source:=si.SVG.Source;
      SVGExportToPng(w,h,IconSvg,se,si.Name+PngExt,cbAspectRatio.Checked);
      inc(n);
      end;
    if n>0 then MessageDlg(Format(rsConverted,[n]),mtInformation,[mbOk],0,mbNo);
    end
  else MessageDlg(Format(rsDirErr,[se]),mtError,[mbOk],0,mbNo);
  end;

procedure TfmExplorerSVG.IconActionExecute(Sender: TObject);
var
  si : TSVGIconItem;
  se,s : string;
  i,n,k : integer;
  SizeList   : array of integer;
  PngList    : TList;
  sPng       : TMemoryStream;
  ok         : boolean;

  procedure FreeList (AList : TList);
  var
    i : integer;
  begin
    with AList do begin
      for i:=0 to Count-1 do if assigned(Items[i]) then begin
        try TObject(Items[i]).Free; except end;
        Items[i]:=nil;
        end;
      Clear;
      end;
    end;

  function ExportToPng (ASize : Integer; FSVG: ISVG; sPng : TMemoryStream) : boolean;
  var
    LImagePng: TPngImage;
    LBitmap: TBitmap;
  begin
    Result:=false;
    LBitmap := nil;
    LImagePng := nil;
    try
      LBitmap := TBitmap.Create;
      LBitmap.PixelFormat := TPixelFormat.pf32bit;   // 32bit bitmap
      LBitmap.AlphaFormat := TAlphaFormat.afDefined; // Enable alpha channel

      LBitmap.SetSize(ASize, ASize);

      // Fill background with transparent
      LBitmap.Canvas.Brush.Color := clNone;
      LBitmap.Canvas.FillRect(Rect(0, 0, ASize, ASize));

      FSVG.PaintTo(LBitmap.Canvas.Handle, TRectF.Create(0, 0, ASize, ASize));

      LImagePng := PNG4TransparentBitMap(LBitmap);
      LImagePng.SaveToStream(sPng);
      sPng.Position:=0;
      Result:=true;
    finally
      LBitmap.Free;
      LImagePng.Free;
      end;
    end;

begin
  se:=cbIconDir.Text;
  if not ContainsFullPath(se) then se:=AddPath(cbSelectedDir.Text,se);
  if ForceDirectories(se) then begin
    PngList:=TList.Create;
    n:=0;
    with ImageView do if SelCount>0 then begin
      SetLength(SizeList,NumSizes); k:=0;
      with gbSizes do for i:=0 to ControlCount-1  do if Controls[i] is TCheckBox then begin
        with (Controls[i] as TCheckBox) do if Checked then begin
          SizeList[k]:=IconSizes[Tag];
          inc(k);
          end
        end;
      if k>0 then begin
        SetLength(SizeList,k);
        for i:=0 to Items.Count-1 do if Items[i].Selected then begin
          si:=SVGIconImageList.SVGIconItems[Items[i].ImageIndex];
          for k:=0 to High(SizeList) do begin
            sPng:=TMemoryStream.Create;
            ok:=ExportToPng(SizeList[k],si.SVG,sPng);
            if ok then PngList.Add(sPng) else Break;
            end;
          if ok then begin
            CreateIconFromPngStreamList(AddPath(se,NewExt(si.Name,IconExt)),PngList);
            inc(n);
            end
          else  MessageDlg(Format(rsIconError,[si.Name]),mtError,[mbOk],0,mbNo);
          FreeList(PngList);
          end
        end;
      SizeList:=nil;
      end;
    if n>0 then MessageDlg(Format(rsIconCreated,[n]),mtInformation,[mbOk],0,mbNo);
    end
  else MessageDlg(Format(rsDirErr,[se]),mtError,[mbOk],0,mbNo);
  PngList.Free;
  end;

procedure TfmExplorerSVG.OptimizeActionExecute(Sender: TObject);
var
  s,sd : string;
  hr : HResult;
  i,n : integer;
begin
  sd:=cbOptimizeDir.Text;
  if not ContainsFullPath(sd) then sd:=AddPath(cbSelectedDir.Text,sd);
  if ForceDirectories(sd) then begin
    try
      Screen.Cursor := crHourGlass; n:=0;
      with ImageView do for i:=0 to Items.Count-1 do if Items[i].Selected then begin
        s:= SVGIconImageList.Names[Items[i].ImageIndex]+SvgExt;
        s:=MakeQuotedStr(OptProg)+Space+edOptions.Text+Space+ MakeQuotedStr(AddPath(cbSelectedDir.Text,s))
          +Space+MakeQuotedStr(AddPath(sd,s));
        hr:=ExecuteConsoleProcess(s,'',nil);
        if(hr=0) or ((hr and UserError)<>0) then begin
          if (hr and UserError)<>0 then begin
            MessageDlg(Format(rsExecErr,[hr and $FFFF]),mtError,[mbOk],0,mbNo);
            Break;
            end
          else inc(n);
          end
         else begin
           MessageDlg(rsError+ColSpace+SysErrorMessage(hr),mtError,[mbOk],0,mbNo);
           Break;
           end;
         end;
    finally
      Screen.Cursor := crDefault;
      end;
    if n>0 then MessageDlg(Format(rsOptimized,[n]),mtInformation,[mbOk],0,mbNo);
    end
  else MessageDlg(Format(rsDirErr,[sd]),mtError,[mbOk],0,mbNo);
  end;

procedure TfmExplorerSVG.OpenActionExecute(Sender: TObject);
begin
  ShellExecute(Handle,'open',pchar(IncludeTrailingPathDelimiter(cbSelectedDir.Text)+
    SVGIconImageList.Names[ImageView.Selected.ImageIndex]+SvgExt),nil,nil,SW_SHOW);
  end;

procedure TfmExplorerSVG.RefreshActionExecute(Sender: TObject);
var
  sn : string;

  // Listview-Index from Caption
  function GetListViewIndex (lv : TListView; const ACaption : string): integer;
  begin
    with lv.Items do for Result:=0 to Count-1 do
      if AnsiSameText(Item[Result].Caption,ACaption) then Exit;
    Result:=-1;
    end;

begin
  with ImageView do begin
    if assigned(Selected) then sn:=ImageView.Selected.Caption
    else sn:='';
    end;
  ReloadImages(sn);
  end;

procedure TfmExplorerSVG.SelectImage (const ImgName : string);
var
  n : integer;
begin
  n:=GetListViewIndex(ImageView,ImgName);
  with ImageView do begin
    if (n<0) and (Items.Count>0) then n:=0;
    ShowSelectedItem(n);
    end;
  end;

procedure TfmExplorerSVG.ReloadImages (const ImgName : string);
begin
  LoadFilesDir(cbSelectedDir.Text, SearchBox.Text);
  SelectImage(ImgName);
  end;

procedure TfmExplorerSVG.pmiCopyImagesClick(Sender: TObject);
var
  sl   : TStringList;
  i    : integer;
begin
  sl:=TStringList.Create;
  with ImageView do for i:=0 to Items.Count-1 do if Items[i].Selected then begin
    sl.Add(AddPath(cbSelectedDir.Text,SVGIconImageList.Names[Items[i].ImageIndex]+SvgExt));
    end;
  WriteFileListToClipboard(sl);
  sl.Free;
  end;

procedure TfmExplorerSVG.pmiPasteImagesClick(Sender: TObject);
var
  ss,sd  : string;
  ok     : boolean;
  mr,i,n : integer;
  sl     : TStringList;
begin
  sl:=TStringList.Create;
  ReadFileListFromClipboard(sl);
  n:=0;
  if sl.Count>0 then for i:=0 to sl.Count-1 do begin
    ss:=sl[i];
    if AnsiSameText(ExtractFileExt(ss),SvgExt) and FileExists(ss) then begin
      if SameFileName(ExtractFilePath(ss),IncludeTrailingPathDelimiter(cbSelectedDir.Text)) then
        MessageDlg(rsSamePath,mtError,[mbOk],0)
      else begin
        sd:=AddPath(cbSelectedDir.Text,ExtractFileName(ss));
        ok:= not FileExists(sd);
        if not ok then begin
          mr:=SelectOption(Format(rsFileExists,[ExtractFileName(ss)]),mtConfirmation,[fsBold],
            [rsOverwrite,rsRename]);
  //        mr:=MessageDlg(Format(rsOverwrite,[ExtractFileName(ss)]),mtConfirmation,[mbYes,mbNo,mbCancel],0);
          if mr=1 then begin // rename
            sd:=ChangeFileExt(ExtractFileName(ss),'');
            ok:=InputQuery(rsRename,rsNewFile,sd);
            if ok then sd:=AddPath(cbSelectedDir.Text,ChangeFileExt(sd,SvgExt));
            end
          else ok:=mr=0;
          end;
        if ok then begin  // copy file
          CopyFileTS(ss,sd);
          inc(n);
          end;
        end;
      end;
    end;
  if n>0 then begin
    ReloadImages(ChangeFileExt(ExtractFilename(sd),''));
    MessageDlg(Format(rsSvgPaste,[n]),mtInformation,[mbOk],0)
    end
  else MessageDlg(rsNotFound,mtError,[mbOk],0);
  sl.Free;
  end;

procedure TfmExplorerSVG.pmiCopyNameClick(Sender: TObject);
begin
  if ImageView.Selected <> nil then begin
    ClipBoard.AsText:=SVGIconImageList.Names[ImageView.Selected.ImageIndex];
    end;
  end;

procedure TfmExplorerSVG.RenameActionExecute(Sender: TObject);
var
  LIndex: Integer;
  LFileName, LPath, LNewFileName: string;
begin
  if ImageView.Selected <> nil then
  begin
    LIndex := ImageView.Selected.ImageIndex;
    LFileName := SVGIconImageList.Names[LIndex];
    LNewFileName := InputBox(rsRename,rsNewFile, LFileName);
    if (LNewFileName <> '') and (LNewFileName <> LFileName) then
    begin
      LPath := IncludeTrailingPathDelimiter(cbSelectedDir.Text);
      if FileExists(LPath+LNewFileName+SvgExt) then
        raise Exception.CreateFmt(rsRenameErr,[LPath+LNewFileName+SvgExt])
      else
        RenameFile(LPath+LFileName+SvgExt, LPath+LNewFileName+SvgExt);
      SVGIconImageList.Names[LIndex] := LNewFileName;
      UpdateHeader;
      UpdateView(LIndex);
    end;
  end;
end;

procedure TfmExplorerSVG.rgSizeClick(Sender: TObject);
const
  IconSizes : array [0..5] of integer = (16,20,24,32,48,64);
  var
    n : integer;
begin
  n:=ImageView.ItemIndex;
  SVGIconImageList.Size:=IconSizes[rgSize.ItemIndex];
  ShowSelectedItem(n);
end;

procedure TfmExplorerSVG.SearchBoxInvokeSearch(Sender: TObject);
begin
  LoadFilesDir(cbSelectedDir.Text, SearchBox.Text);
end;

procedure TfmExplorerSVG.SVGIconImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (paPreview.Width < MulDiv(paList.Width,15,10)) then
    paPreview.Width := MulDiv(paPreview.Width,15,10)
  else if (Button = mbRight) then begin
    if (paPreview.Width > MulDiv(fpaPreviewSize,15,10)) then
      paPreview.Width := MulDiv(paPreview.Width,100,150)
    else paPreview.Width := fpaPreviewSize;
    end;
  spRightMoved(Sender);
  end;

end.
