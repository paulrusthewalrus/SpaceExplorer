unit unMyShip;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls;

type

  { TfrmMyShip }

  TfrmMyShip = class(TForm)
    btnAddEngine: TButton;
    btnAddHull: TButton;
    btnAddShield: TButton;
    btnAddWeapon: TButton;
    btnSubEngine: TButton;
    btnSubHull: TButton;
    btnSubShield: TButton;
    btnSubWeapon: TButton;
    iconWep1: TImage;
    iconWep2: TImage;
    iconWep3: TImage;
    iconWep4: TImage;
    imgHelpView: TImage;
    imgBack: TImage;
    imgHelp: TImage;
    labPoints: TLabel;
    labTitle: TLabel;
    labEngine: TLabel;
    labHull: TLabel;
    labShields: TLabel;
    labWeapon: TLabel;
    labWepHelp: TLabel;
    labWepTitle: TLabel;
    labnum1: TLabel;
    labnum2: TLabel;
    labnum3: TLabel;
    labnum4: TLabel;
    labWep1: TLabel;
    labWep2: TLabel;
    labWep3: TLabel;
    labWep4: TLabel;
    pbEngine: TProgressBar;
    pbWeapon: TProgressBar;
    pbShield: TProgressBar;
    pbHull: TProgressBar;
    sh1Icon: TShape;
    sh3Icon: TShape;
    sh2Icon: TShape;
    sh4Icon: TShape;
    shHullBack: TShape;
    shShieldBack: TShape;
    shWep3Back: TShape;
    shWep4Back: TShape;
    shWep2Back: TShape;
    shWepTitleBack: TShape;
    shWeaponsBack: TShape;
    shTitleBack: TShape;
    shMidBarrier: TShape;
    shEngineBack: TShape;
    shWep1Back: TShape;
    shHelpBack: TShape;
    timUpdate: TTimer;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure firstcreate;
    procedure imgHelpMouseEnter(Sender: TObject);
    procedure imgHelpMouseLeave(Sender: TObject);
    procedure boxMouseEnter(Sender: TObject);
    procedure boxMouseLeave(Sender: TObject);
    procedure timUpdateTimer(Sender: TObject);
    procedure update;
    procedure closemyform;
    procedure wepcheck;
    procedure iconMouseEnter(Sender : TObject);
    procedure iconMouseLeave(Sender : TObject);
    procedure wepChooseClick(Sender : TObject);
    procedure vanillaClick(Sender : TObject);
  private

  public
     //energy bar numbers
     wepLvl    : byte;
     engineLvl : byte;
     hullLvl   : byte;
     shieldLvl : byte;
     updateWep : boolean;
     replace   : byte;
  end;

var
  frmMyShip: TfrmMyShip;

implementation

uses unGame,unEnemy,unWepTable;

{$R *.lfm}

{ TfrmMyShip }

//ADD / MINUS VANILLA STATEMENT
procedure TfrmMyShip.vanillaClick(Sender: TObject);
var who : TButton;
    cap : string;
    lef : integer;
    which : string;
