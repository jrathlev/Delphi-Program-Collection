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

// Changes: May 2025, J. Rathlev (kontakt(a)rathlev-home.de)

// Skia support removed, some features added
// Export to PNG function implemented
// Calling of external program SvgCleaner implemented
// ShellTreeView component implemented
// TIconImage in preview replaced by TPaintBox for improved rendering
// German localization added

unit FExplorerSVG;

{$INCLUDE SVGIconImageList.inc}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.ImageList, Vcl.ImgList,
  SVGIconImageList, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  SVGIconImage, Vcl.WinXCtrls, System.Actions, Vcl.ActnList, Vcl.Menus,
  SVGIconImageListBase, Vcl.Shell.ShellCtrls, Vcl.Buttons, SVGInterfaces;

resourcestring
  rsConfDelFile = 'Do you really want to delete %u selected files?';
  rsLoadTime = 'Load %u images in %u ms';
  rsDirErr = 'Error creating directory "%s"!';
  rsOptDir = 'Directory for optimized images';
  rsPngDir = 'Directory for PNG images';
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
  rsConverted = '%u images converted to PNG';
  rsExecErr = 'Exit code %u reported!';
  rsError = 'Error';
  rsOptimized = '%u images optimized!';
  rsNotValid = '"%s" is not a valid SVG image!';
  rsSamePath = 'An image cannot be copied to the same path!';
  rsFileExists = 'The image file "%s" already exists!';
  rsOverwrite = 'Overwrite image';

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
    grpFactory: TRadioGroup;
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
    cbxSelectedDir: TComboBox;
    ShellTreeView: TShellTreeView;
    DirOpenDialog: TFileOpenDialog;
    Label2: TLabel;
    cbxExportDir: TComboBox;
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
    cbxOptimizeDir: TComboBox;
    btnOptimizeDir: TSpeedButton;
    FileOpenDialog: TFileOpenDialog;
    btnOptimize: TButton;
    btnOptProg: TButton;
    edOptions: TLabeledEdit;
    OptimizeAction: TAction;
    N2: TMenuItem;
    pmiCopyImage: TMenuItem;
    pmiPasteImage: TMenuItem;
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
    procedure TrackBarChange(Sender: TObject);
    procedure grpFactoryClick(Sender: TObject);
    procedure RefreshActionExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OpenActionExecute(Sender: TObject);
    procedure rgSizeClick(Sender: TObject);
    procedure ExportActionExecute(Sender: TObject);
    procedure cbxSelectedDirChange(Sender: TObject);
    procedure cbxSelectedDirCloseUp(Sender: TObject);
    procedure ShellTreeViewClick(Sender: TObject);
    procedure cbxExportDirCloseUp(Sender: TObject);
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
    procedure pmiCopyImageClick(Sender: TObject);
    procedure pmiPasteImageClick(Sender: TObject);
  private
    fpaPreviewSize: Integer;
    AppPath,IniName,OptProg : string;
    SelectedIndex,
    ExpWidth,ExpHeight : integer;
    IconSvg : ISVG;
    procedure SetFactory(AFactory: TSVGFactory);
    procedure LoadFilesDir(const APath: string; const AFilter: string = '');
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
  WinApi.ActiveX,
  WinApi.KnownFolders,
  WinApi.ShellApi,
  WinApi.ShlObj,
  Vcl.ClipBrd,
  GnuGetText,
  ListUtils,
  PathUtils,
  StringUtils,
  NumDlg,
  WinShell,
  WinExecute,
  FileUtils,
  SelectDlg,
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

  iniLeft = 'Left';
  iniTop  = 'Top';
  iniWdt  = 'Width';
  iniHgt  = 'Height';
  iniSize = 'Size';
  iniDWdt = 'DirWidth';
  iniPrev = 'PreviewWidth';
  iniLast = 'LastDir';
  iniExp  = 'LastExpDir';
  iniOpt  = 'LastOptDir';
  iniOptPrg = 'OptimizeProg';
  iniOptOpt = 'OptimizeOptions';

  IniExt = '.ini';
  SvgExt = '.svg';
  PngExt = '.png';
  SvgClean = 'svgcleaner-cli.exe';
  DirOpt = 'optimized';

