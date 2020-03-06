unit unDead;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TfrmDead }

  TfrmDead = class(TForm)
    btnNewGame: TButton;
    btnMenu: TButton;
    btnSave: TButton;
    edName: TEdit;
    imgBack: TImage;
    labSaved: TLabel;
    labScore: TLabel;
    labName: TLabel;
    labTitle: TLabel;
    shMenuBack: TShape;
    shGameBack: TShape;
    shTitleBack: TShape;
    shSaveBack: TShape;
    timWait: TTimer;
    procedure btnMenuClick(Sender: TObject);
    procedure btnNewGameClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure timWaitTimer(Sender: TObject);
  private

  public

  end;

var
  frmDead: TfrmDead;

implementation

uses unenemy,unGame,unMain,unExit;

{$R *.lfm}

{ TfrmDead }

procedure TfrmDead.btnMenuClick(Sender: TObject);
begin
  //go back to the menu
  frmMain.show;
  frmDead.hide;
end;

procedure TfrmDead.btnNewGameClick(Sender: TObject);
begin
  //show the new form
  frmGame.show;
  //hide the current form
  frmDead.hide;
  //new game
  frmGame.newgame;
end;

procedure TfrmDead.btnSaveClick(Sender: TObject);
var nm : string;
    saved : boolean;
begin
  if (saved = false)
     then begin
            //take the text in edName
            nm := edName.text;
            //check if not empty
            if not(nm.IsEmpty)
             then begin
                     //save the score as a HIGHSCORE
                     frmExit.edName.text := edName.text;
                     //do the save file
                     frmExit.savetext;
                     //timWait and visible
                     labSaved.visible := true;
                     timWait.enabled := true;
                     //saved false
                     saved := true;
                  end;

          end;
end;

procedure TfrmDead.timWaitTimer(Sender: TObject);
begin
  labSaved.visible := false;
end;

end.

