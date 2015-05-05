unit PSEAlert.Service.View.PERatioFilter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Buttons;

type
  TframePERatioFilter = class(TFrame)
    lblFilterDescription: TLabel;
    edtPEFrom: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    btnClose: TSpeedButton;
    edtPETo: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
