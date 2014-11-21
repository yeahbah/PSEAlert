unit PSEAlert.Frames.Settings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.ListBox, System.Actions, FMX.ActnList;

type
  TframeSettings = class(TFrame)
    btnReloadData: TButton;
    edtOpenWav: TEdit;
    chkPlaySound: TCheckBox;
    cmbInterval: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    btnOpenWav: TButton;
    ActionList: TActionList;
    actReloadData: TAction;
    actOpenWav: TAction;
    Label5: TLabel;
    Label6: TLabel;
  private
    { Private declarations }
    procedure Initialize;
    procedure DoReloadData(Sender: TObject);
    procedure DoSelectSound(Sender: TObject);
    procedure DoIntervalCloseUp(Sender: TObject);
    procedure DoCheckPlaySound(Sender: TObject);
  public
    { Public declarations }
    constructor Create(aOwner: TComponent); override;
  end;

implementation

uses
  Yeahbah.Messaging, PSEAlert.Utils, PSEAlert.Messages, PSEAlert.DataModule,
  PSE.Data.Model, PSE.Data.Downloader, TypInfo;

{$R *.fmx}

{ TframeSettings }

constructor TframeSettings.Create(aOwner: TComponent);
begin
  inherited;
  Initialize;
end;

procedure TframeSettings.DoCheckPlaySound(Sender: TObject);
begin

  edtOpenWav.Enabled := chkPlaySound.IsChecked;
  actOpenWav.Enabled := chkPlaySound.IsChecked;

end;

procedure TframeSettings.DoIntervalCloseUp(Sender: TObject);

var
  PollInterval: integer;
begin

  MessengerInstance.SendMessage(TEnableDisablePollingMessage.Create(false));
  PollInterval := GetPollIntervalValue(cmbInterval.ItemIndex);
  MessengerInstance.SendMessage(TPollIntervalChangedMessage.Create(PollInterval));
  MessengerInstance.SendMessage(TEnableDisablePollingMessage.Create(cmbInterval.ItemIndex > 0));
end;

procedure TframeSettings.DoReloadData(Sender: TObject);
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
    begin
      if stock = nil then
      begin
        Exit;
      end;
      PSEStocksData.STOCKSInsert.ParamByName('SYMBOL').AsString := stock.Symbol;
      PSEStocksData.STOCKSInsert.ParamByName('DESCRIPTION').AsString := stock.Description;
      PSEStocksData.STOCKSInsert.ExecSQL;

      PSEStocksData.IntradayInsert.ParamByName('SYMBOL').AsString := stock.Symbol;
      PSEStocksdata.IntradayInsert.ParamByName('VALUE').AsString := FloatToStr(stock.LastTradedPrice);
      PSEStocksdata.IntradayInsert.ParamByName('PCTCHANGE').AsString := FloatToStr(stock.PercentChange);
      PSEStocksdata.IntradayInsert.ParamByName('VOLUME').AsString := FloatToStr(stock.Volume);
      PSEStocksdata.IntradayInsert.ParamByName('STATUS').AsString := GetEnumName(TypeInfo(TStockStatus),
            integer(stock.Status));
      PSEStocksdata.IntradayInsert.ExecSQL;

    end);


end;

procedure TframeSettings.DoSelectSound(Sender: TObject);
var
  openDialog: TOpenDialog;
begin
  openDialog := TOpenDialog.Create(nil);
  try
    openDialog.Filter := 'Wave files|*.wav';
    if openDialog.Execute then
    begin
      edtOpenWav.Text := openDialog.FileName;
    end;
  finally
    openDialog.Free;
  end;

end;

procedure TframeSettings.Initialize;
begin

  actReloadData.OnExecute := DoReloadData;
  actOpenWav.OnExecute := DoSelectSound;
  chkPlaySound.OnChange := DoCheckPlaySound;
  cmbInterval.OnChange := DoIntervalCloseUp;

end;

end.
