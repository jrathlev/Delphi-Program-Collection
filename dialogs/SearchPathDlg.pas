(*  Delphi Dialog
    Zusammenstellung einer Suchpfad-Liste
    =====================================
    
   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.
    
   J. Rathlev, Okt. 2004
   last modified: July 2022
   *)
   
unit SearchPathDlg;

interface

uses  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

const
  CvUp  = 1;
  CvOn  = 2;
  DefRowCount = 21;

type
  TReplace = record
    PlaceHolder,Replacement : string;
    end;

  TReplList = array of TReplace;

  TSearchPathDialog = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    UpBtn: TSpeedButton;
    DownBtn: TSpeedButton;
    DirBtn: TSpeedButton;
    Liste: TListBox;
    ReplBtn: TBitBtn;
    PathEdit: TLabeledEdit;
    InsertBtn: TBitBtn;
    DeleteBtn: TBitBtn;
    sbClearAll: TSpeedButton;
    procedure UpBtnClick(Sender: TObject);
    procedure DownBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure InsertBtnClick(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure DirBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListeClick(Sender: TObject);
    procedure ReplBtnClick(Sender: TObject);
    procedure ListeDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure sbClearAllClick(Sender: TObject);
  private
    { Private declarations }
    APath : string;
    FReplList : TReplList;
{$IFDEF HDPI}   // scale glyphs and images for High DPI
    procedure AfterConstruction; override;
{$EndIf}
    function CheckPath (const APath : string) : boolean;
  public
    { Public declarations }
    function Execute (const Title,StdPath : string;
                      var AListe : string) : boolean; overload;
    function Execute (const Title,StdPath : string; ReplList : TReplList;
                      var AListe : string) : boolean; overload;
  end;

var
  SearchPathDialog: TSearchPathDialog;

implementation

uses System.StrUtils, ShellDirDlg, GnuGetText, WinUtils, PathUtils, MsgDialogs;

{$R *.DFM}

procedure TSearchPathDialog.FormCreate(Sender: TObject);
begin
  TranslateComponent (self,'dialogs');
  Liste.Items.Delimiter:=';'; FReplList:=nil;
  end;

{$IFDEF HDPI}   // scale glyphs and images for High DPI
procedure TSearchPathDialog.AfterConstruction;
begin
  inherited;
  if Application.Tag=0 then
    ScaleButtonGlyphs(self,PixelsPerInchOnDesign,Monitor.PixelsPerInch);
  end;
{$EndIf}

procedure TSearchPathDialog.UpBtnClick(Sender: TObject);
var
  s  : string;
begin
  with Liste do if Items.Count>1 then begin
    if ItemIndex>0 then with Items do begin
      s:=Strings[ItemIndex];
      Strings[ItemIndex]:=Strings[ItemIndex-1];
      Strings[ItemIndex-1]:=s;
      ItemIndex:=ItemIndex-1;
      end;
    end;
  PathEdit.SetFocus;
  end;

procedure TSearchPathDialog.DownBtnClick(Sender: TObject);
var
  s  : string;
begin
  with Liste do if Items.Count>1 then begin
    if ItemIndex<Items.Count-1 then with Items do begin
      s:=Strings[ItemIndex];
      Strings[ItemIndex]:=Strings[ItemIndex+1];
      Strings[ItemIndex+1]:=s;
      ItemIndex:=ItemIndex+1;
      end;
    end;
  PathEdit.SetFocus;
  end;

procedure TSearchPathDialog.DeleteBtnClick(Sender: TObject);
var
  n : integer;
begin
  with Liste do if ItemIndex>=0 then begin
    n:=ItemIndex;
    Items.Delete(ItemIndex);
    ItemIndex:=n;
    PathEdit.Text:=Items[ItemIndex];
    end;
  PathEdit.SetFocus;
  end;

procedure TSearchPathDialog.InsertBtnClick(Sender: TObject);
begin
  with LIste do if length(Trim(PathEdit.Text))>0 then begin
    ItemIndex:=Items.Add(PathEdit.Text);
    end;
  PathEdit.SetFocus;
  end;

procedure TSearchPathDialog.ReplBtnClick(Sender: TObject);
begin
  with PathEdit,Liste do if (ItemIndex>=0) and (length(Trim(Text))>0) then Items[ItemIndex]:=Text;
  PathEdit.SetFocus;
  end;

procedure TSearchPathDialog.sbClearAllClick(Sender: TObject);
begin
  if ConfirmDialog(DGetText('dialogs','Clear search path list?')) then Liste.Clear;
  end;

procedure TSearchPathDialog.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key=VK_RETURN) then InsertBtnClick(Sender);
  end;

procedure TSearchPathDialog.EditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#$0D then Key:=#0;
  end;

procedure TSearchPathDialog.DirBtnClick(Sender: TObject);
var
   s : string;
begin
  if length(PathEdit.Text)=0 then s:=APath
  else s:=GetExistingParentPath(PathEdit.Text,APath);
  if DirectoryDialog (Caption,false,true,false,APath,s) then PathEdit.Text:=s;
  end;

procedure TSearchPathDialog.ListeClick(Sender: TObject);
begin
  with Liste do if (Items.Count>0) and (ItemIndex>=0) then PathEdit.Text:=Items[ItemIndex];
  end;

function TSearchPathDialog.CheckPath (const APath : string) : boolean;
var
  i : integer;
begin
  if FReplList=nil then Result:=DirectoryExists(APath)
  else begin
    Result:=false;
    for i:=0 to High(FReplList) do with FReplList[i] do begin
      Result:=DirectoryExists(AnsiReplaceText(APath,PlaceHolder,Replacement));
      if Result then Exit;
      end;
    end;
  end;

procedure TSearchPathDialog.ListeDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  ok : boolean;
begin
  with (Control as TListBox),Canvas do begin
    ok:=CheckPath(Items[Index]);
    if odSelected in State then begin
      Brush.Color:=clHighlight;
      with Font do if ok then Color:=clHighlightText else Color:=clGrayText;
      end
    else begin
      Brush.Color:=clWindow;
      with Font do if ok then Color:=clWindowText else Color:=clGrayText;
      end;
    FillRect(Rect);
    TextOut(Rect.Left,Rect.Top,Items[Index]);
    end;
  end;

{ ------------------------------------------------------------------- }
function TSearchPathDialog.Execute (const Title,StdPath : string; ReplList : TReplList;
                      var AListe : string) : boolean;
var
  ok : boolean;
begin
  if Title='' then Caption:=Title;
  APath:=StdPath; FReplList:=ReplList;
  with Liste do begin
    Items.DelimitedText:=AListe;
    ItemIndex:=0;
    if Items.Count>0 then PathEdit.Text:=Items[0]
    else PathEdit.Text:='';
    end;
  ActiveControl:=PathEdit;
  ok:=ShowModal=mrOK;
  if ok then AListe:=Liste.Items.DelimitedText;
  Result:=ok;
  end;

function TSearchPathDialog.Execute (const Title,StdPath : string;
                              var AListe : string) : boolean;
begin
  Result:=Execute(Title,StdPath,nil,AListe);
  end;

end.
