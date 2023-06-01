program speccy;

uses
Cmem, SysUtils, mainUnit, KeyboardUnit, DialogUnit;


var Game: TGame;

begin
  Game:= TGame.Create;
  Game.Run;
  Game.Free;
end.
