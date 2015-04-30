program PSEAlert;



{$R *.dres}

uses
  FMX.Forms,
  PSEAlert.FMX.AlertForm in 'PSEAlert.FMX.AlertForm.pas' {frmAlert},
  PSEAlert.FMX.MainForm in 'PSEAlert.FMX.MainForm.pas' {frmMain},
  Yeahbah.GenericQuery in '..\..\Common\YeahbahLib\Yeahbah.GenericQuery.pas',
  Yeahbah.Messaging in '..\..\Common\YeahbahLib\Yeahbah.Messaging.pas',
  Yeahbah.ObjectClone in '..\..\Common\YeahbahLib\Yeahbah.ObjectClone.pas',
  PSEAlert.Settings in '..\..\Common\PSEAlert.Settings.pas',
  PSE.Data.Binding.Converters in '..\..\Data\PSE.Data.Binding.Converters.pas',
  PSE.Data.Binding.DWScript.Functions in '..\..\Data\PSE.Data.Binding.DWScript.Functions.pas',
  PSE.Data.Deserializer in '..\..\Data\PSE.Data.Deserializer.pas',
  PSEAlert.Frames.Settings in '..\..\View\Fmx\PSEAlert.Frames.Settings.pas' {frameSettings: TFrame},
  PSEAlert.Frames.StockAlert in '..\..\View\Fmx\PSEAlert.Frames.StockAlert.pas' {frameStockAlert: TFrame},
  PSEAlert.Frames.StockAlertEntry in '..\..\View\Fmx\PSEAlert.Frames.StockAlertEntry.pas' {frameStockAlertEntry: TFrame},
  PSEAlert.Frames.StockPrice in '..\..\View\Fmx\PSEAlert.Frames.StockPrice.pas' {frameStockPrice: TFrame},
  PSEAlert.AlertFormManager in '..\..\Common\PSEAlert.AlertFormManager.pas',
  PSEAlert.Messages in '..\..\Common\PSEAlert.Messages.pas',
  PSEAlert.Utils in '..\..\Common\PSEAlert.Utils.pas',
  PSE.Data.Model in '..\..\Data\PSE.Data.Model.pas',
  PSE.Data in '..\..\Data\PSE.Data.pas',
  PSE.Data.Downloader in '..\..\Data\PSE.Data.Downloader.pas',
  PSEAlert.Controller.MainForm in '..\..\Controller\PSEAlert.Controller.MainForm.pas',
  PSEAlert.Controller.Settings in '..\..\Controller\PSEAlert.Controller.Settings.pas',
  PSEAlert.Controller.StockAlert in '..\..\Controller\PSEAlert.Controller.StockAlert.pas',
  PSEAlert.Controller.StockAlertEntry in '..\..\Controller\PSEAlert.Controller.StockAlertEntry.pas',
  PSEAlert.Controller.StockDetails in '..\..\Controller\PSEAlert.Controller.StockDetails.pas',
  PSEAlert.Controller.StockPrice in '..\..\Controller\PSEAlert.Controller.StockPrice.pas',
  PSE.Data.Model.JSON in '..\..\Data\PSE.Data.Model.JSON.pas',
  Yeahbah.GenericQueryTypes in '..\..\Common\YeahbahLib\Yeahbah.GenericQueryTypes.pas',
  PSE.Data.Repository in '..\..\Data\PSE.Data.Repository.pas',
  PSEAlert.Forms.StockDetails in '..\..\View\Fmx\PSEAlert.Forms.StockDetails.pas' {frmStockDetails},
  SvSerializerSuperJson;

{$R *.res}

begin
  Application.Initialize;

//  Application.CreateForm(TPSEStocksData, PSEStocksData);
  Application.CreateForm(TfrmMain, frmMain);
  Application.RealCreateForms;
  CreateMainFormController(TObject.Create);

  Application.Run;

end.
