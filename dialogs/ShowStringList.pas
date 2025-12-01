(* Delphi Dialog
   Show string list
   ================
   
   © J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de))

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.
   
   Vers. 1 - December 2021
   last modified: July 2025
   *)

unit ShowStringList;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TStatusListPos = (spCenter,spTopLeft,spTopRight,spBottomLeft,spBottomRight);

  TShowStringListDialog = class(TForm)
    CancelBtn: TBitBtn;
    laDesc: TLabel;
    lbStrings: TListBox;
    paBottom: TPanel;
    paTop: TPanel;
    laStatus: TLabel;
    paCenter: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    bh : integer;
{$IFDEF HDPI}   // scale glyphs and images for High DPI
    procedure AfterConstruction; override;
{$EndIf}
  public
    { Public declarations }
    procedure Execute (APos : TPoint; const Titel,Desc : string; StrList : TStringList); overload;
    procedure Execute (APos : TPoint; const Titel,Desc,Status : string; StrList : TStringList); overload;
    procedure ShowList (APos : TStatusListPos; const Titel,Desc : string);
    procedure AddListItem (const s : string);
    procedure CloseList;
  end;

procedure ShowStatusStrings (APos : TPoint; const Titel,Desc,Status : string; StrList : TStringList);
procedure ShowStatusList (APos :TStatusListPos; const Titel,Desc : string);
procedure AddStatusListItem (const s : string);
procedure CloseStatusList;

var
  ShowStringListDialog: TShowStringListDialog;

{ ---------------------------------------------------------------- }
implementation

{$R *.DFM}

uses
  WinUtils, GnuGetText;

{ ---------------------------------------------------------------- }
procedure TShowStringListDialog.FormCreate(Sender: TObject);
begin
  TranslateComponent (self,'dialogs');
  bh:=paBottom.Height;
  end;

procedure TShowStringListDialog.FormShow(Sender: TObject);
begin
  FitToScreen(Screen,self);
  end;

{$IFDEF HDPI}   // scale glyphs and images for High DPI
procedure TShowStringListDialog.AfterConstruction;
begin
  inherited;
  if Application.Tag=0 then begin
    ScaleButtonGlyphs(self,PixelsPerInchOnDesign,Monitor.PixelsPerInch);
    end;
  end;
{$EndIf}

{ ---------------------------------------------------------------- }
procedure TShowStringListDialog.Execute (APos : TPoint; const Titel,Desc,Status : string; StrList : TStringList);
begin
  AdjustFormPosition(Screen,self,APos);
  Caption:=Titel;
  laDesc.Caption:=Desc;
  laStatus.Caption:=Status;
  lbStrings.Items.Assign(StrList);
  paBottom.Visible:=true;
//  paBottom.Height:=bh;
  ShowModal;
  end;

procedure TShowStringListDialog.Execute (APos : TPoint; const Titel,Desc : string; StrList : TStringList);
begin
  Execute(APos,Titel,Desc,'',StrList);
  end;

procedure TShowStringListDialog.ShowList (APos : TStatusListPos; const Titel,Desc : string);
begin
  Caption:=Titel;
  laDesc.Caption:=Desc;
  lbStrings.Clear;
  paBottom.Visible:=false; // .Height:=0;
  Position:=poDesigned;
  case APos of
  spTopLeft    : begin
                 Left:=5; Top:=5;
                 end;
  spTopRight   : begin
                 Left:=Monitor.WorkareaRect.Width-Width-5; Top:=5;
                 end;
  spBottomLeft : begin
                 Left:=5; Top:=Monitor.WorkareaRect.Height-Height-5;
                 end;
  spBottomRight: begin
                 Left:=Monitor.WorkareaRect.Width-Width-5; Top:=Monitor.WorkareaRect.Height-Height-5;
                 end;
  else Position:=poScreenCenter
    end;
  Show;
  end;

procedure TShowStringListDialog.AddListItem (const s : string);
begin
  with lbStrings do Items.Add(s);
  end;

procedure TShowStringListDialog.CloseList;
begin
  Close;
  end;

{ ---------------------------------------------------------------- }
procedure ShowStatusStrings (APos : TPoint; const Titel,Desc,Status : string; StrList : TStringList);
begin
  if not assigned(ShowStringListDialog) then ShowStringListDialog:=TShowStringListDialog.Create(Application);
  ShowStringListDialog.Execute(APos,Titel,Desc,Status,StrList);
  end;

procedure ShowStatusList (APos : TStatusListPos; const Titel,Desc : string);
begin
  if not assigned(ShowStringListDialog) then ShowStringListDialog:=TShowStringListDialog.Create(Application);
  ShowStringListDialog.ShowList(APos,Titel,Desc);
  end;

procedure AddStatusListItem (const s : string);
begin
  if assigned(ShowStringListDialog) then ShowStringListDialog.AddListItem(s);
  end;

procedure CloseStatusList;
begin
  if assigned(ShowStringListDialog) then ShowStringListDialog.CloseList;
  end;

end.
