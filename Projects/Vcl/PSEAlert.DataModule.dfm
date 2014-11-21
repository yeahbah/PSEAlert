object PSEStocksData: TPSEStocksData
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 288
  Width = 357
  object PSEStocksConnection: TFDConnection
    Params.Strings = (
      'ConnectionDef=PSEAlertDb')
    LoginPrompt = False
    Left = 42
    Top = 28
  end
  object sqlStocks: TFDQuery
    Connection = PSEStocksConnection
    SQL.Strings = (
      'SELECT * FROM STOCKS'
      'WHERE SYMBOL NOT LIKE '#39'^%'#39)
    Left = 42
    Top = 84
  end
  object sqlStockFavorites: TFDQuery
    Connection = PSEStocksConnection
    SQL.Strings = (
      'select * from stocks '
      'left outer join intraday on stocks.symbol = intraday.symbol '
      'WHERE stocks.SYMBOL NOT LIKE '#39'^%'#39
      'AND ISFAVORITE = '#39'1'#39
      'ORDER BY SYMBOL DESC')
    Left = 136
    Top = 80
  end
  object sqlIndeces: TFDQuery
    Connection = PSEStocksConnection
    SQL.Strings = (
      'select * from stocks '
      'left outer join intraday on stocks.symbol = intraday.symbol '
      'WHERE stocks.SYMBOL LIKE '#39'^%'#39)
    Left = 240
    Top = 80
  end
  object FDGUIxWaitCursor: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 48
    Top = 152
  end
  object sqlAlerts: TFDQuery
    Connection = PSEStocksConnection
    SQL.Strings = (
      'SELECT * FROM ALERTS')
    Left = 312
    Top = 80
    object sqlAlertsSYMBOL: TWideMemoField
      FieldName = 'SYMBOL'
      Origin = 'SYMBOL'
      Required = True
      BlobType = ftWideMemo
    end
    object sqlAlertsPRICELEVEL: TIntegerField
      FieldName = 'PRICELEVEL'
      Origin = 'PRICELEVEL'
      Required = True
    end
    object sqlAlertsPRICE: TFloatField
      FieldName = 'PRICE'
      Origin = 'PRICE'
      Required = True
    end
    object sqlAlertsVOL_CONJUNCT: TWideMemoField
      FieldName = 'VOL_CONJUNCT'
      Origin = 'VOL_CONJUNCT'
      BlobType = ftWideMemo
    end
    object sqlAlertsVOLUME: TIntegerField
      FieldName = 'VOLUME'
      Origin = 'VOLUME'
    end
    object sqlAlertsMAX_ALERT: TIntegerField
      FieldName = 'MAX_ALERT'
      Origin = 'MAX_ALERT'
      Required = True
    end
    object sqlAlertsALERT_COUNT: TIntegerField
      FieldName = 'ALERT_COUNT'
      Origin = 'ALERT_COUNT'
    end
    object sqlAlertsNOTES: TWideMemoField
      FieldName = 'NOTES'
      Origin = 'NOTES'
      BlobType = ftWideMemo
    end
  end
  object cdsAppMemTable: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired]
    UpdateOptions.CheckRequired = False
    AutoCommitUpdates = False
    Left = 40
    Top = 224
  end
  object fdInsertAlertCmd: TFDCommand
    Connection = PSEStocksConnection
    CommandKind = skInsert
    CommandText.Strings = (
      
        'INSERT INTO ALERTS (ID, SYMBOL, PRICELEVEL, PRICE, VOL_CONJUNCT,' +
        ' VOLUME, MAX_ALERT, ALERT_COUNT, NOTES)'
      'VALUES'
      
        '(NULL, :SYMBOL, :PRICELEVEL, :PRICE, :VOL_CONJUNCT, :VOLUME, :MA' +
        'X_ALERT, :ALERT_COUNT, :NOTES)'
      '')
    ParamData = <
      item
        Name = 'SYMBOL'
        DataType = ftString
        ParamType = ptInput
      end
      item
        Name = 'PRICELEVEL'
        DataType = ftInteger
        ParamType = ptInput
      end
      item
        Name = 'PRICE'
        DataType = ftCurrency
        ParamType = ptInput
      end
      item
        Name = 'VOL_CONJUNCT'
        DataType = ftString
        ParamType = ptInput
      end
      item
        Name = 'VOLUME'
        DataType = ftInteger
        ParamType = ptInput
      end
      item
        Name = 'MAX_ALERT'
        DataType = ftInteger
        ParamType = ptInput
      end
      item
        Name = 'ALERT_COUNT'
        DataType = ftInteger
        ParamType = ptInput
      end
      item
        Name = 'NOTES'
        DataType = ftString
        ParamType = ptInput
      end>
    Left = 136
    Top = 224
  end
  object STOCKSInsert: TFDCommand
    Connection = PSEStocksConnection
    CommandKind = skInsert
    CommandText.Strings = (
      'INSERT OR REPLACE INTO STOCKS (SYMBOL, DESCRIPTION, ISFAVORITE) '
      
        'VALUES (:SYMBOL, :DESCRIPTION, (SELECT ISFAVORITE FROM STOCKS WH' +
        'ERE SYMBOL = :SYMBOL))')
    ParamData = <
      item
        Name = 'SYMBOL'
        DataType = ftString
        ParamType = ptInput
      end
      item
        Name = 'DESCRIPTION'
        DataType = ftString
        ParamType = ptInput
      end>
    Left = 136
    Top = 152
  end
  object IntradayInsert: TFDCommand
    Connection = PSEStocksConnection
    CommandKind = skInsert
    CommandText.Strings = (
      
        'INSERT OR REPLACE INTO INTRADAY (SYMBOL, VALUE, PCTCHANGE, VOLUM' +
        'E, STATUS)'
      'VALUES (:SYMBOL, :VALUE, :PCTCHANGE, :VOLUME, :STATUS)')
    ParamData = <
      item
        Name = 'SYMBOL'
        DataType = ftString
        ParamType = ptInput
      end
      item
        Name = 'VALUE'
        DataType = ftCurrency
        ParamType = ptInput
      end
      item
        Name = 'PCTCHANGE'
        DataType = ftCurrency
        ParamType = ptInput
      end
      item
        Name = 'VOLUME'
        DataType = ftCurrency
        ParamType = ptInput
      end
      item
        Name = 'STATUS'
        DataType = ftString
        ParamType = ptInput
      end>
    Left = 240
    Top = 152
  end
end
