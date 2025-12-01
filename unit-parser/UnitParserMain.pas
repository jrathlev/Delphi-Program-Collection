(* Parse Delphi project or source for used units
   display unit list, optional export to separate directory
   ========================================================

   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 3: Sept. 2017
   Vers. 3.9: October 2020  - TListView uses groups
   Vers. 4.0: November 2025 - Optional subdirectory selection for units
                              View a list of copied file

   last modified: November 2025
   *)

unit UnitParserMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Buttons, Vcl.ComCtrls, Vcl.ImgList, System.ImageList;

const
  ProgName = 'Parse Delphi project or source for used units';
  Vers = ' - Vers. 4.0';
  CopRgt = '© 2013-2025 - J. Rathlev, D-24222 Schwentinental';
  EMailAdr = 'kontakt(a)rathlev-home.de';

  defSubDir = 'sources\';
  UnitSubpath = 'units\';
  dpjExt = 'dproj';
  dprExt = 'dpr';
  icoExt = 'ico';
  pasExt = 'pas';
  dfmExt = 'dfm';
  resExt = 'res';
  dpkExt = 'dpk';
  dcrExt = 'dcr';

  FileTypes = '*.dpr,*.ico,*.pas,*.dfm,*.res,*.dpk,*.dcr';

type
  TUnitInfo = class(TObject)
    Path,Ref : string;
    NoScan : boolean;
    constructor Create (const APath,ARef : string; ANoScan : boolean = false);
    end;

  TMainForm = class(TForm)
    OpenDialog: TOpenDialog;
    bbParse: TBitBtn;
    lvwFiles: TListView;
    imgSmall: TImageList;
    pnTop: TPanel;
    btSelNone: TBitBtn;
    btSelAll: TBitBtn;
    bbCopy: TBitBtn;
    bbProject: TBitBtn;
    bbExit: TBitBtn;
    bbInfo: TBitBtn;
    edSearchPath: TComboBox;
    Label1: TLabel;
    bbSearchPath: TBitBtn;
    edLanguage: TComboBox;
    Label2: TLabel;
    edPlatform: TComboBox;
    Label3: TLabel;
    edConfig: TComboBox;
    Label4: TLabel;
    edProject: TComboBox;
    Label5: TLabel;
    bbCollapse: TBitBtn;
    bbExpand: TBitBtn;
    StatusBar: TPanel;
    bbShowLog: TBitBtn;
    laStatus: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure bbProjectClick(Sender: TObject);
    procedure bbParseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure bbCopyClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btSelNoneClick(Sender: TObject);
    procedure btSelAllClick(Sender: TObject);
    procedure bbSearchPathClick(Sender: TObject);
    procedure bbExitClick(Sender: TObject);
    procedure bbInfoClick(Sender: TObject);
    procedure edSearchPathCloseUp(Sender: TObject);
    procedure edProjectCloseUp(Sender: TObject);
    procedure edSearchPathExit(Sender: TObject);
    procedure edProjectChange(Sender: TObject);
    procedure bbExpandClick(Sender: TObject);
    procedure bbCollapseClick(Sender: TObject);
    procedure bbShowLogClick(Sender: TObject);
  private
    { Private-Deklarationen }
    ProgVersName,ProgVers,
    ProgVersDate,
    ProgPath,PrjPath,
    AppPath,UserPath,
    DestDir,MainSource,
    LangCode,
    SearchPath,
    IniName          : string;
    IsSelecting,
    IsProject        : boolean;
    CopyLog,
    AllUnits         : TStringList;
    procedure ShowSearchPath (ShowPath : boolean);
    procedure OpenProject(const Filename : string);
    procedure ParseProject;
    procedure WMDROPFILES (var Msg: TMessage); message WM_DROPFILES;
  public
    { Public-Deklarationen }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses System.StrUtils, System.Math, Winapi.ShellApi, System.DateUtils, System.IOUtils,
  System.Types, System.AnsiStrings, InitProg, LangUtils, ListUtils,
  GnugetText, StringUtils, ExtSysUtils, WinUtils, MsgDialogs, NumberUtils,
  IniFiles, PathUtils, FileUtils, ShellDirDlg, SelectDlg, SearchPathDlg,
  UnitDestlDlg, ShowStringList;


{ ------------------------------------------------------------------- }
constructor TUnitInfo.Create (const APath,ARef : string; ANoScan : boolean = false);
begin
  inherited Create;
  Path:=APath; Ref:=ARef; NoScan:=ANoScan;
  end;
  
{ ------------------------------------------------------------------- }
const
  IniExt = 'ini';

  (* INI-Sektionen *)
  CfGSekt = 'Config';
  DirSekt = 'Directories';
  SourceSekt = 'Sources';
  SearchSekt = 'SearchPath';
  LangSekt = 'Languages';

  (* INI-Variablen *)
  iniTop = 'Top';
  iniLeft = 'Left';
  iniHeight = 'Height';
  iniWidth = 'Width';
  iniProject = 'LastProject';
  iniConfig = 'Config';
  iniPlatform = 'Platform';
  iniLanguage = 'Language';
//  iniDest = 'Destination';
  iniPath = 'Path';
  iniDest = 'Dest';

  MaxProj = 50;

// XML Tags
  xpPropGrp = '<PropertyGroup';
  xpMainSrc = '<MainSource';
  xpSearchPath = '<DCC_UnitSearchPath';
  xpImport = '<Import';
  xpProject = 'Project="';
  xpLocale = '<VerInfo_Locale';

