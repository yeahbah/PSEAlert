unit PSEAlert.Frames.StockAlert;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.ActnList, System.Actions, StrUtils, Yeahbah.Messaging,
  PSE.Data.Model;

type
  TframeStockAlert = class(TFrame, IMessageReceiver)
    btnDelete: TSpeedButton;
    btnAlertTriggered: TSpeedButton;
    Panel1: TPanel;
    lblAlertSymbol: TLabel;
    lblAlertDetails: TLabel;
    lblVolumeAlert: TLabel;
    Label1: TLabel;
    btnNotes: TSpeedButton;
    lblNote: TLabel;
    Label2: TLabel;
    procedure btnNotesClick(Sender: TObject);
  private
    { Private declarations }
    actDelete: TAction;
    fModel: TAlertModel;
    procedure Initialize;
    procedure DoCloseView(Sender: TObject);
    procedure TriggerAlert(aStock: TStockModel);
  public
    { Public declarations }
    constructor Create(aOwner: TComponent); overload; override;
    constructor Create(aOwner: TComponent; aAlertModel: TAlertModel); reintroduce; overload;
    procedure Receive(const aMessage: IMessage);
    property Model: TAlertModel read fModel write fModel;
  end;

implementation

uses
  PSEAlert.Messages, PSEAlert.DataModule, OtlTask, OtlTaskControl,
  PSEAlert.Settings, IOUtils, MMSystem;

{$R *.fmx}
{$R PSEAlert.res PSEAlertResource.rc}

{ TframeStockAlert }

procedure TframeStockAlert.btnNotesClick(Sender: TObject);
begin
  lblNote.Visible := not lblNote.Visible;
  if not lblNote.Visible then
    Height := 64
  else
    Height := 113;
end;

constructor TframeStockAlert.Create(aOwner: TComponent);

begin
  inherited Create(aOwner);
  actDelete := TAction.Create(self);

  btnDelete.Action := actDelete;

  lblNote.Text := '';
  lblNote.Visible := false;

end;

constructor TframeStockAlert.Create(aOwner: TComponent;
  aAlertModel: TAlertModel);
begin
  Create(aOwner);
  Model := aAlertModel;
  lblNote.Text := aAlertModel.Notes;
  lblAlertSymbol.Text := aAlertModel.StockSymbol;
  lblAlertDetails.Text := aAlertModel.PriceTrigger.Description;
  lblVolumeAlert.Text := aAlertModel.VolumeTrigger.Description;
  Initialize;
end;

procedure TframeStockAlert.DoCloseView(Sender: TObject);
var
  p: TFMXObject;
  stockSymbol: string;
begin
  p := (Sender as TAction).Owner as TFMXObject;
  try
    p.Parent.RemoveObject(p);
    stockSymbol := ReplaceStr(p.Name, 'alert', string.Empty).Trim;
    PSEStocksData.PSEStocksConnection.ExecSQL('DELETE FROM ALERTS WHERE SYMBOL = ' + QuotedStr(stockSymbol));
    PSEStocksData.cdsAlerts.Refresh;
    MessengerInstance.UnRegisterReceiver(Self);
    MessengerInstance.SendMessage(TDismissAlertMessage.Create(Model));
  finally
    p.Free
  end;
  inherited;

end;

procedure TframeStockAlert.Initialize;

var
  img: TImage;
  res: TResourceStream;

begin
  inherited;
  MessengerInstance.RegisterReceiver(self, TAcknoledgeAlertMessage);
  MessengerInstance.RegisterReceiver(self, TDismissAlertMessage);
  MessengerInstance.RegisterReceiver(self, TStockUpdateMessage);

  actDelete.OnExecute := DoCloseView;

  lblAlertSymbol.Font.Size := 12;
  lblAlertDetails.Font.Size := 9;
  lblVolumeAlert.Font.Size := 9;
  btnAlertTriggered.Visible := Model.AlertCount > 0;

{$IFDEF FMXAPP}
  img := TImage.Create(btnAlertTriggered);
  res := TResourceStream.Create(hInstance, 'bell_alert', RT_RCDATA);
  try
    btnAlertTriggered.AddObject(img);
    img.Align := TAlignLayout.FitRight;
    img.Bitmap.LoadFromStream(res);
  finally
    res.Free;
  end;
{$ENDIF}

end;

procedure TframeStockAlert.Receive(const aMessage: IMessage);
var
  stock: TStockModel;
  alertModel: TAlertModel;
begin
  if aMessage is TStockUpdateMessage then
  begin

    stock := (aMessage as TStockUpdateMessage).Data;
    if SameText(Model.StockSymbol, stock.Symbol) then
    begin
      if Model.CanTrigger then
        TriggerAlert(stock);
    end;
  end
  else
  if aMessage is TAcknoledgeAlertMessage then
  begin
    alertModel := (aMessage as TAcknoledgeAlertMessage).Data;
    if alertModel.StockSymbol = Model.StockSymbol then
    begin
      Model.AlertCount := alertModel.AlertCount + 1;
      PSEStocksData.PSEStocksConnection.ExecSQL('UPDATE ALERTS SET ALERT_COUNT = ' + Model.AlertCount.ToString +' WHERE SYMBOL = ' + QuotedStr(alertModel.StockSymbol));
    end;
  end
  else
  if aMessage is TDismissAlertMessage then
  begin
    if (aMessage as TDismissAlertMessage).Data.StockSymbol = Model.StockSymbol then
    begin
      actDelete.Execute;
    end;
  end;

end;

procedure TframeStockAlert.TriggerAlert(aStock: TStockModel);
var
  task: IOmniTaskControl;
  priceTriggered: boolean;
begin
  task := CreateTask(
    procedure (const t: IOmniTask)
    begin
      case Model.PriceTrigger.PriceTriggerType of
        Below: priceTriggered := aStock.LastTradedPrice < Model.PriceTrigger.Price;
        Equal: priceTriggered := aStock.LastTradedPrice = Model.PriceTrigger.Price;
        Above: priceTriggered := aStock.LastTradedPrice > Model.PriceTrigger.Price;
        BelowEqual: priceTriggered := aStock.LastTradedPrice <= Model.PriceTrigger.Price;
        AboveEqual: priceTriggered := aStock.LastTradedPrice >= Model.PriceTrigger.Price;
      end;

      case Model.VolumeTrigger.Logic of
        TLogicType.None: ;
        TLogicType.LogicOr: priceTriggered := priceTriggered or (aStock.Volume >= Model.VolumeTrigger.Volume);
        TLogicType.LogicAND: priceTriggered := priceTriggered and (aStock.Volume >= Model.VolumeTrigger.Volume);
      end;

      if priceTriggered then
      begin
        TThread.Synchronize(nil,
          procedure
          begin
            if PSEAlertSettings.PlaySound then
            begin
              if TFile.Exists(PSEAlertSettings.AlertSoundFile) then
                sndPlaySound(PWideChar(PSEAlertSettings.AlertSoundFile), SND_NODEFAULT or SND_ASYNC);
            end;
            // AlertFormManager will receive this message
            MessengerInstance.SendMessage(TShowAlertFormMessage.Create(Model));
            MessengerInstance.SendMessage(TAlertTriggeredMessage.Create(Model));
            btnAlertTriggered.Visible := true;
          end);
      end;

    end);
  task.Run;

end;

end.
