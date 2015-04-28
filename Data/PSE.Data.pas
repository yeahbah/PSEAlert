unit PSE.Data;

interface

uses
  System.SysUtils, PSE.Data.Model, Generics.Collections, System.JSON,
  System.Classes, Yeahbah.GenericQuery,
  SQLiteTable3,
  Spring.Persistence.Core.Interfaces,
  Spring.Persistence.Core.Session,
  Spring.Persistence.Mapping.Attributes,
  PSE.Data.Model.JSON;


type
  TPSEAlertDatabase = class
  private
    fConnection: IDBConnection;
    fDatabase: TSQLiteDatabase;
    fSession: TSession;
  public
    constructor Create;
    destructor Destroy; override;
    property Database: TSQLiteDatabase read fDatabase write fDatabase;
    property Connection: IDBConnection read fConnection write fConnection;
    property Session: TSession read fSession write fSession;
  end;

var
  PSEAlertDb: TPSEAlertDatabase;

implementation

uses
  SvHTTPClient.Indy,
  Spring.Persistence.Core.DatabaseManager,
  Spring.Persistence.Core.ConnectionFactory,
  Spring.Persistence.Adapters.SQLite;

//function getStockId(const aSymbol: string): integer;
//var
//  v: Variant;
//begin
//  v := PSEStocksData.PSEStocksConnection.ExecSQLScalar('SELECT ID FROM STOCKID_MAP WHERE SYMBOL = ' + QuotedStr(aSymbol));
//  if v.IsNull then
//    raise Exception.Create('Unable to find stock id of ' + aSymbol +'. Try updating your database. Settings > Reload Stock List');
//
//  result := v
//end;

{ TPSEAlertDatabase }

constructor TPSEAlertDatabase.Create;
begin
  fDatabase := TSQLiteDatabase.Create;
  fDatabase.Filename := 'psestocks.s3db';
  fConnection := TSQLiteConnectionAdapter.Create(fDatabase);
  fConnection.AutoFreeConnection := true;
  fConnection.Connect;

  fSession := TSession.Create(fConnection);
end;

destructor TPSEAlertDatabase.Destroy;
begin
  fSession.Free;
  inherited;
end;

initialization
  PSEAlertDb := TPSEAlertDatabase.Create;

finalization
  PSEAlertDb.Free;

end.