procedure TfmExplorerSVG.FormCreate(Sender: TObject);
var
  LFactory: TSVGFactory;
  IniFile : TMemIniFile;
  LastDir,LastExp,LastOpt : string;
  w,h : integer;
begin
  TranslateComponent(self);
  AppPath:=GetKnownFolder(FOLDERID_RoamingAppData);
  fpaPreviewSize := paPreview.Width;
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
    LastDir:=ReadString(CfgSekt,iniLast,'');
    LastExp:=ReadString(CfgSekt,iniExp,'png');
    ExpWidth:=ReadInteger(ExpSekt,iniWdt,64);
    ExpHeight:=ReadInteger(ExpSekt,iniHgt,64);
    LastOpt:=ReadString(CfgSekt,iniOpt,DirOpt);
    OptProg:=AddPath(ExtractFilePath(Application.ExeName),SvgClean);
    OptProg:=ReadString(CfgSekt,iniOptPrg,OptProg);
    edOptions.Text:=ReadString(CfgSekt,iniOptOpt,'');
    end;
  LoadHistory(IniFile,DirSekt,cbxSelectedDir);
  LoadHistory(IniFile,PngSekt,cbxExportDir);
  LoadHistory(IniFile,OptSekt,cbxOptimizeDir);
  IniFile.Free;
  h:=ClientHeight-gbProperties.Height-pcTools.Height-grpFactory.Height-paTools.Height-MulDiv(btnOpen.Height,15,10);
  if h>w then paPreview.Width:=w
  else paPreview.Width:=h; //ClientHeight-h;
  if ParamCount>0 then LastDir:=ParamStr(1);
  for LFactory := Low(TSVGFactory) to high(TSVGFactory) do
    grpFactory.Items.Add(ASVGFactoryNames[LFactory]);
  SetFactory(Low(TSVGFactory));
  LoadFilesDir('');
  LastDir:=GetExistingParentPath(LastDir,GetKnownFolder(FOLDERID_Documents));
  if not DirectoryExists(LastDir) then LastDir:=GetKnownFolder(FOLDERID_Documents);
  AddToHistory(cbxSelectedDir,LastDir);
  AddToHistory(cbxExportDir,LastExp);
  AddToHistory(cbxOptimizeDir,LastOpt);
  cbAspectRatio.Enabled:=false;
  SelectedIndex:=-1;
  end;

procedure TfmExplorerSVG.FormDestroy(Sender: TObject);
var
  IniFile : TMemIniFile;
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
    WriteString(CfgSekt,iniLast,cbxSelectedDir.Text);
    WriteString(CfgSekt,iniExp,cbxExportDir.Text);
    WriteInteger(ExpSekt,iniWdt,ExpWidth);
    WriteInteger(ExpSekt,iniHgt,ExpHeight);
    WriteString(CfgSekt,iniOpt,cbxOptimizeDir.Text);
    WriteString(CfgSekt,iniOptPrg,OptProg);
    WriteString(CfgSekt,iniOptOpt,edOptions.Text);
    end;
  SaveHistory(IniFile,DirSekt,cbxSelectedDir);
  SaveHistory(IniFile,PngSekt,cbxExportDir);
  SaveHistory(IniFile,OptSekt,cbxOptimizeDir);
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
  SelectDir(cbxSelectedDir.Text);
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
    Path:=GetExistingParentPath(ADir,GetKnownFolder(FOLDERID_Documents));
    if assigned(Selected) then begin
      try Selected.Expand(false); except end;
      Selected.MakeVisible;
      end;
    AddToHistory(cbxSelectedDir,Path);
    end;
  LoadFilesDir(cbxSelectedDir.Text, SearchBox.Text);
  end;

procedure TfmExplorerSVG.ExitActionExecute(Sender: TObject);
begin
  Close;
  end;

procedure TfmExplorerSVG.ActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := ImageView.Selected <> nil;
end;

procedure TfmExplorerSVG.btnOptimizeDirClick(Sender: TObject);
var
  s : string;
