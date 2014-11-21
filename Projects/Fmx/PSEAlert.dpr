program PSEAlert;



{$R *.dres}

uses
  FMX.Forms,
  Yeahbah.Messaging in '..\YeahbahLib\Yeahbah.Messaging.pas',
  PSEAlert.Settings in '..\PSEAlertVcl\PSEAlert.Settings.pas',
  PSE.Data.Model in '..\PSEAlertVcl\Data\PSE.Data.Model.pas',
  PSE.Data.Downloader in '..\PSEAlertVcl\Data\PSE.Data.Downloader.pas',
  PSEAlert.Frames.Settings in 'Frames\PSEAlert.Frames.Settings.pas' {frameSettings: TFrame},
  PSEAlert.Frames.StockAlert in 'Frames\PSEAlert.Frames.StockAlert.pas' {frameStockAlert: TFrame},
  PSEAlert.Frames.StockAlertEntry in 'Frames\PSEAlert.Frames.StockAlertEntry.pas' {frameStockAlertEntry: TFrame},
  PSEAlert.Frames.StockPrice in 'Frames\PSEAlert.Frames.StockPrice.pas' {frameStockPrice: TFrame},
  Yeahbah.ObjectClone in '..\YeahbahLib\Yeahbah.ObjectClone.pas',
  PSEAlert.Utils in '..\PSEAlertVcl\PSEAlert.Utils.pas',
  PSEAlert.Messages in '..\PSEAlertVcl\PSEAlert.Messages.pas',
  Yeahbah.GenericQuery in '..\YeahbahLib\Yeahbah.GenericQuery.pas',
  Yeahbah.GenericQueryTypes in '..\YeahbahLib\Yeahbah.GenericQueryTypes.pas',
  PSE.Data in '..\PSEAlertVcl\Data\PSE.Data.pas',
  PSEAlert.DataModule in '..\PSEAlertVcl\PSEAlert.DataModule.pas' {PSEStocksData: TDataModule},
  PSEAlert.AlertFormManager in '..\PSEAlertVcl\PSEAlert.AlertFormManager.pas',
  PSEAlert.FMX.AlertForm in 'PSEAlert.FMX.AlertForm.pas' {frmAlert},
  PSEAlert.FMX.MainForm in 'PSEAlert.FMX.MainForm.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;

  Application.CreateForm(TPSEStocksData, PSEStocksData);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;

end.
