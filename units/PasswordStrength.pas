(* Delphi 10 Unit
   Calculate password strength
   ===========================

   based on the proposal at
   https://www.delphipraxis.net/154619-passwort-staerke-ermitteln-code-und-prueflogik-4.html
   see also:
   https://passwordmeter.com/

   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1 - May 2024
   *)

unit PasswordStrength;

interface

uses UnitConsts;

type
  TPassphraseStrength = (psVeryWeak, psWeak, psGood, psStrong, psVeryStrong);

  TPassphraseInfo = record
    Length : integer;
    AlphaUC : integer;
    AlphaLC : integer;
    Number : integer;
    Symbol : integer;
    MidChar : integer;
    Requirements : integer;
    AlphasOnly : integer;
    NumbersOnly : integer;
    UnqChar : integer;
    RepChar : integer;
    RepInc : Extended;
    ConsecAlphaUC : integer;
    ConsecAlphaLC : integer;
    ConsecNumber : integer;
    ConsecSymbol : integer;
    ConsecCharType : integer;
    SeqAlpha : integer;
    SeqNumber : integer;
    SeqSymbol : integer;
    SeqChar : integer;
    ReqChar : integer;
    MultConsecCharType : integer;
    function Score : integer;
    function ScoreStr : string;
    function Strength : TPassphraseStrength;
    procedure Clear;
  end;

function PassphraseAnalyseEx (const Password : string) : TPassphraseInfo;
function PassphraseScore (const Password : string) : integer;
function PassphraseScoreStr (const Password : string) : string;
function PassphraseStrength (const Password : string) : TPassphraseStrength;

implementation

uses
  System.SysUtils, System.Math;

function StringReverse (const Str : string): string;
  var
    idx : integer;
  begin
    Result := '';
    for idx := 1 to Length (Str) do
      Result := Str[ idx ] + Result;
  end;

function PassphraseAnalyseEx (const Password : string) : TPassphraseInfo;
const
  AlphasUC = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  AlphasLC = 'abcdefghijklmnopqrstuvwxyz';
  Alphas   = 'abcdefghijklmnopqrstuvwxyz';
  Numerics = '0123456789';
  Symbols  = '!@#$%^&+-/*=?()[]{}~';
  MinLength = 8;
  MinAlphaUC = 1;
  MinAlphaLC = 1;
  MinNumber = 1;
  MinSymbol = 1;
var
  a : integer;
  TmpAlphaUC, TmpAlphaLC, TmpNumber, TmpSymbol : integer;
  b : integer;
  CharExists : Boolean;
  S : integer;
  Fwd, Rev : string;
  pwd : string;
