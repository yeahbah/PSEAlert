unit Yeahbah.Messaging;

interface

uses
  Rtti, Generics.Collections, Generics.Defaults, SysUtils;

type
  IMessage = interface
    ['{903905A4-3025-4BEF-A78F-45E7325492D1}']
  end;

  TMessageBase = class;
  TMessageClass = class of TMessageBase;

  IMessageReceiver = interface
    ['{CC55049C-78FF-40F3-B639-2A1521DBE006}']
    procedure Receive(const aMessage: IMessage);
  end;

  TReceiverMessageMap = class(TDictionary<IMessageReceiver, TList<TMessageClass>>)
  end;

  IMessenger = interface
    ['{5515A62F-8D6F-46D3-B1EE-253D326EEFD9}']
    function GetReceivers: TReceiverMessageMap;
    procedure SetReceivers(const Value: TReceiverMessageMap);
    property Receivers: TReceiverMessageMap read GetReceivers
      write SetReceivers;
    procedure RegisterReceiver(const aReceiver: IMessageReceiver;
      const aMessageClass: TMessageClass);
    procedure UnRegisterReceiver(const aReceiver: IMessageReceiver;
      const aMessageClass: TMessageClass);
    procedure UnRegisterMessageClass(const aFromReceiver: IMessageReceiver;
      const aMessageClass: TMessageClass);
    procedure SendMessage(const aMessage: IMessage);
  end;

  TMessageBase = class(TInterfacedObject, IMessage)
  end;

  TGenericMessage<T> = class(TMessageBase)
  private
    fData: T;
  protected
    procedure SetData(const aData: T);
  public
    constructor Create(const aData: T);
    property Data: T read fData;
  end;

  TStringMessage = class(TGenericMessage<String>)
  public
    constructor Create(const aData: String);
  end;

  TIntegerMessage = class(TGenericMessage<Integer>)
  public
    constructor Create(const aData: Integer);
  end;

  TBooleanMessage = class(TGenericMessage<boolean>)
  public
    constructor Create(const aData: boolean);
  end;

  TDateTimeMessage = class(TGenericMessage<TDateTime>)
  public
    constructor Create(const aData: TDateTime);
  end;

  TMessenger = class(TSingletonImplementation, IMessenger)
  private
    fReceivers: TReceiverMessageMap;
    function GetReceivers: TReceiverMessageMap;
    procedure SetReceivers(const Value: TReceiverMessageMap);
  public
    constructor Create;
    destructor Destroy; override;
    property Receivers: TReceiverMessageMap read GetReceivers
      write SetReceivers;
    procedure RegisterReceiver(const aReceiver: IMessageReceiver;
      const aMessageClass: TMessageClass);
    procedure UnRegisterReceiver(const aReceiver: IMessageReceiver;
      const aMessageClass: TMessageClass); overload;
    procedure UnRegisterReceiver(const aReceiver: IMessageReceiver); overload;
    procedure UnRegisterMessageClass(const aFromReceiver: IMessageReceiver;
      const aMessageClass: TMessageClass);
    procedure UnRegisterAll;
    procedure SendMessage(const aMessage: IMessage);
    class function NewInstance: TObject; override;
    class function GetInstance: TMessenger;
  end;

var
  MessengerInstance: TMessenger;

implementation

{ TStringMessage }

constructor TStringMessage.Create(const aData: String);
begin
  inherited;
  SetData(aData);
end;

{ TGenericMessage<T> }

constructor TGenericMessage<T>.Create(const aData: T);
begin
  inherited Create;
  SetData(aData);
end;

{ TMessenger }

procedure TMessenger.SendMessage(const aMessage: IMessage);
var
  keyPair: TPair<IMessageReceiver, TList<TMessageClass>>;
  receiver: IMessageReceiver;
  msg: TMessageClass;
begin

  for keyPair in fReceivers do
  begin
    receiver := keyPair.Key;
    for msg in keyPair.Value do
    begin
      if msg = (aMessage as TMessageBase).ClassType then
        receiver.Receive(aMessage);
    end;
  end;

end;

procedure TMessenger.SetReceivers(const Value: TReceiverMessageMap);
begin
  fReceivers := Value;
end;

procedure TMessenger.UnRegisterAll;
begin
  fReceivers.Clear;
end;

procedure TMessenger.UnRegisterMessageClass(
  const aFromReceiver: IMessageReceiver; const aMessageClass: TMessageClass);
begin
end;

procedure TMessenger.UnRegisterReceiver(const aReceiver: IMessageReceiver);
begin
  if fReceivers.ContainsKey(aReceiver) then
    fReceivers.Remove(aReceiver);
end;

procedure TMessenger.UnRegisterReceiver(const aReceiver: IMessageReceiver;
  const aMessageClass: TMessageClass);
begin
  if fReceivers.ContainsKey(aReceiver) then
    fReceivers[aReceiver].Remove(aMessageClass);
end;

constructor TMessenger.Create;
begin
  fReceivers := TReceiverMessageMap.Create;
end;

destructor TMessenger.Destroy;
begin
  fReceivers.Free;
  inherited;
end;

class function TMessenger.GetInstance: TMessenger;
begin
  if not Assigned(MessengerInstance) then
    Result := TMessenger.Create
  else
    Result := MessengerInstance;
end;

function TMessenger.GetReceivers: TReceiverMessageMap;
begin
  Result := fReceivers;
end;

class function TMessenger.NewInstance: TObject;
begin
  if ( not Assigned( MessengerInstance ) ) then
  begin
    Result := inherited NewInstance;
  end
  else
    Result := GetInstance;
end;

procedure TMessenger.RegisterReceiver(const aReceiver: IMessageReceiver;
  const aMessageClass: TMessageClass);
begin
  if not fReceivers.ContainsKey(aReceiver) then
    fReceivers.Add(aReceiver, TList<TMessageClass>.Create);
  fReceivers[aReceiver].Add(aMessageClass);
end;

{ TMessageBase<T> }

procedure TGenericMessage<T>.SetData(const aData: T);
begin
  fData := aData;
end;

{ TIntegerMessage }

constructor TIntegerMessage.Create(const aData: Integer);
begin
  fData := aData;
end;

{ TBooleanMessage }

constructor TBooleanMessage.Create(const aData: boolean);
begin
  fData := aData;
end;

{ TDateTimeMessage }

constructor TDateTimeMessage.Create(const aData: TDateTime);
begin
  fData := aData;
end;

initialization
  MessengerInstance := TMessenger.Create;

finalization
  FreeAndNil(MessengerInstance);

end.
