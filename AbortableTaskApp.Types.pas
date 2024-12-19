unit AbortableTaskApp.Types;

interface

type
  IAbortableTaskAppProgressIndicator<K> = interface
    ['{B3AE1A15-D342-44E4-A292-084DDBCBE7CC}']
    procedure ProgressBegin(const aKey: K; const aMaxWorkCount: Int64);
    procedure ProgressEnd(const aKey: K);
    procedure ProgressStep(const aKey: K; const aWorkCount: Int64);
  end;

implementation

end.
