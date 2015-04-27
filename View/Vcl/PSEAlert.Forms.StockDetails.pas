unit PSEAlert.Forms.StockDetails;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmStockDetails = class(TForm)
    lblLastUpdateDateTime: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//var
//  frmStockDetails: TfrmStockDetails;

implementation

{$R *.dfm}

procedure TfrmStockDetails.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmStockDetails.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
