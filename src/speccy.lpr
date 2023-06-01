program speccy;

uses
Cmem, SysUtils, mainUnit;


var Game: TGame;

begin
  Game:= TGame.Create;
  Game.Run;
  Game.Free;
end.