begin
    //typecast it
    who := Sender as TButton;
    //what's the caption?
    cap := who.caption;
    //what's the left amt.?
    lef := who.left;

    //check which it belongs to
    if (lef < 70)
       then which := 'ENGINE'
       else if (lef < 150)
          then which := 'HULL'
          else if (lef < 210)
             then which := 'SHIELDS'
             else which := 'WEAPONS';

    //check if there is at least ONE available energy point
    if (frmGame.energyPoints >= 1)
       then begin
                //check the caption
                //if it's for engine
                if (which = 'ENGINE')
                   then begin
                            //check if it is being added
                            if (cap = '+')
                               then begin
                                        if (enginelvl <> 10)
                                           then begin
                                                    //increment energy level
                                                    inc(enginelvl);
                                                    //remove one point
                                                    dec(frmGame.energyPoints);
                                                end
                                    end
                                    else begin
                                             //check if it does not equal 0
                                             if (enginelvl <> 0)
                                                then begin
                                                         //decrement engine lvl
                                                         dec(enginelvl);
                                                         //remove one point
                                                         inc(frmGame.energyPoints);
                                                     end
                                          end;
                        end;

                //if it's for HULL
                if (which = 'HULL')
                   then begin
                            //check if it is being added
                            if (cap = '+')
                               then begin
                                        if (hulllvl <> 10)
                                           then begin
                                                    //increment energy level
                                                    inc(hulllvl);
                                                    //remove one point
                                                    dec(frmGame.energyPoints);
                                                end
                                    end
                               else begin
                                       //check if it does not equal 0
                                       if (hulllvl <> 0)
                                          then begin
                                                   //decrement engine lvl
                                                   dec(hulllvl);
                                                   //remove one point
                                                   inc(frmGame.energyPoints);
                                               end
                                    end;
                        end;

                //if it's for SHIELDS
                if (which = 'SHIELDS')
                   then begin
                            //check if it is being added
                            if (cap = '+')
                               then begin
                                        if (shieldlvl <> 10)
                                           then begin
                                                    //increment energy level
                                                    inc(shieldlvl);
                                                    //remove one point
                                                    dec(frmGame.energyPoints);
                                                 end
                                    end
                               else begin
                                       //check if it does not equal 0
                                       if (shieldlvl <> 0)
                                          then begin
                                                   //decrement engine lvl
                                                   dec(shieldlvl);
                                                   //remove one point
                                                   inc(frmGame.energyPoints);
                                               end
                                    end;
                        end;

                //if it's for engine
                if (which = 'WEAPONS')
                   then begin
                            //check if it is being added
                            if (cap = '+')
                               then begin
                                        if (weplvl <> 10)
                                           then begin
                                                  //increment energy level
                                                  inc(weplvl);
                                                  //remove one point
                                                  dec(frmGame.energyPoints);
                                                end
                                    end
                               else begin
                                       //check if it does not equal 0
                                       if (weplvl <> 0)
                                          then begin
                                                   //decrement engine lvl
                                                   dec(weplvl);
                                                   //remove one point
                                                   inc(frmGame.energyPoints);
                                               end
                                    end;
                        end;

                //update the progressbars
                pbEngine.position := 10*enginelvl;
                pbHull.position := 10*hulllvl;
                pbWeapon.position := 10*weplvl;
                pbShield.position := 10*shieldlvl;
           end;
end;

//FORM CREATE
procedure TfrmMyShip.FormCreate(Sender: TObject);
begin
  //random it up
  randomize;
  //position form
  frmMyShip.top := 145;
  frmMyShip.left := 404;
  //first form create
  firstcreate;
end;

//PROCEDUE FOR CLOSING THE FORM
procedure TfrmMyShip.closemyform;
begin
  //remove blocks from both frmEnemy and frmGame
   frmGame.shBlock.left := 1000;
   frmGame.shBlock.top := 1000;
   //start timers in frmGame
   frmGame.timEnergy.enabled := true;
   //check if there's a battle going down
   if (frmGame.battle)
      then begin
               //only need to adjust left for frmEnemy
               frmEnemy.shBlock.left := 500;
               //start timers in frmEnemy
               frmEnemy.timBattle.enabled := true;
               frmEnemy.timHP_MOVE.enabled := true;
           end;
end;

//WHEN THE FORM IS CLOSED
procedure TfrmMyShip.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
   closemyform;
end;

//UPDATE PROGRESS BARS
procedure TfrmMyShip.update;
begin
   //update progress bars
   pbEngine.position := 10*engineLvl;
   pbWeapon.position := 10*wepLvl;
   pbShield.position := 10*shieldLvl;
   pbHull.position := 10*hullLvl;
end;

//FIRST CREATE
procedure TfrmMyShip.firstcreate;
begin
   //updateWe[
   updateWep := false;
   //setup the progress bar variables
   wepLvl := 1;
   shieldLvl := 1;
   hullLvl := 1;
   engineLvl := 1;
   //update the positions
   update;
end;

//MOUSE HOVERS OVER HELP
procedure TfrmMyShip.imgHelpMouseEnter(Sender: TObject);
begin
  //turn shape back yellopw
  shHelpBack.Brush.color := clYellow;
  //make the progress bars invisible
  pbShield.visible := false;
  pbWeapon.visible := false;
  //display the image
  imgHelpView.left := 160;
end;

