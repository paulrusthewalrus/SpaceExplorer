program SpaceExplorer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, unMain, unnewship, unGame, unTravel, unenemy, unDead, unMyShip, unJump,
  unWepTable, unExit, unHighscore
  { you can add units after this };

{$R *.res}

begin
  Application.Title:='Space Explorer';
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmGame, frmGame);
  Application.CreateForm(TfrmMyShip, frmMyShip);
  Application.CreateForm(TfrmJumping, frmJumping);
  Application.CreateForm(TfrmEnemy, frmEnemy);
  Application.CreateForm(TfrmTravel, frmTravel);
  Application.CreateForm(TfrmDead, frmDead);
  Application.CreateForm(TfrmWepTable, frmWepTable);
  Application.CreateForm(TfrmExit, frmExit);
  Application.CreateForm(TfrmHighscore, frmHighscore);
  Application.Run;
end.