begin
  s:=cbxOptimizeDir.Text;
  if not ContainsFullPath(s) then s:=AddPath(cbxSelectedDir.Text,s);
  s:=GetExistingParentPath(s,IncludeTrailingPathDelimiter(cbxSelectedDir.Text)+DirOpt);
  with DirOpenDialog do begin
    Title:=rsOptDir;
    DefaultFolder:=s;
    FileName:=s;
    if Execute then begin
      s:=MakeRelativePath(cbxSelectedDir.Text,Filename);
      AddToHistory(cbxOptimizeDir,s);
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
  s:=cbxExportDir.Text;
  if not ContainsFullPath(s) then s:=AddPath(cbxSelectedDir.Text,s);
  s:=GetExistingParentPath(s,IncludeTrailingPathDelimiter(cbxSelectedDir.Text)+PngExt);
  with DirOpenDialog do begin
    Title:=rsPngDir;
    DefaultFolder:=s;
    FileName:=s;
    if Execute then begin
      s:=MakeRelativePath(cbxSelectedDir.Text,Filename);
      AddToHistory(cbxExportDir,s);
      end;
    end;
  end;

procedure TfmExplorerSVG.btnResetFilterClick(Sender: TObject);
begin
  SearchBox.Text:='';
  LoadFilesDir(cbxSelectedDir.Text, SearchBox.Text);
end;

procedure TfmExplorerSVG.cbxExportDirCloseUp(Sender: TObject);
begin
  UpdateHistory(cbxSelectedDir);
  end;

procedure TfmExplorerSVG.cbxSelectedDirChange(Sender: TObject);
begin
  SelectDir(cbxSelectedDir.Text);
  end;

procedure TfmExplorerSVG.cbxSelectedDirCloseUp(Sender: TObject);
begin
  with cbxSelectedDir do SelectDir(Items[ItemIndex]);
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
          LFileName := IncludeTrailingPathDelimiter(cbxSelectedDir.Text)+
                       SVGIconImageList.SVGIconItems[n].Name+SvgExt;
          DeleteFile(LFileName);
          SVGIconImageList.Delete(n);
          end;
        LoadFilesDir(cbxSelectedDir.Text,SearchBox.Text);
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
  grpFactory.ItemIndex := Ord(AFactory);
  Caption := Application.Title + ' - ' + ASVGFactoryNames[AFactory];
end;

