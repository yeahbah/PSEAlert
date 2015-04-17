unit PSEAlert.Controller.Settings;

interface

uses
  Controller.Base,
  SvBindings,
  SysUtils,
  Graphics, Controls, Forms, Dialogs, StdCtrls,
  ExtCtrls,
  PSEAlert.Settings,
  PSEAlert.Frames.Settings
  {$IFDEF FMXAPP}
  , FMX.Types
  , FMX.Edit
  , FMX.ListBox
  , FMX.ActnList
  {$ENDIF},
  Spring.Persistence.Core.Interfaces,
  Spring.Persistence.Criteria.Interfaces,
  Spring.Persistence.Criteria.Restrictions,
  Spring.Collections;

type
  TPSEAlertSettingsController = class(TBaseController<TPSEAlertSettings>)
  private
    {$HINTS OFF}
    [Bind('PlaySound', {$IFDEF FMXAPP}'IsChecked'{$ELSE}'Checked'{$ENDIF})]
    chkPlaySound: TCheckBox;
    [Bind('AlertSoundFile', 'Text')]
{$IFDEF FMXAPP}
    edtOpenWav: TEdit;
    [Bind]
    actOpenWav: TAction;
    [Bind]
    actReloadData: TAction;
    [Bind]
    btnReloadData: TButton;
{$ELSE}
    edtOpenWav: TButtonedEdit;
    [Bind]
    btnReloadData: TButton;
{$ENDIF}

    [Bind('PollInterval', 'ItemIndex')]
    cmbInterval: TComboBox;
    {$HINTS ON}

  protected
    procedure ReloadStockData;
    //procedure ReloadStockMap;
    procedure Initialize; override;
    procedure DoReloadData(Sender: TObject);
    procedure DoSelectSound(Sender: TObject);
    procedure DoIntervalCloseUp(Sender: TObject);
    procedure DoCheckPlaySound(Sender: TObject);
  public
    destructor Destroy; override;
  end;

function CreatePSEAlertSettingsController(aPSEAlertSettings: TPSEAlertSettings;
  aParent: {$IFDEF FMXAPP}TFMXObject{$ELSE}TWinControl{$ENDIF}): IController<TPSEAlertSettings>;

implementation

uses
  PSE.Data.Downloader, PSE.Data.Model, TypInfo,
  PSEAlert.Messages, Yeahbah.Messaging, PSEAlert.Utils, PSE.Data;

function CreatePSEAlertSettingsController(aPSEAlertSettings: TPSEAlertSettings;
  aParent: {$IFDEF FMXAPP}TFMXObject{$ELSE}TWinControl{$ENDIF}): IController<TPSEAlertSettings>;
begin
  TControllerFactory<TPSEAlertSettings>.RegisterFactoryMethod(TframeSettings,
    function: IController<TPSEAlertSettings>
    var
      frame: TframeSettings;
    begin
      frame := TframeSettings.Create(Application);
      frame.Align := {$IFDEF FMXAPP}TAlignLayout.Client{$ELSE}alClient{$ENDIF};
      frame.Parent := aParent;
      result := TPSEAlertSettingsController.Create(aPSEAlertSettings, frame);
      TPSEAlertSettingsController(result).UpdateTargets;
      frame.Visible := true;
    end);
  result := TControllerfactory<TPSEAlertSettings>.GetInstance(TframeSettings);
end;

{ TPSEAlertSettingsController }

destructor TPSEAlertSettingsController.Destroy;
begin

  inherited;
end;

procedure TPSEAlertSettingsController.DoCheckPlaySound(Sender: TObject);
begin
{$IFDEF FMXAPP}
  edtOpenWav.Enabled := chkPlaySound.IsChecked;
  actOpenWav.Enabled := chkPlaySound.IsChecked;
{$ELSE}
  edtOpenWav.Enabled := chkPlaySound.Checked;
{$ENDIF}
  UpdateSources;
end;

procedure TPSEAlertSettingsController.DoIntervalCloseUp(Sender: TObject);
var
  PollInterval: integer;
begin

  MessengerInstance.SendMessage(TEnableDisablePollingMessage.Create(false));
  PollInterval := GetPollIntervalValue(cmbInterval.ItemIndex);
  MessengerInstance.SendMessage(TPollIntervalChangedMessage.Create(PollInterval));
  MessengerInstance.SendMessage(TEnableDisablePollingMessage.Create(cmbInterval.ItemIndex > 0));

  UpdateSources;
end;

procedure TPSEAlertSettingsController.DoReloadData(Sender: TObject);
begin
  ReloadStockData;
//  ReloadStockMap;
end;

