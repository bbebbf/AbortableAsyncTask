unit AbortableTask.Result;

interface

uses System.SysUtils, AbortableTask.Types;

type
  TAbortableAsyncTaskResultBase = class(TInterfacedObject, IAbortableTaskResultBase)
  strict private
    fFinishedState: TAbortableTaskFinishedState;
    fExceptionMessage: string;
    fExceptionClass: TClass;
    function GetFinishedState: TAbortableTaskFinishedState;
    function GetExceptionMessage: string;
    function GetExceptionClass: TClass;
  public
    constructor Create(const aFinishedState: TAbortableTaskFinishedState;
      const aExceptionClass: TClass; const aExceptionMessage: string);
  end;

  TAbortableAsyncTaskResult<T> = class(TAbortableAsyncTaskResultBase, IAbortableTaskResult<T>)
  strict private
    fResult: T;
    function GetResult: T;
  public
    constructor Create(const aFinishedState: TAbortableTaskFinishedState;
      const aExceptionClass: TClass; const aExceptionMessage: string; const aResult: T);
  end;

implementation

{ TAbortableAsyncTaskResultBase }

constructor TAbortableAsyncTaskResultBase.Create(const aFinishedState: TAbortableTaskFinishedState;
  const aExceptionClass: TClass; const aExceptionMessage: string);
begin
  inherited Create;
  fFinishedState := aFinishedState;
  fExceptionMessage := aExceptionMessage;
  fExceptionClass := aExceptionClass;
end;

function TAbortableAsyncTaskResultBase.GetExceptionClass: TClass;
begin
  Result := fExceptionClass;
end;

function TAbortableAsyncTaskResultBase.GetExceptionMessage: string;
begin
  Result := fExceptionMessage;
end;

function TAbortableAsyncTaskResultBase.GetFinishedState: TAbortableTaskFinishedState;
begin
  Result := fFinishedState;
end;

{ TAbortableAsyncTaskResult<T> }

constructor TAbortableAsyncTaskResult<T>.Create(const aFinishedState: TAbortableTaskFinishedState;
  const aExceptionClass: TClass; const aExceptionMessage: string; const aResult: T);
begin
  inherited Create(aFinishedState, aExceptionClass, aExceptionMessage);
  fResult := aResult;
end;

function TAbortableAsyncTaskResult<T>.GetResult: T;
begin
  Result := fResult;
end;

end.
