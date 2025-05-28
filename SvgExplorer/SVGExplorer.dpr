program SVGExplorer;

uses
  GnuGetText in '..\..\Bibliotheken\Units\GnuGetText.pas',
  LangUtils in '..\..\Bibliotheken\Units\LangUtils.pas',
  Vcl.Forms,
  Vcl.Graphics,
  FExplorerSVG in 'FExplorerSVG.pas' {fmExplorerSVG};

{$R *.res}

begin
  TP_GlobalIgnoreClass(TFont);
  // Subdirectory in AppData for user configuration files and supported languages
  InitTranslation('','',['delphi10','units']);

  Application.Title := 'SVG Icons Explorer - (c) 2020-2024 Ethea, 2025 J. Rathlev';
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmExplorerSVG, fmExplorerSVG);
  Application.Run;
end.
