program SVGExplorer;

uses
  Vcl.Forms,
  FExplorerSVG in 'FExplorerSVG.pas' {fmExplorerSVG};

{$R *.res}

begin
  Application.Title := 'SVG Icons Explorer - (c) 2020-2024 Ethea, 2025 J. Rathlev';
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmExplorerSVG, fmExplorerSVG);
  Application.Run;
end.
