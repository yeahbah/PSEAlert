object frameStockAlertEntry: TframeStockAlertEntry
  Left = 0
  Top = 0
  Width = 371
  Height = 428
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  DesignSize = (
    371
    428)
  object Label2: TLabel
    Left = 15
    Top = 1
    Width = 50
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Caption = 'Symbol'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 15
    Top = 53
    Width = 92
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Caption = 'When Price is '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 76
    Top = 84
    Width = 159
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Caption = 'When Volume is at least'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label5: TLabel
    Left = 15
    Top = 113
    Width = 107
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Caption = 'Max Alert Count'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label6: TLabel
    Left = 16
    Top = 146
    Width = 39
    Height = 20
    Caption = 'Notes'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Bevel1: TBevel
    Left = 3
    Top = 191
    Width = 361
    Height = 2
    Anchors = [akLeft, akTop, akRight]
    Shape = bsBottomLine
  end
  object comboSymbol: TComboBox
    Left = 15
    Top = 19
    Width = 90
    Height = 28
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object chkAddToMyStocks: TCheckBox
    Left = 119
    Top = 25
    Width = 167
    Height = 16
    Caption = 'Add to Watch List'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object cmbPriceLevel: TComboBox
    Left = 119
    Top = 51
    Width = 121
    Height = 28
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ItemIndex = 4
    ParentFont = False
    TabOrder = 2
    Text = 'Above/Equal'
    Items.Strings = (
      'Below'
      'Equal'
      'Above'
      'Below/Equal'
      'Above/Equal')
  end
  object edPrice: TEdit
    Left = 244
    Top = 51
    Width = 76
    Height = 28
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
  object edVolume: TEdit
    Left = 244
    Top = 82
    Width = 76
    Height = 28
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
  end
  object cmbLogic: TComboBox
    Left = 15
    Top = 82
    Width = 52
    Height = 28
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ItemIndex = 1
    ParentFont = False
    TabOrder = 5
    Text = 'OR'
    Items.Strings = (
      ''
      'OR'
      'AND')
  end
  object edMaxAlert: TSpinEdit
    Left = 138
    Top = 111
    Width = 50
    Height = 30
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    MaxValue = 100
    MinValue = 1
    ParentFont = False
    TabOrder = 6
    Value = 10
  end
  object memNotes: TMemo
    Left = 63
    Top = 146
    Width = 257
    Height = 40
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 7
  end
  object btnAddAlert: TButton
    Left = 110
    Top = 199
    Width = 70
    Height = 24
    Caption = '&Add'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 8
  end
  object btnReset: TButton
    Left = 186
    Top = 199
    Width = 70
    Height = 24
    Caption = 'R&eset'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 9
  end
  object scrollAlerts: TScrollBox
    Left = 3
    Top = 232
    Width = 361
    Height = 190
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 10
  end
end
