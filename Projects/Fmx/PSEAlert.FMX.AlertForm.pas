unit PSEAlert.FMX.AlertForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  PSEAlert.Messages, PSE.Data.Model;

type
  TfrmAlert = class(TForm)
    lblStockSymbol: TLabel;
    lblPriceTrigger: TLabel;
    lblVolumeTrigger: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    fAlertModel: TAlertModel;
    { Private declarations }
  public
    { Public declarations }
    property AlertModel: TAlertModel read fAlertModel write fAlertModel;
  end;

var
  frmAlert: TfrmAlert;

implementation

uses
  Yeahbah.Messaging;

{$R *.fmx}

procedure TfrmAlert.Button1Click(Sender: TObject);
begin
  MessengerInstance.SendMessage(TDismissAlertMessage.Create(fAlertModel));
  Close;
end;

procedure TfrmAlert.Button2Click(Sender: TObject);
begin
  MessengerInstance.SendMessage(TAcknoledgeAlertMessage.Create(fAlertModel));
  Close;
end;

procedure TfrmAlert.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MessengerInstance.SendMessage(TAlertFormHasClosedMessage.Create(self));
  if fAlertModel <> nil then
    fAlertModel.Free;
  Action := TCloseAction.caFree;
end;

end.
