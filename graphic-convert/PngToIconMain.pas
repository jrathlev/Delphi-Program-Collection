(* Create icon from png images

   © Dr. J. Rathlev, D-24222 Schwentinental

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   J. Rathlev, September 2024
   last modified: September 2024
   *)

unit PngToIconMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Shell.ShellCtrls,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ExtDlgs;

const
  Vers = '1.0.0';
  CopRgt = '© 2024-2025 Dr. J. Rathlev, D-24222 Schwentinental';
  EmailAdr = 'kontakt(a)rathlev-home.de';

type
  TMainForm = class(TForm)
    Label1: TLabel;
    btnImgDir: TSpeedButton;
    cbImgDir: TComboBox;
    bbConvert: TBitBtn;
    ShellListView: TShellListView;
    ShellComboBox: TShellComboBox;
    bbInfo: TBitBtn;
    bbExit: TBitBtn;
    StatusBar: TStatusBar;
    cbDestDir: TComboBox;
    btnDestDir: TSpeedButton;
    gbDest: TGroupBox;
    rbSourceDir: TRadioButton;
    rbOtherDir: TRadioButton;
    sdIcon: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ShellListViewAddFolder(Sender: TObject; AFolder: TShellFolder;
      var CanAdd: Boolean);
    procedure bbInfoClick(Sender: TObject);
    procedure btnImgDirClick(Sender: TObject);
    procedure bbExitClick(Sender: TObject);
    procedure bbConvertClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbImgDirCloseUp(Sender: TObject);
    procedure btnDestDirClick(Sender: TObject);
    procedure cbDestDirCloseUp(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ShellListViewClick(Sender: TObject);
    procedure rbSourceDirClick(Sender: TObject);
    procedure rbOtherDirClick(Sender: TObject);
  private
    { Private-Deklarationen }
    AppPath,IniName,
    LastPath,
    DefPath,FileMask : string;
    procedure ShowStatus;
    procedure UpdateDirList;
  public
    { Public-Deklarationen }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses System.Masks, System.IniFiles, GnuGetText, InitProg, GraphUtils, ListUtils,
  ShellDirDlg, PathUtils, WinUtils, MsgDialogs, StringUtils;

const
  PngMask = '*.png';

  IniExt = 'ini';

  (* INI-Sektionen *)
  CfGSekt = 'Config';
  ImgDirSekt = 'ImageDirs';
  DestSekt   = 'Destination';

  iniLast     = 'LastDir';
  iniTop      = 'Top';
  iniLeft     = 'Left';
  iniSrc      = 'Src';
  iniDest     = 'Dest';

{ ------------------------------------------------------------------- }
procedure TMainForm.FormCreate(Sender: TObject);
var
  IniFile : TMemIniFile;
begin
  TranslateComponent(self);
  InitPaths(AppPath,DefPath);
  IniName:=Erweiter(AppPath,PrgName,IniExt);
  IniFile:=TMemIniFile.Create(IniName);
  with IniFile do begin
    LastPath:=ReadString(CfgSekt,IniLast,DefPath);
    Top:=ReadInteger(CfgSekt,iniTop,Top);
    Left:=ReadInteger(CfgSekt,iniLeft,Left);
    end;
  LoadInfoList(IniFile,ImgDirSekt,iniSrc,iniDest,cbImgDir);
  LoadHistory(IniFile,DestSekt,cbDestDir);
  IniFile.Free;
  FileMask:=PngMask;
  end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  IniFile : TMemIniFile;
begin
  IniFile:=TMemIniFile.Create(IniName);
  with IniFile do begin
    WriteString(CfgSekt,IniLast,cbImgDir.Text);
    WriteInteger(CfgSekt,iniTop,Top);
    WriteInteger(CfgSekt,iniLeft,Left);
    end;
  SaveInfoList(IniFile,ImgDirSekt,iniSrc,iniDest,true,cbImgDir);
  SaveHistory(IniFile,DestSekt,true,cbDestDir);
  FreeListObjects(cbImgDir.Items);
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
  AddToInfoList(cbImgDir,LastPath);
  UpdateDirList;
  with ShellListView do if Items.Count>0 then Items[0].Selected:=true;
  ShowStatus;
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
  s:=GetExistingParentPath(cbImgDir.Text,DefPath);
  if ShellDirDialog.Execute (_('Directory with PNG images'),true,true,false,'',s) then begin
    AddToInfoList(cbImgDir,s);
    UpdateDirList;
    ShowStatus;
    end;
  end;

procedure TMainForm.rbOtherDirClick(Sender: TObject);
begin
  if length(cbDestDir.Text)=0 then btnDestDirClick(Sender)
  else begin
    ChangeInfoInList(cbImgDir,cbDestDir.Text);
    cbDestDir.Enabled:=true;
    btnDestDir.Enabled:=true;
    end;
  end;

procedure TMainForm.rbSourceDirClick(Sender: TObject);
begin
  ChangeInfoInList(cbImgDir,'');
  cbDestDir.Enabled:=false;
  btnDestDir.Enabled:=false;
  end;

procedure TMainForm.btnDestDirClick(Sender: TObject);
var
  s : string;
begin
  s:=GetExistingParentPath(cbImgDir.Text,DefPath);
  if ShellDirDialog.Execute (_('Directory for Icon'),true,true,false,'',s) then begin
    with cbDestDir do begin
      Text:=s; AddToHistory(cbDestDir,s);
      end;
    ChangeInfoInList(cbImgDir,s);
    cbDestDir.Enabled:=true;
    btnDestDir.Enabled:=true;
    end;
  end;

procedure TMainForm.UpdateDirList;
var
  n : integer;
  s : string;
begin
  with cbImgDir do s:=GetExistingParentPath(Items[ItemIndex],DefPath);
  ShellComboBox.Path:=s;
  s:=GetInfoFromList(cbImgDir);
  if length(s)>0 then with cbDestDir do begin
    n:=Items.IndexOf(s);
    if n>=0 then ItemIndex:=n
    else begin
      AddToHistory(Items,s);
      ItemIndex:=0;
      end;
    Text:=Items[ItemIndex];
    rbOtherDir.Checked:=true;
    cbDestDir.Enabled:=true;
    btnDestDir.Enabled:=true;
    end
  else begin
    rbSourceDir.Checked:=true;
    cbDestDir.Text:='';
    cbDestDir.Enabled:=false;
    btnDestDir.Enabled:=false;
    end;
  end;

procedure TMainForm.cbImgDirCloseUp(Sender: TObject);
begin
  UpdateDirList;
  ShowStatus;
  end;

procedure TMainForm.cbDestDirCloseUp(Sender: TObject);
begin
  with cbDestDir do ChangeInfoInList(cbImgDir,Items[ItemIndex]);
  end;

procedure TMainForm.bbConvertClick(Sender: TObject);
var
  sdi,ssp,
  sn       : string;
  pl       : TStringList;
  i        : integer;

begin
  Statusbar.SimpleText:='';
  if ShellListView.SelCount=0 then begin
    ErrorDialog(TopRightPos(bbConvert),_('No PNG imaged selected'));
    Exit;
    end;
  with sdIcon do begin
    if rbSourceDir.Checked then InitialDir:=cbImgDir.Text
    else InitialDir:=cbDestDir.Text;
    Filename:=DelExt(ShellListView.SelectedFolder.DisplayName);
    if Execute then sdi:=Filename else sdi:=''
    end;
  if length(sdi)>0 then begin
    pl:=TStringList.Create;
    ssp:=cbImgDir.Text;
    with ShellListView do for i:=0 to Items.Count-1 do if Items[i].Selected then begin
      sn:=Folders[i].DisplayName;
      pl.Add(AddPath(ssp,sn));
      end;
    if CreateIconFromPngFileList(sdi,pl) then Statusbar.SimpleText:=Format(_('Icon "%s" was created'),[sdi])
    else Statusbar.SimpleText:=Format(_('Error writing to "%s"'),[sdi]);
    pl.Free;
    end;
  end;

end.
