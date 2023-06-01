unit DialogUnit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs;

type

  { TDataModule1 }

  TDataModule1 = class(TDataModule)
    OpenDialog1: TOpenDialog;
  private

  public

  end;

var
  DataModule1: TDataModule1;

implementation

{$R *.lfm}

end.

