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
  SysUtils,
  System.Notification;

type
  TAlertFormManager = class(TInterfacedObject, IMessageReceiver)
  private
    fAlertForms: TList<TForm>;
    fNotificationCenter: TNotificationCenter;
    procedure NotificationReceived(Sender: TObject; ANotification: TNotification);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Receive(const aMessage: IMessage);
  end;

var
  AlertFormManager: TAlertFormManager;

implementation


{ TAlertFormManager }

uses PSE.Data.Model, Yeahbah.ObjectClone,
  JclSysInfo;


constructor TAlertFormManager.Create;
begin
  inherited Create;
  fAlertForms := TList<TForm>.Create;
  MessengerInstance.RegisterReceiver(self, TShowAlertFormMessage);
  MessengerInstance.RegisterReceiver(self, TAlertFormHasClosedMessage);

  fNotificationCenter := TNotificationCenter.Create(nil);
  fNotificationCenter.OnReceiveLocalNotification := NotificationReceived;
end;

destructor TAlertFormManager.Destroy;
begin
  fAlertForms.Free;
  MessengerInstance.UnRegisterReceiver(self);
  fNotificationCenter.Free;
  inherited;
end;

procedure TAlertFormManager.NotificationReceived(Sender: TObject;
  ANotification: TNotification);
begin

end;

procedure TAlertFormManager.Receive(const aMessage: IMessage);
var
  frm: TfrmAlert;
  alertModel: TAlertModel;
  winVersion: TWindowsVersion;
  //notification: TNotification;
begin
  if aMessage is TShowAlertFormMessage then
  begin
    alertModel := (aMessage as TShowAlertFormMessage).Data;
    if alertModel = nil then
      Exit;

//    winVersion := GetWindowsVersion;
//    if winVersion < TWindowsVersion.wvWin10 then
//    begin

      frm := TfrmAlert.Create(Application);
  {$IFDEF FMXAPP}
      frm.Left := Screen.Size.Width - frm.Width - 20;
  {$ELSE}
      frm.Left := Screen.Width - frm.Width - 20;
  {$ENDIF}

      if fAlertForms.Count > 0 then
        frm.Top := fAlertForms.Last.Top + frm.Height + 20
      else
        frm.Top := 20;
      frm.AlertModel := TObjectClone.From(alertModel);
      frm.Show;
      fAlertForms.Add(frm);
//    end;
//    else
//    begin
//      // windows 10 notification
//      notification := fNotificationCenter.CreateNotification;
//      try
//        notification.Name := alertModel.StockSymbol;
//        notification.Title := alertModel.StockSymbol;
//        notification.AlertBody := alertModel.PriceTriggerDescription + ' ' + alertModel.VolumeTriggerDescription;
//
//        fNotificationCenter.PresentNotification(notification);
//      finally
//        notification.Free;
//      end;
//    end;
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
