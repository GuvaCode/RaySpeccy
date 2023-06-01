unit mainUnit;

{$mode objfpc}{$H+} 

interface

uses
  Raylib, rlgl, FrogApplication,
  Computer,
  Computer.Spectrum, SysUtils, Classes;

type
{ TGame }
TGame = class(TFrApplication)
  private
    FHardware: IHardware;
    FTexture: TTexture2d;
    FRectSource: TRectangle;
    FRectDest: TRectangle;
    HelpTim: Integer;
    ShowHelp: Boolean;
    ScreenWidth: Integer;
    FShader: array [0..3] of TShader;
    FEnbaleShader: array [0..3] of Boolean;
    FTarget: TRenderTexture2D;
    procedure DoPaintSpeccy(Sender: TObject; const AImage, ABorder: PByte; const AWidth, AHeight, AScanline: Integer);
    procedure ScaleFactor(Factor:Integer);
  protected
  public

    constructor Create; override;
    procedure Init; override;
    procedure Update; override;
    procedure Render; override;
    procedure Shutdown; override;
    procedure Resized; override;
  end;

const GLSL_VERSION =330;

implementation
uses System.Audio, Computer.Spectrum.Graphic;

procedure TGame.DoPaintSpeccy(Sender: TObject; const AImage, ABorder: PByte;
  const AWidth, AHeight, AScanline: Integer);
begin
 with FTexture do
 begin
 // Copy pixel data to VRAM
   UpdateTexture(FTexture,AImage);
 //  UpdateTexture(FTexture,ABorder);
 end;
end;

procedure TGame.ScaleFactor(Factor: Integer);
begin
 SetWindowSize(320*Factor,256*Factor);
 SetWindowPosition( (GetMonitorWidth(GetCurrentMonitor) div 2)  -320*Factor div 2 ,
 (GetMonitorHeight(GetCurrentMonitor) div 2) - 256*Factor div 2);
 ScreenWidth := 256*Factor;
 FTarget := LoadRenderTexture(320*Factor, 256*Factor);
end;

constructor TGame.Create;
begin
end;

procedure TGame.Init;
var i: integer;
begin
  inherited Init;
  InitWindow(320, 256, 'FrogEngine - Game Project');
  SetWindowState(FLAG_VSYNC_HINT or FLAG_MSAA_4X_HINT);

  SetWindowMinSize(320,256);
  ShowFps:=False;

  FTexture := Default(TTexture2d);
  FTexture.id := rlLoadTexture(nil, 320, 256, PIXELFORMAT_UNCOMPRESSED_R8G8B8A8, 1);
  FTexture.width := 320;
  Ftexture.height := 256;
  Ftexture.format := PIXELFORMAT_UNCOMPRESSED_R8G8B8A8;
  Ftexture.mipmaps := 1;

  FRectSource := RectangleCreate(0,0,320,256);
  FRectDest := FRectSource;

  FHardware := TZXSpectrum.create;
  FHardware.SetPaintCallback(@DoPaintSpeccy);
  FHardware.SetModel(0);



  ScreenWidth := 256;
  ShowHelp := False;

  FShader[0] := LoadShader(nil, TextFormat('shaders/glsl%i/blur.fs', GLSL_VERSION));
  FShader[1] := LoadShader(nil, TextFormat('shaders/glsl%i/grayscale.fs', GLSL_VERSION));
  FShader[2] := LoadShader(nil, TextFormat('shaders/glsl%i/posterization.fs', GLSL_VERSION));
  FShader[3] := LoadShader(nil, TextFormat('shaders/glsl%i/scanlines.fs', GLSL_VERSION));

  for i:=0 to 3 do FEnbaleShader[i]:=false;
  FTarget := LoadRenderTexture(320, 256);
end;


