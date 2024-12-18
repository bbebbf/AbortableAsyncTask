object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'fmMain'
  ClientHeight = 402
  ClientWidth = 771
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object ProgressBar: TProgressBar
    Left = 56
    Top = 144
    Width = 657
    Height = 33
    TabOrder = 0
  end
  object btTaskStart: TButton
    Left = 240
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Task starten'
    TabOrder = 1
    OnClick = btTaskStartClick
  end
  object btRequestAbort: TButton
    Left = 360
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Abbrechen'
    TabOrder = 2
    OnClick = btRequestAbortClick
  end
  object btAwait: TButton
    Left = 448
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Await'
    TabOrder = 3
    OnClick = btAwaitClick
  end
  object ProgressBar1: TProgressBar
    Left = 56
    Top = 192
    Width = 657
    Height = 33
    TabOrder = 4
  end
end
