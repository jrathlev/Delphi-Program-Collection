(* Delphi-Unit
   verschiedene Unterroutinen für MP3-Tags
   =======================================

   © J. Rathlev, D-24222 Schwentinental, (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1 - Nov. 2007
   *)

unit Mp3Utils;

interface

uses System.Classes, System.SysUtils, NumberUtils, WinUtils;

const
// refer to http://id3.org/Developer%20Information for detailef information
  Id3v1Misc = 'Misc';
  Id3v1Count = 147;
  Id3v1Genres : array[0..Id3v1Count] of AnsiString =
    ('Blues','Classic Rock','Country','Dance','Disco','Funk','Grunge',
    'Hip- Hop','Jazz','Metal','New Age','Oldies','Other','Pop','R&B', 
    'Rap','Reggae','Rock','Techno','Industrial','Alternative','Ska', 
    'Death Metal','Pranks','Soundtrack','Euro-Techno','Ambient', 
    'Trip-Hop','Vocal','Jazz+Funk','Fusion','Trance','Classical', 
    'Instrumental','Acid','House','Game','Sound Clip','Gospel','Noise', 
    'Alternative Rock','Bass','Soul','Punk','Space','Meditative','Instrumental Pop', 
    'Instrumental Rock','Ethnic','Gothic','Darkwave','Techno-Industrial','Electronic', 
    'Pop-Folk','Eurodance','Dream','Southern Rock','Comedy','Cult','Gangsta', 
    'Top 40','Christian Rap','Pop/Funk','Jungle','Native US','Cabaret','New Wave', 
    'Psychadelic','Rave','Showtunes','Trailer','Lo-Fi','Tribal','Acid Punk', 
    'Acid Jazz','Polka','Retro','Musical','Rock & Roll','Hard Rock','Folk', 
    'Folk-Rock','National Folk','Swing','Fast Fusion','Bebob','Latin','Revival',
    'Celtic','Bluegrass','Avantgarde','Gothic Rock','Progressive Rock',
    'Psychedelic Rock','Symphonic Rock','Slow Rock','Big Band','Chorus', 
    'Easy Listening','Acoustic','Humour','Speech','Chanson','Opera',
    'Chamber Music','Sonata','Symphony','Booty Bass','Primus','Porn Groove', 
    'Satire','Slow Jam','Club','Tango','Samba','Folklore','Ballad', 
    'Power Ballad','Rhytmic Soul','Freestyle','Duet','Punk Rock','Drum Solo', 
    'Acapella','Euro-House','Dance Hall','Goa','Drum & Bass','Club-House', 
    'Hardcore','Terror','Indie','BritPop','Negerpunk','Polsk Punk','Beat', 
    'Christian Gangsta','Heavy Metal','Black Metal','Crossover','Contemporary C',
    'Christian Rock','Merengue','Salsa','Thrash Metal','Anime','JPop','SynthPop');

  { MPEG version indexes }
  MPEG_VERSION_UNKNOWN = 0; { Unknown     }
  MPEG_VERSION_1 = 1;       { Version 1   }
  MPEG_VERSION_2 = 2;       { Version 2   }
  MPEG_VERSION_25 = 3;      { Version 2.5 }

  { Description of MPEG version index }
  MPEG_VERSIONS : array[0..3] of string = ('Unknown', '1.0', '2.0', '2.5');

  { Channel mode (number of channels) in MPEG file }
  MPEG_MD_STEREO = 0;            { Stereo }
  MPEG_MD_JOINT_STEREO = 1;      { Stereo }
  MPEG_MD_DUAL_CHANNEL = 2;      { Stereo }
  MPEG_MD_MONO = 3;              { Mono   }

  { Description of number of channels }
  MPEG_MODES : array[0..3] of AnsiString = ('Stereo', 'Joint-Stereo',
                                        'Dual-Channel', 'Single-Channel');

  { Description of layer value }
  MPEG_LAYERS : array[0..3] of AnsiString = ('Unknown', 'I', 'II', 'III');

  { Sampling rates table.
    You can read mpeg sampling frequency as
    MPEG_SAMPLE_RATES[mpeg_version_index][samplerate_index]  }
  MPEG_SAMPLE_RATES : array[1..3] of array[0..3] of word =
     { Version 1   }
    ((44100, 48000, 32000, 0),
     { Version 2   }
     (22050, 24000, 16000, 0),
     { Version 2.5 }
     (11025, 12000, 8000, 0));

  { Predefined bitrate table.
    Right bitrate is MPEG_BIT_RATES[mpeg_version_index][layer][bitrate_index] }
  MPEG_BIT_RATES : array[1..3] of array[1..3] of array[0..15] of word =
       { Version 1, Layer I     }
     (((0,32,64,96,128,160,192,224,256,288,320,352,384,416,448,0),
       { Version 1, Layer II    }
       (0,32,48,56, 64, 80, 96,112,128,160,192,224,256,320,384,0),
       { Version 1, Layer III   }
       (0,32,40,48, 56, 64, 80, 96,112,128,160,192,224,256,320,0)),
       { Version 2, Layer I     }
      ((0,32,48, 56, 64, 80, 96,112,128,144,160,176,192,224,256,0),
       { Version 2, Layer II    }
       (0, 8,16,24, 32, 40, 48, 56, 64, 80, 96, 112,128,144,160,0),
       { Version 2, Layer III   }
       (0, 8,16,24, 32, 40, 48, 56, 64, 80, 96, 112,128,144,160,0)),
       { Version 2.5, Layer I   }
      ((0,32,48, 56, 64, 80, 96,112,128,144,160,176,192,224,256,0),
       { Version 2.5, Layer II  }
       (0, 8,16,24, 32, 40, 48, 56, 64, 80, 96, 112,128,144,160,0),
       { Version 2.5, Layer III }
       (0, 8,16,24, 32, 40, 48, 56, 64, 80, 96, 112,128,144,160,0)));

  { Xing VBR header flags }
  XH_FRAMES_FLAG = 1;
  XH_BYTES_FLAG = 2;
  XH_TOC_FLAG = 4;
  XH_VBR_SCALE_FLAG = 8;

  XingSize = 116;
  TagSize = 128;

  defFileMaxRead = 100000;  // read mp3 file to this position for detection

  // Id3V2-Header
  Id3V2ID = 'ID3';   // ID

  IdV3Count = 13;
  IdV3IdLen = 4;
  Id3V2Alb = 'TALB'; // Album
  Id3V2Art = 'TPE1'; // Artist
  Id3V2Gen = 'TCON'; // Genre
  Id3V2Tit = 'TIT2'; // Title
  Id3V2Yer = 'TYER'; // Year
  Id3V2Trk = 'TRCK'; // Track
  Id3V2Ops = 'TIT1'; // Opus
  Id3V2Com = 'TCOM'; // Composer-ID
  Id3V2Txt = 'TEXT'; // Text-Writer-ID
  Id3V2Cmt = 'COMM'; // Comment
  Id3V2Tim = 'TIME'; // Recording time
  Id3V2TLn = 'TLEN'; // Length of file in ms
  Id3V2Pic = 'APIC'; // Embedded picture - not supported

  Id3V2IDs : array [1..IdV3Count] of String[IdV3IdLen] =
     (Id3V2Alb,Id3V2Art,Id3V2Gen,Id3V2Tit,Id3V2Yer,Id3V2Trk,Id3V2Ops,Id3V2Com,
      Id3V2Txt,Id3V2Cmt,Id3V2Tim,Id3V2TLn,Id3V2Pic);

type
  TMp3Info = record
    Titel,Interpret,Contents,
    Album,Jahr,Kommentar,
    Werk,Komponist,Texter  : string;
    Track,Genre,Dauer      : word;
    Unicode                : boolean;
    end;

  TId3V2Header = packed record
    ID          : array [0..2] of AnsiChar;
    Vers1,Vers2,
    Flags        : byte;
    Size         : TLongWord;
    end;

  TMP3Tag = packed record
    Header  : array[1..3] of AnsiChar;      { If tag exists this must be 'TAG' }
    Title   : array[1..30] of AnsiChar;     { Title data (PChar) }
    Artist  : array[1..30] of AnsiChar;     { Artist data (PChar) }
    Album   : array[1..30] of AnsiChar;     { Album data (PChar) }
    Year    : array[1..4] of AnsiChar;      { Date data }
    Comment : array[1..30] of AnsiChar;     { Comment data (PChar) }
    Genre   : Byte;                     { Genre data }
    end;

  TMp3Data = record
    ValidTag         : boolean;
    Title,
    Artist,Album,
    Year,Comment     : AnsiString;
    Genre,Track,
    Duration         : word;
    Version          : byte;      { MPEG audio version index (1 - Version 1,
                                   2 - Version 2,  3 - Version 2.5,
                                   0 - unknown }
    Layer            : byte;      { Layer (1, 2, 3, 0 - unknown) }
    SampleRate       : cardinal;  { Sampling rate in Hz}
    BitRate          : integer;   { Bit Rate }
    BPM              : word;      { bits per minute - for future use }
    Mode             : byte;      { Number of channels (0 - Stereo,
                                   1 - Joint-Stereo, 2 - Dual-channel,
                                   3 - Single-Channel) }
    Copyright        : boolean;    { Copyrighted? }
    Original         : boolean;    { Original? }
    ErrorProtection  : boolean;    { Error protected? }
    Padding          : boolean;    { If frame is padded }
    FrameLength      : word;       { total frame size including CRC }
    FileLength       : cardinal;
    end;

  { Xing VBR Header data structure }
  TXHeadData = record
    flags    : cardinal;     { from Xing header data }
    frames   : cardinal;     { total bit stream frames from Xing header data }
    bytes    : cardinal;     { total bit stream bytes from Xing header data }
    vbrscale : integer;      { encoded vbr scale from Xing header data }
    end;

  TMp3Stream = class (TFileStream)
    Filename    : string;
    FData       : TMp3Data;
    FValid      : boolean;
    FirstFrame  : cardinal;
    FileMaxRead : cardinal;
  private
    procedure ResetData;
    function ReadData : boolean;
  public
    constructor Create (Mp3Name : string; ReadOnly : boolean);
    function ReadIdV2Tag(var Mp3Info : TMp3Info; var HeadLen : cardinal) : boolean;
    property Valid : boolean read FValid;
    property Data : TMp3Data read FData;
    function WriteTag (const Mp3Info : TMp3Info) : boolean;
    end;

procedure ClearMp3Info (var Mp3Info : TMp3Info);

function GetMp3Info (const Mp3Name : string;
                     var Mp3Info   : TMp3Info) : boolean;

function SetMp3Info (const Mp3Name : string;
                     const Mp3Info : TMp3Info) : boolean;
                     
implementation

uses StringUtils;

function BigEndianToCardinal (const Buffer : array of byte; i : cardinal) : cardinal;
var
  k : TLongWord;
begin
  with k do begin
    HiH:=Buffer[i]; HiL:=Buffer[i+1];
    LoH:=Buffer[i+2]; LoL:=Buffer[i+3];
    end;
  Result:=k.LongWord;
  end;

procedure CardinalToBigEndian (var Buffer : array of byte; i,Value : cardinal);
begin
  with TLongWord(Value) do begin
    Buffer[i]:=HiH; Buffer[i+1]:=HiL;
    Buffer[i+2]:=LoH; Buffer[i+3]:=LoL;
    end;
  end;

function Unsynch (Value : cardinal) : cardinal;
begin
//  with TLongWord(Value) do Result:=HiH shl 21 + HiL shl 14 + LoH shl 7 + LoL;
  Result:=(Value and $7F000000) shr 3 + (Value and $7F0000) shr 2
     + (Value and $7F00) shr 1 + (Value and $7F);
  end;

procedure ClearMp3Info (var Mp3Info : TMp3Info);
begin
  with Mp3Info do begin
    Titel:=''; Interpret:=''; Contents:='';
    Album:=''; Jahr:=''; Kommentar:='';
    Werk:=''; Komponist:=''; Texter:='';
    Track:=0; Genre:=255; Dauer:=0;
    UniCode:=false;
    end;
  end;

{------------------------------------------------------------------- }
constructor TMp3Stream.Create (Mp3Name : string; ReadOnly : boolean);
var
  Mode : word;
begin
  if ReadOnly then Mode:=fmOpenRead else Mode:=fmOpenReadWrite;
  inherited Create (Mp3Name,Mode+fmShareDenyNone);
  Filename:=Mp3Name;
  FileMaxRead:=defFileMaxRead;
  FValid:=ReadData;
  end;

procedure TMp3Stream.ResetData;
begin
  with FData do begin
    ValidTag:=false;
    Title:='';
    Artist:='';
    Year:='';
    Comment:='';
    Genre:=$FF;
    Track:=0;
    Duration:=0;
    SampleRate:=0;
    BitRate:=0;
    end;
  end;

function TMp3Stream.ReadData : boolean;
var
  mp3hdr     : TLongWord;
  V2Tag      : TId3V2Header;
  Tag        : TMP3Tag;
  n,InfoLen,
  FirstFrame,
  Offset     : integer;
  XingHeader : TXHeadData;
  XingData   : array[0..XingSize-1] of byte;
  NoXing     : boolean;
  c          : AnsiChar;

  function CalcFrameLength (Layer,SampleRate,BitRate : cardinal; Padding : Boolean) : cardinal;
  begin
    If SampleRate>0 then begin
      if Layer = 1 then Result:=Trunc(12*BitRate*1000/SampleRate+(cardinal(Padding)*4))
      else Result:=Trunc(144*BitRate*1000/SampleRate+cardinal(Padding))
      end
    else Result := 0;
  end;

  function ValidHeader (const Mp3Data : TMp3Data) : boolean;
  begin
  with Mp3Data do Result:=(FileLength>5) and (Version>0) and (Layer>0)
             and (BitRate>0) and (SampleRate>0);
    end;

 { Decode MPEG Frame Header and store data to TMp3Data fields.
      Return True if header seems valid }
  function DecodeHeader (Mp3Header  : TLongWord;
                         var Mp3Data : TMp3Data) : Boolean;
  var
    BitrateIndex : byte;
    VersionIndex : byte;

  begin
    with Mp3Data do begin
      Version:=0; Layer:=0;
      SampleRate:=0; Mode:=0;
      Copyright:=False;
      Original:=False;
      ErrorProtection:=False;
      Padding:=False;
      BitRate:=0;
      FrameLength:=0;
      end;
    if (Mp3Header.Lo and $e0ff) = $e0ff then begin
      VersionIndex:=(Mp3Header.LoH shr 3) and $3;
      with Mp3Data do case VersionIndex of
        0 : Version:=MPEG_VERSION_25;      { Version 2.5 }
        1 : Version:=MPEG_VERSION_UNKNOWN; { Unknown }
        2 : Version:=MPEG_VERSION_2;       { Version 2 }
        3 : Version:=MPEG_VERSION_1;       { Version 1 }
      end;
      { if Version is known, read other data }
      with Mp3Data do if Version<>MPEG_VERSION_UNKNOWN then begin
        Layer:=4-((Mp3Header.LoH shr 1) and $3);
        If (Layer>3) then Layer:=0;
        ErrorProtection:=(Mp3Header.LoH and $1)=1;
        BitrateIndex:=((Mp3Header.HiL shr 4) and $F);
        SampleRate:=MPEG_SAMPLE_RATES[Version][((Mp3Header.HiL shr 2) and $3)];
        Copyright:=((Mp3Header.HiH shr 3) and $1) = 1;
        Original:=((Mp3Header.HiH shr 2) and $1)=1;
        Mode:=((Mp3Header.HiH shr 6) and $3);
        Padding:=((Mp3Header.HiL shr 1) and $1)=1;
        BitRate:=MPEG_BIT_RATES[Version][Layer][BitrateIndex];
        end;
      Result:=ValidHeader(Mp3Data);
      end
    else Result:=False;
    end;

begin
  ResetData;
  FData.FileLength:=Size;
  Result:=false;
  FirstFrame:=0;
  NoXing:=true;
  if Size>5 then begin
//    repeat
      // Check if ID3 tag version 2 found at beginning
      Read(V2Tag,sizeof(TId3V2Header));
      if V2Tag.ID=Id3V2ID then begin     // overread
        n:=UnSynch(BigEndianToCardinal(V2Tag.Size.Bytes,0));
        if V2Tag.Flags and $10 <>0 then inc(n,10);  // footre present
        Seek(n,soCurrent);               // overread
        end
      else Seek(0,soFromBeginning);
      { read MPEG header from file }
      Read (mp3hdr,4);
      while (not DecodeHeader(mp3hdr,FData)) and (Position<Size) and
            (Position<=FileMaxRead) do begin
        { if mpeg header is not at the begining of the file, search file
          to find proper frame sync. This block can be speed up by reading
          blocks of bytes instead reading single byte from file }
        with mp3hdr do LongWord:=LongWord shr 8;
        Read (mp3hdr.HiH,1);
        end;
      FirstFrame:=Position-4;
      with FData do n:=Size-FirstFrame-FrameLength+(2*Byte(ErrorProtection));
      if (not ValidHeader(FData)) or (n<=0) then begin
        ResetData;
        FData.FileLength:=Size;
        end
      else begin
        { Ok, one header is found, but that is not good proof that file realy
          is MPEG Audio. But, if we look for the next header which must be
          FrameLength bytes after first one, we may be very sure file is
          valid. }
        Position:=FirstFrame+FData.FrameLength;
        Read (mp3hdr,4);
        if not DecodeHeader (mp3hdr,FData) then begin
          { well, next header is not valid. this is not MPEG audio file }
          ResetData;
          Position:=FirstFrame+1;
          end
        else begin
          { BINGO!!! This really is Mp3 audio file so we may proceed }
          Result:=true;
          InfoLen:=FirstFrame;
          { read TAG if it exists }
          if Size>TagSize then begin
            Seek(-TagSize,soFromEnd);
            Read(Tag,TagSize);
            with FData do if tag.header='TAG' then begin
              ValidTag:=true;
              Title:=TrimRight(Tag.Title);
              Artist:=TrimRight(Tag.Artist);
              Album:=TrimRight(Tag.Album);
              Year:=TrimRight(Tag.Year);
              Comment:=TrimRight (Tag.Comment);
              Genre:=Tag.Genre;
              c:=Tag.Comment[30];
              if c=#32 then Track:=0 else Track:=Ord(c);
              InfoLen:=InfoLen+TagSize;
              end
            else Title:=ExtractFileName(FileName);
            end;
          { check for Xing Variable BitRate info }
          with FData do if (Version=1) then begin
            if Mode<>3 then Offset:=32+4
            else Offset:=17+4;
            end
          else begin
            if Mode<>3 then Offset:=17+4
            else Offset:=9+4;
            end;
          Position:=FirstFrame+Offset;
          Read (mp3hdr,4);
          with mp3hdr do if (LoL=Ord('X')) and (LoH=Ord('i')) and
             (HiL=Ord('n')) and (HiH=Ord('g')) then begin
            FData.Bitrate:=-1;
            InfoLen:=InfoLen+Offset+4+XingSize;
            Read (XingData,XingSize);
            with XingHeader do begin
              n:=0;
              Flags:=BigEndianToCardinal(XingData,n);
              inc(n,4);
              if (Flags and XH_FRAMES_FLAG)<>0 then begin
                frames:=BigEndianToCardinal(XingData,n);
                inc(n,4);
                end
              else frames:=0;
              if (Flags and XH_BYTES_FLAG)<>0 then begin
                bytes:=BigEndianToCardinal(XingData,n);
                inc(n,4);
                end
              else bytes:=0;
              if (Flags and XH_TOC_FLAG)<>0 then inc(n,100);
              if (Flags and XH_VBR_SCALE_FLAG)<>0 then
                vbrscale:=BigEndianToCardinal(XingData,n)
              else XingHeader.vbrscale:=0;
              with FData do if Frames>0 then begin
                Duration:=Round((1152/samplerate)*frames);
                FrameLength:=(FileLength-InfoLen) div frames;
                NoXing:=false;
                end;
              end;
            end;
          if NoXing then with FData do begin
            if BitRate=0 then Duration:=0
            else Duration:=((FileLength-InfoLen)*8) div (longint(Bitrate)*1000);
            FrameLength:=CalcFrameLength(Layer,SampleRate,BitRate,Padding);
            end;
          end;
        end;
//      until ValidHeader(FData) or (Position>=Size) or (Position>FileMaxRead);
    end;
  end;

function TMp3Stream.ReadIdV2Tag(var Mp3Info : TMp3Info; var HeadLen : cardinal) : boolean;
var
  V2Tag      : TId3V2Header;
  TagID      : string[IdV3IdLen];
  i,j        : integer;
  k,n        : cardinal;
  spos       : int64;
  s          : String;
  sa         : AnsiString;
  tbuf       : array of AnsiChar;
  buf        : array [0..5] of byte;
  b          : AnsiChar;
begin
  Result:=false;
  // Check if ID3 tag version 2 found
  Seek(0,soFromBeginning);
  Read(V2Tag,sizeof(TId3V2Header));
  if V2Tag.ID=Id3V2ID then begin
    HeadLen:=UnSynch(BigEndianToCardinal(V2Tag.Size.Bytes,0));
    spos:=Position;
    k:=0; TagID[0]:=chr(IdV3IdLen);
    repeat  // read frames
      Read(TagID[1],IdV3IdLen);
      if (TagId[1]<'A') or (TagId[1]>'W') then Break;  // no legal tag
      i:=1;
      while (i<=IdV3Count) and (TagID<>Id3V2IDs[i]) do inc(i);
      if i<=IdV3Count then begin
        inc(k,IdV3IdLen);
        Read(buf[0],6);
        n:=BigEndianToCardinal(buf,0);  // length of tag
        if n>0 then begin
          inc(k,n+6);
          Read(buf[0],1);  // Unicode
          dec(n);
          SetLength(tbuf,n);
          Read(TBuf[0],n);
          if buf[0]=1 then begin   // Unicode
            Mp3Info.Unicode:=true;
            n:=n div 2;
            if tbuf[0]=#$FE then begin       // exchange bytes
              for j:=1 to n-1 do begin
                b:=tbuf[2*j];
                tbuf[2*j]:=tbuf[2*j+1];
                tbuf[2*j+1]:=b;
                end;
              end;
            SetLength(s,n-1);
            StrLCopy(PChar(s),PChar(@tbuf[2]),n-1);
            s:=DelCtrlChars(s);
            end
          else begin   // ISO-8859-1
            for j:=0 to n-1 do if tbuf[j]=#0 then tbuf[j]:=' ';
            SetLength(sa,n+1);
            StrLCopy(PAnsiChar(sa),PAnsiChar(@tbuf[0]),n);
            s:=Trim(sa);
            end;
          if length(s)>0 then with Mp3Info do case i of
          1 : Album:=s;
          2 : Interpret:=s;
          3 : begin           // Genre
              Contents:=s;
              if s[1]='(' then begin
                Delete(s,1,1);
                Genre:=ReadNxtInt(s,')',254)
                end
              else if Genre=255 then Genre:=254;
              end;
          4 : Titel:=s;
          5 : Jahr:=s;
          6 : Track:=ReadNxtInt(s,'/',0);
          7 : Werk:=s;
          8 : Komponist:=s;
          9 : Texter:=s;
          10 : Kommentar:=s;
          11 : Dauer:=60*(10*(ord(s[1])-48)+(ord(s[2])-48))+10*(ord(s[3])-48)+(ord(s[4])-48);
          12 : Dauer:=ReadNxtInt(s,' ',0) div 1000;
            end;
          end;
        end
      else begin        // unsupported tag
        inc(k,IdV3IdLen);
        Read(buf[0],6);
        n:=BigEndianToCardinal(buf,0);  // length of tag
        if n>0 then begin
          SetLength(tbuf,n);
          Read(TBuf[0],n);
          end;
        inc(k,n+6);
        end;
      until k>=HeadLen;
    Position:=spos;    // back to begin of tags
    Result:=true;
    tbuf:=nil;
    end;
  end;

function TMp3Stream.WriteTag (const Mp3Info : TMp3Info) : boolean;
var
  Tag        : TMP3Tag;
  V2Hd       : array of byte;
  HdLen,k    : cardinal;
  Mp3V1Info,
  Mp3V2Info  : TMp3Info;
  s          : AnsiString;

  procedure SetTagValue (var TagValue : array of AnsiChar; TagLength : integer; s : AnsiString);
  var
    i,n : integer;
  begin
    n:=length(s);
    if n>TagLength then n:=TagLength;
    for i:=1 to n do TagValue[i-1]:=s[i];
    end;

  // Id3V2-Tags (see: http://www.id3.org/id3v2.4.0-structure.txt)
  procedure CopyFrame (var Buffer : array of byte; var Index : cardinal;
                       Len : cardinal; ID : AnsiString;
                       const Value : AnsiString);
  var
    i,n : cardinal;
  begin
    if Index+length(ID)+7+length(Value)<Len then begin
      for i:=1 to length(Id) do Buffer[Index+i-1]:=ord(Id[i]);
      inc(Index,length(ID));
      n:=length(Value);
      if Mp3V2Info.Unicode then begin
        CardinalToBigEndian(Buffer,Index,2*n+5);
        Buffer[Index+6]:=1;
        Buffer[Index+7]:=$FF; Buffer[Index+8]:=$FE;
        StringToWideChar(Value,@Buffer[Index+9],n+1);
        inc(Index,2*n+11);
        end
      else begin
        CardinalToBigEndian(Buffer,Index,n+1);
        inc(Index,7);
        for i:=1 to n do Buffer[Index+i-1]:=ord(Value[i]);
        inc(Index,n);
        end;
      end;
    end;

  procedure CopyString (var Buffer : array of byte; var Index : cardinal;
                       Len : cardinal; ID : AnsiString;
                       const Value,Value2,Value1 : AnsiString);
  var
    s : AnsiString;
  begin
    if length(Value)>0 then s:=Value
    else if length(Value2)>0 then s:=Value2
    else s:=Value1;
    if length(s)>0 then CopyFrame(Buffer,k,HdLen,ID,s)
    end;

  procedure CopyInteger (var Buffer : array of byte; var Index : cardinal;
                         Len : cardinal; ID : AnsiString;
                         Value,Value2,Value1,NoVal : integer);
  var
    n : integer;
  begin
    if Value<>NoVal then n:=Value
    else if Value2<>NoVal then n:=Value2
    else n:=Value1;
    if n<>NoVal then CopyFrame(Buffer,k,HdLen,ID,IntToStr(n));
    end;

begin
  if FData.ValidTag then Seek(-TagSize,soFromEnd)
  else Seek(0,soFromEnd);
  FillChar(Tag,TagSize,0);
  Mp3V1Info:=Mp3Info;
  with Mp3V1Info do begin
    Tag.Header:='TAG';
    if length(Titel)=0 then Titel:=FData.Title;
    SetTagValue(Tag.Title,30,TrimRight(Titel));
    if length(Interpret)=0 then Interpret:=FData.Artist;
    SetTagValue(Tag.Artist,30,TrimRight(Interpret));
    if length(Album)=0 then Album:=FData.Album;
    SetTagValue(Tag.Album,30,TrimRight(Album));
    if length(Jahr)=0 then Jahr:=FData.Year;
    SetTagValue(Tag.Year,4,TrimRight(Jahr));
    if length(Kommentar)=0 then Kommentar:=FData.Comment;
    SetTagValue(Tag.Comment,29,TrimRight(Kommentar));
    if Track=0 then Track:=FData.Track;
    Tag.Comment[30]:=AnsiChar(Track);
    if Genre=255 then Genre:=FData.Genre;
    Tag.Genre:=Genre;
    try
      Write(Tag,TagSize);
      Result:=true;
    except
      Result:=false;
      end;
    end;
  // Read IdV2-Header
  ClearMp3Info(Mp3V2Info);
  if ReadIdV2Tag(Mp3V2Info,HdLen) then begin
    SetLength(V2Hd,HdLen);
    FillChar(V2Hd[0],HdLen,0);
    k:=0;
    with Mp3Info do begin
      CopyString (V2Hd,k,HdLen,Id3V2Alb,Trim(Album),Mp3V2Info.Album,Mp3V1Info.Album);
      CopyString (V2Hd,k,HdLen,Id3V2Art,Trim(Interpret),Mp3V2Info.Interpret,Mp3V1Info.Interpret);
      CopyString (V2Hd,k,HdLen,Id3V2Tit,Trim(Titel),Mp3V2Info.Titel,Mp3V1Info.Titel);
      if Genre<255 then begin
        if Genre<=Id3v1Count then s:=Id3v1Genres[Genre]
        else s:=Id3v1Misc;
        end
      else s:='';
      CopyString (V2Hd,k,HdLen,Id3V2Gen,s,Mp3V2Info.Contents,'');
      CopyInteger(V2Hd,k,HdLen,Id3V2Trk,Track,Mp3V2Info.Track,Mp3V1Info.Track,0);
      CopyString (V2Hd,k,HdLen,Id3V2Yer,Trim(Jahr),Mp3V2Info.Jahr,Mp3V1Info.Jahr);
      CopyString (V2Hd,k,HdLen,Id3V2Ops,Trim(Werk),Mp3V2Info.Werk,'');
      CopyString (V2Hd,k,HdLen,Id3V2Com,Trim(Komponist),Mp3V2Info.Komponist,'');
      CopyString (V2Hd,k,HdLen,Id3V2Txt,Trim(Texter),Mp3V2Info.Texter,'');
      end;
    // overwrite header
    Write(V2Hd[0],HdLen);
    V2Hd:=nil;
    end;
  end;

// =================================================================
function GetMp3Info (const Mp3Name : string;
                     var Mp3Info   : TMp3Info) : boolean;
var
  fs : TMp3Stream;
  HdLen : cardinal;
begin
  Result:=false;
  if not FileExists(Mp3Name) then Exit;
  ClearMp3Info(Mp3Info);
  try
    fs:=TMp3Stream.Create(Mp3Name,true);
    with fs do begin
      Result:=Valid;
      if Valid then with Data do begin
        Mp3Info.Titel:=Title;
        Mp3Info.Interpret:=Artist;
        Mp3Info.Album:=Album;
        Mp3Info.Jahr:=Year;
        Mp3Info.Track:=Track;
        Mp3Info.Genre:=Genre;
        Mp3Info.Dauer:=Duration
        end;
      try
      ReadIdV2Tag(Mp3Info,HdLen);  // overwrite infos with IdV2 if found
      except end;
      end;
  finally
    fs.Free;
    end;
  end;

function SetMp3Info (const Mp3Name : string;
                     const Mp3Info : TMp3Info) : boolean;
var
  fs : TMp3Stream;
begin
  Result:=false;
  try
    fs:=TMp3Stream.Create(Mp3Name,false);
    with fs do begin
      Result:=WriteTag(Mp3Info);
      end;
  finally
    fs.Free;
    end;
  end;

end.
