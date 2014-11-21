unit PSEAlert.View.ExceptionDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmException = class(TForm)
    StaticText1: TStaticText;
    memException: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}


end.
