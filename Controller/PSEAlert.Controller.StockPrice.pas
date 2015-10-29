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
  Dialogs,
  ExtCtrls;

type
  TUserAction = (Close, AddAlert);
  TUserActions = set of TUserAction;
  TStockPriceController = class(TBaseController<TIntradayModel>, IMessageReceiver)
  private
    {$HINTS OFF}
    [Bind('Symbol', {$IFDEF FMXAPP}'Text'{$ELSE}'Caption'{$ENDIF})]
    lblStockSymbol: TLabel;
    [Bind('Description', {$IFDEF FMXAPP}'Text'{$ELSE}'Caption'{$ENDIF})]
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
    [Bind]
    stockInfoPanel: TPanel;
{$HINTS ON}

{$IFNDEF FMXAPP}
    [Bind]
    ImageList1: TImageList;
{$ENDIF}

    fUserActions: TUserActions;
    fStock: TIntradayModel;
    procedure SetUserActions(const Value: TUserActions);
  protected
    fStockDetailsController: IController<TStockHeaderModel>;
    procedure Initialize; override;
    procedure DoCloseView(Sender: TObject);
    procedure DoStockInfoPanelClick(Sender: TObject);
    procedure SetStockStatusImage(const aStockStatus: TStockStatus;
      const aImage: {$IFDEF FMXAPP}TImage{$ELSE}TImage{$ENDIF});
  public
    destructor Destroy; override;
    procedure Receive(const aMessage: IMessage);
    property UserActions: TUserActions read fUserActions write SetUserActions;
  end;

function CreateStockPriceController(aStockModel: TIntradayModel;
  aParent: {$IFDEF FMXAPP}TFMXObject{$ELSE}TWinControl{$ENDIF};
  aUserActions: TUserActions): IController<TIntradayModel>;

implementation

uses
  PSEAlert.Utils, PSEAlert.Messages, PSE.Data, PSE.Data.Repository, System.UITypes,
  PSEAlert.Controller.StockDetails, PSE.Data.Downloader,
  Spring.Persistence.Criteria.Interfaces,
  Spring.Persistence.Criteria.Restrictions;

{$R PSEAlert.res PSEAlertResource.rc}

function CreateStockPriceController(aStockModel: TIntradayModel;
  aParent: {$IFDEF FMXAPP}TFMXObject{$ELSE}TWinControl{$ENDIF};
  aUserActions: TUserActions): IController<TIntradayModel>;
begin
  TControllerFactory<TIntradayModel>.RegisterFactoryMethod(TframeStockPrice,
    function: IController<TIntradayModel>
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
      if aStockModel.Symbol[1] = '^' then
        frm.stockInfoPanel.Cursor := crDefault;

      result := TStockPriceController.Create(aStockModel, frm);
      result.AutoFreeModel := true;
      TStockPriceController(result).UserActions := aUserActions;
      //frm.Show;

    end);
  result := TControllerFactory<TIntradayModel>.GetInstance(TframeStockPrice);

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
    stockRepository.Unfavorite(ExtractStockSymbol(p.Name));
  finally
    p.Free;
  end;
end;

procedure TStockPriceController.DoStockInfoPanelClick(Sender: TObject);
var
  downloader: TStockDetail_HeaderDownloader;
  stockModel: TStockModel;