procedure TfmExplorerSVG.grpFactoryClick(Sender: TObject);
begin
  SetFactory(TSVGFactory(grpFactory.ItemIndex));
  if Visible then RefreshActionExecute(Sender);
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
      SVGMemo.Text := CharToCrLf(SVGText,#$0A);
      laImgName.Caption:=LFileName;
      LFileName:=IncludeTrailingPathDelimiter(cbxSelectedDir.Text)+LFileName;
      if FileAge(LFileName,dt) then laDate.Caption:=rsModified+DateTimeToStr(dt)
      else laDate.Caption:='';
      laSize.Caption:=rsSize+IntToDecimal(GetFileSize(LFileName));
      laLayout.Caption:=rsLayout+IntToStr(round(SVG.Width))+'x'+IntToStr(round(SVG.Height));
      s:=SVG.Source;
      end;
    with IconSvg do begin
      Source:=s;
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
  cbxSelectedDir.Text:=ShellTreeView.SelectedFolder.PathName;
  LoadFilesDir(cbxSelectedDir.Text, SearchBox.Text);
  AddToHistory(cbxSelectedDir);
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
  laFoldername.Caption:=cbxSelectedDir.Text;
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
  SVGIconImage.Height := SVGIconImage.width;
end;

procedure TfmExplorerSVG.pmImagesPopup(Sender: TObject);
begin
  with pmiOpen do begin
    Enabled:=ImageView.SelCount=1;
    pmiCopyname.Enabled:=Enabled;
    pmiRename.Enabled:=Enabled;
    end;
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
  se:=cbxExportDir.Text;
  if not ContainsFullPath(se) then se:=AddPath(cbxSelectedDir.Text,se);
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
      SVGExportToPng(w,h,si.SVG,se,si.Name+PngExt,cbAspectRatio.Checked);
      inc(n);
      end;
    if n>1 then MessageDlg(Format(rsConverted,[n]),mtInformation,[mbOk],0,mbNo);
    end
  else MessageDlg(Format(rsDirErr,[se]),mtError,[mbOk],0,mbNo);
  end;

procedure TfmExplorerSVG.OptimizeActionExecute(Sender: TObject);
var
  s,sd : string;
  hr : HResult;
  i,n : integer;
begin
  sd:=cbxOptimizeDir.Text;
  if not ContainsFullPath(sd) then sd:=AddPath(cbxSelectedDir.Text,sd);
  if ForceDirectories(sd) then begin
    try
      Screen.Cursor := crHourGlass; n:=0;
      with ImageView do for i:=0 to Items.Count-1 do if Items[i].Selected then begin
        s:= SVGIconImageList.Names[Items[i].ImageIndex]+SvgExt;
          s:=MakeQuotedStr(OptProg)+Space+edOptions.Text+Space+ MakeQuotedStr(AddPath(cbxSelectedDir.Text,s))
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
    if n>1 then MessageDlg(Format(rsOptimized,[n]),mtInformation,[mbOk],0,mbNo);
    end
  else MessageDlg(Format(rsDirErr,[sd]),mtError,[mbOk],0,mbNo);
  end;

procedure TfmExplorerSVG.OpenActionExecute(Sender: TObject);
begin
  ShellExecute(Handle,'open',pchar(IncludeTrailingPathDelimiter(cbxSelectedDir.Text)+
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

procedure TfmExplorerSVG.ReloadImages (const ImgName : string);
var
  n : integer;
begin
  LoadFilesDir(cbxSelectedDir.Text, SearchBox.Text);
  n:=GetListViewIndex(ImageView,ImgName);
  with ImageView do begin
    if (n<0) and (Items.Count>0) then n:=0;
    ShowSelectedItem(n);
    end;
  end;

procedure TfmExplorerSVG.pmiCopyImageClick(Sender: TObject);
begin
  if ImageView.Selected <> nil then begin
    ClipBoard.AsText:=AddPath(cbxSelectedDir.Text,SVGIconImageList.Names[ImageView.Selected.ImageIndex]+SvgExt);
    end;
  end;

procedure TfmExplorerSVG.pmiPasteImageClick(Sender: TObject);
var
  ss,sd : string;
  ok    : boolean;
  mr    : integer;
begin
  ss:=ClipBoard.AsText;
  if AnsiSameText(ExtractFileExt(ss),SvgExt) and FileExists(ss) then begin
    if SameFileName(ExtractFilePath(ss),IncludeTrailingPathDelimiter(cbxSelectedDir.Text)) then
      MessageDlg(rsSamePath,mtError,[mbOk],0)
    else begin
      sd:=AddPath(cbxSelectedDir.Text,ExtractFileName(ss));
      ok:= not FileExists(sd);
      if not ok then begin
        mr:=SelectOption(Format(rsFileExists,[ExtractFileName(ss)]),mtConfirmation,[fsBold],
          [rsOverwrite,rsRename]);
//        mr:=MessageDlg(Format(rsOverwrite,[ExtractFileName(ss)]),mtConfirmation,[mbYes,mbNo,mbCancel],0);
        if mr=1 then begin // rename
          sd:=ChangeFileExt(ExtractFileName(ss),'');
          ok:=InputQuery(rsRename,rsNewFile,sd);
          if ok then sd:=AddPath(cbxSelectedDir.Text,ChangeFileExt(sd,SvgExt));
          end
        else ok:=mr=0;
        end;
      if ok then begin  // copy file
        CopyFileTS(ss,sd);
        ReloadImages(ChangeFileExt(ExtractFilename(sd),''));
        end;
      end;
    end
  else MessageDlg(Format(rsNotValid,[ss]),mtError,[mbOk],0)
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
      LPath := IncludeTrailingPathDelimiter(cbxSelectedDir.Text);
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
  LoadFilesDir(cbxSelectedDir.Text, SearchBox.Text);
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
end;

procedure TfmExplorerSVG.TrackBarChange(Sender: TObject);
begin
  //Resize all icons into ImageList
//  SVGIconImageList.Size := TrackBar.Position;
//  laIconsSize.Caption:=Format('Icons size: %u',[SVGIconImageList.Size]);
end;

end.
