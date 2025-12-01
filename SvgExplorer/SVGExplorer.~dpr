program SVGExplorer;

{$R 'languages.res' 'languages.rc'}

uses
  GnuGetText in '..\..\Bibliotheken\Units\GnuGetText.pas',
  LangUtils in '..\..\Bibliotheken\Units\LangUtils.pas',
  SVGIconItems in '..\..\Bibliotheken\SVG\SVGIconItems.pas',
  Vcl.Forms,
  Vcl.Graphics,
  FExplorerSVG in 'FExplorerSVG.pas' {fmExplorerSVG},
  SelectDlg in '..\..\Bibliotheken\Dialogs\SelectDlg.pas' {SelectDialog};

{$R *.res}

begin
  TP_GlobalIgnoreClass(TFont);
  TP_GlobalIgnoreClass(TSVGIconItem);
  // Subdirectory in AppData for user configuration files and supported languages
  InitTranslation(['delphi10','units']);

//  Application.Title := 'SVG Icons Explorer - (c) 2020-2024 Ethea, 2025 J. Rathlev';
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmExplorerSVG, fmExplorerSVG);
  Application.CreateForm(TSelectDialog, SelectDialog);
  Application.Run;
end.
