(* Delphi program
   Show properties of all connected monitors
   =========================================

   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Calling: showreparse.exe [<directory>]

   Vers. 1 - October 2021
   last modified: Septener 2025
   *)

unit MonMain;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TMainForm = class(TForm)
    lbMon: TListBox;
    paRight: TPanel;
    bbExit: TBitBtn;
    bbPaste: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure bbExitClick(Sender: TObject);
    procedure bbPasteClick(Sender: TObject);
    procedure lbMonClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses Vcl.ClipBrd;

procedure TMainForm.FormShow(Sender: TObject);
var
  i : integer;

  procedure AddLine (const s : string);
  begin
    lbMon.Items.Add(s);
    end;

begin
  with Screen do for i:=0 to MonitorCount-1 do with Monitors[i] do begin
    AddLine('Monitor '+IntToStr(i+1)+':');
    AddLine('----------');
    if Primary then AddLine('Primary Monitor');
    AddLine(Format('Position: Top    = %5d, Left  = %5d',[Top,Left]));
    AddLine(Format('Size:     Height = %5d, Width = %5d',[Height,Width]));
    with WorkareaRect do begin
      AddLine(Format('Workarea: Top    = %5d, Left  = %5d',[Top,Left]));
      AddLine(Format('          Bottom = %5d, Right = %5d',[Bottom,Right]));
      end;
    AddLine(Format('Resolution: %u dpi',[PixelsPerinch]));
    AddLine('');
    end;
  lbMon.ItemIndex:=-1;
  end;

procedure TMainForm.lbMonClick(Sender: TObject);
begin
  lbMon.ItemIndex:=-1;
  end;

procedure TMainForm.bbPasteClick(Sender: TObject);
begin
  ClipBoard.AsText:=lbMon.Items.Text;
  end;

procedure TMainForm.bbExitClick(Sender: TObject);
begin
  Close;
  end;

end.
