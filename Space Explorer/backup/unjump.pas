unit unJump;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls;

type

  { TfrmJumping }

  TfrmJumping = class(TForm)
    imgShip: TImage;
    imgBack: TImage;
    labTele: TLabel;
    pbLoading: TProgressBar;
    shBack: TShape;
    shPbBack: TShape;
    timWait: TTimer;
    timLabelChange: TTimer;
    timShipMove: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure timLabelChangeTimer(Sender: TObject);
    procedure timShipMoveTimer(Sender: TObject);
    procedure timWaitTimer(Sender: TObject);
  private

  public

  end;

var
  frmJumping: TfrmJumping;

implementation

uses unGame,unEnemy,unTravel;

{$R *.lfm}

{ TfrmJumping }

Var num : byte;
    pos : integer;

//LABEL CHANGE
procedure TfrmJumping.timLabelChangeTimer(Sender: TObject);
begin
  //check the num and update the label
  case num of
   0: labTele.caption := 'Teleporting.';
   1: labTele.caption := 'Teleporting..';
   2: labTele.caption := 'Teleporting...';
  end;
  //incremenet the num
  num := (num+1) mod 3;
  //check if loading is on
  if (timWait.enabled)
     then begin
            //increment
            pos := pos + 12;
            //set pb
            pbLoading.position := pos;
          end;
end;

//move the ship
procedure TfrmJumping.timShipMoveTimer(Sender: TObject);
begin
   //move the ship to the right
   imgShip.left := imgShip.left + 30;
   //check if it's gone across the screen
   if (imgShip.left > clientwidth + imgShip.width)
      then begin
             //reposition it
             imgShip.top := random(clientheight-imgShip.height);
             imgShip.left := -imgShip.width;
           end;

end;

//TIM WAIT
procedure TfrmJumping.timWaitTimer(Sender: TObject);
begin
  //show the other form
  //SET UP THE NEW FORMS
  frmTravel.setup(frmTravel.which);
  //set the pos var
  pos := 0;
  //stop all the timWait timer
  timWait.Enabled := false;
  //jumping is false
  frmTravel.jumping := false;
  //hide the form
  frmJumping.Hide;
end;

//form create
procedure TfrmJumping.FormCreate(Sender: TObject);
begin
  //randomize
  randomize;
  //setup the num
  num := 0;
end;

end.

//to do list
//1) flying ship going across form

