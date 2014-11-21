unit PSEAlert.Frames.StockPrice;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, PSE.Data.Model, Yeahbah.Messaging;

type
  TframeStockPrice = class(TFrame, IMessageReceiver)
    Panel1: TPanel;
    lblStockSymbol: TLabel;
    lblStockName: TLabel;
    lblStockPrice: TLabel;
    lblStockVolume: TLabel;
    btnClose: TSpeedButton;
    btnAlert: TSpeedButton;
    Label1: TLabel;
  private
    { Private declarations }
    imgStatus: TImage;
    fStockModel: TStockModel;
    procedure DoCloseView(Sender: TObject);
    procedure SetStockStatusImage(const aStockStatus: TStockStatus;
      const aImage: {$IFDEF FMXAPP}TImage{$ELSE}TImage{$ENDIF});
  public
    { Public declarations }
    constructor Create(aOwner: TComponent); overload; override;
    constructor Create(aOwner: TComponent; aStockModel: TStockModel); reintroduce; overload;
    property StockModel: TStockModel read fStockModel write fStockModel;
    procedure Receive(const aMessage: IMessage);
  end;

implementation

uses
  PSEAlert.Messages, PSEAlert.Utils, PSEAlert.DataModule;

{$R *.fmx}
{$R PSEAlert.res PSEAlertResource.rc}

{ TframeStockPrice }

constructor TframeStockPrice.Create(aOwner: TComponent);
var
  imgAlert: TImage;
  res: TResourceStream;
begin
  inherited;
  imgStatus := TImage.Create(Panel1);
  Panel1.AddObject(imgStatus);

  imgStatus.Width := 24;
  imgStatus.Height := 24;
  imgStatus.Position.X := 3;
  imgStatus.Position.Y := 8;

  imgAlert := TImage.Create(btnAlert);
  res := TResourceStream.Create(hInstance, 'bell_alert', RT_RCDATA);
  try
    btnAlert.AddObject(imgAlert);
    imgAlert.Align := TAlignLayout.Client;
    imgAlert.Bitmap.LoadFromStream(res);
  finally
    res.Free;
  end;
  btnAlert.Visible := false;

  MessengerInstance.RegisterReceiver(self, TStockUpdateMessage);
  MessengerInstance.RegisterReceiver(self, TAlertTriggeredMessage);
  MessengerInstance.RegisterReceiver(self, TDismissAlertMessage);

  lblStockSymbol.Font.Size := 12;
  lblStockName.Font.Size := 9;
  lblStockPrice.Font.Size := 11;
  lblStockVolume.Font.Size := 9;
  lblStockPrice.Text := '';
  lblStockVolume.Text := '';
end;

constructor TframeStockPrice.Create(aOwner: TComponent;
  aStockModel: TStockModel);
begin
  Create(aOwner);

  fStockModel := aStockModel;
  if Assigned(btnClose) and (StockModel.Symbol[1] <> '^') then
    btnClose.OnClick := DoCloseView
  else
    btnClose.Visible := false;
  lblStockSymbol.Text := aStockModel.Symbol;
  lblStockName.Text := aStockModel.Description;
end;

procedure TframeStockPrice.DoCloseView(Sender: TObject);
var
  p: TFMXObject;
begin
  p := (Sender as TControl).Owner as TFMXObject;
  try
    p.Parent.RemoveObject(p);
    MessengerInstance.UnRegisterReceiver(self);
    PSEStocksData.PSEStocksConnection.ExecSQL('UPDATE STOCKS SET ISFAVORITE = null WHERE SYMBOL = ' + QuotedStr(p.Name));
  finally
    p.Free;
  end;
end;

procedure TframeStockPrice.Receive(const aMessage: IMessage);
var
  stock: TStockModel;
  alertModel: TAlertModel;
  isIndex: boolean;
  priceText, volumeText: string;
begin
  if aMessage is TStockUpdateMessage then
  begin
    stock := (aMessage as TStockUpdateMessage).Data;
    if GenerateControlName(stock.Symbol) = Name then
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

          lblStockPrice.Text := priceText;
          lblStockVolume.Text := volumeText;

          SetStockStatusImage(stock.Status, imgStatus);
        end);
    end;
  end;

  if aMessage is TAlertTriggeredMessage then
  begin
    alertModel := (aMessage as TAlertTriggeredMessage).Data;
    if GenerateControlName(alertModel.StockSymbol) = Name then
      btnAlert.Visible := true;
  end;

  if aMessage is TDismissAlertMessage then
  begin
    alertModel := (aMessage as TDismissAlertMessage).Data;
    if GenerateControlName(alertModel.StockSymbol) = Name then
      btnAlert.Visible := false;
  end;

end;

procedure TframeStockPrice.SetStockStatusImage(const aStockStatus: TStockStatus;
  const aImage: TImage);
var
  res: TResourceStream;
begin

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

end;

end.