begin
  if self.Model.Symbol[1] <> '^' then
  begin

    stockModel := PSEAlertDb.Session.CreateCriteria<TStockModel>
      .Add(Restrictions.Eq('SYMBOL', Model.Symbol.ToUpper)).ToList.SingleOrDefault(nil);
    if stockModel <> nil then
    begin
      downloader := TStockDetail_HeaderDownloader.Create(stockModel.SecurityId);
      downloader.ExecuteAsync(
        procedure
        begin
          Application.MainForm.Cursor := crHourGlass;
        end,
        procedure
        begin
          Application.MainForm.Cursor := crDefault;
        end,
        procedure (aStock: TStockHeaderModel)
        begin
          TThread.Synchronize(nil,
            procedure
            var
              stockAttr: TStockAttribute;
            begin
              fStockDetailsController := CreateStockDetailsController(self.View as TComponent, aStock);
              stockAttr := TStockAttribute.Create;
              try
                stockAttr.Symbol := aStock.Symbol;
                stockAttr.AttributeKey := 'PE';
                stockAttr.AttributeValue := aStock.CurrentPE.ToString;
                stockAttributeRepository.Update(stockAttr);
              finally
                stockAttr.Free;
              end;

              stockAttr := TStockAttribute.Create;
              try
                stockAttr.Symbol := aStock.Symbol;
                stockAttr.AttributeKey := 'FiftyTwoWeekLow';
                stockAttr.AttributeValue := aStock.FiftyTwoWeekLow.ToString;
                stockAttributeRepository.Update(stockAttr);
              finally
                stockAttr.Free;
              end;

              stockAttr := TStockAttribute.Create;
              try
                stockAttr.Symbol := aStock.Symbol;
                stockAttr.AttributeKey := 'FiftyTwoWeekHigh';
                stockAttr.AttributeValue := aStock.FiftyTwoWeekHigh.ToString;
                stockAttributeRepository.Update(stockAttr);
              finally
                stockAttr.Free;
              end;

              stockAttr := TStockAttribute.Create;
              try
                stockAttr.Symbol := aStock.Symbol;
                stockAttr.AttributeKey := 'LastTradedPrice';
                stockAttr.AttributeValue := aStock.LastTradedPrice.ToString;
                stockAttributeRepository.Update(stockAttr);
              finally
                stockAttr.Free;
              end;

              stockAttr := TStockAttribute.Create;
              try
                stockAttr.Symbol := aStock.Symbol;
                stockAttr.AttributeKey := 'LastTradedDate';
                stockAttr.AttributeValue := DateToStr(aStock.LastTradedDate);
                stockAttributeRepository.Update(stockAttr);
              finally
                stockAttr.Free;
              end;
            end);
        end)
    end;

  end;
end;

procedure TStockPriceController.Initialize;
begin
  inherited;
  MessengerInstance.RegisterReceiver(self, TIntradayUpdateMessage);
  MessengerInstance.RegisterReceiver(self, TAlertTriggeredMessage);
  MessengerInstance.RegisterReceiver(self, TDismissAlertMessage);

//  if Assigned(btnClose) then
//  begin
//    if (Self.Model.Symbol[1] = '^') then
//      btnClose.Visible := false
//    else
//
//  end;
  btnClose.OnClick := DoCloseView;
  stockInfoPanel.OnClick := DoStockInfoPanelClick;
  lblStockSymbol.Font.Style := [TFontStyle.fsBold];
  lblStockSymbol.Font.Size := 12;
  lblStockName.Font.Size := 9;
  lblStockPrice.Font.Size := 11;
  lblStockVolume.Font.Size := 9;
end;

procedure TStockPriceController.Receive(const aMessage: IMessage);
var
  stock: TIntradayModel;
  alertModel: TAlertModel;
  isIndex: boolean;
  priceText, volumeText: string;
  parentName: string;
begin
  if aMessage is TIntradayUpdateMessage then
  begin
    stock := (aMessage as TIntradayUpdateMessage).Data;
    parentName := ExtractStockSymbol((View as TframeStockPrice).Name);
    isIndex := stock.Symbol[1] = '^';
    fStock := stock;
    if isIndex then
      parentName := '^' + parentName;
    if ExtractStockSymbol(stock.Symbol) = parentName then
    begin

      TThread.Synchronize(nil,
        procedure
        begin
          if isIndex then
          begin
            priceText := FormatFloat('#,##0.00', stock.Volume);
            volumeText := Format('%f (%f%%)', [stock.LastTradedPrice, stock.PercentChange]);
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
          {$IFDEF FMXAPP}
          (View as TframeStockPrice).Repaint;
          {$ELSE}
          (View as TframeStockPrice).Refresh;
          {$ENDIF}
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

procedure TStockPriceController.SetUserActions(const Value: TUserActions);
begin
  fUserActions := Value;
  if Assigned(btnClose) then
  begin
{$IFDEF FMXAPP}
    btnClose.Visible := TUserAction.Close in Value;
{$ELSE}
    btnClose.Enabled := TUserAction.Close in Value;
{$ENDIF}
  end;
end;

end.
