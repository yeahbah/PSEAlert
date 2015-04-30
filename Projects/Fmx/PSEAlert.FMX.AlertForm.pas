unit PSEAlert.FMX.AlertForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  PSEAlert.Messages, PSE.Data.Model, FMX.Controls.Presentation;

type
  TfrmAlert = class(TForm)
    lblStockSymbol: TLabel;
    lblPriceTrigger: TLabel;
    lblVolumeTrigger: TLabel;
    Button1: TButton;
    Button2: TButton;
    lblNotes: TLabel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
  private
    fAlertModel: TAlertModel;
    procedure SetAlertModel(const Value: TAlertModel);
    { Private declarations }
  public
    { Public declarations }
    property AlertModel: TAlertModel read fAlertModel write SetAlertModel;
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

procedure TfrmAlert.SetAlertModel(const Value: TAlertModel);
begin
  fAlertModel := Value;

  lblStockSymbol.Text := Format(lblStockSymbol.Text, [fAlertModel.StockSymbol]);
  lblPriceTrigger.Text := Value.PriceTriggerDescription;
  lblVolumeTrigger.Text := fAlertModel.VolumeTriggerDescription;
  lblNotes.Text := fAlertModel.Notes;
end;

procedure TfrmAlert.Timer1Timer(Sender: TObject);
begin
  Button2Click(Button2);
end;

end.