//MOUSE LEAVES HELP IMAGE
procedure TfrmMyShip.imgHelpMouseLeave(Sender: TObject);
begin
   //turn shape back to white
   shHelpBack.brush.color := clWhite;
   //make the progress bars visible
   pbShield.visible := true;
   pbWeapon.visible := true;
   //hide image
   imgHelpView.left := 616;
end;

//MOUSE ICON/BOX CLICK
procedure TfrmMyShip.wepChooseClick(Sender : TObject);
var who : TImage;
    num : byte;
begin
   //typecast it
   who := Sender as TImage;
   //find tag
   num := who.tag;
   //set it up as replacement
   replace := num;
   //showmessage(inttostr(replace));
   //open the new form
   frmWepTable.show;
end;

//WHEN THE MOUSE ENTERS THE ICON
procedure TfrmMyShip.iconMouseEnter(Sender: TObject);
var who : TImage;
    num : byte;
begin
   //typecast it
   who := Sender as TImage;
   //find the tag
   num := who.tag;
   //find which shape it belongs to and change the color;
   case num of
    1: sh1Icon.brush.color := clYellow;
    2: sh2Icon.brush.color := clYellow;
    3: sh3Icon.brush.color := clYellow;
    4: sh4Icon.brush.color := clYellow;
   end
end;

//WHEN THE MOUSE LEAVES THE ICON
procedure TfrmMyShip.iconMouseLeave(Sender: TObject);
begin
  //change them all to white
  sh1Icon.brush.color := clWhite;
  sh2Icon.brush.color := clWhite;
  sh3Icon.brush.color := clWhite;
  sh4Icon.brush.color := clWhite;
end;

//WHEN THE MOUSE ENTERS THE BOX
procedure TfrmMyShip.boxMouseEnter(Sender: TObject);
var who : TShape;
begin
   //typecast it
   who := Sender as TShape;
   //change the colour
   who.brush.color := clYellow;
end;

//WHEN THE MOUSE LEAVES THE BOX
procedure TfrmMyShip.boxMouseLeave(Sender: TObject);
var who : TShape;
begin
   //typecast it
   who := Sender as TShape;
   //change the color back
   who.brush.color := clWhite;

end;

//CHECK FOR WEAPON UPDATES
procedure TfrmMyShip.wepcheck;
var r,c  : byte;
    item : unGame.items;
    //item : items;
    eq   : byte;
    ic   : TImage;
    nm : string;
begin
   //go through the inventory looking for equipped = 1,2,3,4
   for r := 1 to frmGame.rows do
      for c := 1 to frmGame.cols do
         begin
           //typecast it
           item := frmGame.inventory[r,c];

           //find it's name
           nm := item.name;
           if not(nm.IsEmpty)
              then begin
                       //get the equipped var
                       eq := item.equipped;
                       //check if an item exists
                       //case it up
                       case eq of
                          //check if it's in place one
                          1: begin
                               //apply the name to labWep1
                               labWep1.caption := item.name;
                               //PICTURE
                               frmGame.imgLMiniProj.getbitmap(item.projimgref,iconWep1.picture.bitmap);
                               frmGame.att1 := item;
                             end;
                          //check if it's in place 2
                          2: begin
                               //apply the name to labWep2
                               labWep2.caption := item.name;
                               //PICTURE
                               frmGame.imgLMiniProj.getbitmap(item.projimgref,iconWep2.picture.bitmap);
                               frmGame.att2 := item;
                             end;
                          //check if it's in place 3
                          3: begin
                               //apply the name to labWep2
                               labWep3.caption := item.name;
                               //PICTURE
                               frmGame.imgLMiniProj.getbitmap(item.projimgref,iconWep3.picture.bitmap);
                               frmGame.att3 := item;
                             end;
                          //check if it's in place 4
                          4: begin
                               //apply the name to labWep2
                               labWep4.caption := item.name;
                               //PICTURE
                               frmGame.imgLMiniProj.getbitmap(item.projimgref,iconWep4.picture.bitmap);
                               frmGame.att4 := item;
                             end;
                       end;
                  end;
         end;
   //update wepcheck
   updateWep := true;


end;

//UPDATE TIMER
procedure TfrmMyShip.timUpdateTimer(Sender: TObject);
begin
  //update weapons
   if (updateWep = false)
      then wepcheck;
  //update all values
  labPoints.caption := 'Remaining Energy Points: '+inttostr(frmGame.energyPoints);
end;

end.