begin
  // Initialisierung
  TmpAlphaUC := 0;
  TmpAlphaLC := 0;
  TmpNumber := 0;
  TmpSymbol := 0;

  pwd := StringReplace (Password, ' ', '', [ rfReplaceAll ]);

  Result.Clear;
  Result.Length := Length (pwd);

  // Durchsuche das Passwort nach Symbolen, Nummern, Groß- und Kleinschreibung
  for a := 1 to Length (pwd) do begin

    // Großbuchstaben
    if Pos (pwd[ a ], AlphasUC) >= 1 then
      begin
        if  (TmpAlphaUC > 0) then
          begin
            if  (TmpAlphaUC + 1 = a) then
              begin
                inc (Result.ConsecAlphaUC);
                inc (Result.ConsecCharType);
              end;
          end;
        TmpAlphaUC := a;
        inc (Result.AlphaUC);
      end

    // Kleinbuchstaben
    else if Pos (pwd[ a ], AlphasLC) >= 1 then
      begin
        if  (TmpAlphaLC > 0) then
          begin
            if  (TmpAlphaLC + 1 = a) then
              begin
                inc (Result.ConsecAlphaLC);
                inc (Result.ConsecCharType);
              end;
          end;
        TmpAlphaLC := a;
        inc (Result.AlphaLC);
      end

    // Ziffern
    else if Pos (pwd[ a ], Numerics) >= 1 then
      begin
        if  (a > 1) and  (a < Length (pwd) ) then
          inc (Result.MidChar);
        if  (TmpNumber > 0) then
          begin
            if  (TmpNumber + 1 = a) then
              begin
                inc (Result.ConsecNumber);
                inc (Result.ConsecCharType);
              end;
          end;
        TmpNumber := a;
        inc (Result.Number);
      end

    // Symbole
    else if Pos (pwd[ a ], AlphasLC + AlphasUC + Numerics) < 1 then
      begin
        if  (a > 1) and  (a < Length (pwd) ) then
          inc (Result.MidChar);
        if  (TmpSymbol > 0) then
          begin
            if  (TmpSymbol + 1 = a) then
              begin
                inc (Result.ConsecSymbol);
                inc (Result.ConsecCharType);
              end;
          end;
        TmpSymbol := a;
        inc (Result.Symbol);
      end;

    // Doppelte Zeichen prüfen
    CharExists := False;
    for b := 1 to Length (pwd) do
      if  (a <> b) and  (pwd[ a ] = pwd[ b ]) then
        begin
          CharExists := true;
          Result.RepInc := Result.RepInc +  (Length (pwd) / Abs (b - a ));
        end;
    if CharExists then
      begin
        inc (Result.RepChar);
        Result.UnqChar := Length (pwd) - Result.RepChar;
        if Result.UnqChar <> 0 then
          Result.RepInc := Ceil (Result.RepInc / Result.UnqChar )
        else
          Result.RepInc := Ceil (Result.RepInc);
      end;
    end; // for a := 1 to Length (pwd) do

  for S := 1 to Length (Alphas) - 2 do
    begin
      Fwd := Copy (Alphas, S, 3);
      Rev := StringReverse (Fwd);
      if  (Pos (Fwd, LowerCase (pwd) ) >= 1) or  (Pos (Rev, LowerCase (pwd) ) >= 1) then
        begin
          inc (Result.SeqAlpha);
          inc (Result.SeqChar);
        end;
    end;

  for S := 1 to Length (Numerics) - 2 do
    begin
      Fwd := Copy (Numerics, S, 3);
      Rev := StringReverse (Fwd);
      if  (Pos (Fwd, LowerCase (pwd) ) >= 1) or  (Pos (Rev, LowerCase (pwd) ) >= 1) then
        begin
          inc (Result.SeqNumber);
          inc (Result.SeqChar);
        end;
    end;

  for S := 1 to Length (Symbols) - 2 do
    begin
      Fwd := Copy (Symbols, S, 3);
      Rev := StringReverse (Fwd);
      if  (Pos (Fwd, LowerCase (pwd) ) >= 1) or  (Pos (Rev, LowerCase (pwd) ) >= 1) then
        begin
          inc (Result.SeqSymbol);
          inc (Result.SeqChar);
        end;
    end;

  if  (Result.AlphaLC + Result.AlphaUC > 0) and  (Result.Symbol = 0) and
     (Result.Number = 0) then
    Result.AlphasOnly := Length (pwd);

  if  (Result.AlphaLC + Result.AlphaUC = 0) and  (Result.Symbol = 0) and
     (Result.Number > 0) then
    Result.NumbersOnly := Length (pwd);

  if  (Result.Length > 0) and  (Result.Length >= MinLength) then
    inc (Result.ReqChar);
  if  (Result.AlphaUC > 0) and  (Result.AlphaUC >= MinAlphaUC) then
    inc (Result.ReqChar);
  if  (Result.AlphaLC > 0) and  (Result.AlphaLC >= MinAlphaLC) then
    inc (Result.ReqChar);
  if  (Result.Number > 0) and  (Result.Number >= MinNumber) then
    inc (Result.ReqChar);
  if  (Result.Symbol > 0) and  (Result.Symbol >= MinSymbol) then
    inc (Result.ReqChar);

  Result.Requirements := Result.ReqChar;
  end;

