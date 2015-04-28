unit PSEAlert.AlertFormManager;

interface

uses
  Yeahbah.Messaging,
  PSEAlert.Messages,
  Generics.Collections,
{$IFDEF FMXAPP}
  PSEAlert.FMX.AlertForm,
{$ELSE}
  PSEAlert.AlertForm,
{$ENDIF}
  Forms,
  SysUtils;

type
  TAlertFormManager = class(TInterfacedObject, IMessageReceiver)
  private
    fAlertForms: TList<TForm>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Receive(const aMessage: IMessage);
  end;

var
  AlertFormManager: TAlertFormManager;

implementation

{ TAlertFormManager }

uses PSE.Data.Model, Yeahbah.ObjectClone;

constructor TAlertFormManager.Create;
begin
  inherited Create;
  fAlertForms := TList<TForm>.Create;
  MessengerInstance.RegisterReceiver(self, TShowAlertFormMessage);
  MessengerInstance.RegisterReceiver(self, TAlertFormHasClosedMessage);
end;

destructor TAlertFormManager.Destroy;
begin
  fAlertForms.Free;
  MessengerInstance.UnRegisterReceiver(self);
  inherited;
end;

procedure TAlertFormManager.Receive(const aMessage: IMessage);
var
  frm: TfrmAlert;
  alertModel: TAlertModel;
begin
  if aMessage is TShowAlertFormMessage then
  begin
    alertModel := (aMessage as TShowAlertFormMessage).Data;
    if alertModel = nil then
      Exit;

    frm := TfrmAlert.Create(Application);
{$IFDEF FMXAPP}
//    frm.lblStockSymbol.Text := Format(frm.lblStockSymbol.Text, [alertModel.StockSymbol]);
//    frm.lblPriceTrigger.Text := alertModel.PriceTrigger.ToString;
//    frm.lblVolumeTrigger.Text := alertModel.VolumeTrigger.ToString;
    frm.Left := Screen.Size.Width - frm.Width - 20;
{$ELSE}
//    frm.lblStockSymbol.Caption := Format(frm.lblStockSymbol.Caption, [alertModel.StockSymbol]);
//    frm.lblPriceTrigger.Caption := alertModel.PriceTriggerDescription;
//    frm.lblVolumeTrigger.Caption := alertModel.VolumeTriggerDescription;
//    frm.lblNote.Caption := alertModel.Notes;
    frm.Left := Screen.Width - frm.Width - 20;
{$ENDIF}

    if fAlertForms.Count > 0 then
      frm.Top := fAlertForms.Last.Top + frm.Height + 20
    else
      frm.Top := 20;
    frm.AlertModel := TObjectClone.From(alertModel);
    frm.Show;
    fAlertForms.Add(frm);
  end
  else
  if aMessage is TAlertFormHasClosedMessage then
  begin
    if fAlertForms.Contains((aMessage as TAlertFormHasClosedMessage).Data) then
    begin
      fAlertForms.Remove((aMessage as TAlertFormHasClosedMessage).Data);
    end;
  end;
end;

initialization
  AlertFormManager := TAlertFormManager.Create;

end.
