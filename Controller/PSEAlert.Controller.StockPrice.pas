unit PSEAlert.Controller.StockPrice;

interface

uses
  Controller.Base,
  SvBindings,
  PSE.Data.Model,
  Forms,
  Controls,
  System.Types,
  {$IFDEF FMXAPP}
  FMX.Types,
  FMX.Objects,
  {$ELSE}
  Vcl.Buttons,
  {$ENDIF}
  PSEAlert.Frames.StockPrice,
  SysUtils,
  StdCtrls,
  Yeahbah.Messaging,
  Classes,
  ExtCtrls;

type
  TStockPriceController = class(TBaseController<TStockModel>, IMessageReceiver)
  private
    {$HINTS OFF}
    [Bind('Symbol', {$IFDEF FMXAPP}'Text'{$ELSE}'Caption'{$ENDIF})]
    lblStockSymbol: TLabel;
    [Bind('Description',  {$IFDEF FMXAPP}'Text'{$ELSE}'Caption'{$ENDIF})]
    lblStockName: TLabel;
    [Bind]
    btnClose: TSpeedButton;
    [Bind]
    btnAlert: TSpeedButton;
    [Bind]
    lblStockPrice: TLabel;
    [Bind]
    lblStockVolume: TLabel;
    [Bind]
    imgStatus: TImage;
{$IFDEF FMXAPP}

{$ELSE}
    [Bind]
    ImageList1: TImageList;
{$ENDIF}
    {$HINTS ON}
  protected
    procedure Initialize; override;
    procedure DoCloseView(Sender: TObject);
    procedure SetStockStatusImage(const aStockStatus: TStockStatus;
      const aImage: {$IFDEF FMXAPP}TImage{$ELSE}TImage{$ENDIF});
  public
    destructor Destroy; override;
    procedure Receive(const aMessage: IMessage);
  end;

function CreateStockPriceController(aStockModel: TStockModel;
  aParent: {$IFDEF FMXAPP}TFMXObject{$ELSE}TWinControl{$ENDIF}): IController<TStockModel>;

implementation

uses
  PSEAlert.Utils, PSEAlert.Messages, PSE.Data;

{$R PSEAlert.res PSEAlertResource.rc}

function CreateStockPriceController(aStockModel: TStockModel;
  aParent: {$IFDEF FMXAPP}TFMXObject{$ELSE}TWinControl{$ENDIF}): IController<TStockModel>;
begin
  TControllerFactory<TStockModel>.RegisterFactoryMethod(TframeStockPrice,
    function: IController<TStockModel>
    var
      frm: TframeStockPrice;
    begin
      frm := TframeStockPrice.Create(aParent);
      {$IFDEF FMXAPP}
      aParent.AddObject(frm);
      {$ELSE}
      frm.Parent := aParent;
      {$ENDIF}
      frm.Align := {$IFDEF FMXAPP}TAlignLayout.Top{$ELSE}alTop{$ENDIF};
      frm.Name := GenerateControlName(aStockModel.Symbol);
      result := TStockPriceController.Create(aStockModel, frm);
      frm.Visible := true;
    end);
  result := TControllerFactory<TStockModel>.GetInstance(TframeStockPrice);
end;

{ TStockPriceController }

destructor TStockPriceController.Destroy;
begin
  inherited;
end;

procedure TStockPriceController.DoCloseView(Sender: TObject);
var
{$IFDEF FMXAPP}
  p: TFMXObject;
{$ELSE}
  p: TWinControl;
{$ENDIF}
begin
  p := (Sender as TControl).Owner as {$IFDEF FMXAPP}TFMXObject{$ELSE}TWinControl{$ENDIF};
  try
{$IFDEF FMXAPP}
    p.Parent.RemoveObject(p);
{$ELSE}
    p.Parent.RemoveControl(p);
{$ENDIF}
    MessengerInstance.UnRegisterReceiver(self);
    PSEAlertDb.Session.Execute('UPDATE STOCKS SET ISFAVORITE = null WHERE SYMBOL = :0', [p.Name]);
