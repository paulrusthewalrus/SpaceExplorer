unit unExit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  player = record
    captain : string[30];
    score   : integer;
  end;

  players = array of player;

  { TfrmExit }

  TfrmExit = class(TForm)
    btnExit: TButton;
    btnBack: TButton;
    edName: TEdit;
    imgBack: TImage;
    labTitle: TLabel;
    labName: TLabel;
    labScore: TLabel;
    memHighscores: TMemo;
    shTextBack: TShape;
    procedure btnBackClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure scoreupdate;
    procedure savetext;
  private

  public
    highscores : players;
  end;

var
  frmExit: TfrmExit;

implementation

uses unGame,unMain;

{$R *.lfm}

{ TfrmExit }

//SAVE THE HIGHSCORES MEMO BOX
procedure TfrmExit.savetext;
var plate : string;
begin
  //CHECK IF A FILE EXISTS
   if (FileExists('highscores.lsr'))
      then begin
             //load the lines from file
             memHighscores.lines.loadfromfile('highscores.lsr');
           end;

   //check if there is text in edName
   if (edName.text <> '')
      //add the score to the memHighscores
      then begin
             //plate up the string
             plate := inttostr(frmGame.scrap) + ' | ' + edName.text;
             //add that to the lines
             memHighscores.lines.add(plate);
             //save that
             memHighscores.lines.SaveToFile('highscores.lsr');
           end;

end;

//UPDATE THE SCORRE
procedure TfrmExit.scoreupdate;
begin
  //update score
  labScore.caption := 'Your Score: '+inttostr(frmGame.Scrap);
end;

//FORM CREATE
procedure TfrmExit.FormCreate(Sender: TObject);
begin
   //randomize;
   randomize;
   //update the score
   scoreupdate;
   //position
   frmExit.left := 501;
   frmExit.top := 164;
   //set the length of highscores
   setlength(highscores,0);

end;

//BACK BUTTON
procedure TfrmExit.btnBackClick(Sender: TObject);
begin
  //hide this form
  frmExit.Hide;
  //show game form
  frmGame.show;
end;

//EXIT AND SAVE
procedure TfrmExit.btnExitClick(Sender: TObject);
begin
  //save the text
  savetext;
  //exit
  frmMain.close;
end;

end.