// Delphi placeholders
  phConfig = '$(Config)';
  phPlatForm = '$(Platform)';
  phLanguage = '$(LANGDIR)';

procedure TMainForm.FormCreate(Sender: TObject);
var
  ss : string;
  IniFile : TMemIniFile;
begin
  TranslateComponent (self);
  DragAcceptFiles(MainForm.Handle, true);
  InitPaths (AppPath,UserPath,ProgPath);
  InitVersion (ProgName,Vers,CopRgt,3,3,ProgVersName,ProgVers,ProgVersDate);
  IniName:=Erweiter(AppPath,PrgName,IniExt);
  IniFile:=TMemIniFile.Create(IniName);
  with IniFile do begin
    Top:=ReadInteger(CfgSekt,iniTop,Top);
    Left:=ReadInteger(CfgSekt,iniLeft,Left);
    ClientHeight:=ReadInteger(CfgSekt,iniHeight,ClientHeight);
    ClientWidth:=ReadInteger(CfgSekt,iniWidth,ClientWidth);
    ss:=ReadString(CfgSekt,IniProject,'');
    edConfig.ItemIndex:=ReadInteger(CfgSekt,IniConfig,0);
    edPlatform.ItemIndex:=ReadInteger(CfgSekt,IniPlatform,0);
    LangCode:=ReadString(CfgSekt,IniLanguage,'EN');
    DestDir:=ReadString(CfgSekt,IniDest,UserPath);
    end;
  LoadInfoList(IniFile,SourceSekt,iniPath,iniDest,edProject,MaxProj);
  AddToInfoList(edProject,ss);
  LoadHistory(IniFile,LangSekt,iniLanguage,edLanguage);
  LoadHistory(IniFile,SearchSekt,iniPath,edSearchPath);
  SearchPath:=edSearchPath.Text;
  IniFile.Free;
  PrjPath:=ExtractFilePath(edProject.Text);
  SetCurrentDir(PrjPath);
  IsProject:=AnsiSameText(GetExt(edProject.Text),dpjExt);
  ShowSearchPath(false);
  Caption:=_('Parse Delphi project or source for used units')+ProgVers;
  AllUnits:=TStringList.Create;
  CopyLog:=TStringList.Create;
  end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  IniFile : TMemIniFile;
begin
  AllUnits.Free; CopyLog.Free;
  IniFile:=TMemIniFile.Create(IniName);
  with IniFile do begin
    WriteInteger(CfgSekt,iniTop,Top);
    WriteInteger(CfgSekt,iniLeft,Left);
    WriteInteger(CfgSekt,iniHeight,ClientHeight);
    WriteInteger(CfgSekt,iniWidth,ClientWidth);
    WriteString(CfgSekt,IniProject,edProject.Text);
    WriteInteger(CfgSekt,IniConfig,edConfig.ItemIndex);
    WriteInteger(CfgSekt,IniPlatform,edPlatform.ItemIndex);
    WriteString(CfgSekt,IniLanguage,LangCode);
    WriteString(CfgSekt,IniDest,DestDir);
    end;
  SaveInfoList(IniFile,SourceSekt,iniPath,iniDest,true,edProject,MaxProj);
  SaveHistory(IniFile,SearchSekt,iniPath,true,edSearchPath);
  SaveHistory(IniFile,LangSekt,iniLanguage,true,edLanguage);
  with IniFile do begin
    UpdateFile;
    Free;
    end;
  end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  with lvwFiles do begin
    Column[2].Width:=140;
    Column[3].Width:=70;
    Column[1].Width:=150;
    Column[0].Width:=Width-385;
    Invalidate;
    end;
  edProject.SelLength:=0;
  edSearchPath.SelLength:=0;
  end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  ShellDirDialog.LoadFromIni(IniName,DirSekt);
  with edProject do if FileExists(Text) then OpenProject(Text);
  end;

procedure TMainForm.WMDROPFILES (var Msg: TMessage);
var
   n,size: integer;
   Filename: PChar;
   se : string;
begin
  inherited;
  Filename:=nil;
  n:= DragQueryFile(Msg.WParam, $FFFFFFFF, Filename, 255);
  if n>0 then begin
    size := DragQueryFile(Msg.WParam, 0 , nil, 0) + 1;
    Filename:= StrAlloc(size);
    DragQueryFile(Msg.WParam,0 , Filename, size);
    Application.BringToFront;
    OpenProject(Filename);
    StrDispose(Filename);
    end;
  DragFinish(Msg.WParam);
  end;

procedure TMainForm.bbExitClick(Sender: TObject);
begin
  Close;
  end;

procedure TMainForm.bbInfoClick(Sender: TObject);
begin
  InfoDialog(Caption+' - '+ProgVersDate+sLineBreak+CopRgt
           +sLineBreak+'E-Mail: '+EmailAdr);
  end;

procedure TMainForm.ShowSearchPath (ShowPath : boolean);
begin
  with edSearchPath do begin
    Enabled:=not IsProject;
    if IsProject and not ShowPath then Text:=_('<Retrieved from project>')
    else Text:=SearchPath;
    end;
  if not ShowPath then edLanguage.Enabled:=not IsProject;
  end;

