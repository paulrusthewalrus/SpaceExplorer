unit unGame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms,
  Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, LCLIntf, LCLType;

type
  //weapons record
  items = record
    name     : string[20];
    weapon   : boolean; //whether it's a weapon or not
    dmg      : byte;    //how much damage it does
    interval : integer; //the time between attacks
    projimg  : TImage;
    projimgref : byte;
    equipped : byte; //where does the player have it?
    allow    : boolean;
    here     : boolean;
  end;

  //proj icon class
  projico = class(TImage)
    public
       something : string; //for something
  end;

  //icon class
  iconA = class(TImage)
    public
      what : string;
  end;
  //rooms class
  rooms = class(TShape)
    public
      HP   : integer; //current health of room (for calculating room colour)
      task : string; //task of room (e.g. engine, hull)
      amt  : byte; //current amount of crew inside the room
      ic : iconA; //which icon is it?
  end;
  //projectiles class
  projectiles = class(TImage)
    public
      dmg    : integer; //how much damage it's dealing
      seen   : boolean;
      img    : byte; //which img is it?
      swap   : boolean;
      user   : boolean; //who does the proj belong to?
  end;

  { TfrmGame }

  TfrmGame = class(TForm)
    btnLootFinish: TButton;
    btnWelcome: TButton;
    imgQuit: TImage;
    imgWelcome: TImage;
    imgLProj: TImageList;
    imgWep1: TImage;
    imgLMiniProj: TImageList;
    imgHelp: TImage;
    imgHelpView: TImage;
    imgWep2: TImage;
    imgWep3: TImage;
    imgWep4: TImage;
    imgWrench: TImage;
    imgExplosion: TImage;
    imgEngineIcon: TImage;
    imgProj1: TImage;
    imgProj2: TImage;
    imgWepIcon: TImage;
    imgHull: TImage;
    imgBackground: TImage;
    imgShield: TImage;
    imgMyShip: TImage;
    imgShop: TImage;
    imgShip: TImage;
    imgTravel: TImage;
    labMiss: TLabel;
    labnum1: TLabel;
    labnum2: TLabel;
    labnum3: TLabel;
    labnum4: TLabel;
    labWep1: TLabel;
    labEnergy: TLabel;
    labHP: TLabel;
    labMyShip: TLabel;
    labShop: TLabel;
    labTravel: TLabel;
    labWep2: TLabel;
    labWep3: TLabel;
    labWep4: TLabel;
    memLoot: TMemo;
    pbHP: TProgressBar;
    pbEnergy: TProgressBar;
    pbWep1: TProgressBar;
    pbWep2: TProgressBar;
    pbWep3: TProgressBar;
    pbWep4: TProgressBar;
    shBlock: TShape;
    shHelpBack: TShape;
    shQuitBack: TShape;
    shMiss: TShape;
    shShopRecBack: TShape;
    shTravelRECBACK: TShape;
    shnum1: TShape;
    shnum2: TShape;
    sh1Icon: TShape;
    sh2Icon: TShape;
    sh3Icon: TShape;
    shnum3: TShape;
    sh4Icon: TShape;
    shnum4: TShape;
    shHPENERGYback: TShape;
    shTravelBACK: TShape;
    shMYSHIPback: TShape;
    shShopBack: TShape;
    shTravelHOVER: TShape;
    shMYSHIPRECBACK: TShape;
    shLootBack: TShape;
    timEnergy: TTimer;
    timEnergyRecharge: TTimer;
    timWep1: TTimer;
    timWep: TTimer;
    timRepair: TTimer;
    timMiss2: TTimer;
    timMiss: TTimer;
    timWep2: TTimer;
    timWep3: TTimer;
    timWep4: TTimer;
    procedure btnLootFinishClick(Sender: TObject);
    procedure btnWelcomeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure imgHelpMouseEnter(Sender: TObject);
    procedure imgHelpMouseLeave(Sender: TObject);
    procedure imgQuitMouseEnter(Sender: TObject);
    procedure imgQuitMouseLeave(Sender: TObject);
    procedure roomMouseLeave(Sender: TObject);
    procedure imgMyShipClick(Sender: TObject);
    procedure mouseleaveTRAVEL(Sender: TObject);
    procedure mouseleaveSHIP(Sender: TObject);
    procedure roomMouseEnter(Sender: TObject);
    procedure timEnergyRechargeTimer(Sender: TObject);
    procedure timEnergyTimer(Sender: TObject);
    procedure timMiss2Timer(Sender: TObject);
    procedure timMissTimer(Sender: TObject);
    procedure timRepairTimer(Sender: TObject);
    procedure timUserProjTimer(Sender: TObject);
    procedure timWep1Timer(Sender: TObject);
    procedure timWep2Timer(Sender: TObject);
    procedure timWep3Timer(Sender: TObject);
    procedure timWep4Timer(Sender: TObject);
    procedure timWepTimer(Sender: TObject);
    procedure update; //update HP and energy
    procedure originalcreate; //procedure for spawning rooms of ORIGINAL ship
    procedure createrooms; //determining which ship to create rooms for
    function distance(x : real; y : real; mousex : integer; mousey : integer) : real; //distance calc
    procedure mousemoveTRAVEL(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
    procedure mousemoveSHIP(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
    procedure travelclick(Sender : TObject);
    procedure newgame;
    procedure iconMouseEnter(Sender : TObject);
    procedure roomClick(Sender : TObject); //mostly for checking repairs
    procedure closemyform(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer); //closing myship form
    procedure addweapons; //add the weapons
    procedure iconRepairClick(Sender : TObject); //for when they click the icon
    procedure addbasic;
    procedure attackupdate;
    procedure equipitem(att : byte; item : items);
    procedure resetcolor;
    procedure keyclick; //detects when a key is clicked
    procedure changecolor(which : byte ; new : word); //change the color of an object
    procedure loot;
    procedure addweapon(which : byte); //add a weapon to inventory
    procedure exit(Sender: TObject);

  private

  public
    health : integer; //Hull HP (Ship) (Expressed as %)
    energy : byte; //Energy HP (Ship) (Expressed as %)
    battle : boolean;
    ccount : byte;
    weproom    : rooms;   //room references
    hullroom   : rooms;
    engineroom : rooms;
    shieldroom : rooms;
    Scrap      : integer; //scrap is the score. It's also what you receieve after fights
    inventory  : array[1..4,1..4] of items;   //row, col
    att1,att2,att3,att4                     : items; //what are your attacks?
    att1B,att2B,att3B,att4B                 : boolean; //is the active active?
    wep1sleep,wep2sleep,wep3sleep,wep4sleep : integer;
    energyPoints                            : integer; //how many energy points
    count,rows,cols                         : byte;
  end;

var
  frmGame: TfrmGame;

implementation

uses unTravel,unEnemy,unMyShip,unJump,unWepTable,unExit;

{$R *.lfm}

{ TfrmGame }

Var repair,reploc                       : boolean;
    repairtarget                        : rooms;
    wep1,wep2,wep3,wep4,wep5,wep6       : items; //the total items in game
    wait1,wait2,wait3,wait4             : byte;
    myshipB                             : boolean;
    att1name,att2name,att3name,att4name : string;
    up1,up2,up3,up4                     : boolean;
    row,col                             : byte;
    newgameB                            : boolean; //new game?

//EXIT THE GAME CLICK
procedure TfrmGame.exit(Sender: TObject);
begin
  //check if not newgame
  if (newgameB = false)
     then begin
            //check if battle is FALSE
            if (battle = false)
               then begin
                        //update score
                        frmExit.scoreupdate;
                        //hide the game form
                        frmGame.hide;
                        //open the exit form
                        frmExit.show;
                    end
                    else begin
                           //visibly show that you can't exit during battle

                         end;

           end;
end;

//ADD WEAPON TO INVENTORY
procedure TfrmGame.addweapon(which : byte);
var item : items;
    r,c  : byte;
    found: boolean;
    nm : string;
    exist : boolean;
begin
 {//typecast the byte number to a certain item
  case which of
   0: item := wep1;
   1: item := wep2;
   2: item := wep3;
   3: item := wep4;
   4: item := wep5;
   5: item := wep6;
  end;
  //apply it to the place
  inventory[row,col] := item;
  //increase the count }


  //no place has been found yet
  found := false;
  //typecast the byte number to a certain item
  case which of
   0: item := wep1;
   1: item := wep2;
   2: item := wep3;
   3: item := wep4;
   4: item := wep5;
   5: item := wep6;
  end;
  //go through and find if there is an open inventory area
  //test all possible places in inventory
  for r := 1 to 4 do
      for c := 1 to 4 do
          begin
              //find the name
              nm := inventory[r,c].name;
              //test specific spot
              if (nm.IsEmpty)
                  then begin
                          inventory[r,c].allow := true;
                          exist := true;
                       end;
          end;

  //pick the nearest one
  if (exist)
      then begin
              //setup found as false
              found := false;
              //repeat till it finds one
              repeat
                  //pick two random row and col
                  r := random(rows)+1;
                  c := random(cols)+1;
                  //is this place an allow?
                  if (inventory[r,c].allow)
                      //it is!
                      then begin
                             //set found to true
                             found := true;
                             //set the item
                             inventory[r,c] := item;
                             //showmessage('bazigna');
                           end;
              until(found)
           end



       {nm := inventory[r,c].name;
       //check if the said place in inventory is an item
       if (nm.isEmpty)
          //the place is free
          then begin
                 //put the item there
                 inventory[r,c] := item;
                 //set found to true
                 found := true;
               end
               //it is an item
               else begin
                        //check if there if we've hit max. If not, increase
                         if ((r <> 4) and (c <> 4))
                            then begin
                                   //check if c is 4
                                   if (c = 4)
                                      then begin
                                             //increase r
                                             inc(r);
                                             //reset c
                                             c := 1;
                                           end
                                 end
                                 //no available combinations
                                 else found := true;
                    end      }
end;

//LOOT PROCEDURE
procedure TfrmGame.loot;
var scrpran                    : integer;
    wepran                     : byte;
    wepgot                     : boolean;
    scrapline,wepline,energyln : string;
    energynew                  : byte;
    enbool                     : boolean;
begin
   //give loot to the player
   //wepgot starts false
   wepgot := false;
   enbool := false;
   //give the player a bunch of loot/scrap (random amt.)
   scrpran := random(300)+150;
   //add it to scrap
   Scrap := Scrap + scrpran;
   //if player gets a NEW weapon
   if (random(200) < 140)
       then begin
               //give the player a random WEAPON (also includes no weapon)
               {wepran := random(601);
               if (wepran < 100)
                   then wepran := 0
                   else if (wepran < 200)
                       then wepran := 1
                       else if (wepran < 300)
                           then wepran := 2
                           else if (wepran < 400)
                               then wepran := 3
                               else if (wepran < 500)
                                   then wepran := 4
                                   else wepran := 5; }
               wepran := random(6);
               //weapon was chosen boolean
               wepgot := true;
               //add the weapon to the inventory
               addweapon(wepran);
            end;
   //ENERGY POINTS
   if (random(200) < 200)
       then begin
               //generate a random amount of energy points
               energynew := random(4)+1;
               //add them to the current points
               energyPoints := energyPoints + energynew;
               //plate up a string
               energyln := 'You earned: '+inttostr(energynew)+' energy points!';
               //energy boolean
               enbool := true;
            end;
   //clear off the mem
   frmEnemy.memLoot.lines.clear;

   //you won lines
   frmEnemy.memLoot.lines.add('You won!');
   frmEnemy.memLoot.lines.add('');

   //plate up said lines
   scrapline := 'You earned: '+inttostr(scrpran)+' scrap!';
   //add the scrap line
   frmEnemy.memLoot.Lines.add(scrapline);

   //if they got energy points
   if (enbool)
       //add the line
       then frmEnemy.memLoot.lines.add(energyln);

   //if they got a weapon
   if (wepgot)
       then begin
              //plate up the line
              wepline := 'You found (1) Weapon. Check your inventory!';
              //add it
              frmEnemy.memLoot.Lines.add(wepline);
              //showmessage('a');
            end;
   //position the loot box
   frmEnemy.shLootBack.left := 30;
   //shLootBack.top := 151;
   frmEnemy.memLoot.left := 48;
   //memLoot.top := 167;
   frmEnemy.btnLootFinish.left := 50;
   //btnLootFinish.top := 381;
   //bring everything to front
   {shLootBack.bringtofront;
   memLoot.bringtofront;
   btnlootFinish.bringtofront; }

   //UPDATE INVENTORY
   frmWepTable.update;

end;

//CHANGE COLOUR OF ATT PROCEDURE
procedure TfrmGame.changecolor(which : byte; new : word);
begin
  //find which one we're working with
   case which of
    1: begin
          //change the colours around
          sh1Icon.Brush.color := new;
          shNum1.brush.color := new;
          labWep1.Font.Color := new;
       end;
    2: begin
          //change the colours around
          sh2Icon.Brush.color := new;
          shNum2.brush.color := new;
          labWep2.Font.Color := new;
       end;
    3: begin
          //change the colours around
          sh3Icon.Brush.color := new;
          shNum3.brush.color := new;
          labWep3.Font.Color := new;
       end;
    4: begin
          //change the colours around
          sh4Icon.Brush.color := new;
          shNum4.brush.color := new;
          labWep4.Font.Color := new;
       end;
   end;
   //showmessage(inttostr(new));
end;

//KEY PRESS PROCEDURE (VERY IMPORTANT)
procedure TfrmGame.keyclick;
var KeyState : TKeyboardState;
    what     : TColor;
begin
  //use timer to detect keypresses
  if ((GetKeyState(vk_1) and $80) <> 0)
      then begin
             //check if it's enabled AND in battle
             if ((att1.equipped <> 0) and (battle))
                 //go ahead
                 then begin

                         //change the cursor for the fighter
                         frmEnemy.imgFighter.Cursor := crCross;
                         //check if active
                         if (att1B)
                             then begin
                                     //change the colour of the object BACK
                                     //changecolor(1,clGray);
                                     sh1Icon.Brush.color := clWhite;
                                     shNum1.brush.color := clWhite;
                                     labWep1.Font.Color := clWhite;
                                     //update active boolean
                                     att1B := false;
                                     //change the cursor for the fighter
                                     frmEnemy.imgFighter.Cursor := crDefault;
                                  end
                                  //not active, turn it on
                                  else begin
                                           //change the colour of the object
                                           changecolor(1,clRed);
                                           //what := clRed;
                                           //update active boolean
                                           att1B := true;

                                           //ATT 2 OFF
                                           //change the colour of the object BACK
                                           if (att2.projimgref <> 0)
                                               then begin
                                                       sh2Icon.Brush.color := clWhite;
                                                       shNum2.brush.color := clWhite;
                                                       labWep2.Font.Color := clWhite;
                                                    end
                                                    else begin
                                                           sh2Icon.Brush.color := clGray;
                                                           shNum2.brush.color := clGray;
                                                           labWep2.Font.Color := clGray;
                                                         end;
                                           //update active boolean
                                           att2B := false;

                                           //ATT 3 OFF
                                           if (att3.projimgref <> 0)
                                               then begin
                                                       sh3Icon.Brush.color := clWhite;
                                                       shNum3.brush.color := clWhite;
                                                       labWep3.Font.Color := clWhite;
                                                    end
                                                    else begin
                                                           sh3Icon.Brush.color := clGray;
                                                           shNum3.brush.color := clGray;
                                                           labWep3.Font.Color := clGray;
                                                         end;
                                           //update active boolean
                                           att3B := false;

                                           //ATT 4 OFF
                                           if (att4.projimgref <> 0)
                                               then begin
                                                       sh4Icon.Brush.color := clWhite;
                                                       shNum4.brush.color := clWhite;
                                                       labWep4.Font.Color := clWhite;
                                                    end
                                                    else begin
                                                           sh4Icon.Brush.color := clGray;
                                                           shNum4.brush.color := clGray;
                                                           labWep4.Font.Color := clGray;
                                                         end;
                                           //update active boolean
                                           att4B := false;

                                           //change the cursor for the fighter
                                           frmEnemy.imgFighter.Cursor := crCross;
                                       end;
                         //reset color
                         //changecolor(1,what);
                      end;

           end;
  //FOR VK_2
  if ((GetKeyState(vk_2) and $80) <> 0)
      then begin
             //check if it's enabled AND in battle
             if ((att2.equipped <> 0) and (battle))
                 //go ahead
                 then begin
                         //change the cursor for the fighter
                         frmEnemy.imgFighter.Cursor := crCross;
                         //check if active
                         if (att2B)
                             then begin
                                     //change the colour of the object BACK
                                     //changecolor(2,clGray);
                                     sh2Icon.Brush.color := clWhite;
                                     shNum2.brush.color := clWhite;
                                     labWep2.Font.Color := clWhite;
                                     //update active boolean
                                     att2B := false;
                                     //change the cursor for the fighter
                                     frmEnemy.imgFighter.Cursor := crDefault;
                                  end
                                  //not active, turn it on
                                  else begin
                                           //change the colour of the object
                                           changecolor(2,clRed);
                                           //update active boolean
                                           att2B := true;

                                           //ATT 1 OFF
                                           //change the colour of the object BACK
                                           if (att1.projimgref <> 0)
                                               then begin
                                                       sh1Icon.Brush.color := clWhite;
                                                       shNum1.brush.color := clWhite;
                                                       labWep1.Font.Color := clWhite;
                                                    end
                                                    else begin
                                                           sh1Icon.Brush.color := clGray;
                                                           shNum1.brush.color := clGray;
                                                           labWep1.Font.Color := clGray;
                                                         end;
                                           //update active boolean
                                           att1B := false;

                                           //ATT 3 OFF
                                           if (att3.projimgref <> 0)
                                               then begin
                                                       sh3Icon.Brush.color := clWhite;
                                                       shNum3.brush.color := clWhite;
                                                       labWep3.Font.Color := clWhite;
                                                    end
                                                    else begin
                                                           sh3Icon.Brush.color := clGray;
                                                           shNum3.brush.color := clGray;
                                                           labWep3.Font.Color := clGray;
                                                         end;
                                           //update active boolean
                                           att3B := false;

                                           //ATT 4 OFF
                                           if (att4.projimgref <> 0)
                                               then begin
                                                       sh4Icon.Brush.color := clWhite;
                                                       shNum4.brush.color := clWhite;
                                                       labWep4.Font.Color := clWhite;
                                                    end
                                                    else begin
                                                           sh4Icon.Brush.color := clGray;
                                                           shNum4.brush.color := clGray;
                                                           labWep4.Font.Color := clGray;
                                                         end;
                                           //update active boolean
                                           att4B := false;

                                           //change the cursor for the fighter
                                           frmEnemy.imgFighter.Cursor := crCross;
                                       end;
                      end;

           end;
  //FOR VK_3
  if ((GetKeyState(vk_3) and $80) <> 0)
      then begin
             //check if it's enabled AND in battle
             if ((att3.equipped <> 0) and (battle))
                 //go ahead
                 then begin
                         //change the cursor for the fighter
                         frmEnemy.imgFighter.Cursor := crCross;
                         //check if active
                         if (att3B)
                             then begin
                                     //change the colour of the object BACK
                                     //changecolor(3,clGray);
                                     sh3Icon.Brush.color := clWhite;
                                     shNum3.brush.color := clWhite;
                                     labWep3.Font.Color := clWhite;
                                     //update active boolean
                                     att3B := false;
                                     //change the cursor for the fighter
                                     frmEnemy.imgFighter.Cursor := crDefault;
                                  end
                                  //not active, turn it on
                                  else begin
                                           //change the colour of the object
                                           changecolor(3,clRed);
                                           //update active boolean
                                           att3B := true;

                                           //ATT 1 OFF
                                           //change the colour of the object BACK
                                           if (att1.projimgref <> 0)
                                               then begin
                                                       sh1Icon.Brush.color := clWhite;
                                                       shNum1.brush.color := clWhite;
                                                       labWep1.Font.Color := clWhite;
                                                    end
                                                    else begin
                                                           sh1Icon.Brush.color := clGray;
                                                           shNum1.brush.color := clGray;
                                                           labWep1.Font.Color := clGray;
                                                         end;
                                           //update active boolean
                                           att1B := false;

                                           //ATT 2 OFF
                                           if (att2.projimgref <> 0)
                                               then begin
                                                       sh2Icon.Brush.color := clWhite;
                                                       shNum2.brush.color := clWhite;
                                                       labWep2.Font.Color := clWhite;
                                                    end
                                                    else begin
                                                           sh2Icon.Brush.color := clGray;
                                                           shNum2.brush.color := clGray;
                                                           labWep2.Font.Color := clGray;
                                                         end;
                                           //update active boolean
                                           att2B := false;

                                           //ATT 4 OFF
                                           if (att4.projimgref <> 0)
                                               then begin
                                                       sh4Icon.Brush.color := clWhite;
                                                       shNum4.brush.color := clWhite;
                                                       labWep4.Font.Color := clWhite;
                                                    end
                                                    else begin
                                                           sh4Icon.Brush.color := clGray;
                                                           shNum4.brush.color := clGray;
                                                           labWep4.Font.Color := clGray;
                                                         end;
                                           //update active boolean
                                           att4B := false;

                                           //change the cursor for the fighter
                                           frmEnemy.imgFighter.Cursor := crCross;
                                       end;
                      end;

           end;
  //FOR VK_4
  if ((GetKeyState(vk_4) and $80) <> 0)
      then begin
             //check if it's enabled AND in battle
             if ((att4.equipped <> 0) and (battle))
                 //go ahead
                 then begin
                         //check if active
                         if (att4B)
                             then begin
                                     //change the colour of the object BACK
                                     //changecolor(4,clGray);
                                     sh4Icon.Brush.color := clWhite;
                                     shNum4.brush.color := clWhite;
                                     labWep4.Font.Color := clWhite;
                                     //update active boolean
                                     att4B := false;
                                     //change the cursor for the fighter
                                     frmEnemy.imgFighter.Cursor := crDefault;
                                  end
                                  //not active, turn it on
                                  else begin
                                           //change the colour of the object
                                           changecolor(4,clRed);
                                           //update active boolean
                                           att4B := true;

                                           //ATT 1 OFF
                                           //change the colour of the object BACK
                                           if (att1.projimgref <> 0)
                                               then begin
                                                       sh1Icon.Brush.color := clWhite;
                                                       shNum1.brush.color := clWhite;
                                                       labWep1.Font.Color := clWhite;
                                                    end
                                                    else begin
                                                           sh1Icon.Brush.color := clGray;
                                                           shNum1.brush.color := clGray;
                                                           labWep1.Font.Color := clGray;
                                                         end;
                                           //update active boolean
                                           att1B := false;

                                           //ATT 2 OFF
                                           if (att2.projimgref <> 0)
                                               then begin
                                                       sh2Icon.Brush.color := clWhite;
                                                       shNum2.brush.color := clWhite;
                                                       labWep2.Font.Color := clWhite;
                                                    end
                                                    else begin
                                                           sh2Icon.Brush.color := clGray;
                                                           shNum2.brush.color := clGray;
                                                           labWep2.Font.Color := clGray;
                                                         end;
                                           //update active boolean
                                           att2B := false;

                                           //ATT 3 OFF
                                           if (att3.projimgref <> 0)
                                               then begin
                                                       sh3Icon.Brush.color := clWhite;
                                                       shNum3.brush.color := clWhite;
                                                       labWep3.Font.Color := clWhite;
                                                    end
                                                    else begin
                                                           sh3Icon.Brush.color := clGray;
                                                           shNum3.brush.color := clGray;
                                                           labWep3.Font.Color := clGray;
                                                         end;
                                           //update active boolean
                                           att3B := false;


                                           //change the cursor for the fighter
                                           frmEnemy.imgFighter.Cursor := crCross;
                                       end;
                      end;

           end;

end;

//RESET COLOURS
procedure TfrmGame.resetcolor;
begin
  //reset all the colours
  sh1Icon.Brush.color := clGray;
  shNum1.brush.color := clGray;
  labWep1.Font.Color := clGray;

  sh2Icon.Brush.color := clGray;
  shNum2.brush.color := clGray;
  labWep2.Font.Color := clGray;

  sh3Icon.Brush.color := clGray;
  shNum3.brush.color := clGray;
  labWep3.Font.Color := clGray;

  sh4Icon.Brush.color := clGray;
  shNum4.brush.color := clGray;
  labWep4.Font.Color := clGray;

  //turn off myshipB boolean
  myshipB := false;
end;

//EQUIP ITEM
procedure TfrmGame.equipitem(att : byte; item : items);
var ico : projico;
begin
   //find which one we're working with
   case att of
    1: begin
          //update the name
          labWep1.caption := item.name;
          //change the colours around
          sh1Icon.Brush.color := clWhite;
          shNum1.brush.color := clWhite;
          labWep1.Font.Color := clwhite;
          //SETUP icon
          imgLMiniProj.getbitmap(item.projimgref,imgWep1.picture.bitmap);
          //create the icon
          {ico := projico.create(self);
          ico.parent := frmGame;
          //make it look good
          ico.stretch := true;
          //ico.picture := item.projimg.picture;
          ico.left := 63;
          ico.top := 142;
          ico.width := 34;
          ico.height := 39;
          imgLMiniProj.getbitmap(item.projimgref,ico.picture.bitmap);
          //setup the pbBar and timer
          //timWep1.interval := item.interval;  }
          pbWep1.position := wep1sleep;
          //enable pb
          pbWep1.visible := true;

       end;
    2: begin
          //update the name
          labWep2.caption := item.name;
          //change the colours around
          sh2Icon.Brush.color := clWhite;
          shNum2.brush.color := clWhite;
          labWep2.Font.Color := clwhite;
          //SETUP icon
          imgLMiniProj.getbitmap(item.projimgref,imgWep2.picture.bitmap);
          {//create the icon
          ico := projico.create(self);
          ico.parent := frmGame;
          //make it look good
          ico.stretch := true;
          //ico.picture := item.projimg.picture;
          ico.left := 63;
          ico.top := 222;
          ico.width := 34;
          ico.height := 39;
          imgLMiniProj.getbitmap(item.projimgref,ico.picture.bitmap);
          //setup the pbBar and timer
          //timWep2.interval := item.interval;}
          pbWep2.position := wep2sleep;
          //enable pb
          pbWep2.visible := true;
       end;
    3: begin
          //update the name
          labWep3.caption := item.name;
          //change the colours around
          sh3Icon.Brush.color := clWhite;
          shNum3.brush.color := clWhite;
          labWep3.Font.Color := clwhite;
          //SETUP icon
          imgLMiniProj.getbitmap(item.projimgref,imgWep3.picture.bitmap);
          //create the icon
          {ico := projico.create(self);
          ico.parent := frmGame;
          //make it look good
          ico.stretch := true;
          //ico.picture := item.projimg.picture;
          ico.left := 63;
          ico.top := 302;
          ico.width := 34;
          ico.height := 39;
          imgLMiniProj.getbitmap(item.projimgref,ico.picture.bitmap);
          //setup the pbBar and timer
          //timWep3.interval := item.interval;}
          pbWep3.position := wep3sleep;
          //enable pb
          pbWep3.visible := true;
       end;
    4: begin
          //update the name
          labWep4.caption := item.name;
          //change the colours around
          sh4Icon.Brush.color := clWhite;
          shNum4.brush.color := clWhite;
          labWep4.Font.Color := clwhite;
          //SETUP icon
          imgLMiniProj.getbitmap(item.projimgref,imgWep4.picture.bitmap);
         { ico := projico.create(self);
          ico.parent := frmGame;
          //make it look good
          ico.stretch := true;
          //ico.picture := item.projimg.picture;
          ico.left := 63;
          ico.top := 384;
          ico.width := 34;
          ico.height := 39;
          imgLMiniProj.getbitmap(item.projimgref,ico.picture.bitmap);
          //setup the pbBar and timer
          //timWep4.interval := item.interval; }
          pbWep4.position := wep4sleep;
          //enable pb
          pbWep4.visible := true;
       end;
   end;
end;

//UPDATE THE ATTACKS
procedure TfrmGame.attackupdate;
var item   : items;
    r,c    : byte; //row and col
    which  : byte; //check if it's equipped
begin
  //reset colours if NOT in battle and my ship hasn't been opened
  if ((battle = false) and (myshipB))
      then begin

              //reset the color
              resetcolor;

              //go through the inventory testing each item
              for r := 1 to 4 do
                  for c := 1 to 4 do
                      begin
                         //store it
                         item := inventory[r,c];
                         //is it equipped?
                         which := item.equipped;
                         //check if it's not 0
                         if (which <> 0)
                             then equipitem(which,item);

                      end;

      end;

end;

//PROCEUDRE FOR ADDING BASIC WEAPONS
procedure TfrmGame.addbasic;
begin
  //add 3 basic lasers to the player inventory
  inventory[1,1] := wep1;
  inventory[1,1].equipped := 1; //ATTACK 1
  inventory[1,2] := wep1;
  inventory[1,2].equipped := 2; //ATTACK 2
  inventory[1,3] :=  wep1;
  inventory[1,3].equipped := 3; //ATTACK 3

  //set these up as the current weapons
  att1 := inventory[1,1];
  att2 := inventory[1,2];
  att3 := inventory[1,3];

end;

//PROCEDURE FOR ADDING WEAPONS TO THE GAME
procedure TfrmGame.addweapons;
begin
  //add the basic laser
  with wep1 do
    begin
        name := 'Basic Laser';
        weapon := true; //it is a weapon
        dmg := 12;
        interval := 3; //2 sec
        equipped := 0; //0 DOES NOT HAVE ANYWHERE
        projimgref := 2;
        //ADD PROJECTILE TO ENEMY AND GAME FORMS
    end;

  //add missile launcher
  with wep2 do
    begin
       name := 'Missile Launcher';
       weapon := true;
       dmg := 31;
       interval := 7; //7 sec
       equipped := 0; //0 DOES NOT HAVE ANYWHERE
       projimgref := 5;
       //ADD PROJECTILE TO ENEMY AND GAME FORMS
    end;

  //add laser disk shooter
  with wep3 do
    begin
       name := 'Laser Disk Shooter';
       weapon := true;
       dmg := 6;
       interval := 8; //0.8 sec
       equipped := 0; //0 DOES NOT HAVE ANYWHERE
       projimgref := 0;
       //ADD PROJECTILE TO ENEMY AND GAME FORMS
    end;

  //add spike disk shooter
  with wep4 do
    begin
       name := 'Spike Disk Shooter';
       weapon := true;
       dmg := 17;
       interval := 10; //1.6 sec
       equipped := 0; //0 DOES NOT HAVE ANYWHERE
       projimgref := 1;
       //ADD PROJECTILE TO ENEMY AND GAME FORMS
    end;

  //add fireballer
  with wep5 do
    begin
       name := 'Fireballer';
       weapon := true;
       dmg := 20;
       interval := 3; //3 sec
       equipped := 0; //0 DOES NOT HAVE ANYWHERE
       projimgref := 3;
       //ADD PROJECTILE TO ENEMY AND GAME FORMS
    end;

  //add plasma gun
  with wep6 do
    begin
       name := 'Plasma Gun';
       weapon := true;
       dmg := 60;
       interval := 17; //20 sec
       equipped := 0; //0 DOES NOT HAVE ANYWHERE
       projimgref := 4;
       //ADD PROJECTILE TO ENEMY AND GAME FORMS
    end;


end;

//PROCEDUE FOR CLOSING THE FORM
procedure TfrmGame.closemyform(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
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

//NEW GAME
procedure TfrmGame.newgame;
var i                                  : byte;
    weptag,enginetag,shieldtag,hulltag : byte;
    death                              : rooms;
begin
  //bring out the welcome
  imgWelcome.left := 216;
  btnWelcome.left := 400;
  //delete old rooms
  for i := (componentcount-1) downto 0 do
      if (components[i] is rooms)
         then begin
                 //typecast it
                 death := components[i] as rooms;
                 //kill it
                 death.destroy; //dark much?
              end;
  //reset scrap
  scrap := 0;
  //set the newgame bool
  newgameB := true;
  row := 1;
  col := 4;
  //sleep
  wep1sleep := 0;
  wep2sleep := 0;
  wep3sleep := 0;
  wep4sleep := 0;
  wait1 := 0;
  wait2 := 0;
  wait3 := 0;
  wait4 := 0;
  //update bools
  up1 := false;
  up2 := false;
  up3 := false;
  up4 := false;
  //scrap is 0
  scrap := 0;
  //energy points
  energyPoints := 3;
  //teach shape to get clicked on
  //shBlock.OnClick := @frmMyShip.closemyform;
  //count
  count := 1;
  myshipB := true;
  //disable shop
  //frmEnemy.amt := 1;
  //unTravel.shop := false;
  battle := false;
  //randomize it all
  randomize;
  //setup starting variables (new game)
  health := 100;
  energy := 100;
  //create the rooms for said ship
  createrooms;
  //call update procedure to update health and energy
  update;
  //order everything up
  imgWrench.sendtoback; //FIRST
  //setup variables
  {hulltag := weproom.ic.tag;   //15
  enginetag := engineroom.ic.tag;  //16
  shieldtag := shieldroom.ic.tag;  //17
  hulltag := hullroom.ic.tag;      //18}
  //go through finding the certain components and send them to back
  for i := (componentcount-1) downto 0 do
      case components[i].tag of
        15 : hullroom.ic.SendToBack;
        16 : shieldroom.ic.sendtoback;
        17 : weproom.ic.sendtoback;
        18 : engineroom.ic.sendtoback;
      end;
  weproom.sendtoback;
  hullroom.sendtoback;   //THIRD - GROUP
  engineroom.sendtoback;
  shieldroom.sendtoback;
  //the ship is behind the rooms
  imgShip.sendtoback;
  //the background is behind the ship
  imgBackground.sendtoback;
  //imgHelpView.BringToFront;
  imgHelpView.bringtofront;
  shBlock.bringtofront;
  imgWelcome.bringtofront;
  btnWelcome.bringtofront;

  //add basic
  addbasic;
  //add another weapon for a bit of fun
  frmGame.addweapon(4);

  //checked is equal to false if a new ship is being created
  //frmTravel.created := false;
end;

//FORM CREATE
procedure TfrmGame.FormCreate(Sender: TObject);
begin
  randomize;
  //new game
  //wait
  //wait := 1;
  //rows and cols
  rows := 4;
  cols := 4;
  //add all the weapons
  addweapons;
  //create a new game
  newgame;
  //not repairing anything
  //repair := false;
  //frmGame.addweapon(4);
end;

//PLAYER IS DONE WITH THE LOOT BOX
procedure TfrmGame.btnLootFinishClick(Sender: TObject);
begin
   //clear the memo box
   memLoot.lines.Clear;
   //position it back
   shLootBack.left := -456;
   memLoot.left := -440;
   btnLootFinish.left := -440;
end;

//SEND THE WELCOME BACK
procedure TfrmGame.btnWelcomeClick(Sender: TObject);
begin
   //change newgame bool
   newgameB := false;
   //send them back
   btnWelcome.left := -100;
   imgWelcome.left := -500;
end;

//MOUSE ENTER THE IMAGE
procedure TfrmGame.imgHelpMouseEnter(Sender: TObject);
begin
  //change the colour of the shape behind it
  shHelpBack.brush.color := clYellow;
  //display the help
  imgHelpView.left := 280;
end;

//MOUSE LEAVES HELP
procedure TfrmGame.imgHelpMouseLeave(Sender: TObject);
begin
  //change the colour back
  shHelpBack.brush.color := clWhite;
  //undisplay the help
  imgHelpView.left := 848;

end;

//MOUSE ENTERS THE EXIT BTN
procedure TfrmGame.imgQuitMouseEnter(Sender: TObject);
begin
   //change sh colour
   shQuitback.brush.color := clYellow;
end;

//MOUSE LEAVES THE EXIT BTN
procedure TfrmGame.imgQuitMouseLeave(Sender: TObject);
begin
  //change sh colour back
  shQuitback.brush.color := clWhite;
end;

//ICON REPAIR CLICK
procedure TfrmGame.iconRepairClick(Sender : Tobject);
var who  : iconA;
    room : rooms;
    role : string;
begin
  //typecast it
  who := Sender as iconA;
  //holding var
  role := who.what;
  //find which room it is
  case role of
    'HULL'    : room := hullroom;
    'ENGINE'  : room := engineroom;
    'SHIELD'  : room := shieldroom;
    'WEAPONS' : room := weproom;
  end;
  //check if it's HP is below 100
  if (room.HP < 100)
    then begin
           //the room has been clicked to indicate a repair
           //Check if there is enough energy for a repair
           if (energy <> 0)
             then begin
                     //indicate which room it is
                     repairtarget := room;
                     //turn on the energy sapper timer which also adds health
                     timRepair.enabled := true;
                  end;
         end;

end;

//ROOM REPAIR CLICK
procedure TfrmGame.roomClick(Sender: TObject);
var room : rooms;
begin
  //typecast it
  room := Sender as rooms;
  //check if it's HP is below 100
  if (room.HP < 100)
    then begin
           //the room has been clicked to indicate a repair
           //Check if there is enough energy for a repair
           if (energy <> 0)
             then begin
                     //indicate which room it is
                     repairtarget := room;
                     //turn on the energy sapper timer which also adds health
                     timRepair.enabled := true;
                  end;
         end;
end;

//ROOM MOUSE LEAVE
procedure TfrmGame.roomMouseLeave(Sender: TObject);
begin
   //make the image invisible
   imgWrench.visible := false;
   //set repair to false
   //repair := false;
end;

//WHEN MY SHIP IS CLICKED
procedure TfrmGame.imgMyShipClick(Sender: TObject);
begin
  //check if newgame
  if (newgameB = false)
    then begin
            //boolean
            myshipB := true;
            //spawn the my ship form
            frmMyShip.show;
            //stop interaction with frmGame
            shBlock.left := -8;
            shBlock.top := -4;
            //turn off interaction with weapons

            //turn off frmGame timers
            frmGame.timEnergy.enabled := false;
            //check if there is a battle going on
            if (battle)
                    //stop interaction with the battlefield
                    then begin
                            //disable timers
                            frmEnemy.timBattle.enabled := false;
                            frmEnemy.timHP_MOVE.enabled := false;
                            //set block in motion
                            frmEnemy.shBlock.left := -8;
                            frmEnemy.shBlock.top := -22;
                         end;

         end;
end;

//MOUSE LEAVES THE TRAVEL BUTTON PROXIMITY
procedure TfrmGame.mouseleaveTRAVEL(Sender: TObject);
begin
   //set the button back to normal
   shTravelBACK.brush.color := clWhite;
   shTravelBACK.width := 60;
   shTravelBACK.height := 60;
   imgTravel.width := 50;
   imgTravel.height := 50;
end;

//MOUSE ENTERS THE TRAVEL BUTTON PROXIMITY
procedure TfrmGame.mousemoveTRAVEL(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
   //update the button to signify the hover
   shTravelBACK.brush.color := clYellow;
   shTravelBACK.width := 65;
   shTravelBACK.height := 65;
   imgTravel.width := 55;
   imgTravel.height := 55;
   //shTravelBACK.left := 395;
   //shTravelBACK.top := 13-5;
end;

//USER CLICKS THE TRAVEL BUTTON
procedure TfrmGame.travelclick(Sender : TObject);
begin
  if (newgameB = false)
      then begin
              //check if battle is true
              if (battle)
                 then begin
                        //turemy.timHP_MOVE.enabled := false;
                        //set battle to falsn off battle timers
                        frmEnemy.timBattle.enabled := false;
                        frmEnemy.timHP_MOVE.enabled := false;
                        //battle := false;
                        //hide the battle form
                        frmEnemy.Hide;
                      end;
              //hide this form
              frmGame.hide;
              //show the travel form
              frmTravel.show;
              //update score
              frmTravel.caption := frmGame.caption;

           end;
end;

//MOUSE MOVES OVER MY SHIP
procedure TfrmGame.mousemoveSHIP(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
   //update the button as the mouse has moved over it
   shMYSHIPback.brush.color := clYellow;
   //update size
   shMYSHIPback.Height := 64;
   shMYSHIPback.Width := 82;
   imgMyShip.height := 45;
   imgMyShip.width := 48;
   //update positioning
   shMYSHIPback.left := 487;
   imgMyShip.left := 506;
end;

//MOUSE LEAVES MY SHIP BTN
procedure TfrmGame.mouseleaveSHIP(Sender: TObject);
begin
   //revert the hover update
   shMYSHIPback.brush.color := clWhite;
   //update size
   shMYSHIPback.Height := 59;
   shMYSHIPback.Width := 77;
   imgMyShip.height := 40;
   imgMyShip.width := 43;
   //update positioning
   shMYSHIPback.left := 489;
   imgMyShip.left := 508;
end;

//MOUSE HOVERS OVER A ROOM
procedure TfrmGame.roomMouseEnter(Sender: TObject);
var room : rooms;
    task : string;
begin
    //typecast it
    room := Sender as rooms;
    //find out what task
    task := room.task;
    //check if it's not in battle
    if ((battle = false) or (battle)) //It would be too hard to take it out
       then begin
                //do a set of commands accordingly
                case task of
                 'HULL' : begin
                            //check for damage
                            if (hullroom.HP < 100)
                               then begin
                                        //position the repair image
                                        imgWrench.top := 301;
                                        imgWrench.left := 576;
                                        //make it visible
                                        imgWrench.visible := true;
                                    end;
                          end;
                 'WEAPONS' : begin
                               //check for damage
                               if (weproom.HP < 100)
                                  then begin
                                         //position the repair image
                                         imgWrench.top := 200;
                                         imgWrench.left := 568;
                                         //make it visible
                                         imgWrench.visible := true;
                                       end;
                             end;
                 'ENGINE' : begin
                               if (engineroom.HP < 100)
                                  then begin
                                           //position the repair image
                                           imgWrench.top := 272;
                                           imgWrench.left := 360;
                                           //make it visible
                                           imgWrench.visible := true;
                                       end;
                            end;
                 'SHIELD' : begin
                              if (shieldroom.HP < 100)
                                 then begin
                                          //position the repair image
                                          imgWrench.top := 358;
                                          imgWrench.left := 592;
                                          //make it visible
                                          imgWrench.visible := true;
                                      end;
                            end;
                end;

       end;


    //change repair to true
    //repair := true;
end;

//ACTUAL ENERGY RECHARGE
procedure TfrmGame.timEnergyRechargeTimer(Sender: TObject);
begin
  //if form travel is open don't recharge
  if ((frmTravel.visible = false) and (frmJumping.visible = false))
     then begin
              //count is the COEFFICIENT OF TIME (higher = slower)
              //if count equals 3. IF IT DOES KEEP GOING
              if (count = 3)
                 then begin
                        //check if energy is maxed out
                        if (energy <> 100)
                          //if it isn't keep adding some
                          then begin
                                 //energy add
                                 energy := energy + 1;
                                 //count reset
                                 count := 1;
                               end;
                      end
                      //it doesn't, add to it
                      else inc(count);
          end;
end;

//MOUSE HOVERS OVER AN ICON
procedure TfrmGame.iconMouseEnter(Sender: TObject);
var ico : iconA;
    this : string;
begin
  //typecast it
  ico := Sender as iconA;
  //find the type
  this := ico.what;
  //find out if it's in battle
  if ((battle = false) or (battle)) //too difficult to take out
     then begin
              //find which one it is
              case this of
               'HULL' : begin
                          if (hullroom.HP < 100)
                             then imgWrench.visible := true;
                        end;
               'SHIELD' : begin
                            if (shieldroom.HP < 100)
                               then imgWrench.visible := true;
                          end;
               'WEAPONS' : begin
                            if (weproom.HP < 100)
                              then imgWrench.visible := true;
                           end;
               'ENGINE' : begin
                            if (engineroom.HP < 100)
                              then imgWrench.visible := true;
                          end;
              end;

     end;


end;

//UPDATE ENERGY + OTHER THINGS
procedure TfrmGame.timEnergyTimer(Sender: TObject);
var oldnum : integer;
    new    : projectiles;
    i      : byte;
    find   : TImage;
begin
  //sort out the intervals for timers
  //Basic Laser: 2000milli /10 = 100charge/100milli
  //Missile Launcher: 7000milli /35 = 100charge/100milli
  //Laser Disk Shooter: 800milli / 100charge/100milli
  //Spike Disk Shooter: 1600milli / 100charge/100milli
  //Fireballer: 3000milli / 100charge/100milli
  for i := (componentcount-1) downto 0 do
      if ((components[i] is unEnemy.projectiles) and (battle = false))
        then begin
               //typecast
               new := components[i] as projectiles;
               //destory it
               new.destroy;
             end;
  //update scrap
  frmGame.Caption := 'SPACE EXPLORER (Score: '+inttostr(Scrap)+')';
  //CHECK IF BATTLE IS TRUE
  if (battle)
    then begin
            if (att1.projimgref <> 0)
              then begin
                     //variable it up
                     att1name := att1.name;
                     //battle timer
                     timWep1.enabled := true;
                     //showmessage('a')
                   end;

            if (att2.projimgref <> 0)
              then begin
                     //variable it up
                     att2name := att2.name;
                     //battle timer
                     timWep2.enabled := true
                   end;

            if (att3.projimgref <> 0)
              then begin
                     //variable it up
                     att3name := att3.name;
                     //battle timer
                     timWep3.enabled := true;
                   end;

            if (att4.projimgref <> 0)
              then begin
                     //variable it up
                     att4name := att4.name;
                     //battle timer
                     timWep4.enabled := true;
                   end;

      end;

  //update the attacks
  attackupdate;
  //move the wrench
  if (battle = false)
    then begin
            imgWrench.left := Mouse.CursorPos.X-270;
            imgWrench.top := Mouse.CursorPos.Y-145;
         end
         else begin
                imgWrench.left := Mouse.CursorPos.X-80;
                imgWrench.top := Mouse.CursorPos.Y-145;
              end;


  //update the progress bar and label
  {pbEnergy.position := energy;
  labEnergy.caption := 'Energy level: ' + inttostr(energy) + '%';}
  //check if the energy is maxed out
  //update health
  update;
  //move all projectiles
  ccount := componentcount;

  //check all rooms and update colour of rooms respectively
  weproom.Brush.Color := RGB(255,trunc(weproom.HP*2.55),trunc(weproom.HP*2.55));
  engineroom.Brush.Color := RGB(255,trunc(engineroom.HP*2.55),trunc(engineroom.HP*2.55));
  hullroom.Brush.Color := RGB(255,trunc(hullroom.HP*2.55),trunc(hullroom.HP*2.55));
  shieldroom.Brush.Color := RGB(255,trunc(shieldroom.HP*2.55),trunc(shieldroom.HP*2.55));
  {for i := (componentcount-1) downto 0 do
      if (components[i] is TImage)
               then begin
                      //typecast it
                      find := components[i] as TImage;
                      //check width
                      //showmessage(inttostr(find.width));
                      if (find.tag >= 5)
                         //move it to the right
                         then find.left := find.left + 5;
                    end;}
  //frmEnemy.who.left + 50

end;

//SLEEP FOR MISS
procedure TfrmGame.timMiss2Timer(Sender: TObject);
begin
   //disable both timers
   timMiss.enabled := false;
   timMiss2.enabled := false;
   //make it invisible
   labMiss.visible := false;
   shMiss.visible := false;
end;

//MISS VISIBLE TIMER
procedure TfrmGame.timMissTimer(Sender: TObject);
begin
  //change lab and shape visibility
  labMiss.visible := not(labMiss.visible);
  shMiss.visible := not(shMiss.visible);
end;

//REPAIR TIMER
procedure TfrmGame.timRepairTimer(Sender: TObject);
var role : string;
begin
  //find the room and check that it's HP does not equal 100
  if ((repairtarget.HP < 100) and (energy > 0))
    then begin
           //repair the target
           if (repairtarget.HP + 6 < 100)
               then repairtarget.HP := repairtarget.HP + 6
               else repairtarget.HP := 100;
           //turn off energy recharger
           timEnergyRecharge.enabled := false;
           //drain the energy
           if (energy - 12 > 0)
               then energy := energy - 12
               else energy := 0;
           //change the icon of the image
           repairtarget.ic.picture := imgWrench.picture;
           //make the wrench invisible
           imgWrench.visible := false;
         end
    //finished the job
    else begin
           timRepair.enabled := false;
           //turn on the recharge timer
           timEnergyRecharge.enabled := true;
           //find the role
           role := repairtarget.task;
           //change the image back around
           case role of
            'HULL' : repairtarget.ic.picture := imgHull.picture;
            'SHIELD' : repairtarget.ic.picture := imgShield.picture;
            'WEAPONS' : repairtarget.ic.picture := imgWepIcon.picture;
            'ENGINE' : repairtarget.ic.picture := imgEngineIcon.picture;
           end;

         end;
   //LabMyShip.caption := inttostr(hullroom.HP);
end;

//MOVE USER PROJECTILES (now on frmEnemy)
procedure TfrmGame.timUserProjTimer(Sender: TObject);
var i    : byte;
    proj : projectiles;
begin
  {//go through all components checking for projectiles
  for i := (componentcount-1) downto 0 do
      if (components[i] is projectiles)
          then begin
                 //typecast it
                 showmessage('a');
                 proj := components[i] as projectiles;
                 //check if it's a user proj
                 if (proj.user)
                     then begin
                            //move it to the right
                            proj.left := proj.left + 30;
                            //check if it's gone off the screen
                            if (proj.left > clientwidth + proj.width)
                                then begin
                                       //call a function to create a new one on frmEnemy

                                       //destroy the projectile
                                       proj.destroy;
                                     end;
                          end;
               end;}

end;

//SLEEP TIMER FOR WEP 1
procedure TfrmGame.timWep1Timer(Sender: TObject);
var interv : integer;
    finter : integer;
    charge : integer;
begin
  if (battle)
      then begin
              //charge := 8;
              //showmessage('a');
              if (up1 = false)
                  then begin
                           //find what the interval is
                           {case interv of
                            2000: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 8;
                                  end;
                            7000: begin
                                     //setup interval
                                     timWep1.interval := 350;
                                     //setup charge rate
                                     charge := 20;

                                  end;
                            800: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 20;

                                  end;
                            1600: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 20;

                                  end;
                            3000: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 20;

                                  end;
                            20000: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 20;
                                  end
                           end; }

                           //setup interval
                           interv := att1.interval;
                           //setup charge
                           //charge := 13;
                           //set bool
                           up1 := true;
                      end;
              if (wait1 = att1.interval)
                  then begin
                          //labTravel.caption := inttostr(pbWep1.Position);
                          charge := 10;
                          //showmessage(inttostr(charge));
                          //check if it has reached max yet
                          if (wep1sleep <> 100)
                              //check if adding an amount won't destroy it
                              then if (wep1sleep + charge < 101)
                                      //if not add an amount to the pb
                                      then begin
                                             wep1sleep := wep1sleep + charge;
                                             pbWep1.position := wep1sleep;
                                           end;
                                           //reset wait
                                           wait1 := 1;

                       end
                       else inc(wait1);

      end;
end;

//SLEEP TIMER FOR WEP 2
procedure TfrmGame.timWep2Timer(Sender: TObject);
var interv : integer;
    finter : integer;
    charge : integer;
begin
  if (battle)
      then begin
              //charge := 8;
              //showmessage('a');
              if (up2 = false)
                  then begin
                           //find what the interval is
                           {case interv of
                            2000: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 8;
                                  end;
                            7000: begin
                                     //setup interval
                                     timWep1.interval := 350;
                                     //setup charge rate
                                     charge := 20;

                                  end;
                            800: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 20;

                                  end;
                            1600: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 20;

                                  end;
                            3000: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 20;

                                  end;
                            20000: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 20;
                                  end
                           end; }

                           //setup interval
                           interv := att1.interval;
                           //setup charge
                           //charge := 8;
                           //set bool
                           up2 := true;
                      end;
              if (wait2 = att2.interval)
                  then begin
                          charge := 10;
                          //showmessage(inttostr(charge));
                          //check if it has reached max yet
                          if (wep2sleep <> 100)
                              //check if adding an amount won't destroy it
                              then if (wep2sleep + charge < 101)
                                      //if not add an amount to the pb
                                      then begin
                                             wep2sleep := wep2sleep + charge;
                                             pbWep2.position := wep2sleep;

                                           end;
                                           //reset wait
                                           wait2 := 1;

                         end
                         else inc(wait2);

      end;
end;

//SLEEP TIMER FOR WEP 3
procedure TfrmGame.timWep3Timer(Sender: TObject);
var interv : integer;
    finter : integer;
    charge : integer;
begin
  if (battle)
      then begin
              //charge := 8;
              //showmessage('a');
              if (up3 = false)
                  then begin
                           //find what the interval is
                           {case interv of
                            2000: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 8;
                                  end;
                            7000: begin
                                     //setup interval
                                     timWep1.interval := 350;
                                     //setup charge rate
                                     charge := 20;

                                  end;
                            800: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 20;

                                  end;
                            1600: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 20;

                                  end;
                            3000: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 20;

                                  end;
                            20000: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 20;
                                  end
                           end; }

                           //setup interval
                           interv := att1.interval;
                           //setup charge
                           //charge := 8;
                           //set bool
                           up3 := true;
                      end;
              if (wait3 = att3.interval)
                  then begin
                          charge := 10;
                          //showmessage(inttostr(charge));
                          //check if it has reached max yet
                          if (wep3sleep <> 100)
                              //check if adding an amount won't destroy it
                              then if (wep3sleep + charge < 101)
                                      //if not add an amount to the pb
                                      then begin
                                             wep3sleep := wep3sleep + charge;
                                             pbWep3.position := wep3sleep;

                                           end;
                                           //reset wait
                                           wait3 := 1;

                       end
                       else inc(wait3);

      end;
end;

//SLEEP TIMER FOR WEP 4
procedure TfrmGame.timWep4Timer(Sender: TObject);
var interv : integer;
    finter : integer;
    charge : integer;
begin
  if (battle)
      then begin
              //charge := 8;
              //showmessage('a');
              if (up4 = false)
                  then begin
                           //find what the interval is
                           {case interv of
                            2000: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 8;
                                  end;
                            7000: begin
                                     //setup interval
                                     timWep1.interval := 350;
                                     //setup charge rate
                                     charge := 20;

                                  end;
                            800: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 20;

                                  end;
                            1600: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 20;

                                  end;
                            3000: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 20;

                                  end;
                            20000: begin
                                     //setup interval
                                     timWep1.interval := 200;
                                     //setup charge rate
                                     charge := 20;
                                  end
                           end; }

                           //setup interval
                           interv := att1.interval;
                           //setup charge
                           //charge := 8;
                           //set bool
                           up4 := true;
                      end;
              if (wait4 = att4.interval)
                  then begin
                          charge := 10;
                          //showmessage(inttostr(charge));
                          //check if it has reached max yet
                          if (wep4sleep <> 100)
                              //check if adding an amount won't destroy it
                              then if (wep4sleep + charge < 101)
                                      //if not add an amount to the pb
                                      then begin
                                             wep4sleep := wep4sleep + charge;
                                             pbWep4.position := wep4sleep;

                                           end;
                                           //reset wait
                                           wait4 := 1;

                       end
                       else inc(wait4);

      end;
end;

//KEY PRESS TIMER
procedure TfrmGame.timWepTimer(Sender: TObject);
begin
   //check for keypresses
   keyclick;
end;

//CALC DISTANCE
function TfrmGame.distance(x : real; y : real; mousex : integer; mousey : integer) : real;
begin
   //substitute values into the formula
   distance := sqrt((x-mousex)*(x-mousex)+(y-mousey)*(y-mousey));
end;

//UPDATE HP AND ENERGY
procedure TfrmGame.update;
begin
  //update percentage labels of hull and energy
  labHP.caption := 'Hull HP: ' + inttostr(health) + '%';
  labEnergy.caption := 'Energy Level: ' + inttostr(energy) + '%';
  //update health depending on the HP of the rooms
  health := weproom.HP div 4 + engineroom.HP div 4 + hullroom.HP div 4 + shieldroom.HP div 4;
  //setup position of TProgressBars
  pbHP.position := health;
  {showmessage(inttostr(weproom.hp));
  showmessage(inttostr(engineroom.hp));
  showmessage(inttostr(hullroom.hp));
  showmessage(inttostr(shieldroom.hp));}
  pbEnergy.position := energy;
end;

//ORIGINAL SHIP CREATE PROCEDURE
procedure TfrmGame.originalcreate;
var room     : rooms;
    icontemp : iconA;
begin
  //spawn the hull image
  icontemp := iconA.create(nil);
  with icontemp do
    begin
      parent := frmGame;
      picture := imgHull.picture;
      stretch := true;
      tag := 15;
      //role
      icontemp.what := 'HULL';
      //position it up
      width := 24;
      height := 26;
      Left := 520;
      top := 323;
      //teach it some events
      onMouseEnter := @iconMouseEnter;
      onMouseLeave := @roomMouseLeave;
      onClick := @iconRepairClick;
    end;
    //spawn in the HULL room with a tag of 1
    hullroom := rooms.create(nil); //NIL INSTEAD OF SELF? WHAT? - it shouldn't matter
    with hullroom do
      begin
        parent := frmGame;
        tag := 1;
        //setup link to icon
        ic := icontemp;
        //setup basic room stats
        HP := 100;
        task := 'HULL';
        amt := 0; //when the room spawns NO ONE is in it
        //room dimensions
        height := 45;
        width := 57;
        top := 313;
        left := 504;
        //teach it some events
        onMouseEnter := @roomMouseEnter;
        onMouseLeave := @roomMouseLeave;
        onClick := @roomClick;
      end;

  //spawn the shield image
  icontemp := iconA.create(nil);
  with icontemp do
    begin
      parent := frmGame;
      picture := imgShield.picture;
      stretch := true;
      tag := 16;
      //role
      icontemp.what := 'SHIELD';
      //position it up
      width := 24;
      height := 26;
      Left := 516;
      top := 403;
      //teach it some events
      onMouseEnter := @iconMouseEnter;
      onMouseLeave := @roomMouseLeave;
      onClick := @iconRepairClick;

    end;
    //spawn in the SHIELD room with a tag of 2
    shieldroom := rooms.create(nil); //NIL INSTEAD OF SELF? WHAT?
    with shieldroom do
      begin
        parent := frmGame;
        tag := 2;
        ic := icontemp;
        //setup basic room stats
        HP := 100;
        task := 'SHIELD';
        amt := 0; //when the room spawns NO ONE is in it
        //room dimensions
        height := 65;
        width := 81;
        top := 384;
        left := 488;
        //teach it some events
        onMouseEnter := @roomMouseEnter;
        onMouseLeave := @roomMouseLeave;
        onClick := @roomClick;
      end;

  //add the weapons icon
  icontemp := iconA.create(nil);
  with icontemp do
    begin
      parent := frmGame;
      picture := imgWepIcon.picture;
      stretch := true;
      tag := 17;
      //role
      icontemp.what := 'WEAPONS';
      //position it up + dim
      height := 26;
      left := 516;
      top := 243;
      width := 24;
      bringtofront;
      //teach it some events
      onMouseEnter := @iconMouseEnter;
      onMouseLeave := @roomMouseLeave;
      onClick := @iconRepairClick;
    end;
    //spawn in the WEAPONS room with a tag of 3
    weproom := rooms.create(nil);
    with weproom do
      begin
        parent := frmGame;
        tag := 3;
        ic := icontemp;
        //basic stats
        HP := 100;
        task := 'WEAPONS';
        amt := 0;
        //dimensions and positioning
        height := 65;
        left := 488;
        top := 225;
        width := 81;
        //teach it some events
        onMouseEnter := @roomMouseEnter;
        onMouseLeave := @roomMouseLeave;
        onClick := @roomClick;
      end;

  {//spawn in the main CONNECTOR room with a tag of 4
  room := rooms.Create(nil);
  with room do
    begin
      parent := frmGame;
      tag := 4;
      //basic stats
      HP := 100;
      task := 'CORRIDOR';
      amt := 0;
      //setup dimensions
      height := 65;
      left := 432;
      top := 304;
      Width := 73
    end;

  //spawn in the shield room CORRIDOR with a tag of 5
  room := rooms.create(nil);
  with room do
    begin
      parent := frmGame;
      tag := 5;
      //basic stats
      HP := 100;
      task := 'CORRIDOR';
      amt := 0;
      //setup dimensions
      height := 81;
      left := 456;
      top := 368;
      width := 33
    end;

  //spawn in the weapons room CORRIDOR with a tag of 6
  room := rooms.create(nil);
  with room do
    begin
      parent := frmGame;
      tag := 6;
      //basic stats
      HP := 100;
      task := 'CORRIDOR';
      amt := 0;
      //setup dimensions
      height := 81;
      left := 456;
      top := 224;
      width := 33
    end;  }

  icontemp := iconA.create(nil);
  with icontemp do
    begin
      parent := frmGame;
      picture := imgEngineIcon.picture;
      stretch := true;
      tag := 18;
      //role
      icontemp.what := 'ENGINE';
      //positioning and dimensions
      height := 26;
      left := 389;
      top := 323;
      width := 24;
      //teach it some events
      onMouseEnter := @iconMouseEnter;
      onMouseLeave := @roomMouseLeave;
      onClick := @iconRepairClick;
    end;
    //spawn in the ENGINE room with a tag of 4
    engineroom := rooms.create(nil);
    with engineroom do
      begin
        parent := frmGame;
        tag := 4;
        ic := icontemp;
        //basic stats
        HP := 100;
        task := 'ENGINE';
        amt := 0;
        //role
        icontemp.what := 'ENGINE';
        //dimensions and positioning
        height := 46;
        left := 368;
        top := 313;
        width := 65;
        //teach it some events
        onMouseEnter := @roomMouseEnter;
        onMouseLeave := @roomMouseLeave;
        onClick := @roomClick;
      end;



end;

//Determine which ship the player is using - call on specific procedure for it
procedure TfrmGame.createrooms;
begin
  //check which ship the PLAYER is using

  //original for current time since there's only 1
  originalcreate;
end;



end.

{
TO DO LIST
- Coloured Progress bars
- A visible notice saying OUT OF ENERGY when repairing fails
- PROJECTILE GOES WHERE THE MOUSE CLICKS
- Settings button to QUIT
- UPDATE SCORE AND SAVE IT WHEN DEAD
- LOCATION HIT WHEN YOU CLICK ON ENEMY
- Help button for HELP (Photoshop style)

- Move Loot to FINAL battle end. Once Ok is clicked go back to normal
}