//    PSEStocksData.PSEStocksConnection.ExecSQL('UPDATE STOCKS SET ISFAVORITE = null WHERE SYMBOL = ' + QuotedStr(p.Name));
  finally
    p.Free;
  end;
end;

procedure TStockPriceController.Initialize;
begin
  inherited;
  MessengerInstance.RegisterReceiver(self, TStockUpdateMessage);
  MessengerInstance.RegisterReceiver(self, TAlertTriggeredMessage);
  MessengerInstance.RegisterReceiver(self, TDismissAlertMessage);

  if Assigned(btnClose) and (Self.Model.Symbol[1] <> '^') then
    btnClose.OnClick := DoCloseView
  else
    btnClose.Visible := false;
  lblStockSymbol.Font.Size := 12;
  lblStockName.Font.Size := 9;
  lblStockPrice.Font.Size := 11;
  lblStockVolume.Font.Size := 9;
end;

procedure TStockPriceController.Receive(const aMessage: IMessage);
var
  stock: TStockModel;
  alertModel: TAlertModel;
  isIndex: boolean;
  priceText, volumeText: string;
begin
  if aMessage is TStockUpdateMessage then
  begin
    stock := (aMessage as TStockUpdateMessage).Data;
    if GenerateControlName(stock.Symbol) = (View as TframeStockPrice).Name then
    begin
      isIndex := stock.Symbol[1] = '^';
      TThread.Synchronize(nil,
        procedure
        begin
          if isIndex then
          begin
            priceText := FormatFloat('#,##0.00', stock.Volume);
            volumeText := Format('%f (%f%%)', [stock.PercentChange, stock.LastTradedPrice]);
          end
          else
          begin
            priceText := Format('%s (%f%%)', [FormatFloat('#,##0.00', stock.LastTradedPrice), stock.PercentChange]);
            volumeText := FormatFloat('#,##0', stock.Volume);
          end;
{$IFDEF FMXAPP}
          lblStockPrice.Text := priceText;
          lblStockVolume.Text := volumeText;
{$ELSE}
          lblStockPrice.Caption := priceText;
          lblStockVolume.Caption := volumeText;
{$ENDIF}
          SetStockStatusImage(stock.Status, imgStatus);
        end);
    end;
  end;

  if aMessage is TAlertTriggeredMessage then
  begin
    alertModel := (aMessage as TAlertTriggeredMessage).Data;
    if GenerateControlName(alertModel.StockSymbol) = (View as TframeStockPrice).Name then
      btnAlert.Visible := true;
  end;

  if aMessage is TDismissAlertMessage then
  begin
    alertModel := (aMessage as TDismissAlertMessage).Data;
    if GenerateControlName(alertModel.StockSymbol) = (View as TframeStockPrice).Name then
      btnAlert.Visible := false;
  end;
end;

procedure TStockPriceController.SetStockStatusImage(
  const aStockStatus: TStockStatus; const aImage: {$IFDEF FMXAPP}TImage{$ELSE}TImage{$ENDIF});
{$IFDEF FMXAPP}
var
  res: TResourceStream;
{$ENDIF}
begin
{$IFDEF FMXAPP}
  case aStockStatus of
    TStockStatus.Unchanged: aImage.Bitmap := nil;
    TStockStatus.Up:
      begin
        res := TResourceStream.Create(hInstance, 'stock_up', RT_RCDATA);
        try
          aImage.Bitmap.LoadFromStream(res);
        finally
          res.Free;
        end;
      end;
    TStockStatus.Down:
      begin
        res := TResourceStream.Create(hInstance, 'stock_down', RT_RCDATA);
        try
          aImage.Bitmap.LoadFromStream(res);
        finally
          res.Free;
        end;
      end;
  end;
{$ELSE}
  aImage.Transparent := true;
  if Assigned(aImage.Picture) then
    aImage.Picture := nil;
  case aStockStatus of
    TStockStatus.Up: ImageList1.GetBitmap(0, aImage.Picture.Bitmap);
    TStockStatus.Down: ImageList1.GetBitmap(1, aImage.Picture.Bitmap);
  end;
{$ENDIF}
end;

end.
