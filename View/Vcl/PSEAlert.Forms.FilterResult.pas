unit PSEAlert.Forms.FilterResult;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids;

type
  TfrmFilterResult = class(TForm)
    gridResult: TStringGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmFilterResult: TfrmFilterResult;

implementation

{$R *.dfm}

procedure TfrmFilterResult.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
