(* Delphi-Unit
   collection of routines for string processing
   ============================================

   - Conversions ANSI <-> OEM (removed from StringUtils)

   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   New compilation - May 2007
   last modified: August 2025
   *)

unit OEMUtils;

interface

uses System.SysUtils;

type
  TCvTable = array [0..127] of AnsiChar;

const
  TabToANSI : TCvTable =(
    #$C7,#$FC,#$E9,#$E2,#$E4,#$E0,#$E5,#$E7,#$EA,#$EB,#$E9,#$E8,#$EF,#$EE,#$C4,#$C5,
    #$C9,#$E6,#$C6,#$F4,#$F6,#$F2,#$FB,#$F9,#$FF,#$D6,#$DC,#$A2,#$A3,#$A5,#$20,#$20,
    #$E1,#$ED,#$F3,#$FA,#$F1,#$D1,#$61,#$6F,#$BF,#$20,#$AC,#$BD,#$BC,#$A1,#$AB,#$BB,
    #$20,#$20,#$20,#$A6,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,
    #$20,#$20,#$20,#$20,#$AD,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,
    #$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,
    #$20,#$DF,#$B6,#$20,#$20,#$20,#$B5,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,
    #$20,#$B1,#$20,#$20,#$20,#$20,#$F7,#$20,#$B0,#$20,#$B7,#$20,#$B3,#$B2,#$20,#$20);
  TabToOEM : TCvTable =(
    #$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,
    #$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,
    #$20,#$AD,#$9B,#$9C,#$20,#$9D,#$B3,#$15,#$20,#$20,#$20,#$AE,#$AA,#$C4,#$20,#$20,
    #$F8,#$F1,#$FD,#$FC,#$20,#$E6,#$E3,#$20,#$20,#$20,#$20,#$AF,#$AC,#$AB,#$20,#$A8,
    #$41,#$41,#$41,#$41,#$8E,#$8F,#$92,#$80,#$45,#$90,#$45,#$45,#$49,#$49,#$49,#$49,
    #$44,#$A5,#$4F,#$4F,#$4F,#$4F,#$99,#$20,#$20,#$55,#$55,#$55,#$9A,#$59,#$20,#$E1,
    #$85,#$61,#$83,#$61,#$84,#$86,#$91,#$87,#$8A,#$82,#$88,#$89,#$8D,#$A1,#$8C,#$8B,
    #$20,#$A4,#$95,#$A2,#$93,#$6F,#$94,#$F6,#$20,#$97,#$A3,#$96,#$81,#$79,#$20,#$98);

{ ---------------------------------------------------------------- }
// Umwandeln eines DOS-Zeichens in eines Groﬂbuchstaben (auch Umlaute)
function OEMUpCase (c : AnsiChar) : AnsiChar;

// Umwandeln eines ANSI-Zeichens in eines Groﬂbuchstaben (auch Umlaute)
function ANSIUpCase (c : AnsiChar) : AnsiChar;

// Umwandeln eines DOS-Strings in Groﬂbuchstaben (auch Umlaute)
function OEMUpString (const S : AnsiString) : AnsiString;

// Umwandeln eines ANSI-Strings in Groﬂbuchstaben (auch Umlaute)
function ANSIUpString (const S : AnsiString) : AnsiString;

// Umwandeln von ISO-8859-Zeichen f¸r eine Sortierung
function ANSISortConvert (const S : string) : string;
function ANSISortUpper (const S : string) : string;

// Umwandeln eines Strings in Groﬂbuchstaben (Umlaute in AE, OE, UE) zu Sortierzwecken
function OEMUpSort (const S : AnsiString) : AnsiString;

// Umwandeln eines OEM-Strings nach ANSI
function StrToAnsi (const s : AnsiString) : AnsiString;

// Umwandeln eines ANSI-Strings nach OEM
function StrToOEM (const s : AnsiString) : AnsiString;

// Umwandeln eines Zeichens in Kleinbuchstaben  (fehlt in Unit System)
function LowCase(Ch: WideChar): WideChar;

implementation

uses System.StrUtils;

{ ---------------------------------------------------------------- }
(* Umwandeln eines Zeichens in eines Groﬂbuchstaben (auch Umlaute)
   OEM-Zeichen *)
function OEMUpCase (c : AnsiChar) : AnsiChar;
begin
  if c<#127 then Result:=upcase(c)
  else begin
    case c of
    'Ñ' : Result:='é';
    'î' : Result:='ô';
    'Å' : Result:='ö';
    '·' : Result:='S';
      else Result:=c;
      end;
    end;
  end;

{ ---------------------------------------------------------------- }
(* Umwandeln eines Zeichens in eines Groﬂbuchstaben (auch Umlaute)
   ANSI-Zeichen *)
function ANSIUpCase (c : AnsiChar) : AnsiChar;
begin
  if c<#224 then Result:=upcase(c)
  else Result:=AnsiChar(ord(c)-32);
{  begin
    case c of
    '‰' : Result:='ƒ';
    'ˆ' : Result:='÷';
    '¸' : Result:='‹';
    'ﬂ' : Result:='S';
      else Result:=c;
      end;
    end;          }
  end;

{ ---------------------------------------------------------------- }
(* Umwandeln eines Strings in Groﬂbuchstaben (auch Umlaute) *)
function OEMUpString (const S : AnsiString) : AnsiString;
var
  i  : integer;
  ns : AnsiString;
  c  : AnsiChar;
begin
  ns:='';
  for i:=1 to length(s) do begin
    c:=s[i];
    if c<#127 then ns:=ns+upcase(c)
    else begin
      case c of
      'Ñ' : ns:=ns+'é';
      'î' : ns:=ns+'ô';
      'Å' : ns:=ns+'ö';
      '·' : ns:=ns+'SS';
        else ns:=ns+c;
        end;
      end;
    end;
  OEMUpString:=ns;
  end;

{ ---------------------------------------------------------------- }
(* Umwandeln eines ANSI-Strings in Groﬂbuchstaben (auch Umlaute) *)
function ANSIUpString (const S : AnsiString) : AnsiString;
var
  i  : integer;
  ns : AnsiString;
  c  : AnsiChar;
begin
  ns:='';
  for i:=1 to length(s) do begin
    c:=s[i];
    if c<#127 then ns:=ns+upcase(c)
    else begin
      case c of
      '‰' : ns:=ns+'ƒ';
      'ˆ' : ns:=ns+'÷';
      '¸' : ns:=ns+'‹';
      'ﬂ' : ns:=ns+'SS';
        else ns:=ns+c;
        end;
      end;
    end;
  ANSIUpString:=ns;
  end;

{ ---------------------------------------------------------------- }
(* Umwandeln von ISO-8859-Zeichen f¸r eine Sortierung *)
function ANSISortConvert (const S : string) : string;
var
  i  : integer;
  c  : char;
begin
  Result:='';
  for i:=1 to length(s) do begin
    c:=s[i];
    if c<#127 then Result:=Result+c
    else begin
      case c of
      'ƒ' : Result:=Result+'Ae';
      '÷' : Result:=Result+'Oe';
      '‹' : Result:=Result+'Ue';
      '‰' : Result:=Result+'ae';
      'ˆ' : Result:=Result+'oe';
      '¸' : Result:=Result+'ue';
      'ﬂ' : Result:=Result+'ss';
      #$C6 : Result:=Result+#$5B; // nach 'Z'  - d‰nisch
      #$D8 : Result:=Result+#$5C; // nach 'Z'
      #$C5 : Result:=Result+#$5D; // nach 'Z'
      #$E6 : Result:=Result+#$7B; // nach 'z'
      #$F8 : Result:=Result+#$7C; // nach 'z'
      #$E5 : Result:=Result+#$7D; // nach 'z'
      #$C0..#$C3 : Result:=Result+'A';
      #$C7 : Result:=Result+'C';
      #$C8..#$CB : Result:=Result+'E';
      #$CC..#$CF : Result:=Result+'I';
      #$D0 : Result:=Result+'D';
      #$D1 : Result:=Result+'N';
      #$D2..#$D5 : Result:=Result+'O';
      #$D9..#$DB :  Result:=Result+'U';
      #$DD : Result:=Result+'Y';
      #$E0..#$E3 : Result:=Result+'a';
      #$E7 : Result:=Result+'c';
      #$E8..#$EB : Result:=Result+'e';
      #$EC..#$EF : Result:=Result+'i';
      #$F0 : Result:=Result+'d';
      #$F1 : Result:=Result+'n';
      #$F2..#$F5 : Result:=Result+'o';
      #$F9..#$FB :  Result:=Result+'u';
      #$FD,#$FF : Result:=Result+'y';
      else Result:=Result+c;
        end;
      end;
    end;
  end;

(* Umwandeln von ISO-8859-Zeichen f¸r eine Sortierung mit Groﬂbuchstaben*)
function ANSISortUpper (const S : string) : string;
begin
  Result:=AnsiUpperCase(ANSISortConvert(s));
  end;

{ ---------------------------------------------------------------- }
(* Umwandeln eines Strings in Groﬂbuchstaben (Umlaute in AE, OE, UE)
   zu Sortierzwecken *)
function OEMUpSort (const S : AnsiString) : AnsiString;
var
  i  : integer;
  ns : AnsiString;
  c  : AnsiChar;
begin
  ns:='';
  for i:=1 to length(s) do begin
    c:=s[i];
    if c<#127 then ns:=ns+upcase(c)
    else begin
      case c of
      'é','Ñ' : ns:=ns+'AE';
      'ô','î' : ns:=ns+'OE';
      'ö','Å' : ns:=ns+'UE';
      '·'     : ns:=ns+'SS';
        else ns:=ns+c;
        end;
      end;
    end;
  OEMUpSort:=ns;
  end;

{ ---------------------------------------------------------------- }
(* Umwandeln eines OEM-Strings nach ANSI *)
function StrToAnsi (const s : AnsiString) : AnsiString;
var
  i  : integer;
begin
  Result:=s;
  for i:=1 to length(Result) do begin
    if Result[i]>=#128 then Result[i]:=TabToANSI[ord(Result[i])-128]
    else if Result[i]=#$15 then Result[i]:=#$A7;
    end;
  end;

{ ---------------------------------------------------------------- }
(* Umwandeln eines ANSI-Strings nach OEM *)
function StrToOEM (const s : AnsiString) : AnsiString;
var
  i  : integer;
begin
  Result:=s;
  for i:=1 to length(Result) do begin
    if Result[i]>=#128 then Result[i]:=TabToOEM[ord(Result[i])-128];
    end;
  end;

{ ---------------------------------------------------------------- }
// Umwandeln eines Zeichens in Kleinbuchstaben  (fehlt in Unit System)
function LowCase(Ch: WideChar): WideChar;
begin
  Result:=Ch;
  if (Ch>='A') and (Ch<='Z') then inc(Result,Ord('a') - Ord('A'));
  end;

end.

