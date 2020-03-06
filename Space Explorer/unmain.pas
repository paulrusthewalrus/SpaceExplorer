unit unMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnQuit: TButton;
    btnNewGame: TButton;
    btnLoadGame: TButton;
    btnHighscores: TButton;
    imgBack: TImage;
    labTitle: TLabel;
    shQuitBack: TShape;
    shLoadBack: TShape;
    shHighscoreBack: TShape;
    shTitleBack: TShape;
    shNewBack: TShape;
    procedure btnHighscoresClick(Sender: TObject);
    procedure btnNewGameClick(Sender: TObject);
    procedure btnQuitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public
     highClick : boolean;
  end;

var
  frmMain: TfrmMain;

implementation

uses unnewship,unGame,unHighscore;

{$R *.lfm}

{ TfrmMain }

//BTN QUIT CLICK
procedure TfrmMain.btnQuitClick(Sender: TObject);
begin
  close;
end;

//FORM CREATE
procedure TfrmMain.FormCreate(Sender: TObject);
begin
  //set position
  frmMain.left := 457;
  frmMain.top := 193;
end;

//NEW GAME CLICK
procedure TfrmMain.btnNewGameClick(Sender: TObject);
begin
  {//show the new ship form
  frmNewShip.show;
  //set it to the same left top
  frmNewShip.left := frmMain.left;
  frmNewShip.top := frmMain.top; }
  //show the game form
  frmGame.show;
  //hide the menu form
  frmMain.Hide;
end;

//OPEN THE HIGHSCORES
procedure TfrmMain.btnHighscoresClick(Sender: TObject);
begin
  //check if a highscore exists
  if fileExists('highscores.lsr')
     //open highscores
     then begin
            //show highscore form
            frmHighscore.show;
            //do the load score
            frmHighscore.loadscore;
            //hide main form
            frmMain.hide;
          end
          //message
          else showmessage('No highscores!');

end;

end.

