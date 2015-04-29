unit PSEAlert.Controller.StockAlert;

interface

uses
  Controller.Base,
  SvBindings,
  PSE.Data.Model,
  Forms,
  Controls,
  PSEAlert.Frames.StockAlert,
  SysUtils,
  StdCtrls,
  Yeahbah.Messaging,
  Classes,
  UITypes,
  System.Types,
  {$IFDEF FMXAPP}
  FMX.Types,
  FMX.Objects,
  {$ELSE}
  Buttons,
  {$ENDIF}
  ExtCtrls,
  ActnList;

type
  TStockAlertController = class(TBaseController<TAlertModel>, IMessageReceiver)
  private
    {$HINTS OFF}
    [Bind]
    btnAlertTriggered: TSpeedButton;
    [Bind]
    actDelete: TAction;
{$IFDEF FMXAPP}
    [Bind('Notes', 'Text')]
    lblNote: TLabel;
{$ELSE}
    [Bind('Notes', 'Caption')]
    lblNote: TLabel;
{$ENDIF}
    [Bind]
    Label1: TLabel;
    [Bind('StockSymbol', {$IFDEF FMXAPP}'Text'{$ELSE}'Caption'{$ENDIF})]
    lblAlertSymbol: TLabel;
    [Bind('PriceTriggerDescription', {$IFDEF FMXAPP}'Text'{$ELSE}'Caption'{$ENDIF})]
    lblAlertDetails: TLabel;
    [Bind('VolumeTriggerDescription', {$IFDEF FMXAPP}'Text'{$ELSE}'Caption'{$ENDIF})]
    lblVolumeAlert: TLabel;
    {$HINTS ON}
  protected
    procedure Initialize; override;
    procedure DoCloseView(Sender: TObject);
    procedure TriggerAlert(aStock: TIntradayModel);
  public
    destructor Destroy; override;
    procedure Receive(const aMessage: IMessage);
  end;

function CreateStockAlertController(aAlertModel: TAlertModel;
  aParent: {$IFDEF FMXAPP}TFMXObject{$ELSE}TWinControl{$ENDIF}): IController<TAlertModel>;

implementation

uses
  PSEAlert.Utils, PSEAlert.Messages, OtlTask, OtlTaskControl,
  PSEAlert.Settings, IOUtils, MMSystem,
  StrUtils, PSE.Data, PSE.Data.Repository;

{$R PSEAlert.res PSEAlertResource.rc}

function CreateStockAlertController(aAlertModel: TAlertModel;
  aParent: {$IFDEF FMXAPP}TFMXObject{$ELSE}TWinControl{$ENDIF}): IController<TAlertModel>;
begin
  TControllerFactory<TAlertModel>.RegisterFactoryMethod(TframeStockAlert,
    function: IController<TAlertModel>
    var
      frm: TframeStockAlert;
    begin
      frm := TframeStockAlert.Create(Application);
      frm.Parent := aParent;
      frm.Align := {$IFDEF FMXAPP}TAlignLayout.Top;{$ELSE}alTop{$ENDIF};
      frm.Name := 'alert' + GenerateControlName(aAlertModel.StockSymbol) + '_' + aAlertModel.ID.ToString;
      result := TStockAlertController.Create(aAlertModel, frm);
      result.AutoFreeModel := true;
      frm.Visible := true;
    end);
  result := TControllerFactory<TAlertModel>.GetInstance(TframeStockAlert);
end;

{ TStockAlertController }

destructor TStockAlertController.Destroy;
begin

  inherited;
end;

procedure TStockAlertController.DoCloseView(Sender: TObject);
var
  p: {$IFDEF FMXAPP}TFMXObject{$ELSE}TWinControl{$ENDIF};
begin
  p := (Sender as TAction).Owner as {$IFDEF FMXAPP}TFMXObject{$ELSE}TWinControl{$ENDIF};
  try
{$IFDEF FMXAPP}
    p.Parent.RemoveObject(p);
{$ELSE}
    p.Parent.RemoveControl(p);
{$ENDIF}
    stockAlertRepository.DeleteStockAlert(Model.ID);
    MessengerInstance.UnRegisterReceiver(Self);
    MessengerInstance.SendMessage(TDismissAlertMessage.Create(Model));
  finally
    p.Free
  end;
  inherited;
end;

procedure TStockAlertController.Initialize;
{$IFDEF FMXAPP}
var
  img: TImage;
  res: TResourceStream;
{$ENDIF}
begin
  inherited;
  MessengerInstance.RegisterReceiver(self, TAcknoledgeAlertMessage);
  MessengerInstance.RegisterReceiver(self, TDismissAlertMessage);
  MessengerInstance.RegisterReceiver(self, TIntradayUpdateMessage);

  actDelete.OnExecute := DoCloseView;

  lblAlertSymbol.Font.Size := 12;
  lblAlertSymbol.Font.Style := [TFontStyle.fsBold];
  lblAlertDetails.Font.Size := 9;
  lblVolumeAlert.Font.Size := 9;
  lblNote.Font.Size := 9;
  Label1.Font.Size := 9;

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

procedure TStockAlertController.Receive(const aMessage: IMessage);
var
  stock: TIntradayModel;
  alertModel: TAlertModel;
begin
  if aMessage is TIntradayUpdateMessage then
  begin

    stock := (aMessage as TIntradayUpdateMessage).Data;
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
      alertModel.AlertCount := alertModel.AlertCount + 1;
      Model.AlertCount := alertModel.AlertCount;
      stockAlertRepository.AcknowledgeAlert(alertModel);
    end;
  end
  else
  if aMessage is TDismissAlertMessage then
  begin
    if (aMessage as TDismissAlertMessage).Data.ID = Model.ID then
    begin
      actDelete.Execute;
    end;
  end;
end;

procedure TStockAlertController.TriggerAlert(aStock: TIntradayModel);
var
  task: IOmniTaskControl;
  priceTriggered: boolean;
begin
  task := CreateTask(
    procedure (const t: IOmniTask)
    begin
      case Model.PriceTriggerType of
        Below: priceTriggered := aStock.LastTradedPrice < Model.Price;
        Equal: priceTriggered := aStock.LastTradedPrice = Model.Price;
        Above: priceTriggered := aStock.LastTradedPrice > Model.Price;
        BelowEqual: priceTriggered := aStock.LastTradedPrice <= Model.Price;
        AboveEqual: priceTriggered := aStock.LastTradedPrice >= Model.Price;
      end;

      case Model.Logic of
        TLogicType.None: ;
        TLogicType.LogicOr: priceTriggered := priceTriggered or (aStock.Volume >= Model.Volume);
        TLogicType.LogicAND: priceTriggered := priceTriggered and (aStock.Volume >= Model.Volume);
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
