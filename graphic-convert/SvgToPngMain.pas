(* Convert svg images to transparent png

   © Dr. J. Rathlev, D-24222 Schwentinental

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   J. Rathlev, September 2024
   Vers. 1 - uses inkscape for the conversion
   Vers. 2 (March 2025) - uses the Delphi SVG package by  Ethea
                          https://github.com/EtheaDev/SVGIconImageList
   last modified: March 2025
   *)

unit SvgToPngMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Shell.ShellCtrls,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

const
  Vers = '2.0.0';
  CopRgt = '© 2024-2025 Dr. J. Rathlev, D-24222 Schwentinental';
  EmailAdr = 'kontakt(a)rathlev-home.de';

  MaxSizes = 4;

type
  TMainForm = class(TForm)
    Label1: TLabel;
    btnImgDir: TSpeedButton;
    edtImgDir: TComboBox;
    bbConvert: TBitBtn;
    ShellListView: TShellListView;
    ShellComboBox: TShellComboBox;
    bbInfo: TBitBtn;
    bbExit: TBitBtn;
    StatusBar: TStatusBar;
    btSelectAll: TBitBtn;
    btSelectNone: TBitBtn;
    edtPngDir: TComboBox;
    Label2: TLabel;
    btnPngDir: TSpeedButton;
    paStatus: TPanel;
    paMain: TPanel;
    meStatus: TMemo;
    spStatus: TSplitter;
    OpenDialog: TOpenDialog;
    rgScale: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ShellListViewAddFolder(Sender: TObject; AFolder: TShellFolder;
      var CanAdd: Boolean);
    procedure bbInfoClick(Sender: TObject);
    procedure btnImgDirClick(Sender: TObject);
    procedure btSelectAllClick(Sender: TObject);
    procedure btSelectNoneClick(Sender: TObject);
    procedure bbExitClick(Sender: TObject);
    procedure bbConvertClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtImgDirCloseUp(Sender: TObject);
    procedure btnPngDirClick(Sender: TObject);
    procedure edtPngDirCloseUp(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ShellListViewClick(Sender: TObject);
    procedure rgScaleClick(Sender: TObject);
  private
    { Private-Deklarationen }
    AppPath,IniName,
    LastPath,LastDest,
    DefPath,FileMask : string;
    Scale : integer;
    procedure ShowStatus;
    procedure UpdateDirList;
  public
    { Public-Deklarationen }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses System.Masks, System.IniFiles, SVGInterfaces, SVGIconUtils,
  GnuGetText, InitProg, WinShell, ShellDirDlg, PathUtils, ListUtils, WinUtils,
  MsgDialogs, StringUtils, GraphUtils;

const
  PngExt = 'png';
  PngSubDir = PngExt;
  SvgMask = '*.svg';

  IniExt = 'ini';

  (* INI-Sektionen *)
  CfGSekt = 'Config';
  ImgDirSekt = 'ImageDirs';
  DestSekt   = 'PngDirs';

  iniTop      = 'Top';
  iniLeft     = 'Left';
  iniHeight   = 'Height';
  iniWidth    = 'Width';
  iniStatus   = 'StatusHeight';
  iniLast     = 'LastDir';
  iniDest     = 'LastDest';
  iniSize     = 'Scale';

  ImgScales : array[0..4] of integer = (50,75,100,159,200);

{ ------------------------------------------------------------------- }
procedure TMainForm.FormCreate(Sender: TObject);
var
  IniFile : TMemIniFile;
  i       : integer;
begin
  TranslateComponent(self);
  InitPaths(AppPath,DefPath);
  IniName:=Erweiter(AppPath,PrgName,IniExt);
  IniFile:=TMemIniFile.Create(IniName);
  with IniFile do begin
    Top:=ReadInteger(CfgSekt,iniTop,Top);
    Left:=ReadInteger(CfgSekt,iniLeft,Left);
    ClientHeight:=ReadInteger(CfgSekt,iniHeight,ClientHeight);
    ClientWidth:=ReadInteger(CfgSekt,iniWidth,ClientWidth);
    with paStatus do Height:=ReadInteger(CfgSekt,iniStatus,Height);
    LastPath:=ReadString(CfgSekt,IniLast,DefPath);
    LastDest:=ReadString(CfgSekt,IniDest,'png');
    Scale:=ReadInteger(CfgSekt,iniSize,100);
    end;
  LoadHistory(IniFile,ImgDirSekt,edtImgDir);
  LoadHistory(IniFile,DestSekt,edtPngDir);
  IniFile.Free;
  for i:=0 to High(ImgScales) do if Scale=ImgScales[i] then Break;
  if i>High(ImgScales) then begin
    i:=2; Scale:=100;
    end;
  rgScale.ItemIndex:=i;
  FileMask:=SvgMask;
  end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  IniFile : TMemIniFile;
begin
  IniFile:=TMemIniFile.Create(IniName);
  with IniFile do begin
    WriteInteger(CfgSekt,iniTop,Top);
    WriteInteger(CfgSekt,iniLeft,Left);
    WriteInteger(CfgSekt,iniHeight,ClientHeight);
    WriteInteger(CfgSekt,iniWidth,ClientWidth);
    WriteInteger(CfgSekt,iniStatus,paStatus.Height);
    WriteString(CfgSekt,IniLast,edtImgDir.Text);
    WriteString(CfgSekt,IniDest,edtPngDir.Text);
    WriteInteger(CfgSekt,iniSize,Scale);
    end;
  SaveHistory(IniFile,ImgDirSekt,true,edtImgDir);
  SaveHistory(IniFile,DestSekt,true,edtPngDir);
  with IniFile do begin
    UpdateFile; Free;
    end;
  end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  with ShellListView do SetColWidths([GetWidth-46,12,12,18]);
  end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  AddToHistory(edtImgDir,LastPath);
  AddToHistory(edtPngDir,LastDest);
  UpdateDirList;
  with ShellListView do if Items.Count>0 then Items[0].Selected:=true;
  ShowStatus;
  end;

procedure TMainForm.rgScaleClick(Sender: TObject);
begin
  Scale:=ImgScales[rgScale.ItemIndex];
  end;

procedure TMainForm.ShowStatus;
begin
  with ShellListView do if Items.Count>0 then begin
    if SelCount>0 then Statusbar.SimpleText:=GetPluralString(_('image of'),_('images of'),SelCount)+
      Format(_(' %u selected'),[Items.Count])
    else Statusbar.SimpleText:=GetPluralString(_('matching image'),_('matching images'),Items.Count);
    end
  else Statusbar.SimpleText:='';
  end;

procedure TMainForm.ShellListViewAddFolder(Sender: TObject;
  AFolder: TShellFolder; var CanAdd: Boolean);
begin
  CanAdd:=MatchesMask(AFolder.DisplayName,FileMask);
  end;

procedure TMainForm.ShellListViewClick(Sender: TObject);
begin
  ShowStatus;
  end;

procedure TMainForm.bbExitClick(Sender: TObject);
begin
  Cursor:=crDefault;
  Close;
  end;

procedure TMainForm.bbInfoClick(Sender: TObject);
begin
  InfoDialog(TopLeftPos(bbExit),Caption+' - '+GetVersion(3,Vers)
    +' ('+DateToStr(FileDateToDateTime(FileAge(Application.ExeName)))+')'+sLineBreak
    +CopRgt+sLineBreak+'E-Mail: '+EMailAdr);
  end;

procedure TMainForm.btnImgDirClick(Sender: TObject);
var
  s : string;
begin
  s:=GetExistingParentPath(edtImgDir.Text,DefPath);
  if ShellDirDialog.Execute (_('Directory with SVG images'),true,true,false,'',s) then begin
    AddToHistory(edtImgDir,s);
    UpdateDirList;
    ShowStatus;
    end;
  end;

procedure TMainForm.btnPngDirClick(Sender: TObject);
var
  s : string;
begin
  s:=edtPngDir.Text;
  if not ContainsFullPath(s) then s:=AddPath(edtImgDir.Text,s);
  s:=GetExistingParentPath(s,DefPath);
  if ShellDirDialog.Execute (_('Directory for PNG images'),true,true,false,'',s) then begin
    s:=MakeRelativePath(edtImgDir.Text,s);
    AddToHistory(edtPngDir,s);
    end;
  end;

procedure TMainForm.UpdateDirList;
var
  sp : string;
begin
  with edtImgDir do sp:=Items[ItemIndex];
  ShellComboBox.Path:=GetExistingParentPath(sp,DefPath);
  end;

procedure TMainForm.edtImgDirCloseUp(Sender: TObject);
begin
  UpdateHistory(edtImgDir);
  UpdateDirList;
  ShowStatus;
  end;

procedure TMainForm.edtPngDirCloseUp(Sender: TObject);
begin
  UpdateHistory(edtPngDir);
  end;

procedure TMainForm.btSelectNoneClick(Sender: TObject);
var
  i : integer;
begin
  with ShellListView do for i:=0 to Items.Count-1 do Items[i].Selected:=false;
  ShowStatus;
  end;

procedure TMainForm.btSelectAllClick(Sender: TObject);
var
  i : integer;
begin
  with ShellListView do for i:=0 to Items.Count-1 do Items[i].Selected:=true;
  ShowStatus;
  end;

procedure TMainForm.bbConvertClick(Sender: TObject);
var
  sd,sn,sp,s,se : string;
  i,n,k  : integer;
  LSVG: ISVG;

  function ConvertToPng (Scale : integer; const SvgName,PngName : string) : boolean;
  begin
    Result:=false;
    if FileExists(SvgName) then begin
      try
        LSVG.LoadFromFile(SvgName);
        SVGExportToPng(round(LSVG.Width*Scale/100),round(LSVG.Height*Scale/100),LSVG,PngName);
        Result:=true;
      except
        on E:Exception do se:=E.Message;
        end;
      end;
    end;

begin
  Cursor:=crHourglass;
  LSVG:=GlobalSVGFactory.NewSvg;
  sd:=edtImgDir.Text; sp:=edtPngDir.Text;
  if not ContainsFullPath(sp) then sp:=AddPath(sd,sp);
  ForceDirectories(sp);
  meStatus.Clear;
  n:=0;
  with ShellListView do for i:=0 to Items.Count-1 do if Items[i].Selected then begin
    sn:=Folders[i].DisplayName;
    s:=NewExt(sn,PngExt);
    k:=meStatus.Lines.Add(_('Converting')+ColSpace+sn+' -> '+AddPath(edtPngDir.Text,s));
    s:=AddPath(sp,s); se:='';
    if ConvertToPng(Scale,AddPath(sd,sn),s) then begin
      s:=_('Done'); inc(n);
      end
    else s:='*** '+_('Error')+' ***';
    with meStatus do begin
      Lines[k]:=Lines[k]+' -> '+s;
      if not se.IsEmpty then Lines.Add('  *** '+se);
      end;
    end;
  if n>0 then begin
    meStatus.Lines.Add(' => '+Format(_('%u png images were created'),[n]));
    end
  else meStatus.Lines.Add('  *** '+_('No images selected'));
  meStatus.Lines.Add(' => '+_('Done'));
  Cursor:=crDefault;
  end;

end.
