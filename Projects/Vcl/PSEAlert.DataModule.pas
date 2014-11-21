unit PSEAlert.DataModule;

interface

uses
  System.SysUtils, System.Classes, Data.DbxSqlite, Data.FMTBcd, Data.DB,
  Data.SqlExpr, Forms, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Stan.ExprFuncs, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI, Datasnap.Provider, Datasnap.DBClient, FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLiteVDataSet;

type
  TPSEStocksData = class(TDataModule)
    sqlStocks: TFDQuery;
    sqlStockFavorites: TFDQuery;
    sqlIndeces: TFDQuery;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    sqlAlerts: TFDQuery;
    sqlAlertsSYMBOL: TWideMemoField;
    sqlAlertsPRICELEVEL: TIntegerField;
    sqlAlertsPRICE: TFloatField;
    sqlAlertsVOL_CONJUNCT: TWideMemoField;
    sqlAlertsVOLUME: TIntegerField;
    sqlAlertsMAX_ALERT: TIntegerField;
    PSEStocksConnection: TFDConnection;
    sqlAlertsALERT_COUNT: TIntegerField;
    sqlAlertsNOTES: TWideMemoField;
    cdsAppMemTable: TFDMemTable;
    fdInsertAlertCmd: TFDCommand;
    STOCKSInsert: TFDCommand;
    IntradayInsert: TFDCommand;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PSEStocksData: TPSEStocksData;

implementation

uses
  IOUtils;

{$IFDEF FMXAPP}
{%CLASSGROUP 'FMX.Controls.TControl'}
{$ENDIF}

{$R *.dfm}

procedure TPSEStocksData.DataModuleCreate(Sender: TObject);
begin
//  FDManager.ConnectionDefFileName := TPath.Combine(ExtractFilePath(ParamStr(0)), 'PSEAlert.INI');
//  FDManager.ConnectionDefFileAutoLoad := True;
//  PSEStocksConnection.ConnectionDefName := 'PSEAlertDb';
//  PSEStocksConnection.Close;
//  PSEStocksConnection.Params.Values['Database'] := 'psestocks.s3db';
end;

end.
