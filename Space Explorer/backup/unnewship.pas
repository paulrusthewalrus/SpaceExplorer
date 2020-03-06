unit unnewship;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TfrmNewShip }

  TfrmNewShip = class(TForm)
    btnConfirm: TButton;
    btnBack: TButton;
    procedure btnBackClick(Sender: TObject);
    procedure btnConfirmClick(Sender: TObject);
  private

  public

  end;

var
  frmNewShip: TfrmNewShip;

implementation

uses unMain;
uses unGame;

{$R *.lfm}

{ TfrmNewShip }

procedure TfrmNewShip.btnBackClick(Sender: TObject);
begin
  //hide this form
  frmNewShip.hide;
  //show the menu form
  frmMain.show;
end;

procedure TfrmNewShip.btnConfirmClick(Sender: TObject);
begin
  //player has confirmed his/her ship - SEND DATA

  //hide the current form
  frmNewShip.hide;
  //show the game form with all elements
  frmGame.show;
end;

end.