procedure TMainForm.bbProjectClick(Sender: TObject);
begin
  with OpenDialog do begin
    if length(edProject.Text)>0 then InitialDir:=ExtractFilePath(edProject.Text)
    else InitialDir:=UserPath;
    Filename:='';
    Filter:=_('Delphi projects|*.dproj|Delphi sources|*.pas;*.dpr|all|*.*');
    Title:=_('Select Delphi project or source');;
    if Execute then OpenProject(Filename);
    end;
  end;

procedure TMainForm.OpenProject(const Filename : string);
begin
  AddToInfoList(edProject,Filename,MaxProj);
//  edProject.Text:=Filename;
  PrjPath:=ExtractFilePath(Filename);
  SetCurrentDir(PrjPath);
  IsProject:=AnsiSameText(GetExt(Filename),dpjExt);
  ShowSearchPath(false);;
  with lvwFiles do begin
    Clear;
    Groups.Clear;
    end;
  bbCopy.Enabled:=IsProject;
  if IsProject then ParseProject;
  end;

procedure TMainForm.edProjectChange(Sender: TObject);
var
  s: string;
begin
  s:=edProject.Text;
  if FileExists(s) then OpenProject(s);
  end;

procedure TMainForm.edProjectCloseUp(Sender: TObject);
var
  s : string;
begin
//  with edProject do s:=Items[ItemIndex];
//  if FileExists(s) then OpenProject(s);
//  PrjPath:=ExtractFilePath(s);
//  SetCurrentDir(PrjPath);
//  IsProject:=AnsiSameText(GetExt(s),dpjExt);
//  ShowSearchPath(false);
//  with lvwFiles do begin
//    Clear;
//    Groups.Clear;
//    end;
//  bbCopy.Enabled:=false;
  end;

procedure TMainForm.edSearchPathCloseUp(Sender: TObject);
begin
  with edSearchPath do SearchPath:=Items[ItemIndex];
  end;

procedure TMainForm.edSearchPathExit(Sender: TObject);
begin
  SearchPath:=edSearchPath.Text;
  end;

procedure TMainForm.bbSearchPathClick(Sender: TObject);
var
  sp,ss,s,sr : string;
  rl : TReplList;

  procedure SetReplList(var re : TReplace; const sp,sr : string);
  begin
    with re do begin
      PlaceHolder:=sp; Replacement:=sr;
      end;
    end;

begin
  if FileExists(edProject.Text) then begin
    sr:=ExtractFilePath(edProject.Text);
    s:=SearchPath;
    ss:='';
    while length(s)>0 do begin
      sp:=ReadNxtStr(s,';');
      if length(sp)>0 then begin
        if length(ss)>0 then ss:=ss+';';
        ss:=ss+ExpandPath(sp);
        end;
      end;
    SetLength(rl,3);
    SetReplList(rl[0],phConfig,edConfig.Text);
    SetReplList(rl[1],phPlatForm,edPlatform.Text);
    SetReplList(rl[2],phLanguage,LangCode);
    if SearchPathDialog.Execute(_('Define search path for units'),sr,rl,ss) then begin
      s:='';
      while length(ss)>0 do begin
        sp:=ReadNxtStr(ss,';');
        if length(sp)>0 then begin
          if length(s)>0 then s:=s+';';
          sr:=ExtractRelativePath(PrjPath,sp);
          if length(sr)=0 then s:=s+'.\' else s:=s+sr;
          end;
        end;
      SearchPath:=s;
      AddToHistory(edSearchPath,SearchPath);
      edSearchPath.Text:=s;
      end;
    end;
  end;

procedure TMainForm.bbShowLogClick(Sender: TObject);
begin
  ShowStringListDialog.Execute(CenterPos,_('Copied files'),_('Destination: ')+DestDir,
    Format(_('%u files copied'),[CopyLog.Count]),CopyLog);
  end;