procedure TPSEAlertSettingsController.DoSelectSound(Sender: TObject);
var
  openDialog: TOpenDialog;
begin
  openDialog := TOpenDialog.Create(nil);
  try
    openDialog.Filter := 'Wave files|*.wav';
    if openDialog.Execute then
    begin
      edtOpenWav.Text := openDialog.FileName;
      UpdateSources;
    end;
  finally
    openDialog.Free;
  end;
end;

procedure TPSEAlertSettingsController.Initialize;
begin
  inherited;


{$IFDEF FMXAPP}
  actReloadData.OnExecute := DoReloadData;
  actOpenWav.OnExecute := DoSelectSound;
  chkPlaySound.OnChange := DoCheckPlaySound;
  cmbInterval.OnChange := DoIntervalCloseUp;
{$ELSE}
  btnReloadData.OnClick := DoReloadData;
  edtOpenWav.OnRightButtonClick := DoSelectSound;
  cmbInterval.OnCloseUp := DoIntervalCloseUp;
  chkPlaySound.OnClick := DoCheckPlaySound;
{$ENDIF}
end;

procedure TPSEAlertSettingsController.ReloadStockData;
var
  downloadTask: TDownloadTask;
begin

  downloadTask := TDownloadTask.Create;
  downloadTask.Execute(
    procedure
    begin
      {$IFDEF FMXAPP}
      actReloadData.Enabled := false;
      {$ELSE}
      btnReloadData.Enabled := false;
      {$ENDIF}
    end,
    procedure
    begin
      {$IFDEF FMXAPP}
      actReloadData.Enabled := true;
      {$ELSE}
      btnReloadData.Enabled := true;
      {$ENDIF}
      MessengerInstance.SendMessage(TReloadDataMessage.Create);

    end,
    procedure (stock: TStockModel)
    var
      c1: ICriteria<TStockModel>;
      //c2: ICriteria<TIntradayModel>;
      //intradayObj: TIntradayModel;
      //trans: IDBTransaction;
      l: IList<TStockModel>;
    begin
      if stock = nil then
      begin
        Exit;
      end;
      c1 := PSEAlertDb.Session.CreateCriteria<TStockModel>;
      //PSEStocksData.PSEStocksConnection.Close;

      //trans := PSEAlertDb.Session.BeginTransaction;
      l := c1.Add(TRestrictions.eq('Symbol', stock.Symbol)).ToList;
      if l.Any  then
        PSEAlertDb.Session.Update(stock)
      else
        PSEAlertDb.Session.Insert(stock);

//      PSEStocksData.STOCKSInsert.ParamByName('SYMBOL').AsString := stock.Symbol;
//      PSEStocksData.STOCKSInsert.ParamByName('DESCRIPTION').AsString := stock.Description;
//      PSEStocksData.STOCKSInsert.Execute;
//      intradayObj := TIntradayModel.Create;
//      try
//        intradayObj.Symbol := stock.Symbol;
//        intradayObj.Price := stock.LastTradedPrice;
//        intradayObj.PercentChange := stock.PercentChange;
//        intradayObj.Volume := stock.Volume;
//        intradayObj.Status := stock.Status;
//
//        c2 := PSEAlertDb.Session.CreateCriteria<TIntradayModel>;
//        if c2.Add(TRestrictions.Eq('Symbol', stock.Symbol)).Count > 0 then
//          PSEAlertDb.Session.Update(intradayObj)
//        else
//          PSEAlertDb.Session.Insert(intradayObj);
//      finally
//        intradayObj.Free;
//      end;
      //trans.Commit;
//      PSEStocksData.IntradayInsert.ParamByName('SYMBOL').AsString := stock.Symbol;
//      PSEStocksdata.IntradayInsert.ParamByName('PRICE').AsString := FloatToStr(stock.LastTradedPrice);
//      PSEStocksdata.IntradayInsert.ParamByName('PCTCHANGE').AsString := FloatToStr(stock.PercentChange);
//      PSEStocksdata.IntradayInsert.ParamByName('VOLUME').AsString := FloatToStr(stock.Volume);
//      PSEStocksdata.IntradayInsert.ParamByName('STATUS').AsString := GetEnumName(TypeInfo(TStockStatus),
//            integer(stock.Status));
//      PSEStocksdata.IntradayInsert.Execute;

    end);
end;

//procedure TPSEAlertSettingsController.ReloadStockMap;
//var
//  stockMapDownloader: TStockIdMapDownloader;
//begin
//  stockMapDownloader := TStockIdMapDownloader.Create;
//  stockMapDownloader.Execute;
//end;

end.
