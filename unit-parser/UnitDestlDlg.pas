(* Delphi Standard Dialog
   ========================

   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1 - November 2025
   last modified: November 2025
   *)

unit UnitDestlDlg;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TUnitDestDialog = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    cbDeleteAll: TCheckBox;
    Label1: TLabel;
    edDestDir: TEdit;
    rgDestOptions: TRadioGroup;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
{$IFDEF HDPI}   // scale glyphs and images for High DPI
    procedure AfterConstruction; override;
{$EndIf}
    function Execute (APos       : TPoint;
                      const ADir : string;
                      var AMode  : integer) : boolean;
  end;

var
  UnitDestDialog: TUnitDestDialog;

implementation

{$R *.DFM}

uses System.IniFiles, GnuGetText, WinUtils
  {$IFDEF ACCESSIBLE}, ShowMessageDlg{$ENDIF};

{ ------------------------------------------------------------------- }
procedure TUnitDestDialog.FormCreate(Sender: TObject);
begin
  TranslateComponent (self);
  end;

{$IFDEF HDPI}   // scale glyphs and images for High DPI
procedure TInputStringDialog.AfterConstruction;
begin
  inherited;
  if Application.Tag=0 then
    ScaleButtonGlyphs(self,PixelsPerInchOnDesign,Monitor.PixelsPerInch);
  end;
{$EndIf}

procedure TUnitDestDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
{$IFDEF ACCESSIBLE}
  if (Key=VK_F11) then begin
    with ActiveControl do if length(Hint)>0 then ShowHintInfo(Hint);
    end;
{$ENDIF}
  end;

procedure TUnitDestDialog.FormShow(Sender: TObject);
begin
  FitToScreen(Screen,self);
  end;

{ ------------------------------------------------------------------- }
function TUnitDestDialog.Execute (APos       : TPoint;
                                  const ADir : string;
                                  var AMode  : integer) : boolean;
var
  w : integer;
begin
  AdjustFormPosition(Screen,self,APos);
  edDestDir.Text:=ADir; cbDeleteAll.Checked:=false;
  rgDestOptions.ItemIndex:=AMode and 3;
  if ShowModal=mrOK then begin
    AMode:=rgDestOptions.ItemIndex;
    if cbDeleteAll.Checked then AMode:=AMode or $10;
    Result:=true;
    end
  else Result:=false;
  end;

end.