//  de\;..\Units\;..\ZLib\$(Platform)\;..\Aes\$(Platform)\;..\Indy10\Core\;..\Indy10\Protocols\;..\Indy10\System\
procedure TMainForm.bbCopyClick(Sender: TObject);
var
  fcnt,SubMode,
  i,n : integer;
  sp,s,su : string;
  ok : boolean;

  procedure CopyNewerFile (const Source,Dest : string);
  var
    dts,dtd : TDateTime;
    ok,cop : boolean;
  begin
    ok:=FileExists(Dest);
    if ok then ok:=FileAge(Dest,dtd,false);
    if ok then ok:=FileAge(Source,dts,false);
    if ok then cop:=not WithinPastSeconds(dts,dtd,2) else cop:=true;
    if cop then begin
      CopyFileTS(Source,Dest); inc(fcnt);
      CopyLog.Add(MakeRelativePath(DestDir,Dest));
      end;
    end;

  procedure CopyMainSource (const ms : string);
  var
    mf,mc  : TextFile;
    n,k    : integer;
    sl,sm,s,t,u : string;
    usect  : boolean;
  begin
    AssignFile(mf,ms); Reset (mf);
    AssignFile(mc,DestDir+ExtractFilename(ms)); Rewrite(mc);
    usect:=false;
    while not Eof(mf) do begin
      Readln(mf,sl);
      if usect then begin
        sm:=trim(sl);
        usect:=not AnsiEndsStr(';',sm);
        if length(sm)>0 then begin
          n:=TextPos(' in ',sm);
          if n>0 then begin
            u:=copy(sm,1,n-1);    // Unit name
            k:=TextPosEx('''',sm,n);
            if k>0 then begin
              n:=TextPosEx('''',sm,k+1);
              if n>0 then t:=copy(sm,k+1,n-k-1);  // unit path
              s:=ExtractFilePath(t);
              if length(s)>0 then begin
                case SubMode of
                1 : t:=UnitSubpath+ExtractFileName(t);
                2 : t:=SetDirName(ExtractLastDir(s))+ExtractFileName(t);
                else t:=ExtractFileName(t);
                  end;
                end
              else t:=ExtractFileName(t);
              sl:='  '+u+' in '''+t+copy(sm,n,length(sm));
              end;
            end;
          end;
        end
      else if AnsiStartsText('uses',trim(sl)) then usect:=true;
      Writeln(mc,sl);
      end;
    CloseFile(mf); CloseFile(mc);
    sm:=NewExt(ms,resExt);
    if FileExists(sm) then CopyNewerFile(sm,NewExt(DestDir+ExtractFilename(ms),resExt));
    sm:=NewExt(ms,icoExt);
    if FileExists(sm) then CopyNewerFile(sm,NewExt(DestDir+ExtractFilename(ms),icoExt));
    end;

  procedure CopyProjectFiles (const Source,Dest : string);
  var
    s : string;
  begin
    CopyNewerFile(Source,Dest);
    if AnsiSameText(GetExt(Source),pasExt) then begin
      s:=NewExt(Source,dfmExt);
      if FileExists(s) then CopyNewerFile(s,NewExt(Dest,dfmExt));
      s:=NewExt(Source,resExt);
      if FileExists(s) then CopyNewerFile(s,NewExt(Dest,resExt));
      s:=NewExt(Source,dpkExt);
      if FileExists(s) then CopyNewerFile(s,NewExt(Dest,dpkExt));
      s:=NewExt(Source,dcrExt);
      if FileExists(s) then CopyNewerFile(s,NewExt(Dest,dcrExt));
      end;
    end;

  procedure DeleteProjectFiles (const Path : string);
  var
    sm : string;
  begin
    sm:=FileTypes;
    repeat
      DeleteMatchingFiles(Path,ReadNxtStr(sm,','));
      until length(sm)=0;
    end;

  procedure DeleteUnitFiles(const DestDir : string);
  var
    SubDirs : TStringDynArray;
    sn      : string;
  begin
    case SubMode of
    1 : DeleteProjectFiles(DestDir+UnitSubpath);
    2 : begin
        SubDirs:=TDirectory.GetDirectories(DestDir);
        for sn in SubDirs do DeleteProjectFiles(sn);
        if IsEmptyDir(sn) then RemoveDir(sn);
        end;
      end;
    end;

begin
  if (lvwFiles.SelCount=0) then
    ok:=ConfirmDialog(_('No units selected!'+sLineBreak+'Copy only project files?'))
  else ok:=true;
  if ok then begin
    DestDir:=GetInfoFromList(edProject);
    if DestDir.IsEmpty then DestDir:=PrjPath+defSubDir;
    if not DirectoryExists(DestDir) then DestDir:=PrjPath;
    if ShellDirDialog.Execute(_('Select destination directory'),true,true,false,PrjPath,DestDir) then begin
      if AnsiSameText(DestDir,PrjPath) then DestDir:=SetDirName(DestDir)+defSubDir;
      if DirectoryExists(DestDir) then sp:=_('Delete all existing files') else sp:='';
      n:=GetTagFromList(edProject);
      if not UnitDestDialog.Execute(CenterPos,DestDir,n) then n:=-1;
      end
    else n:=-1;
//      ConfirmDialog(Format(_('Destination directory:'+sLineBreak+'%s'+
//        sLineBreak+'Delete all existing files?'),[DestDir])) then DeleteDirectory(DestDir,false);
    if n<0 then Exit;
    SubMode:=n and 3;
    ChangeInfoInList(edProject,DestDir,SubMode);
    if n and $10<>0 then begin
      DeleteProjectFiles(DestDir);
      if SubMode>0 then DeleteUnitFiles(DestDir);
      end;
    ForceDirectories(DestDir);
    n:=0; fcnt:=0; CopyLog.Clear;
    if IsProject then begin
      CopyMainSource(mainsource);   // adjust paths and copy dpr file
      end
    else begin
      sp:=edProject.Text;
      CopyNewerFile(sp,DestDir+ExtractFilename(sp));
      if AnsiSameText(GetExt(sp),dprExt) then begin
        s:=NewExt(sp,resExt);
        if FileExists(s) then CopyNewerFile(s,DestDir+ExtractFilename(s));
        end;
      end;
    // copy units
    with lvwFiles.Items do for i:=0 to Count-1 do with Item[i] do
        if (ImageIndex=0) and Selected then begin
      with (AllUnits.Objects[integer(Data)] as TUnitInfo) do if FileExists(Path) then begin
        sp:=ExtractFilePath(Path);
        laStatus.Caption:=Format(_('Copying: %s'),[Caption]);
        if AnsiSameText(sp,PrjPath) then CopyProjectFiles(Path,DestDir+ExtractFilename(Path))
        else begin
          case SubMode of
          1 : su:=DestDir+UnitSubpath;
          2 : su:=DestDir+SetDirName(ExtractLastDir(sp));
          else su:=DestDir;
            end;
          ForceDirectories(su);
          CopyProjectFiles(Path,su+ExtractFilename(Path));
          end;
        end;
      end;
    laStatus.Caption:=Format(_('%u files copied to %s'),[fcnt,DestDir]);
    end
 end;

procedure TMainForm.bbParseClick(Sender: TObject);
begin
  ParseProject;
  end;

procedure TMainForm.ParseProject;
var
  s     : string;
  lp,lu : TStringList;
  i     : integer;
  skip,stop : boolean;
const
  Utf8BomS : RawByteString = #$EF#$BB#$BF;

  function ReadProject(const sf : string) : string;
  var
    pf    : TFileStream;
    sa    : AnsiString;
  begin
    pf:=TFileStream.Create(sf,fmOpenRead);
    with pf do begin
      SetLength(sa,Size+1);
      Read(sa[1],Size);
      Free;
      end;
    if System.AnsiStrings.AnsiSameStr(copy(sa,1,3),Utf8BomS) then Result:=Utf8ToString(copy(sa,4,length(sa)))
    else Result:=sa;
    end;

  function GetXmlTag (const s,Tag : string) : string;
  var
    n,k : integer;
  begin
    Result:='';
    n:=TextPos(Tag,s);
    if n>0 then begin
      k:=TextPosEx('>',s,n);
      if k>0 then begin
        n:=TextPosEx('<',s,k+1);
        if n>0 then Result:=copy(s,k+1,n-k-1);
        end;
      end;
    end;

  function GetMainSrc (const s : string) : string;
  begin
    Result:=GetXmlTag(s,xpMainSrc);
    end;

  function GetLocale (const s : string; var LangCode : string) : boolean;
  var
    id : integer;
    sid  : string;
  begin
    sid:=GetXmlTag(s,xpLocale);
    Result:=(length(sid)>0) and TryStrToInt(sid,id);
    if Result then LangCode:=LangIdToCode(id);
    end;

  function GetSearchPath (const s : string; var n : integer) : string;
  var
    k : integer;
  begin
    Result:='';
    n:=TextPosEx(xpSearchPath,s,n);
    if n>0 then begin
      k:=TextPosEx('>',s,n);
      if k>0 then begin
        n:=TextPosEx('<',s,k+1);
        if n>0 then Result:=copy(s,k+1,n-k-1);
        end;
      end;
    end;

  procedure AddPathToList (ss: String; AtBegin : boolean = false);
  var
    i,n : integer;
    s,su : string;
  begin
    with lp do if length(ss)>0 then begin
      n:=Count;
      if length(DelimitedText)=0 then DelimitedText:=ss
      else repeat
        su:=ReadNxtQuotedStr(ss,';','"');
        if IndexOf(su)<0 then begin
          if AtBegin then Insert(0,su) else Add(su);
          end;
        until length(ss)=0;
//        if TextPos(ss,DelimitedText)=0 then DelimitedText:=DelimitedText+';'+ss
      if Count>n then for i:=Count-1 downto 0 do begin
        s:=Strings[i];
        if (length(s)=0) or (s[1]='$') then Delete(i)
        else Strings[i]:=SetDirName(s);
        end;
      end;
    end;

  procedure ReplacePathPlaceholder;
  var
    i : integer;
    ss : string;
  begin
    // Replace path placeholders
    with lp do for i:=0 to Count-1 do begin
      ss:=Strings[i];
      ss:=AnsiReplaceText(ss,phConfig,edConfig.Text);
      ss:=AnsiReplaceText(ss,phPlatform,edPlatform.Text);
      ss:=AnsiReplaceText(ss,phLanguage,LangCode);
      Strings[i]:=ExpandPath(ss);
      end;
    end;

  procedure RetrieveSearchPaths (const s : string);
  var
    n,k : integer;
    ss  : string;
  begin
    n:=1; lp.Clear;
//    AddPathToList(PrjPath);
    ss:=GetSearchPath(s,n);
    if length(ss)>0 then repeat
      AddPathToList(ss);
      ss:=GetSearchPath(s,n);
      until n=0;
    // check for import
    n:=TextPos(xpImport,s);
    if n>0 then begin
      k:=TextPosEx(xpProject,s,n);
      if k>0 then begin
        inc(k,length(xpProject));
        n:=TextPosEx('"',s,k+1);
        if n>0 then begin
          ss:=copy(s,k,n-k);
          if FileExists(ss) then begin
            n:=1;
            ss:=GetSearchPath(ReadProject(ss),n);
            if length(ss)>0 then AddPathToList(ss);
            end;
          end;
        end;
      end;
    SearchPath:=lp.DelimitedText;
    ReplacePathPlaceholder;
    end;

  function CheckSearchPaths : boolean;
  var
    i : integer;
  begin
    Result:=true;
    with lp do for i:=0 to Count-1 do Result:=Result and DirectoryExists(Strings[i]);
    end;

  function ExpandSearchPath (const Name : string) : string;
  var
    i : integer;
    s : string;
  begin
    Result:='';
    if (lp.IndexOf(PrjPath)<0) then begin
      s:=PrjPath+Name;
      if FileExists(s) then Result:=s;
      end;
    if length(Result)=0 then begin
//    else begin
      with lp do for i:=0 to Count-1 do begin
        s:=Strings[i]+Name;
        if FileExists(s) then begin
          Result:=s; Break;
          end;
        end;
      if length(Result)=0 then begin
        Result:=ExtractSamePath(PrjPath,Name);
        end;
      end;
    end;

  procedure ScanMainSource (const ms : string);
  var
    mf : TextFile;
    n,k  : integer;
    sm,t,u : string;
    ok     : boolean;
  begin
    laStatus.Caption:=Format(_('Scanning: %s'),[ms]);
    Application.ProcessMessages;
    AssignFile(mf,ms); Reset (mf);
    while not Eof(mf) do begin
      Readln(mf,sm);
      if AnsiStartsText('uses',trim(sm)) then begin
        ok:=true;
        while ok and not Eof(mf) do begin
          Readln(mf,sm);
          sm:=trim(sm);
          if AnsiStartsText('//',sm) then continue;
          ok:=not EndsStr(';',sm);
          if length(sm)>0 then begin
            n:=TextPos(' in ',sm);
            if n>0 then begin
              u:=copy(sm,1,n-1);    // Unit name
              k:=TextPosEx('''',sm,n);
              if k>0 then begin
                n:=TextPosEx('''',sm,k+1);
                if n>0 then begin
                  t:=ExpandPath(copy(sm,k+1,n-k-1));  // unit path
                  AllUnits.AddObject(u,TUnitInfo.Create(t,ExtractFilename(ms)));
                  AddPathToList(ExtractFilePath(t),true);
                  end;
                end;
              end
            else begin
              n:=TextPos(',',sm); k:=1;
              if n=0 then n:=TextPos(';',sm);
              if n>0 then repeat
                u:=Trim(copy(sm,k,n-k));    // Unit name
                t:=ExpandSearchPath(u+'.'+pasExt);
                if length(t)>0 then begin
                  AllUnits.AddObject(u,TUnitInfo.Create(t,ExtractFilename(ms)));
                  AddPathToList(ExtractFilePath(t),true);
                  end;
                k:=n+1;
                n:=TextPosEx(',',sm,k);
                if n=0 then n:=TextPosEx(';',sm,k);
                until n=0;
              end;
            end;
          end;
        end;
      end;
    CloseFile(mf);
    end;

  function ReadInclude (const Filename : string) : string;
  var
    mi : TextFile;
    s  : string;
    n  : integer;
  begin
    Result:='';
    if FileExists(Filename) then begin
      AssignFile(mi,Filename); Reset (mi);
      while not Eof(mi) do begin
        Readln(mi,s);
        s:=Trim(s);
        n:=Pos('//',s);
        if n>0 then s:=Trim(copy(s,1,n-1));
        if length(s)>0 then Result:=Result+s;
        end;
      CloseFile(mi);
      end;
    end;

  function FindNextDirective(const sl,Dir,DirA : string; var n,m : integer; var se : string) : boolean;
  type
    StrPos = record
      Pos,Len : integer;
      end;
  var
    p : array [0..3] of StrPos;
    j : integer;

    procedure NextPos (const SubStr,s: string; Offset,Index: Integer);
    begin
      with p[Index] do begin
        Pos:=PosEx(SubStr,s,Offset);
        if Pos=0 then Pos:=MaxInt;
        Len:=length(SubStr);
        end;
      end;

    function MinPos : Integer;
    var
      i,m : Integer;
    begin
      begin
        m:=p[0].Pos; Result:=0;
        for I:=1 to 3 do if m>p[i].Pos then Result:=i;
        end;
      end;

  begin
    se:='';
    NextPos('{$'+Dir+' ',sl,n,0); NextPos('{$'+DirA+' ',sl,n,1);
    NextPos('(*$'+Dir+' ',sl,n,2); NextPos('(*$'+DirA+' ',sl,n,3);
    j:=MinPos;
    with p[j] do begin
      n:=Pos;
      Result:=n<>MaxInt;
      if not Result then Exit;
      if j<2 then begin
        m:=PosEx('}',sl,n+Len); se:=Trim(copy(sl,n+Len,m-n-Len));
        end
      else begin
        m:=PosEx('*)',sl,n+Len)+1; se:=Trim(copy(sl,n+Len,m-n-Len-1));
        end;
      end;
    end;

  function ParseUnit(UnitInfo : TUnitInfo; var SkipIfNotExists : boolean) : boolean;
  var
    mu : TextFile;
    su,ss,sl,u,t : string;
    cmode,                 // 0 = Progr., 1 = "{", 2 = "(*"
    n,k     : integer;
    ok      : boolean;
//    fs : TFileStream;
  begin
    Result:=true;
    if UnitInfo.NoScan then Exit;
    laStatus.Caption:=Format(_('Scanning: %s'),[UnitInfo.Path]);
    Application.ProcessMessages;
    UnitInfo.NoScan:=true;
    if not FileExists(UnitInfo.Path) then begin
      if SkipIfNotExists then Exit;
      n:=SelectDialog.Execute(CenterPos,_('Error'),_('File not found: ')+UnitInfo.Path,
        mtConfirmation,[fsBold],[_('Skip'),_('Skip all')]);
      if n=1 then SkipIfNotExists:=true;
      Result:=n>=0;
      Exit;
      end;
    AssignFile(mu,UnitInfo.Path); Reset (mu);
    su:=''; cmode:=0;
    while not Eof(mu) do begin
      Readln(mu,sl);
      sl:=trim(sl); ss:='';
      if length(sl)>0 then begin   // strip comment
        if cmode=0 then begin // no comment
          n:=1;
          repeat    // insert include files
            ok:=FindNextDirective(sl,'I','INCLUDE',n,k,ss);
            if ok then begin
//            j:=PosEx('{$I ',sl,n);
//            k:=PosEx('{$INCLUDE ',sl,n);
//            m:=9;
//            if (j=0) then n:=k
//            else if (k=0) or (j<k) then begin
//              n:=j; m:=3;
//              end
//            else n:=k;
//            if n>0 then begin   // include files
//              k:=PosEx('}',sl,n);
              delete(sl,n,k-n+1);
              ss:=UnixPathToDosPath(ss);
              ss:=ExpandSearchPath(ss);
              if length(ss)>0 then begin
                insert('!L'+ss+'!',sl,n);   // replace with !L<name>!
                n:=n+length(ss)+3;
                ss:=ReadInclude(MakeAbsolutePath(ExtractFilePath(UnitInfo.Path),ss));
                insert(ss,sl,n);
                end;
              n:=k;
              end;
            until not ok;
          n:=1;
          repeat    // search for $L or $LINK
            ok:=FindNextDirective(sl,'L','LINK',n,k,ss);
            if ok then begin
//            j:=PosEx('{$L ',sl,n);
//            k:=PosEx('{$LINK ',sl,n);
//            m:=6;
//            if (j=0) then n:=k
//            else if (k=0) or (j<k) then begin
//              n:=j; m:=3;
//              end
//            else n:=k;
//            if n>0 then begin
//              k:=PosEx('}',sl,n);
              delete(sl,n,k-n+1);
              insert('!L'+ss+'!',sl,n);   // replace with !L<name>!
              n:=k;
              end;
            until not ok;
          n:=Pos('{',sl); k:=Pos('(*',sl);
          if (k>0) and ((n=0) or ((n>0) and (k<n))) then begin
            cmode:=2; n:=k;
            end
          else if n>0 then cmode:=1;
          k:=Pos('//',sl);
          if (k>0) and ((n=0) or ((n>0) and (k<n))) then begin
            cmode:=0; n:=k;
            end;
          if n>0 then begin
            ss:=copy(sl,1,n-1);
            if cmode>0 then begin
              if cmode=1 then begin
                k:=PosEx('}',sl,n);
                if k>0 then begin
                  ss:=ss+copy(sl,k+1,length(sl));
                  cmode:=0
                  end;
                end
              else begin
                k:=Pos('*)',sl);
                if k>n then begin
                  ss:=ss+copy(sl,k+2,length(sl));
                  cmode:=0
                  end;
                end;
              end;
            end
          else ss:=sl;
          end
        else begin
          if cmode=1 then begin  // comment {}
            n:=Pos('}',sl);
            if n>0 then begin
              delete(ss,1,n); cmode:=0;
              end
            else ss:='';
            end
          else begin // comment (* *)
            n:=Pos('*)',sl);
            if n>0 then begin
              delete(ss,1,n+1); cmode:=0;
              end
            else ss:='';
            end;
          if cmode=0 then begin
            n:=Pos('//',sl);
            if n>0 then ss:=copy(ss,1,n-1);
            end;
          end;
        if length(ss)>0 then su:=su+' '+trim(ss);          // check for comments
        end;
      end;
    CloseFile(mu);
//    fs:=TFileStream.Create('test.txt',fmCreate);
//    fs.Write(su[1],2*length(su));
//    fs.Free;
    n:=1;
    repeat        // linked object or include file
      n:=PosEx('!L',su,n);
      if n>0 then begin
        k:=PosEx('!',su,n+1);
        if k>n then begin
          u:=Trim(copy(su,n+2,k-n-2));
          t:=ExpandSearchPath(u);
          if length(t)>0 then with AllUnits do begin
            if (IndexOf(u)<0) then begin
              AddObject(ExtractFilename(u),TUnitInfo.Create(u,ExtractFilename(UnitInfo.Path),true));
              AddPathToList(ExtractFilePath(u));
              end;
            end;
          n:=k+1;
          end
        else inc(n);
        end;
      until n=0;
    n:=TextPos('uses',su);
    if n>0 then repeat
      k:=TextPosEx(' ',su,n);
      if k>0 then begin
        n:=TextPosEx(';',su,k+1);
        if n>0 then begin
          ss:=trim(copy(su,k+1,n-k-1));
          repeat
            u:=Trim(ReadNxtStr(ss,','));
            t:=ExpandSearchPath(u+'.'+pasExt);
            if length(t)>0 then with AllUnits do begin
              if (IndexOf(u)<0) then AddObject(u,TUnitInfo.Create(t,ExtractFilename(UnitInfo.Path)));
              end;
            until length(ss)=0;
          end;
        end;
      n:=TextPosEx('uses',su,n);
      until n=0;
    end;

  procedure ShowUnits;
  var
    i,j,n : integer;
    sp  : string;
  begin
    with lvwFiles do begin
      Items.BeginUpdate;
      Groups.BeginUpdate;
      end;
    for i:=-1 to lp.Count-1 do begin
      if i<0 then sp:=PrjPath
      else begin
        sp:=lp[i];
        if AnsiSameText(sp,PrjPath) then sp:='';
        end;
      if length(sp)>0 then begin
        laStatus.Caption:=Format(_('Searching for units from: %s'),[sp]);
        Application.ProcessMessages;
        lu.Clear;
        with AllUnits do for j:=0 to Count-1 do with Objects[j] as TUnitInfo do begin
          if AnsiSameText(ExtractFilePath(Path),sp) then
            lu.AddObject(Strings[j],pointer(j));
          end;
        if lu.Count>0 then begin
          with lvwFiles.Groups.Add do begin
            State:=[lgsNormal,lgsCollapsible];
            Header:=sp; TitleImage:=1; n:=GroupId;
            end;
          for j:=0 to lu.Count-1 do begin
            with lvwFiles.Items.Add do begin
              Caption:=lu[j]; ImageIndex:=0; Data:=lu.Objects[j];
              with (AllUnits.Objects[integer(Data)] as TUnitInfo) do begin
                GroupId:=n;
                SubItems.Add(Ref);
                if FileExists(Path) then begin
                  SubItems.Add(DateTimeToStr(GetFileDateTime(Path)));
                  SubItems.Add(SizeToStr(LongFileSize(Path)));
                  end
                else SubItems.Add(_('<File not found>'));
                end;
              end;
            end;
          end;
        end;
      end;
    with lvwFiles do begin
      Items.EndUpdate;
      Groups.EndUpdate;
      end;
    laStatus.Caption:=Format(_('%u Units found'),[AllUnits.Count]);
    Application.ProcessMessages;
    btSelAllClick(self);
    bbCopy.Enabled:=true;
    end;

begin
  with lvwFiles do begin
    Clear;
    Groups.Clear;
    end;
  AllUnits.Clear;
  LangCode:=edLanguage.Text;
  AddToHistory(edLanguage);
  Application.ProcessMessages;
  if FileExists(edProject.Text) then begin
//    with edProject do begin
//      AddToHistory(Items,Text);
//      ItemIndex:=0;
//      end;
    lp:=TStringList.Create; lu:=TStringList.Create;
    with lp do begin
      Delimiter:=';'; QuoteChar:='"';
      CaseSensitive:=false;
      end;
    with lu do begin
      Sorted:=true;
      end;
    if IsProject then begin // analyze project file
      s:=ReadProject(edProject.Text);
      laStatus.Caption:=Format(_('Scanning: %s'),[edProject.Text]);
      Application.ProcessMessages;
      MainSource:=GetMainSrc(s);
      with edLanguage do if GetLocale(s,LangCode) then Text:=LangCode
      else Enabled:=true;
      if length(MainSource)>0 then begin
        MainSource:=PrjPath+MainSource;  // main source
        if FileExists(MainSource) then begin
          RetrieveSearchPaths(s); // Get search paths
          // Scan main source for units
          ScanMainSource(MainSource);
          AddToHistory(edSearchPath,SearchPath);
          ShowSearchPath (true);
          with AllUnits do if Count>0 then begin
            i:=0; skip:=false;
            repeat
              stop:=not ParseUnit(Objects[i] as TUnitInfo,skip);
              inc(i);
              until stop or (i>=Count);
            end;
          ShowUnits;
          end
        else ErrorDialog(_('File not found: ')+MainSource);
        end
      else ErrorDialog(_('Main source not found!'));
      end
//    else if AnsiSameText(GetExt(edProject.Text),dprExt) then begin
//      MainSource:=edProject.Text;
//      if FileExists(MainSource) then begin
//        lp.DelimitedText:=SearchPath;
//        ReplacePathPlaceholder;
//        // Scan main source for units
//        ScanMainSource(MainSource);
//        with AllUnits do if Count>0 then begin
//          i:=0; skip:=false;
//          repeat
//            stop:=not ParseUnit(Objects[i] as TUnitInfo,skip);
//            inc(i);
//            until stop or (i>=Count);
//          end;
//        ShowUnits;
//        end
//      else ErrorDialog(_('File not found: ')+MainSource);
//      end
    else begin   // Pascal source
      lp.DelimitedText:=SearchPath;
      ReplacePathPlaceholder;
      if CheckSearchPaths then with AllUnits do begin
        AddObject(DelExt(ExtractFileName(edProject.Text)),TUnitInfo.Create(edProject.Text,ExtractFilename(PrjPath)));
        i:=0; skip:=false;
        stop:=not ParseUnit(Objects[i] as TUnitInfo,Skip);
        inc(i);
        if not stop and (i<Count) then repeat
          stop:=not ParseUnit(Objects[i] as TUnitInfo,Skip);
          inc(i);
          until stop or (i>=Count);
        ShowUnits;
        end
      else ErrorDialog(_('Invalid search path!'));
      end;
    lp.Free; lu.Free;
    end
  else ErrorDialog(TryFormat(_('File not found: %s'),[edProject.Text]));
  end;

procedure TMainForm.btSelAllClick(Sender: TObject);
var
  i : integer;
begin
  IsSelecting:=true;
  with lvwFiles.Items do for i:=0 to Count-1 do with Item[i] do
    if ImageIndex=0 then Selected:=true;
  IsSelecting:=false;
  end;

procedure TMainForm.btSelNoneClick(Sender: TObject);
var
  i : integer;
begin
  IsSelecting:=true;
  with lvwFiles.Items do for i:=0 to Count-1 do Item[i].Selected:=false;
  IsSelecting:=false;
  end;

procedure TMainForm.bbExpandClick(Sender: TObject);
var
  i : integer;
begin
  with lvwFiles do begin
    Items.BeginUpdate;
    with Groups do begin
      BeginUpdate;
      for i:=0 to Count-1 do with Items[i] do State:=State-[lgsCollapsed];
      EndUpdate;
      end;
    Items.EndUpdate;
    end;
  end;

procedure TMainForm.bbCollapseClick(Sender: TObject);
var
  i : integer;
begin
  with lvwFiles do begin
    Items.BeginUpdate;
    with Groups do begin
      BeginUpdate;
      for i:=0 to Count-1 do with Items[i] do State:=State+[lgsCollapsed];
      EndUpdate;
      end;
    Items.EndUpdate;
    end;
  end;

end.
