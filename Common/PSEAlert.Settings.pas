unit PSEAlert.Settings;

interface

type
  TPSEAlertSettings = class
  private
    fPlaySound: boolean;
    fPollInterval: integer;
    fAlertSoundFile: string;
    fFormTop: integer;
    fFormHeight: integer;
    fFormLeft: integer;
    fFormWidth: integer;
    FSkin: string;
    procedure SetPlaySound(const Value: boolean);
    procedure SetAlertSoundFile(const Value: string);
    procedure SetFormHeight(const Value: integer);
    procedure SetFormLeft(const Value: integer);
    procedure SetFormTop(const Value: integer);
    procedure SetFormWidth(const Value: integer);
  public
    property PollInterval: integer read fPollInterval write fPollInterval;
    property PlaySound: boolean read fPlaySound write SetPlaySound;
    property AlertSoundFile: string read fAlertSoundFile write SetAlertSoundFile;
    property FormLeft: integer read FFormLeft write SetFormLeft;
    property FormTop: integer read FFormTop write SetFormTop;
    property FormHeight: integer read FFormHeight write SetFormHeight;
    property FormWidth: integer read FFormWidth write SetFormWidth;
    property Skin: string read FSkin write FSkin;
    procedure LoadSettings;
    procedure SaveSettings;
  end;

var
  PSEAlertSettings: TPSEAlertSettings;

implementation

uses
  IniFiles, IOUtils, Forms, SysUtils;

{ TPSEAlertSettings }

procedure TPSEAlertSettings.LoadSettings;
var
  ini: TIniFile;
  tmpInt: integer;
  tmp: string;
  function GetProperInt(const aInt: Integer; aDefault: integer; aMax: integer): integer;
  begin
    result := aDefault;
    if (aInt >= 0) and (aInt <= aMax) then
      result := aInt;
  end;
begin
  ini := TIniFile.Create(TPath.ChangeExtension(ParamStr(0), 'INI'));
  try
    fAlertSoundFile := ini.ReadString('Settings', 'AlertSoundFile', tmp);
    if tmp = '' then
      fAlertSoundFile := TPath.Combine( TPath.GetDirectoryName(ParamStr(0)), 'Alarm01.wav');
    fPlaySound := ini.ReadBool('Settings', 'PlaySound', true);
    fPollInterval := ini.ReadInteger('Settings', 'PollInterval', 1);

    tmpInt := ini.ReadInteger('Default', 'FormLeft', 0);
    fFormLeft := GetProperInt(tmpInt, 0, {$IFDEF FMXAPP}Screen.Size.Width{$ELSE}Screen.Width{$ENDIF});

    tmpInt := ini.ReadInteger('Default', 'FormTop', 0);
    fFormTop := GetProperInt(tmpInt, 0, {$IFDEF FMXAPP}Screen.Size.Height{$ELSE}Screen.Height{$ENDIF});

    tmpInt := ini.ReadInteger('Default', 'FormHeight', 785);
    fFormHeight := GetProperInt(tmpInt, 507, {$IFDEF FMXAPP}Screen.Size.Height{$ELSE}Screen.Height{$ENDIF});

    tmpInt := ini.ReadInteger('Default', 'FormWidth', 400);
    fFormWidth := GetProperInt(tmpInt, 400, {$IFDEF FMXAPP}Screen.Size.Width{$ELSE}Screen.Width{$ENDIF});

    fSkin := ini.ReadString('Default', 'Skin', 'Metropolis UI Blue');
  finally
    ini.Free;
  end;
end;

procedure TPSEAlertSettings.SaveSettings;
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(TPath.ChangeExtension(ParamStr(0), 'INI'));
  try
    ini.WriteString('Settings', 'AlertSoundFile', fAlertSoundFile);
    ini.WriteBool('Settings', 'PlaySound', fPlaySound);
    ini.WriteInteger('Settings', 'PollInterval', fPollInterval);
    ini.WriteInteger('Default', 'FormLeft', fFormLeft);
    ini.WriteInteger('Default', 'FormTop', fFormTop);
    ini.WriteInteger('Default', 'FormHeight', fFormHeight);
    ini.WriteInteger('Default', 'FormWidth', fFormWidth);
    ini.WriteString('Default', 'Skin', fSkin);
  finally
    ini.Free;
  end;
end;

procedure TPSEAlertSettings.SetAlertSoundFile(const Value: string);
begin
  fAlertSoundFile := Value;
end;

procedure TPSEAlertSettings.SetFormHeight(const Value: integer);
begin
  FFormHeight := Value;
end;

procedure TPSEAlertSettings.SetFormLeft(const Value: integer);
begin
  FFormLeft := Value;
end;

procedure TPSEAlertSettings.SetFormTop(const Value: integer);
begin
  FFormTop := Value;
end;

procedure TPSEAlertSettings.SetFormWidth(const Value: integer);
begin
  FFormWidth := Value;
end;

procedure TPSEAlertSettings.SetPlaySound(const Value: boolean);
begin
  fPlaySound := Value;
end;

initialization
  PSEAlertSettings := TPSEAlertSettings.Create;
  PSEAlertSettings.LoadSettings;

finalization
  PSEAlertSettings.SaveSettings;
  PSEAlertSettings.Free;

end.