procedure TGame.Update;
var Shift: TShiftState; droppedFiles: TFilePathList;
begin
 inherited Update;

 FHardware.CycleTick;

 if IsKeyPressed(294) then FEnbaleShader[0] := not FEnbaleShader[0];
 if IsKeyPressed(295) then FEnbaleShader[1] := not FEnbaleShader[1];
 if IsKeyPressed(296) then FEnbaleShader[2] := not FEnbaleShader[2];
 if IsKeyPressed(297) then FEnbaleShader[3] := not FEnbaleShader[3];

 if IsKeyPressed(298) then ScaleFactor(1);
 if IsKeyPressed(299) then ScaleFactor(2);
 if IsKeyPressed(300) then ScaleFactor(3);

 if IsKeyDown(KEY_LEFT_ALT) and IsKeyDown(KEY_ONE) then Begin FHardware.Reset; FHardware.SetModel(0); end;
 if IsKeyDown(KEY_LEFT_ALT) and IsKeyDown(KEY_TWO) then Begin FHardware.Reset; FHardware.SetModel(1); end;
 if IsKeyDown(KEY_LEFT_ALT) and IsKeyDown(KEY_THREE) then Begin FHardware.Reset; FHardware.SetModel(2); end;
 if IsKeyDown(KEY_LEFT_ALT) and IsKeyDown(KEY_FOUR) then Begin FHardware.Reset; FHardware.SetModel(3); end;
 if IsKeyDown(KEY_LEFT_ALT) and IsKeyDown(KEY_FIVE) then Begin FHardware.Reset; FHardware.SetModel(4); end;
 if IsKeyDown(KEY_LEFT_ALT) and IsKeyDown(KEY_SIX) then Begin FHardware.Reset; FHardware.SetModel(5); end;
 if IsKeyDown(KEY_LEFT_ALT) and IsKeyDown(KEY_SEVEN) then Begin FHardware.Reset; FHardware.SetModel(6); end;
 if IsKeyDown(KEY_LEFT_ALT) and IsKeyDown(KEY_EIGHT) then Begin FHardware.Reset; FHardware.SetModel(7); end;
 if IsKeyDown(KEY_LEFT_ALT) and IsKeyDown(KEY_NINE) then Begin FHardware.Reset; FHardware.SetModel(8); end;

 if IsKeyPressed(290) then ShowHelp:=not ShowHelp;

 if IsKeyPressed(KEY_LEFT_SHIFT) then Include(Shift, ssShift) else
 if IsKeyReleased(KEY_LEFT_SHIFT) then Exclude(Shift, ssShift);

 if IsKeyPressed(KEY_LEFT_CONTROL) then Include(Shift, ssCtrl) else
 if IsKeyReleased(KEY_LEFT_CONTROL) then Exclude(Shift, ssCtrl);

 if IsKeyPressed(KEY_BACKSPACE) then
 begin
 Include(Shift, ssShift);
 FHardware.doKey(true, 8, Shift);
 end;

 if IsKeyReleased(KEY_BACKSPACE) then
 begin
 Exclude(Shift, ssShift);
 FHardware.doKey(false, 8, Shift);
 end;

 if IsKeyDown(KEY_A) then FHardware.doKey(true, 65, Shift);
 if IsKeyUp(KEY_A) then FHardware.doKey(false, 65, Shift);

 if IsKeyDown(KEY_B) then FHardware.doKey(true, 66, Shift);
 if IsKeyUp(KEY_B) then FHardware.doKey(false, 66, Shift);

 if IsKeyDown(KEY_C) then FHardware.doKey(true, 67, Shift);
 if IsKeyUp(KEY_C) then FHardware.doKey(false, 67, Shift);

 if IsKeyDown(KEY_D) then FHardware.doKey(true, 68, Shift);
 if IsKeyUp(KEY_D) then FHardware.doKey(false, 68, Shift);

 if IsKeyDown(KEY_E) then FHardware.doKey(true, 69, Shift);
 if IsKeyUp(KEY_E) then FHardware.doKey(false, 69, Shift);

 if IsKeyDown(KEY_F) then FHardware.doKey(true, 70, Shift);
 if IsKeyUp(KEY_F) then FHardware.doKey(false, 70, Shift);

 if IsKeyDown(KEY_G) then FHardware.doKey(true, 71, Shift);
 if IsKeyUp(KEY_G) then FHardware.doKey(false, 71, Shift);

 if IsKeyDown(KEY_H) then FHardware.doKey(true, 72, Shift);
 if IsKeyUp(KEY_H) then FHardware.doKey(false, 72, Shift);

 if IsKeyDown(KEY_I) then FHardware.doKey(true, 73, Shift);
 if IsKeyUp(KEY_I) then FHardware.doKey(false, 73, Shift);

 if IsKeyDown(KEY_J) then FHardware.doKey(true, 74, Shift);
 if IsKeyUp(KEY_J) then FHardware.doKey(false, 74, Shift);

 if IsKeyDown(KEY_K) then FHardware.doKey(true, 75, Shift);
 if IsKeyUp(KEY_K) then FHardware.doKey(false, 75, Shift);

 if IsKeyDown(KEY_L) then FHardware.doKey(true, 76, Shift);
 if IsKeyUp(KEY_L) then FHardware.doKey(false, 76, Shift);

 if IsKeyDown(KEY_M) then FHardware.doKey(true, 77, Shift);
 if IsKeyUp(KEY_M) then FHardware.doKey(false, 77, Shift);

 if IsKeyDown(KEY_N) then FHardware.doKey(true, 78, Shift);
 if IsKeyUp(KEY_N) then FHardware.doKey(false, 78, Shift);

 if IsKeyDown(KEY_O) then FHardware.doKey(true, 79, Shift);
 if IsKeyUp(KEY_O) then FHardware.doKey(false, 79, Shift);

 if IsKeyDown(KEY_P) then FHardware.doKey(true, 80, Shift);
 if IsKeyUp(KEY_P) then FHardware.doKey(false, 80, Shift);

 if IsKeyDown(KEY_Q) then FHardware.doKey(true, 81, Shift);
 if IsKeyUp(KEY_Q) then FHardware.doKey(false, 81, Shift);

 if IsKeyDown(KEY_R) then FHardware.doKey(true, 82, Shift);
 if IsKeyUp(KEY_R) then FHardware.doKey(false, 82, Shift);

 if IsKeyDown(KEY_S) then FHardware.doKey(true, 83, Shift);
 if IsKeyUp(KEY_S) then FHardware.doKey(false, 83, Shift);

 if IsKeyDown(KEY_T) then FHardware.doKey(true, 84, Shift);
 if IsKeyUp(KEY_T) then FHardware.doKey(false, 84, Shift);

 if IsKeyDown(KEY_U) then FHardware.doKey(true, 85, Shift);
 if IsKeyUp(KEY_U) then FHardware.doKey(false, 85, Shift);

 if IsKeyDown(KEY_V) then FHardware.doKey(true, 86, Shift);
 if IsKeyUp(KEY_V) then FHardware.doKey(false, 86, Shift);

 if IsKeyDown(KEY_W) then FHardware.doKey(true, 87, Shift);
 if IsKeyUp(KEY_W) then FHardware.doKey(false, 87, Shift);

 if IsKeyDown(KEY_X) then FHardware.doKey(true, 88, Shift);
 if IsKeyUp(KEY_X) then FHardware.doKey(false, 88, Shift);

 if IsKeyDown(KEY_Y) then FHardware.doKey(true, 89, Shift);
 if IsKeyUp(KEY_Y) then FHardware.doKey(false, 89, Shift);

 if IsKeyDown(KEY_Z) then FHardware.doKey(true, 90, Shift);
 if IsKeyUp(KEY_Z) then FHardware.doKey(false, 90, Shift);

 if IsKeyDown(KEY_ZERO) then FHardware.doKey(true, 48, Shift);
 if IsKeyUp(KEY_ZERO) then FHardware.doKey(false, 48, Shift);

 if IsKeyDown(KEY_ONE) then FHardware.doKey(true, 49, Shift);
 if IsKeyUp(KEY_ONE) then FHardware.doKey(false, 49, Shift);

 if IsKeyDown(KEY_TWO) then FHardware.doKey(true, 50, Shift);
 if IsKeyUp(KEY_TWO) then FHardware.doKey(false, 50, Shift);

 if IsKeyDown(KEY_THREE) then FHardware.doKey(true, 51, Shift);
 if IsKeyUp(KEY_THREE) then FHardware.doKey(false, 51, Shift);

 if IsKeyDown(KEY_FOUR) then FHardware.doKey(true, 52, Shift);
 if IsKeyUp(KEY_FOUR) then FHardware.doKey(false, 52, Shift);

 if IsKeyDown(KEY_FIVE) then FHardware.doKey(true, 53, Shift);
 if IsKeyUp(KEY_FIVE) then FHardware.doKey(false, 53, Shift);

 if IsKeyDown(KEY_SIX) then FHardware.doKey(true, 54, Shift);
 if IsKeyUp(KEY_SIX) then FHardware.doKey(false, 54, Shift);

 if IsKeyDown(KEY_SEVEN) then FHardware.doKey(true, 55, Shift);
 if IsKeyUp(KEY_SEVEN) then FHardware.doKey(false, 55, Shift);

 if IsKeyDown(KEY_EIGHT) then FHardware.doKey(true, 56, Shift);
 if IsKeyUp(KEY_EIGHT) then FHardware.doKey(false, 56, Shift);

 if IsKeyDown(KEY_NINE) then FHardware.doKey(true, 57, Shift);
 if IsKeyUp(KEY_NINE) then FHardware.doKey(false, 57, Shift);

 if IsKeyDown(KEY_UP) then FHardware.doKey(true, 38, Shift) else
 if IsKeyUp(KEY_UP) then FHardware.doKey(false, 38, Shift );

 if IsKeyDown(KEY_DOWN) then FHardware.doKey(true, 40, Shift) else
 if IsKeyUp(KEY_DOWN) then FHardware.doKey(false, 40, Shift);

 if IsKeyDown(KEY_LEFT) then FHardware.doKey(true, 37, Shift) else
 if IsKeyUp(KEY_LEFT) then FHardware.doKey(false, 37, Shift);

 if IsKeyDown(KEY_RIGHT) then FHardware.doKey(true, 39, Shift) else
 if IsKeyUp(KEY_RIGHT) then FHardware.doKey(false, 39, Shift);

 if IsKeyDown(KEY_ENTER) then FHardware.doKey(true, 13, Shift) else
 if IsKeyUp(KEY_ENTER) then FHardware.doKey(false, 13, Shift);

 if IsKeyDown(KEY_SPACE) then FHardware.doKey(true, 32, Shift) else
 if IsKeyUp(KEY_SPACE) then FHardware.doKey(false, 32, Shift);

 if HelpTim <300 then Inc(HelpTim);

 // ---- Loading ----------------------------------------------------------------

 if IsFileDropped() then
 begin
   droppedFiles := LoadDroppedFiles();

   if droppedFiles.count = 1 then
   begin
      if (
         IsFileExtension (droppedFiles.paths[0], '.tap') or
         IsFileExtension (droppedFiles.paths[0], '.sna') or
         IsFileExtension (droppedFiles.paths[0], '.tzx') or
         IsFileExtension (droppedFiles.paths[0], '.z80')
         ) then
         begin
           //FHardware.NMI;
          // FHardware.Reset;
           FHardware.LoadFromFile(droppedFiles.paths[0]);
         end;
   end;
   UnloadDroppedFiles(droppedFiles);    // Unload filepaths from memory
 end;


