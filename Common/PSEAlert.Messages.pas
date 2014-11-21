unit PSEAlert.Messages;

interface

uses
  Yeahbah.Messaging, PSE.Data.Model, Forms;

type
  TStockUpdateMessage = class(TGenericMessage<TStockModel>)
  end;

  TAlertTriggeredMessage = class(TGenericMessage<TAlertModel>)
  end;

  TDismissAlertMessage = class(TAlertTriggeredMessage)
  end;

  TAcknoledgeAlertMessage = class(TAlertTriggeredMessage)
  end;

  TShowAlertFormMessage = class(TAlertTriggeredMessage)
  end;

  TAlertFormHasClosedMessage = class(TGenericMessage<TForm>)

  end;

  TBeforeDownloadMessage = class(TMessageBase)

  end;

  TAfterDownloadMessage = class(TDateTimeMessage)

  end;

  TReloadDataMessage = class(TMessageBase)

  end;

  TPollIntervalChangedMessage = class(TIntegerMessage)

  end;

  TEnableDisablePollingMessage = class(TBooleanMessage)

  end;

  TNoDataMessage = class(TMessageBase)

  end;

  TAddStockToWatchListMessage = class(TStringMessage)

  end;



implementation

end.