function PassphraseScore (const Password : string) : integer;
begin
  Result:=PassphraseAnalyseEx(Password).Score;
  end;

function PassphraseScoreStr (const Password : string) : string;
begin
  Result:=PassphraseAnalyseEx(Password).ScoreStr;
  end;

function PassphraseStrength (const Password : string) : TPassphraseStrength;
begin
  Result:=PassphraseAnalyseEx(Password).Strength;
  end;

{ TPassphraseInfo }

procedure TPassphraseInfo.Clear;
begin
  Length := 0;
  AlphaUC := 0;
  AlphaLC := 0;
  Number := 0;
  Symbol := 0;
  MidChar := 0;
  Requirements := 0;
  AlphasOnly := 0;
  NumbersOnly := 0;
  UnqChar := 0;
  RepChar := 0;
  RepInc := 0;
  ConsecAlphaUC := 0;
  ConsecAlphaLC := 0;
  ConsecNumber := 0;
  ConsecSymbol := 0;
  ConsecCharType := 0;
  SeqAlpha := 0;
  SeqNumber := 0;
  SeqSymbol := 0;
  SeqChar := 0;
  ReqChar := 0;
  MultConsecCharType := 0;
  end;

function TPassphraseInfo.Score : integer;
const
  MultLength = 4;
  MultRepChar = 1;
  MultMidChar = 2;
  MultRequirements = 2;
  MultConsecAlphaUC = 2;
  MultConsecAlphaLC = 2;
  MultConsecNumber = 2;
  MultConsecCharType = 0;
  MultConsecSymbol = 1;
  MultAlphaUC = 2;
  MultAlphaLC = 2;
  MultSeqAlpha = 3;
  MultSeqNumber = 3;
  MultSeqSymbol = 3;
  MultNumber = 4;
  MultSymbol = 6;
begin
  Result := 0;
  // Additions
  Result := Result + Length * MultLength;
  if  (AlphaUC > 0) and  (AlphaUC < Length) then
    Result := Result +  (Length - AlphaUC) * MultAlphaUC;
  if  (AlphaLC > 0) and  (AlphaLC < Length) then
    Result := Result +  (Length - AlphaLC) * MultAlphaLC;
  if  (Number > 0) and  (Number < Length) then
    Result := Result + Number * MultNumber;
  Result := Result + Symbol * MultSymbol;
  if (NumbersOnly=0) then Result := Result + MidChar * MultMidChar;   // JR
  if Requirements > 3 then
    Result := Result + Requirements * MultRequirements;
  // Deducations
  Result := Result - AlphasOnly;
  Result := Result - NumbersOnly;
  Result := Result - Trunc (RepInc);
  Result := Result - ConsecAlphaUC * MultConsecAlphaUC;
  Result := Result - ConsecAlphaLC * MultConsecAlphaLC;
  Result := Result - ConsecNumber * MultConsecNumber;
  Result := Result - SeqAlpha * MultSeqAlpha;
  Result := Result - SeqNumber * MultSeqNumber;
  Result := Result - SeqSymbol * MultSeqSymbol;

  if Result > 500 then Result := 500
  else if Result < 0 then Result := 0;
  Result:=round(100*(1-exp(-Result/100)/0.993));
  if Result < 0 then Result := 0;
  end;

function TPassphraseInfo.ScoreStr : string;
begin
  case Strength of
    psWeak :   Result := rsWeak;
    psGood :   Result := rsGood;
    psStrong : Result := rsStrong;
    psVeryStrong : Result := rsVeryStrong;
    else Result := rsVeryWeak;
    end;
  end;

function TPassphraseInfo.Strength : TPassphraseStrength;
var
  sc : integer;
begin
  sc := Score;
  if sc >= 80 then Result := psVeryStrong
  else if sc >= 65 then Result := psStrong
  else if sc >= 45 then Result := psGood
  else if sc >= 25 then Result := psWeak
  else Result := psVeryWeak;
  end;

end.