end;

procedure TGame.Render;

begin
DrawTexturePro(FTexture, FRectSource, FRectDest,  Vector2Create(0, 0), 0, White);

if FEnbaleShader[0] then
begin
 BeginShaderMode(FShader[0]);
   FTarget.texture := FTexture;
   DrawTexturePro(FTarget.texture, FRectSource, FRectDest,  Vector2Create(0, 0), 0, White);
 EndShaderMode();
end;

if FEnbaleShader[1] then
begin
 BeginShaderMode(FShader[1]);
   FTarget.texture := FTexture;
   DrawTexturePro(FTarget.texture, FRectSource, FRectDest,  Vector2Create(0, 0), 0, White);
 EndShaderMode();
end;

if FEnbaleShader[2] then
begin
 BeginShaderMode(FShader[2]);
   FTarget.texture := FTexture;
   DrawTexturePro(FTarget.texture, FRectSource, FRectDest,  Vector2Create(0, 0), 0, White);
 EndShaderMode();
end;

if FEnbaleShader[3] then
begin
 BeginShaderMode(FShader[3]);
   FTarget.texture := FTexture;
   DrawTexturePro(FTarget.texture, FRectSource, FRectDest,  Vector2Create(0, 0), 0, White);
 EndShaderMode();
end;


If HelpTim < 250 then DrawText('Press F1 for show/hide help', 10 , ScreenWidth - 20, 10, RED);

 if ShowHelp then
 begin
   DrawText('F5 - F8 : On/Off Shader effect', 10 , 10, 10, BLUE);
   DrawText('F9 - F11 : Change window size', 10 , 22, 10, BLUE);
   DrawText('Alt + 1 or 9 : Set zx-spectrum mashine', 10 , 34, 10, BLUE);
   DrawText('Drop file is here for loading ...', 10 , 46, 10, DARKGREEN);
 end;

 inherited Render;
end;

procedure TGame.Resized;
begin
  inherited Resized;

  FRectDest := RectangleCreate(0,0,GetRenderWidth,GetRenderHeight);
end;

procedure TGame.Shutdown;
begin
  FHardware := nil;
  UnloadTexture(FTexture);
  UnloadShader(FShader[0]);
end;

end.

