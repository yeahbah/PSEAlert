unit PSEAlert.Service.UpgradeService;

interface

type
  IUpgradeService = interface
    ['{214FA595-DC9D-44EE-ABF1-9855DB2B1F9E}']
    function CheckForNewVersion(out aNewVersion: string): boolean;
    procedure DownloadNewVersion;
  end;

  TUpgradeService = class(TInterfacedObject, IUpgradeService)
  protected
    fNewVersion: string;
  public
    function CheckForNewVersion(out aNewVersion: string): boolean;
    procedure DownloadNewVersion;
  end;

implementation

uses
  Classes, SvHTTPClient.Indy, IniFiles, JclFileUtils, Dialogs, Forms, SysUtils;

{ TUpgradeService }

function TUpgradeService.CheckForNewVersion(out aNewVersion: string): boolean;
var
  httpGet: TIndyHTTPClient;
  outputStream: TMemoryStream;
  iniFile: TIniFile;
  currentVersion: string;
begin
  result := false;
  outputStream := TMemoryStream.Create;
  httpGet := TIndyHTTPClient.Create;
  try
    httpGet.Get('http://www.absolutetraders.com/yeahbah/psealert-newversion.ini', outputStream);
    if outputStream.Size > 0 then
    begin
      outputStream.Position := 0;
      outputStream.SaveToFile('upgradeinfo.ini');
      iniFile := TIniFile.Create(ExtractFilePath(Application.ExeName)+ '\upgradeinfo.ini');
      try
        currentVersion := VersionFixedFileInfoString(ParamStr(0), vfFull, 'Unknown');
        fNewVersion := iniFile.ReadString('UPGRADE', 'NewVersion', currentVersion);

        result := currentVersion <> fNewVersion;

      finally
        iniFile.Free;
      end;
    end;
  finally
    httpGet.Free;
    outputStream.Free;
  end;

end;

procedure TUpgradeService.DownloadNewVersion;
var
  httpGet: TIndyHTTPClient;
  url: string;
  outputStream: TMemoryStream;
  saveDialog: TSaveDialog;
  updateFile: string;
begin
  saveDialog := TSaveDialog.Create(nil);
  try
    updateFile := 'PSEAlert-Patch-'+fNewVersion+'.zip';
    saveDialog.FileName := updateFile;
    if saveDialog.Execute then
    begin
      outputStream := TMemoryStream.Create;
      httpGet := TIndyHTTPClient.Create;
      try
        httpGet.Get('http://www.absolutetraders.com/yeahbah/'+updateFile, outputStream);
        if outputStream.Size > 0 then
        begin
          outputStream.Position := 0;
          outputStream.SaveToFile(saveDialog.FileName);
          ShowMessage('Download complete. Shutdown PSEAlert then unzip ' + updateFile +' into the install folder of PSEAlert.');
        end;
      finally
        httpGet.Free;
        outputStream.Free;
      end;
    end;
  finally
    saveDialog.Free;
  end;
end;

end.
