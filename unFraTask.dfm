object fraTask: TfraTask
  Left = 0
  Top = 0
  Width = 705
  Height = 54
  TabOrder = 0
  DesignSize = (
    705
    54)
  object ProgressBar: TProgressBar
    Left = 16
    Top = 12
    Width = 514
    Height = 25
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
  end
  object btWaitFor: TButton
    Left = 617
    Top = 12
    Width = 75
    Height = 25
    Anchors = [akTop, akRight, akBottom]
    Caption = 'WaitFor'
    TabOrder = 2
    ExplicitLeft = 640
  end
  object btAbort: TButton
    Left = 536
    Top = 12
    Width = 75
    Height = 25
    Anchors = [akTop, akRight, akBottom]
    Caption = 'Abort'
    TabOrder = 1
    ExplicitLeft = 559
  end
end
