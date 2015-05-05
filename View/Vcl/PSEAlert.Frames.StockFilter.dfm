object frameStockFilter: TframeStockFilter
  Left = 0
  Top = 0
  Width = 370
  Height = 360
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 319
    Width = 370
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      370
      41)
    object btnRun: TButton
      Left = 272
      Top = 8
      Width = 87
      Height = 25
      Action = actRun
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object btnClearAll: TButton
      Left = 103
      Top = 8
      Width = 75
      Height = 25
      Action = actClearAll
      TabOrder = 1
    end
    object btnReloadData: TButton
      Left = 9
      Top = 8
      Width = 91
      Height = 25
      Action = actReloadData
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 370
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 9
      Top = 14
      Width = 58
      Height = 13
      Caption = 'Select filter:'
    end
    object cmbFilter: TComboBox
      Left = 83
      Top = 11
      Width = 185
      Height = 21
      Style = csDropDownList
      TabOrder = 0
    end
    object btnAdd: TButton
      Left = 279
      Top = 10
      Width = 50
      Height = 26
      Action = actAddFilter
      TabOrder = 1
    end
  end
  object scrollFilter: TScrollBox
    Left = 0
    Top = 41
    Width = 370
    Height = 278
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    TabOrder = 2
  end
  object ActionList1: TActionList
    Left = 144
    Top = 168
    object actReloadData: TAction
      Caption = 'Reload Data'
    end
    object actClearAll: TAction
      Caption = 'Clear All'
    end
    object actRun: TAction
      Caption = 'Run'
    end
    object actAddFilter: TAction
      Caption = 'Add'
    end
  end
end
